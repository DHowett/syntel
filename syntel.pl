#!/usr/bin/env perl
use strict;
use warnings;
use Context;
use Function;
use Assign;
use Variable;
use Vararg;
use Return;
use ConstantValue;
use String;
use BinaryOperator;
use PrefixOperator;
use While;

my $root = Context->new();
my $x = Variable->new("x", "int");
my $y = Variable->new("y", "int");
$root->push($x->declaration);
$root->push($y->declaration);

my $mul = Function->new("multiply", "int", [Variable->new("_x", "int"), Variable->new("_y", "int")]);
$mul->push(Return->new(BinaryOperator->new($mul->param(0), "*", $mul->param(1))));
$root->push($mul);

my $f = Function->new("whatever", "int", []);
$f->defer(Return->new(32));
$root->push($f);

my $printf = Function->new("printf", "int", [Variable->new("fmt", "char *"), Vararg->new()]);
$root->push($printf->prototype);

my $main = Function->new("main", "int", [Variable->new("argc", "int"), Variable->new("argv", "char**")]);
$main->defer(Return->new($y));
$main->push($x->assign(ConstantValue->new(10)));
$main->push($y->assign($f->call()));
my $printcall = $printf->call(String->new("x == %d, y == %d\n"), $x, $y);
$main->push($printcall);
$main->defer($printcall);
$main->push($printf->call(String->new("mul == %d\n"), $mul->call($x, $y)));
$main->push($x->assign($y));

{
	my $block = BlockContext->new();
	my $i = Variable->new("i", "int");
	$block->push($i->declaration(10));

	my $iprint = $printf->call(String->new("i = %d "), $i);
	my $idec = PrefixOperator->new("--", $i);
	my $icmp = BinaryOperator->new($i, ">", 0);

	my $while = While->new($icmp, [$iprint, $idec]);
	$block->push($while);
	$block->push($printf->call(String->new("\n")));

	$block->push($i->assign(10));
	$block->push(While->do([$iprint, $idec])->while($icmp));
	$block->push($printf->call(String->new("\n")));
	$main->push($block);
}

$root->push($main);

print $root->emit();
