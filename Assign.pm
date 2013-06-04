package Assign;
use strict;
use warnings;
use parent qw(Expression);

use Carp;

use Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{VARIABLE} = shift;
	$self->{VALUE} = shift;
	croak "Variable in Assign not an lvalue" if !$self->{VARIABLE}->isa("LValue");
	return bless $self, $pkg
}

sub emit {
	my $self = shift;
	return $self->{VARIABLE}->expr()." = ".Util::expr($self->{VALUE});
}

1;
