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

my $f = Function->new("whatever", "int");
$f->body->push(Return->new(32));
$root->push($f);

my $main = Function->new("main", "int", [Variable->new("argc", "int"), Variable->new("argv", "char**")]);
$main->body->push($x->assign(10));
$main->body->push($y->assign($f->call()));
$main->body->push($x->assign($y));
$main->body->push(Return->new($y));
$root->push($main);

print $root->emit();
