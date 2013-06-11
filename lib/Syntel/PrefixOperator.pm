package Syntel::PrefixOperator;
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
	return $self->{OP}.Syntel::Util::expr($self->{M1});
}

# emit: handled by Expression

1;
