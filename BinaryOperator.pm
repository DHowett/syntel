package BinaryOperator;
use strict;
use warnings;
use parent qw(Expression);

use Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{M1} = shift;
	$self->{OP} = shift;
	$self->{M2} = shift;
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return Util::expr($self->{M1})." ".$self->{OP}." ".Util::expr($self->{M2});
}

# emit: handled by Expression

1;

