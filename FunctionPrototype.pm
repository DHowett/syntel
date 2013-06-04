package FunctionPrototype;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{FUNCTION} = shift;
	return bless $self, $pkg
}

sub emit {
	my $self = shift;
	my $r = "";
	$r .= $self->{FUNCTION}->{RETURN}." ".$self->{FUNCTION}->{NAME};
	$r .= "(";
	$r .= join(",", map {$_->declaration()->emit()} @{$self->{FUNCTION}->{PARAMETERS}});
	$r .= ")";
	return $r;
}

1;

