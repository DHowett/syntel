package Syntel::UnaryOperator;
use strict;
use warnings;
use parent qw(Syntel::Expression);
use role;

use Syntel::Util;

sub conformsToRole {
	my $self = shift;
	my $role = shift;
	return 0 if !ref $self;
	return 1 if $role eq "Assignable" && ($self->{M1}->DOES("Assignable"));
	return 0;
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{OP} = shift;
	$self->{M1} = shift;
	$self->{TYPE} = Syntel::Util::type($self->{M1});
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return $self->{OP}.Syntel::Util::expr($self->{M1});
}

# emit: handled by Expression

1;
