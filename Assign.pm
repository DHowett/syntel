package Assign;
use strict;
use warnings;

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
	my $v = $self->{VALUE};
	if(ref($v)) {
		$v = $v->value();
	}
	return $self->{VARIABLE}->value()." = ".$v;
}

1;
