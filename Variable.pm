package Variable;
use strict;
use warnings;

use Declare;
use Assign;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{NAME} = shift;
	$self->{TYPE} = shift;
	return bless $self, $pkg
}

sub declaration {
	my $self = shift;
	return Declare->new($self);
}

sub assign {
	my $self = shift;
	return Assign->new($self, shift);
}

sub value {
	my $self = shift;
	return $self->{NAME};
}

sub emit {
	my $self = shift;
	return $self->{NAME};
}

1;

