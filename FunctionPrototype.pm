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
	my $i = $self->{FUNCTION}->{NAME};
	$i .= "(";
	if(defined $self->{FUNCTION}->{PARAMETERS}) {
		if(scalar @{$self->{FUNCTION}->{PARAMETERS}} > 0) {
			$i .= join(",", map {$_->declaration()->emit()} @{$self->{FUNCTION}->{PARAMETERS}});
		} else {
			$i .= "void";
		}
	}
	$i .= ")";
	return $self->{FUNCTION}->{RETURN_TYPE}->declString($i);
}

1;

