package Variable;
use strict;
use warnings;
use parent qw(Expression LValue);

use Declare;
use Assign;
use PrefixOperator;
use Expression;

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
	return Declare->new($self);
}

sub assign {
	my $self = shift;
	return Assign->new($self, shift);
}

sub pointer {
	my $self = shift;
	return PrefixOperator->new("&", $self)->typed($self->type->pointer);
}

sub expr {
	my $self = shift;
	return $self->name;
}

# emit: handled by Expression

1;
