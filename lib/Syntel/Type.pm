package Syntel::Type;
use strict;
use warnings;
use role qw(Type);
use Scalar::Util qw(blessed);
use Storable;

our %_typeCache = (
	void		=>	Syntel::Type::Plain->new("void"),
	char		=>	Syntel::Type::Plain->new("char"),
	short		=>	Syntel::Type::Plain->new("short"),
	int		=>	Syntel::Type::Plain->new("int"),
	long		=>	Syntel::Type::Plain->new("long"),
	float		=>	Syntel::Type::Plain->new("float"),
	double		=>	Syntel::Type::Plain->new("double"),
	signed		=>	Syntel::Type::Plain->new("signed"),
	unsigned	=>	Syntel::Type::Plain->new("unsigned"),
	bool		=>	Syntel::Type::Plain->new("bool"),
	"..."		=>	Syntel::Type::Vararg->new(),
);

use Syntel::Util qw(matchedDelimiterSet matchedParenthesisSet smartSplit fallsBetween);

our $VOID = __PACKAGE__->new("void");
our $CHAR = __PACKAGE__->new("char");
our $SHORT = __PACKAGE__->new("short");
our $INT = __PACKAGE__->new("int");
our $LONG = __PACKAGE__->new("long");
our $FLOAT = __PACKAGE__->new("float");
our $DOUBLE = __PACKAGE__->new("double");
our $SIGNED = __PACKAGE__->new("signed");
our $UNSIGNED = __PACKAGE__->new("unsigned");
our $BOOL = __PACKAGE__->new("bool");
our $CSTRING = __PACKAGE__->new("char")->pointer;
our $VARARGS = __PACKAGE__->new("...");

# May not return a new instance.
sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	if($pkg eq __PACKAGE__) {
		my $typeName = shift;
		(my $cacheKey = $typeName) =~ s/\s+/ /g;
		my $c = \$_typeCache{$cacheKey};
		$$c = scalar _parseTypeString($typeName) if !$$c;
		$$c->{_CACHED} = 1;
		return $$c;
	}
	return bless {}, $pkg;
}

sub _isStorageClass {
	my $n = shift;
	return 0 if $n eq "";
	return 1 if $n eq "typedef"
		|| $n eq "extern"
		|| $n eq "static"
		|| $n eq "auto"
		|| $n eq "register";
	return 0;
}

sub _isTypeQualifier {
	my $n = shift;
	return 0 if $n eq "";
	return 1 if $n eq "const"
		|| $n eq "restrict"
		|| $n eq "volatile";
	return 0;
}

sub _isFunctionSpecifier {
	my $n = shift;
	return 0 if $n eq "";
	return 1 if $n eq "inline";
	return 0;
}

sub _isKeyword {
	my $n = shift;
	return 0 if $n eq "";
	return _isStorageClass($n) || _isTypeQualifier($n) || _isFunctionSpecifier($n);
}

