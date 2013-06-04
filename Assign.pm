package Assign;
use strict;
use warnings;

use Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{VARIABLE} = shift;
	$self->{VALUE} = shift;
	return bless $self, $pkg
}

sub emit {
	my $self = shift;
	return $self->{VARIABLE}->value()." = ".Util::coerce($self->{VALUE});
}

1;
