package Type;
use strict;
use warnings;
use Scalar::Util qw(blessed);

our %_typeCache;

use Util qw(matchedDelimiterSet matchedParenthesisSet smartSplit fallsBetween);

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

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	if($pkg eq __PACKAGE__) {
		my $typeName = shift;
		(my $cacheKey = $typeName) =~ s/\s+/ /g;
		return $_typeCache{$cacheKey} if defined $_typeCache{$cacheKey};
		return $_typeCache{$cacheKey} = scalar _parseTypeString($typeName);
	}
	return bless {}, $pkg;
}

sub pointer {
	my $self = shift;
	my $ptr = $self->{_POINTER_TYPE};
	if(!defined $ptr) {
		$ptr = ($self->{_POINTER_TYPE} = PointerType->new());
		$ptr->{INNER_TYPE} = $self;
	}
	return $ptr;
}

sub array {
	my $self = shift;
	my $arr = ArrayType->new();
	$arr->{LENGTH} = shift;
	$arr->{INNER_TYPE} = $self;
	return $arr;
}

sub _parseTypeString {
	my $typeString = _stripUnnecessaryParens(shift);
	my $passedInnerType = shift;
	my $typeName = undef;

	$typeString =~ s/\s+/ /;
	$typeString =~ s/^\s+//;
	$typeString =~ s/\s+$//;

	return undef if $typeString eq "";

	my $type = {};

	my @braces = matchedDelimiterSet($typeString, "{", "}");
	my @parens = matchedDelimiterSet($typeString, "(", ")");

	# If there's more than two sets of parens outside braces (which would be a possible struct/complex type)
	# Erase it, and take the right as function arguments: we probably have a function pointer.
	if(@parens > 3 && !fallsBetween($parens[3], @braces)) {
		bless $type, "FunctionType";

		my ($left, $right) = (
			substr($typeString, $parens[0], $parens[1]-$parens[0]-1),
			substr($typeString, $parens[2], $parens[3]-$parens[2]-1)
		);

		$typeString = substr($typeString, 0, $parens[0]-1).substr($typeString, $parens[3]);
		# If we bear a passed inner type, it's probably our return type.
		$type->{RETURN_TYPE} = scalar _parseTypeString($typeString, $passedInnerType);

		my @argStrings = smartSplit(qr/\s*,\s*/, $right);
		#print STDERR join("!", @argStrings),$/;
		$type->{ARGUMENTS} = [map {scalar _parseTypeString($_);} @argStrings];
		# Descend left iff there's a righthand side. We might need to nest within it.

		($type, $typeName) = _parseTypeString($left, $type);
	} else {
		my $pkg = undef;
		# If our type is of the sort '*NAME[' or '^NAME[' where the '[' is optional,
		# pull NAME out and leave the rest unmolested.
		# This is also valid for TYPE *NAME[ and TYPE ^NAME
		if($typeString =~ /[\^\*](\w+)(\[\d*\])?$/) {
			$typeName = $1;
			substr($typeString, $-[1], $+[1] - $-[1]) = "";
		}

		if($typeString =~ /\s*(\^|\*|\[\s*(\d*)\s*\])$/p) {
			my $newType = ${^PREMATCH};
			$pkg = "PointerType" if($1 eq "*");
			$pkg = "BlockPointerType" if($1 eq "^");
			if(substr($1, 0, 1) eq "[") {
				$pkg = "ArrayType";
				my $alen = undef;
				$alen = int($2) if $2 ne "";
				$type->{LENGTH} = $alen;
			}

			# If we have a subtype string, we might need to nest *our* inner type inside it.
			my $innerType = $newType ? scalar _parseTypeString($newType, $passedInnerType) : $passedInnerType;
			if($innerType) {
				$innerType->{_POINTER_TYPE} = $type if $pkg eq "PointerType";
				$type->{INNER_TYPE} = $innerType;
			}
		} elsif($typeString =~ /^\s*(struct|union|enum)\s*(\w+)?\s*{?/) {
			my $cacheKey = $1;
			$pkg = ucfirst($1)."Type";
			my $structname = $2;
			$type->{NAME} = $structname;

			if(($structname && $typeString =~ /$structname\s+(\w+)$/)
			 || $typeString =~ /}\s*(\w+)$/) {
				$typeName = $1;
			}

			if($structname) {
				$cacheKey .= " ".$structname;
				$type = $_typeCache{$cacheKey} if $_typeCache{$cacheKey};
				$_typeCache{$cacheKey} = $type;
			}

			if(defined $braces[0]) {
				my $contents = substr($typeString, $braces[0], $braces[1] - $braces[0] - 1);

				my @subTypeStrings;
				my @members;
				if($pkg ne "EnumType") {
					@subTypeStrings = grep { $_ ne "" } smartSplit(qr/\s*;\s*/, $contents);
					@members = map {
							my $m = bless {}, "_StructMember";
							($m->{TYPE}, $m->{NAME}) = _parseTypeString($_, undef, 1);
							$m;
						} @subTypeStrings;
				} else {
					@subTypeStrings = grep { $_ ne "" } smartSplit(qr/\s*,\s*/, $contents);
					@members = map {_parseEnumValueString($_);} @subTypeStrings;
				}
				$type->{MEMBERS} = \@members if(scalar @members > 0)
			}
		} else {
			$pkg = "PlainType";
			my $cacheKey = "";

			if($typeString =~ /\s*:\s*(\d+)$/p) {
				$typeString = ${^PREMATCH};
				$type->{PACKED_BITS} = $1;
				$cacheKey = ":$1";
			}

			# If our type string is of the sort 'TYPE NAME', pull out the name.
			if($typeString =~ /\s+(\w+)$/p) {
				$typeString = ${^PREMATCH};
				$typeName = $1;
			} elsif($typeString eq "...") {
				$pkg = "VarargType";
			}
			$cacheKey = $typeString.$cacheKey;

			$type->{TYPE} = $typeString;

			$type = $_typeCache{$cacheKey} if $_typeCache{$cacheKey};
			$_typeCache{$cacheKey} = $type;
		}
		bless $type, $pkg;
	}

	return ($type, $typeName) if wantarray;
	return $type;
}

