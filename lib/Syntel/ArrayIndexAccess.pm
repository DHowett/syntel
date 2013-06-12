package Syntel::ArrayIndexAccess;
use strict;
use warnings;
use parent qw(Syntel::Expression);

use Syntel::Util;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{EXPR} = shift;
	$self->{INDEX} = shift;
	$self->{TYPE} = $self->{EXPR}->type->innerType;
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	return Syntel::Util::expr($self->{EXPR})."[".$self->{INDEX}."]";
}

# emit: handled by Expression

1;

