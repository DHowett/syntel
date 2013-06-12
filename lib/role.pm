package role;
our $VERSION = '1.0';

sub __does {
	my $self = shift;
	$pkg = ref $self || $self;
	my $role = shift;
	return 1 if $self->can("conformsToRole") && $self->conformsToRole($role);
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
