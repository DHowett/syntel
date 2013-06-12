package Syntel::Function;
use strict;
use warnings;
use parent qw(Syntel::BlockContext);
use role qw(Expression);

use Scalar::Util;
use Carp;

use Syntel::FunctionCall;
use Syntel::Declare;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;

	my $name = shift;
	my $type = shift;
	my $paramnames = shift;

	croak "Type of function $name is not function type" if !$type->DOES("Function");
	# TODO: Make up param names if there aren't enough.

	my $self = $pkg->SUPER::new(@_);
	$self->{NAME} = $name;
	$self->{TYPE} = $type;

	if($paramnames) {
		my $paramtypes = $type->arguments;
		$self->{_PARAMS} = [map {Syntel::Variable->new($paramnames->[$_], $paramtypes->[$_])} (0..$#$paramnames)];
	}

	$self->{_DECL} = Syntel::Function::_Declaration->new($self);
	return bless $self, $pkg
}

sub name {
	return $_[0]->{NAME};
}

sub type {
	return $_[0]->{TYPE};
}

sub prototype {
	return Syntel::Declare->new(@_);
}

sub declaration {
	return $_[0]->{_DECL};
}

sub param {
	my $self = shift;
	my $idx = shift;
	if(Scalar::Util::looks_like_number($idx)) {
		return $self->{_PARAMS}->[$idx];
	} else {
		for(@{$self->{_PARAMS}}) {
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
	$r .= $self->declaration->emit();
	$r .= $self->SUPER::emit();
	return $r;
}

1;

package Syntel::Function::_Declaration;
use strict;
use warnings;
use parent qw(Syntel::Statement);

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{FUNCTION} = shift;
	return bless $self, $pkg
}

sub emit {
	# This is all magic to get the variable names to exist.
	
	my $self = shift;
	my $i = $self->{FUNCTION}->{NAME};
	$i .= "(";
	if(defined $self->{FUNCTION}->{_PARAMS}) {
		if(scalar @{$self->{FUNCTION}->{_PARAMS}} > 0) {
			$i .= join(",", map {$_->declaration()->emit()} @{$self->{FUNCTION}->{_PARAMS}});
		} else {
			$i .= "void";
		}
	}
	$i .= ")";
	return $self->{FUNCTION}->type->returnType->declString($i);
}

1;

