package Syntel::Return;
use strict;
use warnings;
use parent qw(Syntel::Statement);

use Syntel::Util;

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
	return "return ".Syntel::Util::expr($v);
}

1;

