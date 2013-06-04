#!/usr/bin/env perl
use strict;
use warnings;
use Context;
use Function;
use Assign;
use Variable;
use Vararg;
use Return;
use String;
use BinaryOperator;

my $root = Context->new();
my $x = Variable->new("x", "int");
my $y = Variable->new("y", "int");
$root->push($x->declaration);
$root->push($y->declaration);

my $mul = Function->new("multiply", "int", [Variable->new("val", "int"), Variable->new("val2", "int")]);
$mul->body->defer(Return->new(BinaryOperator->new($mul->param("val"), "*", $mul->param("val2"))));
$root->push($mul);

my $f = Function->new("whatever", "int", []);
$f->body->defer(Return->new(32));
$root->push($f);

my $printf = Function->new("printf", "int", [Variable->new("fmt", "char *"), Vararg->new()]);
$root->push($printf->prototype);

my $main = Function->new("main", "int", [Variable->new("argc", "int"), Variable->new("argv", "char**")]);
$main->body->defer(Return->new($y));
$main->body->push($x->assign(10));
$main->body->push($y->assign($f->call()));
my $printcall = $printf->call(String->new("x == %d, y == %d\n"), $x, $y);
$main->body->push($printcall);
$main->body->defer($printcall);
$main->body->push($printf->call(String->new("mul == %d\n"), $mul->call($x, $y)));
$main->body->push($x->assign($y));
$root->push($main);

print $root->emit();
