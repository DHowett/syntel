package Syntel::FunctionCall;
use strict;
use warnings;
use parent qw(Syntel::Expression);

use Syntel::Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{FUNCTION} = shift;
	$self->{PARAMETERS} = shift;
	return bless $self, $pkg
}

sub type {
	return $_[0]->{FUNCTION}->returnType;
}

sub expr {
	my $self = shift;
	my $r = $self->{FUNCTION}->{NAME}."(";
	$r .= join(",", map{Syntel::Util::expr($_)} @{$self->{PARAMETERS}});
	$r .= ")";
	return $r;
}

# emit: handled by Expression

1;
