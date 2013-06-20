package Syntel::ConstantValue;
use strict;
use warnings;
use parent qw(Syntel::Expression);

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my ($val, $type) = @_;
	my $self = {
		VALUE => $val,
		TYPE => $type,
	};
	return bless $self, $pkg
}

sub type {
	return shift()->{TYPE};
}

sub expr {
	my $self = shift;
	my $v = $self->{VALUE};
	return "".$v;
}

# emit: handled by Expression

1;

