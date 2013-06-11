package Syntel::Vararg;
use strict;
use warnings;

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	return bless $self, $pkg
}

sub declaration {
	my $self = shift;
	return $self;
}

sub assign {
	my $self = shift;
	return $self;
}

sub expr {
	my $self = shift;
	return "...";
}

sub emit {
	my $self = shift;
	return "...";
}

1;