sub _parseTypeString {
	my $typeString = shift;
	my $passedInnerType = shift;
	my $pullNames = wantarray;
	my $typeName = undef;

	$typeString =~ s/\s+/ /;
	$typeString =~ s/^\s+//;
	$typeString =~ s/\s+$//;

	return undef if $typeString eq "";

	my $type = Syntel::Type::_Base->new();

	my @braces = matchedDelimiterSet($typeString, "{", "}");
	my @parens = matchedDelimiterSet($typeString, "(", ")");

	# If there's more than two sets of parens outside braces (which would be a possible struct/complex type)
	# Erase it, and take the right as function arguments: we probably have a function pointer.
	if(@parens > 3 && !fallsBetween($parens[3], @braces)) {
		bless $type, "Syntel::Type::Function";

		my ($left, $right) = (
			substr($typeString, $parens[0], $parens[1]-$parens[0]-1),
			substr($typeString, $parens[2], $parens[3]-$parens[2]-1)
		);

		$typeString = substr($typeString, 0, $parens[0]-1).substr($typeString, $parens[3]);
		# If we bear a passed inner type, it's probably our return type.
		$type->{RETURN_TYPE} = scalar _parseTypeString($typeString, $passedInnerType);

		# Propagate up storage classes and function specifiers.
		$type->_propagateKeysFrom($type->{RETURN_TYPE}, "STORAGE_CLASSES", "SPECIFIERS");

		if($right =~ /^\s*void\s*/) {
			$type->{ARGUMENTS} = [];
		} elsif($right !~ /^\s*$/) {
			my @argStrings = smartSplit(qr/\s*,\s*/, $right);
			$type->{ARGUMENTS} = [map {scalar _parseTypeString($_);} @argStrings];
		}

		# Descend left iff there's a righthand side. We might need to nest within it.
		($type, $typeName) = _parseTypeString($left, $type);
	} elsif(@parens > 1 && !fallsBetween($parens[1], @braces)) {
		my $inner = substr($typeString, $parens[0], $parens[1]-$parens[0]-1);
		$typeString = substr($typeString, 0, $parens[0]-1).substr($typeString, $parens[1]);

		# The inner type (type outside the parentheses, because C is backwards)
		# is either the type outside the parens, OR the type we were passed
		# to be OUR inner type.

		# We wrap it in the type we found inside the parentheses.
		my $innerType = $typeString ? scalar _parseTypeString($typeString, $passedInnerType) : $passedInnerType;
		($type, $typeName) = _parseTypeString($inner, $innerType);
	} else {
		my $typePackage = undef;
		# If our type is of the sort '*NAME[' or '^NAME[' where the '[' is optional,
		# pull NAME out and leave the rest unmolested.
		# This is also valid for TYPE *NAME[ and TYPE ^NAME
		if($typeString =~ /[*^]\s*([\$\w\s]+)\s*(?:\[\d*\])?$/) {
			my @bits = split(/\s+/, $1);
			my @keywords = sort grep { _isKeyword($_); } @bits;
			my @names = grep { !_isKeyword($_); } @bits;
			$typeName = $names[0];
			if(@keywords) {
				$type->{QUALIFIERS} = [grep { _isTypeQualifier($_); } @keywords];
				# Pointers cannot have storage classes or function specifiers.
				#$type->{SPECIFIERS} = [grep { _isFunctionSpecifier($_); } @keywords];
				#$type->{STORAGE_CLASSES} = [grep { _isStorageClass($_); } @keywords];
			}
			substr($typeString, $-[1], $+[1] - $-[1]) = "";
		}

		if($typeString =~ /\[\s*(\d*)\s*\]$/p) {
			my $newType = ${^PREMATCH};
			$typePackage = "Array";
			my $alen = undef;
			$alen = int($1) if $1 ne "";
			$type->{LENGTH} = $alen;

			# If we have a subtype string, we might need to nest *our* inner type inside it.
			my $innerType = $newType ? scalar _parseTypeString($newType, $passedInnerType) : $passedInnerType;
			$type->{INNER_TYPE} = $innerType if $innerType;

			# Propagate up storage classes and function specifiers.
			$type->_propagateKeysFrom($type->{INNER_TYPE}, "STORAGE_CLASSES", "SPECIFIERS");
		} elsif($typeString =~ /([*^])$/p) {
			my $newType = ${^PREMATCH};
			$typePackage = "Pointer" if($1 eq "*");
			$typePackage = "BlockPointer" if($1 eq "^");

			# If we have a subtype string, we might need to nest *our* inner type inside it.
			my $innerType = $newType ? scalar _parseTypeString($newType, $passedInnerType) : $passedInnerType;
			if($innerType) {
				$type->{_CACHED} = 1;
				$innerType->{_POINTER_TYPE} = $type if $typePackage eq "Pointer";
				$type->{INNER_TYPE} = $innerType;
			}

			# Propagate up storage classes and function specifiers.
			$type->_propagateKeysFrom($type->{INNER_TYPE}, "STORAGE_CLASSES", "SPECIFIERS");
		} elsif($typeString =~ /^\s*(struct|union|enum)\s*(\w+)?\s*{?/) {
			my $cacheKey = $1;
			$typePackage = ucfirst($1);
			my $structname = $2;
			$type->{NAME} = $structname;

			if(($structname && $typeString =~ /$structname\s+(\w+)$/)
			 || $typeString =~ /}\s*(\w+)$/) {
				$typeName = $1;
			}

			if($structname) {
				$cacheKey .= " ".$structname;
				my $c = \$_typeCache{$cacheKey};
				$type = $$c if $$c;
				$type->{_CACHED} = 1;
				$$c = $type;
			}

			if(defined $braces[0]) {
				my $contents = substr($typeString, $braces[0], $braces[1] - $braces[0] - 1);

				my @subTypeStrings;
				my @members;
				if($typePackage ne "Enum") {
					@subTypeStrings = grep { $_ ne "" } smartSplit(qr/\s*;\s*/, $contents);
					@members = map {
							# _parseTypeString returns TYPE,NAME but we want NAME,TYPE.
							Syntel::Type::Struct::Member->new(reverse _parseTypeString($_, undef, 1));
						} @subTypeStrings;
				} else {
					@subTypeStrings = grep { $_ ne "" } smartSplit(qr/\s*,\s*/, $contents);
					@members = map {_parseEnumValueString($_);} @subTypeStrings;
				}
				$type->{MEMBERS} = \@members if(scalar @members > 0)
			}
		} else {
			$typePackage = "Plain";
			my $cacheKey = "";

			my @bits = split(/\s+/, $typeString);
			my @keywords = sort grep { _isKeyword($_); } @bits;
			my @remaining = grep { !_isKeyword($_); } @bits;
			$typeString = join(" ", @remaining);
			if(@keywords) {
				$type->{QUALIFIERS} = [grep { _isTypeQualifier($_); } @keywords];
				$type->{SPECIFIERS} = [grep { _isFunctionSpecifier($_); } @keywords];
				$type->{STORAGE_CLASSES} = [grep { _isStorageClass($_); } @keywords];
				$cacheKey .= join(" ", @keywords);
			}

			if($typeString =~ /\s*:\s*(\d+)$/p) {
				$typeString = ${^PREMATCH};
				$type->{PACKED_BITS} = $1;
				$cacheKey .= ":$1";
			}

			# If our type string is of the sort 'TYPE NAME', pull out the name.
			if($pullNames && $typeString =~ /\s+(\w+)$/p) {
				$typeString = ${^PREMATCH};
				$typeName = $1;
			} elsif($typeString eq "...") {
				$typePackage = "Vararg";
			}
			$cacheKey = $typeString.$cacheKey;

			$type->{TYPE} = $typeString;

			my $c = \$_typeCache{$cacheKey};
			$type = $$c if $$c;
			$type->{_CACHED} = 1;
			$$c = $type;
		}
		bless $type, "Syntel::Type::".$typePackage;
	}

	return ($type, $typeName) if wantarray;
	return $type;
}

