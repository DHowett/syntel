package Syntel::Variable;
use strict;
use warnings;
use parent qw(Syntel::Expression);
use role qw(Addressable Assignable);

use Syntel::Declare;
use Syntel::Assign;
use Syntel::PrefixOperator;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{NAME} = shift;
	$self->{TYPE} = shift;
	return bless $self, $pkg
}

sub name {
	return $_[0]->{NAME};
}

sub type {
	return $_[0]->{TYPE};
}

sub declaration {
	my $self = shift;
	return Syntel::Declare->new($self, @_);
}

sub expr {
	my $self = shift;
	return $self->name;
}

# emit: handled by Expression

1;
