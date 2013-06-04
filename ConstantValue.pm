package ConstantValue;
use strict;
use warnings;
use parent qw(Expression);

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $val = shift;
	my $self = \$val;
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	my $v = $$self;
	return "".$v;
}

# emit: handled by Expression

1;

