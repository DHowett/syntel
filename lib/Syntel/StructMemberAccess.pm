package Syntel::StructMemberAccess;
use strict;
use warnings;
use parent qw(Syntel::Expression);
use role;

use Syntel::Util;

sub conformsToRole {
	my $self = shift;
	my $role = shift;
	return 0 if !ref $self;
	return 1 if $role eq "Assignable" && ($self->{EXPR}->DOES("Assignable"));
	return 0;
}

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{EXPR} = shift;
	$self->{MEMBER} = shift;

	my $t = $self->{EXPR}->type;
	$t = $t->innerType if($t->DOES("Pointer"));
	if($t->members) {
		for(@{$t->members}) {
			if($_->name eq $self->{MEMBER}) {
				$self->{TYPE} = $_->type;
				last;
			}
		}
	}
	return bless $self, $pkg
}

sub expr {
	my $self = shift;
	my $t = $self->{EXPR}->type;
	my $op = ".";
	$op = "->" if($t->DOES("Pointer"));
	return Syntel::Util::expr($self->{EXPR}).$op.$self->{MEMBER};
}

# emit: handled by Expression

1;


