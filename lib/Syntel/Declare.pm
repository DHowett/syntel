package Syntel::Declare;
use strict;
use warnings;
use parent qw(Syntel::Statement);

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{VARIABLE} = shift;
	$self->{EXPR} = shift;
	return bless $self, $pkg
}

sub emit {
	my $self = shift;
	my $type = $self->{VARIABLE}->DOES("Type") ? $self->{VARIABLE} : $self->{VARIABLE}->{TYPE};
	my $name = $self->{VARIABLE}->DOES("Type") ? undef : $self->{VARIABLE}->{NAME};
	my $r = $type->declString($name);
	if(defined $self->{EXPR}) {
		$r .= " = ".Syntel::Util::expr($self->{EXPR});
	}
	return $r;
}

1;

