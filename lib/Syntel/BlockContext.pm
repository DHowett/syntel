package Syntel::BlockContext;
use strict;
use warnings;
use parent qw(Syntel::Context);

sub emit {
	my $self = shift;
	my $r = "";
	$r .= "{".$/;
	$r .= $self->SUPER::emit();
	$r .= "}".$/;
	return $r;
}

1;
