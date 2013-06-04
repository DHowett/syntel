package Type;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = shift;
	return bless $self, $pkg;
}

1;
