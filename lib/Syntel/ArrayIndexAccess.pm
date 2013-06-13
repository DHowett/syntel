package Syntel::ArrayIndexAccess;
use strict;
use warnings;
use parent qw(Syntel::Expression);
use role;

use Syntel::Util;

sub conformsToRole {
	my $self = shift;
	my $role = shift;
	return 0 if !ref $self;
	return 1 if $role eq "Assignable" && ($self->{EXPR}->DOES("Assignable"));
	return 0;
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{EXPR} = shift;
	$self->{INDEX} = shift;
	$self->{TYPE} = $self->{EXPR}->type->innerType;
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return Syntel::Util::expr($self->{EXPR})."[".$self->{INDEX}."]";
}

# emit: handled by Expression

1;

