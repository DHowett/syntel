package Expression;
use strict;
use warnings;
use parent qw(Statement);

sub DOES {
	my ($s, $does) = @_;
	return 1 if $does eq "TypedExpression" && (ref $s) && defined $s->can("type");
	return $s->SUPER::DOES($does);
}

sub expr {
	my $self = shift;
	return "<EXPR>";
}

sub emit {
	my $self = shift;
	return $self->expr;
}

1;

package TypedExpression;
use strict;
use warnings;
use parent -norequire, "Expression";

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my $self = {};
	$self->{EXPRESSION} = shift;
	$self->{TYPE} = shift;
	return bless $self, $pkg
}

sub expression {
	return $_[0]->{EXPRESSION};
}

sub type {
	return $_[0]->{TYPE};
}

sub expr {
	return $_[0]->expression->expr;
}

1;