sub _parseEnumValueString {
	my $s = shift;
	my $enumval = {};
	if($s =~ /^\s*(\w+)(\s*=\s*(.*?)\s*)?$/) {
		return Syntel::Type::Enum::Value->new($1, $3);
	}
	return undef;
}

# Parentheses are considered unnecessary if they are not followed by
# another set of parentheses. (x) => x, (x)() untouched.
# Recursively strip unnecessary parentheses down the left side.
sub _stripUnnecessaryParens {
	my $t = shift;
	my ($o, $c) = matchedParenthesisSet($t);
	while(defined $o) {
		my ($no, $nc) = matchedParenthesisSet(substr($t, $c));
		last if defined $no;
		substr($t, $o - 1, $c - $o + 1) = _stripUnnecessaryParens(substr($t, $o, $c - $o - 1));
		($o, $c) = matchedParenthesisSet($t);
	}
	return $t;
}

# Returns: left part, right part, left opening, right closing (entire span)
sub _leftRight {
	my $t = shift;
	my ($left, $right);
	my ($lo, $lc) = matchedParenthesisSet($t);
	return (undef, undef, undef, undef) if(!defined $lo);
	$left = substr($t, $lo, $lc-$lo-1);

	my $remain = substr($t, $lc);
	my ($ro, $rc) = matchedParenthesisSet($remain);
	return ($left, undef, $lo, undef) if(!defined $ro);
	$right = substr($remain, $ro, $rc-$ro-1);

	return ($left, $right, $lo, $lc+$rc)
}

1;

package Syntel::Type::_Base;
use strict;
use warnings;
my $printContext = { };
my $printDepth = 0;
use overload '""' => sub { my $s = shift; $printDepth++; my $str = $s->_stringify($printContext); $printDepth--; $printContext = {} if $printDepth == 0; $str; };
use role qw(Statement);
use Scalar::Util qw(blessed);

sub _stringify {
	my $s = shift;
	(blessed $s) =~ m/(\w+)$/;
	return join("!", $s->_aggregate("QUALIFIERS", "STORAGE_CLASSES", "SPECIFIERS")).$1;
}

sub _propagateKeysFrom {
	my $self = shift;
	my $from = shift;
	for(@_) {
		$self->{$_} = $from->{$_};
		$from->{$_} = undef;
	}
}

sub _aggregate {
	my $self = shift;
	my @o = ();
	for(@_) {
		push(@o, @{$self->{$_}}) if $self->{$_};
	}
	return grep {$_ && $_ ne ""} @o;
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	return bless {}, $pkg;
}

