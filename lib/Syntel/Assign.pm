package Syntel::Assign;
use strict;
use warnings;
use parent qw(Syntel::Expression);

use Carp;

use Syntel::Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{VARIABLE} = shift;
	$self->{VALUE} = shift;
	$self->{TYPE} = Syntel::Util::type($self->{VALUE}); # Inherit type from righthand value.
	croak "Variable in Assign not an lvalue" if !$self->{VARIABLE}->isa("LValue");
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return $self->{VARIABLE}->expr()." = ".Syntel::Util::expr($self->{VALUE});
}

# emit: handled by Expression

1;
