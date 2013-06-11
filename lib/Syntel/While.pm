package Syntel::While;
use strict;
use warnings;
use parent qw(Syntel::BlockContext);

sub DOES {
	my $self = shift;
	my $does = shift;
	if(ref($self) && $does eq "Statement" && $self->{DO}) {
		return 1;
	}
	return $self->SUPER::DOES($does);
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $expr = shift;
	my $self = $pkg->SUPER::new(@_);
	$self->{EXPR} = $expr;
	$self->{DO} = 0;
	return bless $self, $pkg
}

sub do {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = $pkg->SUPER::new(@_);
	$self->{DO} = 1;
	return bless $self, $pkg;
}

sub while {
	my $self = shift;
	$self->{EXPR} = shift;
	return $self;
}

sub emit {
	my $self = shift;
	my $r = "";
	my $whilebit = "while(".Syntel::Util::expr($self->{EXPR}).")";
	if($self->{DO}) {
		$r .= "do";
	} else {
		$r .= $whilebit;
	}
	$r .= $self->SUPER::emit();
	$r .= $whilebit if $self->{DO};
	return $r;
}

1;

