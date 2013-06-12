package Syntel::Expression;
use strict;
use warnings;
use parent qw(Syntel::Statement);
use role qw(Expression);

use Syntel::PrefixOperator;

sub conformsToRole {
	my $self = shift;
	my $role = shift;
	return 0 if !ref $self;
	return 1 if $role eq "Dereferenceable" && $self->type->DOES("Pointer");
	return 0;
}

sub dereference {
	my $self = shift;
	return Syntel::PrefixOperator->new('*', $self)->typed($self->type->innerType);
}

sub typed {
	my $self = shift;
	$self->{TYPE} = shift;
	return $self;
}

sub expr {
	my $self = shift;
	return "<EXPR>";
}

sub type {
	my $self = shift;
	return $self->{TYPE};
}

sub emit {
	my $self = shift;
	return $self->expr;
}

1;