sub _parseEnumValueString {
	my $s = shift;
	my $enumval = {};
	if($s =~ /^\s*(\w+)(\s*=\s*(.*?)\s*)?$/) {
		$enumval->{NAME} = $1;
		$enumval->{VALUE} = $3 if $3;
	}
	return bless $enumval, "_EnumValue";
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

package _TypeBase;
use strict;
use warnings;
my $printContext = { };
my $printDepth = 0;
use overload '""' => sub { my $s = shift; $printDepth++; my $str = $s->_stringify($printContext); $printDepth--; $printContext = {} if $printDepth == 0; $str; };
our @ISA = qw(Type);

sub _stringify {
	my $self = shift;
	my $pkg = blessed $self;
	$pkg =~ s/(\w+)Type$/$1/;
	return $pkg;
}
1;

package ArrayType; # LENGTH
use strict;
use warnings;
our @ISA = qw(_TypeBase);

sub _stringify {
	my $s = shift;
	return $s->SUPER::_stringify."[".($s->{LENGTH}//"")."](".($s->{INNER_TYPE}//"Nothing").")";
}
1;

package PointerType; # INNER_TYPE
use strict;
use warnings;
our @ISA = qw(_TypeBase);

sub _stringify {
	my $s = shift;
	return $s->SUPER::_stringify."(".($s->{INNER_TYPE}//"Nothing").")";
}
1;

package BlockPointerType; # (see _FunctionType)
use strict;
use warnings;
our @ISA = qw(PointerType);
1;

package FunctionType; # RETURN_TYPE ARGUMENTS
use strict;
use warnings;
our @ISA = qw(_TypeBase);

sub _stringify {
	my $s = shift;
	return $s->SUPER::_stringify."[".$s->{RETURN_TYPE}."](".join(",", map {"".$_} @{$s->{ARGUMENTS}}).")";
}
1;

package StructType; # NAME MEMBERS
use strict;
use warnings;
our @ISA = qw(_TypeBase);

sub _stringify {
	my $s = shift;
	my $printContext = shift;
	my $ck = Scalar::Util::refaddr($s);
	$printContext->{$ck}++;
	return $s->SUPER::_stringify.
		(defined $s->{NAME} ? "(\"".$s->{NAME}."\")" : "").
			"{".($printContext->{$ck} <= 1 ? join(",", map {"".$_} @{$s->{MEMBERS}}) : "--")."}";
};
1;

package UnionType; # See StructType
use strict;
use warnings;
our @ISA = qw(StructType);
1;

package _StructMember; # NAME TYPE
use strict;
use warnings;
use overload '""' => sub { my $s = shift; return $s->{NAME}.":".$s->{TYPE}; };
sub name {
	my $s = shift; return $s->{NAME};
}

sub type {
	my $s = shift; return $s->{TYPE};
}
1;

package EnumType; # See StructType
use strict;
use warnings;
our @ISA = qw(StructType);
sub _stringify {
	my $s = shift;
	return $s->_TypeBase::_stringify.
		(defined $s->{NAME} ? "(\"".$s->{NAME}."\")" : "").
			"{".(scalar @{$s->{MEMBERS}})." values}";
};
1;

package _EnumValue; # NAME VALUE
use strict;
use warnings;
1;

package PlainType; # TYPE PACKED_BITS
use strict;
use warnings;
our @ISA = qw(_TypeBase);

sub _stringify {
	my $s = shift;
	return ($s->{NAME} ? $s->{NAME}.":":"").lc($s->{TYPE}).($s->{PACKED_BITS} ? "*".$s->{PACKED_BITS} : "");
}
1;

package VarargType;
use strict;
use warnings;
our @ISA = qw(_TypeBase);
1;
