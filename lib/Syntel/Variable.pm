package Syntel::Variable;
use strict;
use warnings;
use parent qw(Syntel::Expression Syntel::LValue);

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

sub assign {
	my $self = shift;
	return Syntel::Assign->new($self, shift);
}

sub pointer {
	my $self = shift;
	return Syntel::PrefixOperator->new("&", $self)->typed($self->type->pointer);
}

sub expr {
	my $self = shift;
	return $self->name;
}

# emit: handled by Expression

1;
