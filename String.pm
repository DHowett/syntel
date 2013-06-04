package String;
use strict;
use warnings;
use parent qw(ConstantValue);

sub expr {
	my $self = shift;
	my $v = $$self;
	$v =~ s/"/\\"/g;
	$v =~ s/\n/\\n/g;
	return "\"".$v."\"";
}

1;
