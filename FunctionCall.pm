package FunctionCall;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{FUNCTION} = shift;
	return bless $self, $pkg
}

sub value {
	my $self = shift;
	return $self->{FUNCTION}->{NAME}."()";
}

sub emit {
	my $self = shift;
	return $self->value();
}

1;
