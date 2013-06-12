package Syntel::Expression;
use strict;
use warnings;
use parent qw(Syntel::Statement);
use role qw(Expression);

use Carp;

use Syntel::PrefixOperator;
use Syntel::FunctionCall;
use Syntel::StructMemberAccess;
use Syntel::ArrayIndexAccess;

sub conformsToRole {
	my $self = shift;
	my $role = shift;
	return 0 if !ref $self;
	return 1 if $role eq "Dereferenceable" && $self->type->DOES("Pointer");
	return 1 if $role eq "Callable" && ($self->type->DOES("Function") || ($self->type->DOES("Pointer") && $self->type->innerType->DOES("Function")));
	return 1 if $role eq "Indexable" && $self->type->DOES("Array");
	return 1 if $role eq "Structured" && ($self->type->DOES("Structured") || ($self->type->DOES("Pointer") && $self->type->innerType->DOES("Structured")));
	return 0;
}

sub dereference {
	my $self = shift;
	croak "Expression $self not dereferenceable" if !$self->DOES("Dereferenceable");
	return Syntel::PrefixOperator->new('*', $self)->typed($self->type->innerType);
}

sub pointer {
	my $self = shift;
	croak "Expression $self not addressable" if !$self->DOES("Addressable");
	return Syntel::PrefixOperator->new("&", $self)->typed($self->type->pointer);
}

sub call {
	my $self = shift;
	my @a = @_;
	croak "Expression $self not callable" if !$self->DOES("Callable");
	return Syntel::FunctionCall->new($self, \@a);
}

sub index {
	my $self = shift;
	my $idx = shift;
	croak "Expression $self not indexable" if !$self->DOES("Indexable");
	return Syntel::ArrayIndexAccess->new($self, $idx);
}

sub member {
	my $self = shift;
	my $member = shift;
	croak "Expression $self not structured" if !$self->DOES("Structured");
	return Syntel::StructMemberAccess->new($self, $member);
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
