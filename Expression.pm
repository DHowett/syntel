package Expression;
use strict;
use warnings;
use parent qw(Statement);

sub expr {
	my $self = shift;
	return "<EXPR>";
}

sub emit {
	my $self = shift;
	return $self->expr;
}

1;
