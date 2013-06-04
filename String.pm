package String;
use strict;
use warnings;
use parent qw(Expression);

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $str = shift;
	my $self = \$str;
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	my $v = $$self;
	$v =~ s/"/\\"/g;
	$v =~ s/\n/\\n/g;
	return "\"".$v."\"";
}

1;

