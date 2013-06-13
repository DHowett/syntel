package Syntel::BinaryOperator;
use strict;
use warnings;
use parent qw(Syntel::Expression);
use role;

use Syntel::Util;

sub conformsToRole {
	my $self = shift;
	my $role = shift;
	return 0 if !ref $self;
	return 1 if $role eq "Assignable" && ($self->{M1}->DOES("Assignable") || $self->{M2}->DOES("Assignable"));
	return 0;
}

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

