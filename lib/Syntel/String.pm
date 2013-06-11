package Syntel::String;
use strict;
use warnings;
use parent qw(Syntel::ConstantValue Syntel::LValue);

use Syntel::Type;

sub expr {
	my $self = shift;
	my $v = $$self;
	$v =~ s/"/\\"/g;
	$v =~ s/\n/\\n/g;
	return "\"".$v."\"";
}

sub type {
	return $Syntel::Type::CHAR->pointer;
}

1;
