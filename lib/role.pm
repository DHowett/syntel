package role;
use Scalar::Util;
our $VERSION = '1.0';

sub __does {
	my $pkg = shift;
	$pkg = Scalar::Util::blessed($pkg) if ref $pkg;
	my $role = shift;
	for(@{$pkg."::_roles"}) {
		return 1 if $_ eq $role;
	}
	for(@{$pkg."::ISA"}) {
		return 1 if $_->DOES($role);
	}
	return 0;
}

sub import {
	my $pkg = shift;
	my $callpkg = caller(0);
	if($pkg eq "role") {
		@{$callpkg."::_roles"} = (@_);
		*{$callpkg."::DOES"} = \&__does;
	}
}

"Role role role your boat.";
