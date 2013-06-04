package Util;
use strict;
use warnings;

sub coerce {
	my $val = shift;
	if(ref($val)) {
		return $val->value();
	}
	return $val;
}

1;
