package Context;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{CONTENTS} = [];
	return bless $self, $pkg
}

sub push {
	my $self = shift;
	push(@{$self->{CONTENTS}}, shift)
}

sub emit {
	my $self = shift;
	my $r = "";
	for(@{$self->{CONTENTS}}) {
		$r .= $_->emit();
		$r .= ";".$/;
	}
	return $r;
}

1;
