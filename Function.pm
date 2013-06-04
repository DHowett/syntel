package Function;
use strict;
use warnings;

use BlockContext;
use FunctionCall;
use FunctionPrototype;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{NAME} = shift;
	$self->{RETURN} = shift;
	$self->{PARAMETERS} = shift;
	$self->{BODY} = BlockContext->new();
	$self->{PROTOTYPE} = FunctionPrototype->new($self);
	return bless $self, $pkg
}

sub body {
	my $self = shift;
	return $self->{BODY};
}

sub prototype {
	my $self = shift;
	return $self->{PROTOTYPE}
}

sub call {
	my $self = shift;
	my @a = @_;
	return FunctionCall->new($self, \@a);
}

sub emit {
	my $self = shift;
	my $r = "";
	$r .= $self->prototype->emit();
	$r .= $self->{BODY}->emit();
	return $r;
}

1;
