package Syntel::Statement;
use strict;
use warnings;
use role qw(Statement);

sub emit {
	my $self = shift;
	return "<STMT>";
}
1;
