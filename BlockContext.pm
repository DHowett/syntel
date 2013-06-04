package BlockContext;
use strict;
use warnings;
use parent qw(Context);

sub emit {
	my $self = shift;
	my $r = "";
	$r .= "{".$/;
	for(@{$self->{CONTENTS}}) {
		$r .= $_->emit();
		$r .= ";".$/;
	}
	$r .= "}".$/;
	return $r;
}

1;
