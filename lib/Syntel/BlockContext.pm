package Syntel::BlockContext;
use strict;
use warnings;
use parent qw(Syntel::Context);

sub emit {
	my $self = shift;
	return "{".$self->SUPER::emit()."}";
}

1;
