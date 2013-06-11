package Cast;
use strict;
use warnings;
use parent qw(Expression);

use Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{EXPRESSION} = shift;
	$self->{TYPE} = shift;
	return bless $self, $pkg
}

sub expression {
	return $_[0]->{EXPRESSION};
}

sub type {
	return $_[0]->{TYPE};
}

sub expr {
	my $self = shift;
	return "(".$self->{TYPE}->declString().")(".Util::expr($self->{EXPRESSION}).")";
}

1;
