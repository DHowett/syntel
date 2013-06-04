package BlockContext;
use strict;
use warnings;
use parent qw(Context);

sub emit {
	my $self = shift;
	my $r = "";
	$r .= "{".$/;
	$r .= $self->SUPER::emit();
	$r .= "}".$/;
	return $r;
}

1;
