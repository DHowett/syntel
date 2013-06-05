package PrefixOperator;
use strict;
use warnings;
use parent qw(Expression);

use Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{OP} = shift;
	$self->{M1} = shift;
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return $self->{OP}.Util::expr($self->{M1});
}

# emit: handled by Expression

1;