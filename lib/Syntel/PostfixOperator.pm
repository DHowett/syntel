package Syntel::PostfixOperator;
use strict;
use warnings;
use parent qw(Syntel::Expression);

use Syntel::Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{OP} = shift;
	$self->{M1} = shift;
	$self->{TYPE} = Syntel::Util::type($self->{M1});
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return Syntel::Util::expr($self->{M1}).$self->{OP};
}

# emit: handled by Expression

1;
