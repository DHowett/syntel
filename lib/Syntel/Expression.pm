package Syntel::Expression;
use strict;
use warnings;
use parent qw(Syntel::Statement);

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
