package Util;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(matchedParenthesisSet smartSplit);

sub expr {
	my $val = shift;
	if(ref($val) && $val->DOES("Expression")) {
		return $val->expr();
	}
	return $val;
}

sub fallsBetween {
	my $idx = shift;
	while(@_ > 0) {
		my $start = shift;
		my $end = shift;
		return 1 if ($start < $idx && (!defined($end) || $end > $idx))
	}
	return 0;
}

sub matchedParenthesisSet {
	my $in = shift;

	my $opening = -1;
	my $closing = -1;
	# If we encounter a ) that puts us back at zero, we found a (
	# and have reached its closing ).
	my $parenmatch = $in;
	my $pdepth = 0;
	while($parenmatch =~ /[;()]/g) {

		if($& eq "(") {
			if($pdepth == 0) { $opening = $+[0]; }
			$pdepth++;
		} elsif($& eq ")") {
			$pdepth--;
			if($pdepth == 0) { $closing = $+[0]; last; }
		}
	}

	return undef if $opening == -1;
	return ($opening, $closing);
}

sub smartSplit {
	my $re = shift;
	my $in = shift;
	return () if !$in || $in eq "";

	my $limit = shift;
	$limit = 0 if !defined $limit;

	my @parens = matchedParenthesisSet($in);

	my $lstart = 0;
	my @pieces = ();
	my $piece = "";
	while($in =~ /$re/g) {
		next if (defined $parens[0] && fallsBetween($-[0], @parens));
		$piece = substr($in, $lstart, $-[0]-$lstart);
		push(@pieces, $piece);
		$lstart = $+[0];
		$limit--;
		last if($limit == 1); # One item left? Bail out and throw the rest of the string into it!
	}
	$piece = substr($in, $lstart);
	push(@pieces, $piece);
	return @pieces;
}

1;
