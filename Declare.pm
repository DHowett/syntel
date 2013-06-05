package Declare;
use strict;
use warnings;
use parent qw(Statement);

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
	my $r = $self->{VARIABLE}->{TYPE}." ".$self->{VARIABLE}->{NAME};
	if(defined $self->{EXPR}) {
		$r .= " = ".Util::expr($self->{EXPR});
	}
	return $r;
}

1;

