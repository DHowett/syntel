package Context;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{CONTENTS} = [];
	$self->{DEFERRED} = [];
	return bless $self, $pkg
}

sub push {
	my $self = shift;
	push(@{$self->{CONTENTS}}, shift)
}

sub defer {
	my $self = shift;
	CORE::splice(@{$self->{DEFERRED}}, 0, 0, shift)
}

sub emit {
	my $self = shift;
	my $r = "";
	for(@{$self->{CONTENTS}}, @{$self->{DEFERRED}}) {
		$r .= $_->emit();
		$r .= ";" if $_->DOES("Statement");
		$r .= $/;
	}
	return $r;
}

1;
