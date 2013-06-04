package FunctionCall;
use strict;
use warnings;

use Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{FUNCTION} = shift;
	$self->{PARAMETERS} = shift;
	return bless $self, $pkg
}

sub value {
	my $self = shift;
	my $r = $self->{FUNCTION}->{NAME}."(";
	$r .= join(",", map{Util::coerce($_)} @{$self->{PARAMETERS}});
	$r .= ")";
	return $r;
}

sub emit {
	my $self = shift;
	return $self->value();
}

1;
