package String;
use strict;
use warnings;
use parent qw(ConstantValue LValue);

use Type;

sub expr {
	my $self = shift;
	my $v = $$self;
	$v =~ s/"/\\"/g;
	$v =~ s/\n/\\n/g;
	return "\"".$v."\"";
}

sub type {
	return $Type::CHAR->pointer;
}

1;
