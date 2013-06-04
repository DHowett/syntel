package FunctionPrototype;
use strict;
use warnings;
use parent qw(Statement);

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
	if(defined $self->{FUNCTION}->{PARAMETERS}) {
		if(scalar @{$self->{FUNCTION}->{PARAMETERS}} > 0) {
			$r .= join(",", map {$_->declaration()->emit()} @{$self->{FUNCTION}->{PARAMETERS}});
		} else {
			$r .= "void";
		}
	}
	$r .= ")";
	return $r;
}

1;

