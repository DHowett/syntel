package String;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $str = shift;
	my $self = \$str;
	return bless $self, $pkg
}

sub value {
	my $self = shift;
	my $v = $$self;
	$v =~ s/"/\\"/g;
	$v =~ s/\n/\\n/g;
	return "\"".$v."\"";
}

1;

