package Syntel::BinaryOperator;
use strict;
use warnings;
use parent qw(Syntel::Expression);

use Syntel::Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{M1} = shift;
	$self->{OP} = shift;
	$self->{M2} = shift;
	$self->{TYPE} = Syntel::Util::type($self->{M1}) // Syntel::Util::type($self->{M2}); # Inherit type from first value.
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return Syntel::Util::expr($self->{M1})." ".$self->{OP}." ".Syntel::Util::expr($self->{M2});
}

# emit: handled by Expression

1;

