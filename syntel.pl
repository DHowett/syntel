#!/usr/bin/env perl
use strict;
use warnings;

use File::Basename qw(dirname);
use lib dirname(__FILE__)."/lib";

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
use Type;
use Cast;

my $root = Context->new();
my $x = Variable->new("x", $Type::INT);
my $y = Variable->new("y", $Type::INT);
$root->push($x->declaration);
$root->push($y->declaration);

my $fpretp = Function->new("fpretp", Type->new("void(*(*)(void))(void)"), []);
$fpretp->push(Return->new(Cast->new($fpretp, $fpretp->returnType)));
$root->push($fpretp);

my $mul = Function->new("multiply", $Type::INT, [Variable->new("_x", $Type::INT), Variable->new("_y", $Type::INT)]);
$mul->push(Return->new(BinaryOperator->new($mul->param(0), "*", $mul->param(1))));
$root->push($mul);

my $f = Function->new("whatever", $Type::INT, []);
$f->defer(Return->new(32));
$root->push($f);

my $printf = Function->new("printf", $Type::INT, [Variable->new("fmt", $Type::CHAR->pointer), $Type::VARARGS]);
$root->push($printf->prototype);

my $main = Function->new("main", $Type::INT, [Variable->new("argc", $Type::INT), Variable->new("argv", $Type::CHAR->pointer->pointer)]);
$main->defer(Return->new($y));
$main->push($x->assign(ConstantValue->new(10)));
$main->push($y->assign($f->call()));
my $printcall = $printf->call(String->new("x == %d, y == %d\n"), $x, $y);
$main->push($printcall);
$main->defer($printcall);
$main->push($printf->call(String->new("mul == %d\n"), $mul->call($x, $y)));
$main->push($printf->call(String->new("xp = %p\n"), $x->pointer));
$main->push($x->assign($y));

{
	my $block = BlockContext->new();
	my $i = Variable->new("i", $Type::INT);
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
