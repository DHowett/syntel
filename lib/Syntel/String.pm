package Syntel::String;
use strict;
use warnings;
use parent qw(Syntel::ConstantValue);

use Syntel::Type;

sub new {
	my($o, $val) = @_;
	return $o->SUPER::new($val, $Syntel::Type::CHAR->pointer);
}

sub expr {
	my $self = shift;
	my $v = $self->{VALUE};
	$v =~ s/"/\\"/g;
	$v =~ s/\n/\\n/g;
	return "\"".$v."\"";
}

1;