sub pointer {
	my $self = shift;
	my $ptr = \$self->{_POINTER_TYPE};
	$$ptr = Syntel::Type::Pointer->new($self) if !$$ptr;
	$$ptr->{_CACHED} = 1;
	return $$ptr;
}

sub array {
	my $self = shift;
	my $arr = Syntel::Type::Array->new($self, shift);
	return $arr;
}

sub declaration {
	my $self = shift;
	return $self;
}

sub emit {
	my $self = shift;
	return $self->declString();
}

sub _decache {
	my $self = shift;
	my $s = $self;
	if($s->{_CACHED}) {
		$s = Storable::dclone($self);
		delete $s->{_CACHED};
	}
	return $s;
}

sub withSpecifier {
	my $self = shift()->_decache;
	push(@{$self->{SPECIFIERS}}, @_);
	return $self;
}

sub withQualifier {
	my $self = shift()->_decache;
	push(@{$self->{QUALIFIERS}}, @_);
	return $self;
}

sub withStorageClass {
	my $self = shift()->_decache;
	push(@{$self->{STORAGE_CLASSES}}, @_);
	return $self;
}
1;

package Syntel::Type::Array; # LENGTH
use strict;
use warnings;
use parent -norequire, "Syntel::Type::_Base";
use role qw(Array);

