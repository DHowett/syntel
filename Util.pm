package Util;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(matchedDelimiterSet matchedParenthesisSet smartSplit);

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
		next if !defined $start;
		return 1 if ($start < $idx && (!defined($end) || $end > $idx))
	}
	return 0;
}

sub matchedDelimiterSet {
	my $in = shift;
	my @delims = @_;
	my @locations;

	my $opening = -1;
	my $closing = -1;
	# If we encounter a ) that puts us back at zero, we found a (
	# and have reached its closing ).
	my $parenmatch = $in;
	my $pdepth = 0;

	my $d = join("", @delims);
	my $re = qr/[$d]/;
	while($parenmatch =~ /$re/g) {

		if($& eq $delims[0]) {
			if($pdepth == 0) { push(@locations, $+[0]); }
			$pdepth++;
		} elsif($& eq $delims[1]) {
			$pdepth--;
			if($pdepth == 0) { push(@locations, $+[0]); }
		}
	}

	push(@locations, -1) if((scalar @locations) % 2 == 1);
	return @locations;
}

sub matchedParenthesisSet {
	my $in = shift;
	return matchedDelimiterSet($in, "(", ")");
}

sub smartSplit {
	my $re = shift;
	my $in = shift;
	return () if !$in || $in eq "";

	my $limit = shift;
	$limit = 0 if !defined $limit;

	my @delims = (matchedDelimiterSet($in, "(", ")"), matchedDelimiterSet($in, "{", "}"), matchedDelimiterSet($in, "[", "]"));

	my $lstart = 0;
	my @pieces = ();
	my $piece = "";
	while($in =~ /$re/g) {
		next if fallsBetween($-[0], @delims);
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
