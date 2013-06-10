package Expression;
use strict;
use warnings;
use parent qw(Statement);

sub DOES {
	my ($s, $does) = @_;
	return 1 if $does eq "TypedExpression" && (ref $s) && defined $s->can("type");
	return $s->SUPER::DOES($does);
}

sub expr {
	my $self = shift;
	return "<EXPR>";
}

sub emit {
	my $self = shift;
	return $self->expr;
}

1;
