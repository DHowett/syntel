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
	$self->{EXPR} = shift;
	$self->{VALUE} = shift;
	$self->{TYPE} = Syntel::Util::type($self->{VALUE}); # Inherit type from righthand value.
	croak "Expr in assign not Assignable" if !$self->{EXPR}->DOES("Assignable");
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return Syntel::Util::expr($self->{EXPR})." = ".Syntel::Util::expr($self->{VALUE});
}

# emit: handled by Expression

1;
