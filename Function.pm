package Function;
use strict;
use warnings;

use BlockContext;
use FunctionCall;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{NAME} = shift;
	$self->{RETURN} = shift;
	$self->{PARAMETERS} = shift;
	$self->{BODY} = BlockContext->new();
	return bless $self, $pkg
}

sub body {
	my $self = shift;
	return $self->{BODY};
}

sub call {
	my $self = shift;
	return FunctionCall->new($self);
}

sub emit {
	my $self = shift;
	my $r = "";
	$r .= $self->{RETURN}." ".$self->{NAME};
	$r .= "(";
	$r .= join(",", map {$_->declaration()->emit()} @{$self->{PARAMETERS}});
	$r .= ")";
	$r .= $/;
	$r .= $self->{BODY}->emit();
	return $r;
}

1;
