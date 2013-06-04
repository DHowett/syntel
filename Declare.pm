package Declare;
use strict;
use warnings;
use parent qw(Statement);

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{VARIABLE} = shift;
	return bless $self, $pkg
}

sub emit {
	my $self = shift;
	return $self->{VARIABLE}->{TYPE}." ".$self->{VARIABLE}->{NAME};
}

1;

