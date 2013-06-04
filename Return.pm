package Return;
use strict;
use warnings;

use Util;

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
	return "return ".Util::coerce($v);
}

1;