sub _stringify {
	my $s = shift;
	return $s->SUPER::_stringify."[".($s->{LENGTH}//"")."](".($s->{INNER_TYPE}//"Nothing").")";
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = $pkg->SUPER::new();
	$self->{INNER_TYPE} = shift;
	$self->{LENGTH} = shift;
	return bless $self, $pkg;
}

sub innerType {
	return $_[0]->{INNER_TYPE};
}

sub length {
	return $_[0]->{LENGTH};
}

sub declString {
	my $self = shift;
	my $name = shift//"";
	return $self->{INNER_TYPE}->declString($name."[".($self->{LENGTH}//"")."]");
}
1;

package Syntel::Type::Pointer; # INNER_TYPE
use strict;
use warnings;
use parent -norequire, "Syntel::Type::_Base";
use role qw(Array Pointer);

sub _stringify {
	my $s = shift;
	return $s->SUPER::_stringify."(".($s->{INNER_TYPE}//"Nothing").")";
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = $pkg->SUPER::new();
	$self->{INNER_TYPE} = shift;
	return bless $self, $pkg;
}

sub innerType {
	return $_[0]->{INNER_TYPE};
}

sub _pointerChar {
	return "*";
}

sub declString {
	my $self = shift;
	my $name = shift//"";
	my $inner = $self->{INNER_TYPE};
	my @k = $self->_aggregate("STORAGE_CLASSES", "SPECIFIERS");
	my $s = "";
	$s = join(" ", @k)." " if @k;

	my @qual = $self->_aggregate("QUALIFIERS");
	my $qualifiers = "";
	$qualifiers = join(" ", @qual)." " if @qual;

	$name = $self->_pointerChar.$qualifiers.$name;
	$name = "(".$name.")" if ($inner->DOES("Array") || $inner->DOES("Function")) && !$inner->DOES("Pointer");
	return $s.$inner->declString($name);
}
1;

package Syntel::Type::BlockPointer; # (see Type::Pointer)
use strict;
use warnings;
use parent -norequire, "Syntel::Type::Pointer";

sub _pointerChar {
	return "^";
}

1;

package Syntel::Type::Function; # RETURN_TYPE ARGUMENTS
use strict;
use warnings;
use parent -norequire, "Syntel::Type::_Base";
use role qw(Function);

sub _stringify {
	my $s = shift;
	return $s->SUPER::_stringify."[".$s->{RETURN_TYPE}."](".
		(defined $s->{ARGUMENTS}
			? (@{$s->{ARGUMENTS}} > 0
				? join(",", map {"".$_} @{$s->{ARGUMENTS}})
				: "-VOID-")
			: "")
		.")";
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = $pkg->SUPER::new();
	$self->{RETURN_TYPE} = shift;
	$self->{ARGUMENTS} = shift;
	return bless $self, $pkg;
}

sub returnType {
	return $_[0]->{RETURN_TYPE};
}

sub arguments {
	return $_[0]->{ARGUMENTS};
}

sub declString {
	my $self = shift;
	my $name = shift//"";
	my @k = $self->_aggregate("STORAGE_CLASSES", "SPECIFIERS");
	my $s = "";
	$s = join(" ", @k)." " if @k;
	return $s.$self->{RETURN_TYPE}->declString($name."(".
		(defined $self->{ARGUMENTS}
			? (@{$self->{ARGUMENTS}} > 0
				? join(",", map {$_->declString()} @{$self->{ARGUMENTS}})
				: "void")
			: "")
		.")"
	);
}
1;

package Syntel::Type::Struct; # NAME MEMBERS
use strict;
use warnings;
use parent -norequire, "Syntel::Type::_Base";
use role qw(Structured);

sub _stringify {
	my $s = shift;
	my $printContext = shift;
	my $ck = Scalar::Util::refaddr($s);
	$printContext->{$ck}++;
	return $s->SUPER::_stringify.
		(defined $s->{NAME} ? "(\"".$s->{NAME}."\")" : "").
			"{".($printContext->{$ck} <= 1 ? join(",", map {"".$_} @{$s->{MEMBERS}}) : "--")."}";
};

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = $pkg->SUPER::new();
	$self->{NAME} = shift;
	$self->{MEMBERS} = shift;
	return bless $self, $pkg;
}

sub members {
	return $_[0]->{MEMBERS};
}

sub declString {
	my $self = shift;
	my $name = shift//"";
	(blessed $self) =~ m/(\w+)$/;
	my $t = lc($1);

	my @k = $self->_aggregate("QUALIFIERS", "STORAGE_CLASSES", "SPECIFIERS");
	$t = join(" ", @k)." ".$t if @k;

	if($self->{NAME}) {
		$t .= " ".$self->{NAME};
	}

	if(!$self->{NAME} || $name eq "") {
		$t .= "{".$self->_declStringContents."}";
	}

	$t .= " ".$name;
	$t =~ s/(^\s+|\s+$)//g;
	return $t;
}

sub _declStringContents {
	my $self = shift;
	return join(";", map {$_->{TYPE}->declString($_->{NAME})} @{$self->{MEMBERS}}).";";
}
1;

package Syntel::Type::Union; # See Type::Struct
use strict;
use warnings;
use parent -norequire, "Syntel::Type::Struct";
1;

package Syntel::Type::Struct::Member; # NAME TYPE
use strict;
use warnings;
use overload '""' => sub { my $s = shift; return $s->{NAME}.":".$s->{TYPE}; };

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{NAME} = shift;
	$self->{TYPE} = shift;
	return bless $self, $pkg;
}

sub name {
	my $s = shift; return $s->{NAME};
}

sub type {
	my $s = shift; return $s->{TYPE};
}
1;

package Syntel::Type::Enum; # See Syntel::Type::Struct
use strict;
use warnings;
use parent -norequire, "Syntel::Type::Struct";
sub _stringify {
	my $s = shift;
	return $s->Syntel::Type::_Base::_stringify.
		(defined $s->{NAME} ? "(\"".$s->{NAME}."\")" : "").
			"{".(scalar @{$s->{MEMBERS}})." values}";
};

sub _declStringContents {
	my $self = shift;
	return join(",", map {$_->{NAME}.($_->{VALUE}?"=".$_->{VALUE}:"")} @{$self->{MEMBERS}});
}
1;

package Syntel::Type::Enum::Value; # NAME VALUE
use strict;
use warnings;
sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{NAME} = shift;
	$self->{VALUE} = shift;
	return bless $self, $pkg;
}

sub name {
	my $s = shift; return $s->{NAME};
}

sub value {
	my $s = shift; return $s->{VALUE};
}

1;

package Syntel::Type::Plain; # TYPE PACKED_BITS
use strict;
use warnings;
use parent -norequire, "Syntel::Type::_Base";

sub _stringify {
	my $s = shift;
	return join("!", $s->_aggregate("QUALIFIERS", "STORAGE_CLASSES", "SPECIFIERS")).($s->{NAME} ? $s->{NAME}.":":"").lc($s->{TYPE}).($s->{PACKED_BITS} ? "*".$s->{PACKED_BITS} : "");
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = $pkg->SUPER::new();
	$self->{TYPE} = shift;
	return bless $self, $pkg;
}

sub declString {
	my $self = shift;
	my $name = shift//"";
	my $t = $self->{TYPE}." ".$name;

	my @k = $self->_aggregate("QUALIFIERS", "STORAGE_CLASSES", "SPECIFIERS");
	$t = join(" ", @k)." ".$t if @k;

	$t =~ s/(^\s+|\s+$)//g;
	return $t;
}
1;

package Syntel::Type::Vararg;
use strict;
use warnings;
use parent -norequire, "Syntel::Type::_Base";

sub declString {
	return "...";
}
1;
