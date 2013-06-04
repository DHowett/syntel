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

my $root = Context->new();
my $x = Variable->new("x", "int");
my $y = Variable->new("y", "int");
$root->push($x->declaration);
$root->push($y->declaration);

my $f = Function->new("whatever", "int", []);
$f->body->defer(Return->new(32));

$root->push($f->prototype);

my $printf = Function->new("printf", "int", [Variable->new("fmt", "char *"), Vararg->new()]);
$root->push($printf->prototype);

my $main = Function->new("main", "int", [Variable->new("argc", "int"), Variable->new("argv", "char**")]);
$main->body->defer(Return->new($y));
$main->body->push($x->assign(10));
$main->body->push($y->assign($f->call()));
$main->body->defer($printf->call(String->new("x == %d, y == %d\n"), $x, $y));
$main->body->push($x->assign($y));
$root->push($main);

$root->push($f);

print $root->emit();
