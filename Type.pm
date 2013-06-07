package Type;
use strict;
use warnings;

use Util qw(matchedParenthesisSet smartSplit);

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $typeName = shift;
	return _typify(_parseTypeString($typeName));
}

sub _typify {
	my $typeref = shift;
	return undef if !defined $typeref;

	my $type = {};
	my $pkg;

	my $typeString = $typeref->{TYPE};
	if(defined $typeref->{ARGS}) {
		$pkg = "_FunctionType";
		$type->{ARGUMENTS} = [map {_typify($_)} @{$typeref->{ARGS}}];
		delete $typeref->{ARGS};
		$type->{RETURN_TYPE} = _typify($typeref);
	} elsif($typeString =~ /\s*(\^|\*|\[\s*(\d*)\s*\])$/p) {
		my $newType = ${^PREMATCH};
		$pkg = "_PointerType" if($1 eq "*");
		$pkg = "_BlockType" if($1 eq "^");
		if(substr($1, 0, 1) eq "[") {
			$pkg = "_ArrayType";
			my $alen = undef;
			$alen = int($2) if $2 ne "";
			$type->{LENGTH} = $alen;
		}
		#$pkg = "_ArrayType" if($1 eq "*");

		$typeref->{TYPE} = $newType;
		my $innerType = _typify($newType eq "" ? $typeref->{INNER} : $typeref);
		# Merge everything inside a BlockType's inner type into it. Blocks don't have inner types.
		if($pkg ne "_BlockType") {
			$type->{INNER_TYPE} = $innerType;
		} else {
			# The inner type of a Block will only be a function
			# So we just pretend that function is all we had.
			$type = $innerType;
		}
	} else {
		$pkg = "_PlainType";
		$type->{TYPE} = $typeString;
	}

	return bless $type, $pkg;
}

sub _parseTypeString {
	my $type = _stripUnnecessaryParens(shift);
	my $innerTypeRef = shift;
	my ($left, $right, $lo, $rc) = _leftRight($type);

	my $typeRef = {};
	$typeRef->{INNER} = $innerTypeRef if defined $innerTypeRef;

	# If there's a righthand side, we probably have a function pointer.
	# Attempt to erase it.
	$type = substr($type, 0, $lo-1).substr($type, $rc) if defined $right;
	$type =~ s/^\s+//;
	$type =~ s/\s+$//;
	$typeRef->{TYPE} = $type;

	# $right is typically function arguments.
	if(defined $right) {
		my @argStrings = smartSplit(qr/\s*,\s*/, $right);
		$typeRef->{ARGS} = [map {_parseTypeString($_);} @argStrings];
		# Descend left iff there's a righthand side
		$typeRef = _parseTypeString($left, $typeRef) if defined $right;
	}

	return $typeRef;
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

package _ArrayType; # LENGTH
use strict;
use warnings;
use parent qw(Type);
use overload '""' => sub { my $s = shift; return "Array[".($s->{LENGTH}//"")."](".($s->{INNER_TYPE}//"Nothing").")"; };
1;
package _PointerType; # INNER_TYPE
use strict;
use warnings;
use parent qw(Type);
use overload '""' => sub { my $s = shift; return "Pointer(".($s->{INNER_TYPE}//"Nothing").")"; };
1;
package _BlockType; # (see _FunctionType)
use strict;
use warnings;
use parent qw(Type);
use overload '""' => sub { my $s = shift; return "Block[".$s->{RETURN_TYPE}."](".join(",", map {"".$_} @{$s->{ARGUMENTS}}).")"; };
1;
package _FunctionType; # RETURN_TYPE ARGUMENTS
use strict;
use warnings;
use parent qw(Type);
use overload '""' => sub { my $s = shift; return "Function[".$s->{RETURN_TYPE}."](".join(",", map {"".$_} @{$s->{ARGUMENTS}}).")"; };
1;
package _PlainType; # TYPE
use strict;
use warnings;
use parent qw(Type);
use overload '""' => sub { my $s = shift; return lc($s->{TYPE}); };
1;
