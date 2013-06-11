package Syntel::Function;
use strict;
use warnings;
use parent qw(Syntel::BlockContext);

use Scalar::Util;

use Syntel::FunctionCall;
use Syntel::FunctionPrototype;

sub DOES {
	my ($self, $does) = @_;
	return 1 if $does eq "Expression";
	return $self->SUPER::DOES($does);
}

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
	$self->{PROTOTYPE} = Syntel::FunctionPrototype->new($self);
	return bless $self, $pkg
}

sub name {
	return $_[0]->{NAME};
}

sub returnType {
	return $_[0]->{RETURN_TYPE};
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
	return Syntel::FunctionCall->new($self, \@a);
}

sub expr {
	my $self = shift;
	return $self->{NAME};
}

sub emit {
	my $self = shift;
	my $r = "";
	$r .= $self->prototype->emit();
	$r .= $self->SUPER::emit();
	return $r;
}

1;
