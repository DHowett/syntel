package Syntel::ConstantValue;
use strict;
use warnings;
use parent qw(Syntel::Expression);

use Exporter qw(import);
our @EXPORT = qw(synConstant synString synCharSequence);

sub synConstant { return Syntel::ConstantValue->new(@_); }
sub synString { return Syntel::ConstantValue::String->new(@_); }
sub synCharSequence { return Syntel::ConstantValue::CharSequence->new(@_); }

sub new {
	my $proto = shift;
	my $pkg = ref $proto || $proto;
	my ($val, $type) = @_;
	my $self = {
		VALUE => $val,
		TYPE => $type,
	};
	return bless $self, $pkg
}

sub type {
	return shift()->{TYPE};
}

sub expr {
	my $self = shift;
	my $v = $self->{VALUE};
	return "".$v;
}

# emit: handled by Expression

1;

package Syntel::ConstantValue::String;
use strict;
use warnings;
use parent -norequire, "Syntel::ConstantValue";

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

package Syntel::String;
use parent -norequire, "Syntel::ConstantValue::String";

package Syntel::ConstantValue::CharSequence;
use strict;
use warnings;
use parent -norequire, "Syntel::ConstantValue";

use Syntel::Type;

sub type {
	return length($_[0]->{VALUE}) == 1
		? $Syntel::Type::CHAR
		: $Syntel::Type::INT;
}

sub expr {
	my $self = shift;
	my $v = $self->{VALUE};
	$v =~ s/'/\\'/g;
	$v =~ s/\n/\\n/g;
	return "\'".$v."\'";
}

1;

