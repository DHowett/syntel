package Util;
use strict;
use warnings;

sub expr {
	my $val = shift;
	if(ref($val) && $val->DOES("Expression")) {
		return $val->expr();
	}
	return $val;
}

1;
