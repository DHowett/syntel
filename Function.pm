package Function;
use strict;
use warnings;
use parent qw(BlockContext);

use Scalar::Util;

use BlockContext;
use FunctionCall;
use FunctionPrototype;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;

	my $name = shift;
	my $return = shift;
	my $parameters = shift;

	my $self = $pkg->SUPER::new(@_);
	$self->{NAME} = $name;
	$self->{RETURN_TYPE} = $return;
	$self->{PARAMETERS} = $parameters;
	$self->{PROTOTYPE} = FunctionPrototype->new($self);
	return bless $self, $pkg
}

sub prototype {
	my $self = shift;
	return $self->{PROTOTYPE}
}

sub param {
	my $self = shift;
	my $idx = shift;
	if(Scalar::Util::looks_like_number($idx)) {
		return $self->{PARAMETERS}->[$idx];
	} else {
		for(@{$self->{PARAMETERS}}) {
			return $_ if $_->{NAME} eq $idx;
		}
	}
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
	$r .= $self->SUPER::emit();
	return $r;
}

1;
