package Return;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{VALUE} = shift;
	return bless $self, $pkg
}

sub emit {
	my $self = shift;
	my $v = $self->{VALUE};
	if(ref($v)) {
		$v = $v->value();
	}
	return "return ".$v;
}

1;

