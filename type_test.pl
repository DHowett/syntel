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

sub _declStringForType { my $t = shift; return $t->declString(@_); }

print STDERR Type->new("unsigned int"),$/;
print STDERR Type->new("int abc"),$/;
print STDERR Type->new("int *abc"),$/;
print STDERR Type->new("void ((*))((int))"),$/;
print STDERR Type->new("void (*(*)())()"),$/;
print STDERR Type->new("void (*(*(*)(inner))(middle))(outer)"),$/;
print STDERR Type->new("void (*(*(*)())())()"),$/;
print STDERR Type->new("void (^)()"),$/;
print STDERR Type->new("void (^(^)())()"),$/;
print STDERR Type->new("void (^(^(^)())())()"),$/;
print STDERR Type->new("void (*)(int)"),$/;
print STDERR Type->new("void (*abc)(int)"),$/;
print STDERR Type->new("int (^)(long, long)"),$/;
print STDERR Type->new("int (^named)(long, long)"),$/;
print STDERR Type->new("int (*(*fp)(int x, int))(long, long)"),$/;
print STDERR Type->new("int (*(*)(void (*)(), int))(long, long)"),$/;
print STDERR Type->new("int (*(*)(void (*)(), int))(struct{int x;}, long)"),$/;
print STDERR Type->new("struct{ int (*(*embedded)(void (*)(), int))(struct{int x;}, long); }"),$/;
print STDERR Type->new("struct{ int x; } (*func_returning_direct_struct)(int)"),$/;
print STDERR Type->new("struct{ int x; } *(*func_returning_raw_struct_ptr)(int)"),$/;
print STDERR Type->new("struct abc (*func_returning_named_struct)(int)"),$/;
print STDERR Type->new("struct abc def"),$/;
print STDERR Type->new("struct abc *def"),$/;
print STDERR Type->new("struct {int x;} *"),$/;
print STDERR Type->new("struct {int x; int y; int x; int a; int b; char c; void *p;} *def"),$/;
print STDERR Type->new("union {int x; int y; int x; int a; int b; char c; void *p;}"),$/;
print STDERR Type->new("struct { struct {int x; void *y;} something; int x; }"),$/;
print STDERR Type->new("struct { union {int x; void *y;} something; int x; }"),$/;
print STDERR Type->new("int *abc[]"),$/;
print STDERR Type->new("int (*[])()[]"),$/;
#print STDERR Type->new("int x()"),$/;
print STDERR Type->new("int (*(*x))"),$/;
print STDERR Type->new("int (*printflike)(char *fmt, ...)"),$/;
print STDERR Type->new("struct Layer { int (**x1)(); struct Atomic { struct { int x_1_2_1; } x_2_1_1; } x2; struct Data { unsigned int x_3_1_1; unsigned char x_3_1_2; unsigned char x_3_1_3; unsigned char x_3_1_4; unsigned char x_3_1_5; unsigned int x_3_1_6 : 2; unsigned int x_3_1_7 : 2; unsigned int x_3_1_8 : 4; unsigned int x_3_1_9 : 4; unsigned int x_3_1_10 : 1; unsigned int x_3_1_11 : 1; unsigned int x_3_1_12 : 1; unsigned int x_3_1_13 : 1; unsigned int x_3_1_14 : 1; unsigned int x_3_1_15 : 1; unsigned int x_3_1_16 : 1; unsigned int x_3_1_17 : 1; unsigned int x_3_1_18 : 1; unsigned int x_3_1_19 : 1; unsigned int x_3_1_20 : 1; unsigned int x_3_1_21 : 1; unsigned int x_3_1_22 : 1; unsigned int x_3_1_23 : 1; unsigned int x_3_1_24 : 1; unsigned int x_3_1_25 : 1; unsigned int x_3_1_26 : 1; unsigned int x_3_1_27 : 1; unsigned int x_3_1_28 : 1; unsigned int x_3_1_29 : 1; unsigned int x_3_1_30 : 32; struct Vec2 { double x_31_2_1; double x_31_2_2; } x_3_1_31; struct Rect { double x_32_2_1; double x_32_2_2; double x_32_2_3; double x_32_2_4; } x_3_1_32; } x3; struct Ref { struct Object {} *x_4_1_1; } x4; struct Ref x5; struct Layer {} *x6; struct Ref x7; struct Ref x8; struct Ref x9; }*"),$/;
print STDERR Type->new("int")->pointer,$/;
print STDERR Type->new("struct{int x;}")->pointer,$/;
print STDERR Type->new("struct{enum lilstevie_example_enum { NVFBLOB_TYPE_VERSION = 0x01, NVFBLOB_TYPE_RCMVER, NVFBLOB_TYPE_RCMDLEXEC, NVFBLOB_TYPE_BLHASH, NVFBLOB_TYPE_EXT_WHEELIE_BCTC = 0x7F000000, NVFBLOB_TYPE_EXT_WHEELIE_BCTR, NVFBLOB_TYPE_EXT_WHEELIE_BL, NVFBLOB_TYPE_EXT_WHEELIE_ODMDATA, NVFBLOB_TYPE_EXT_WHEELIE_CPU_ID, NVFBLOB_TYPE_FORCE32 = 0x7FFFFFFF } type;}"),$/;
print STDERR Type->new("struct { int x; } (*cool)(struct { void (**fp) (int); int z; } q, void(*(*(*(*(*coolest)())())())())())"),$/;

print STDERR _declStringForType($Type::INT),$/;
print STDERR _declStringForType($Type::INT, "a"),$/;
print STDERR _declStringForType($Type::INT->pointer, "a"),$/;
print STDERR _declStringForType($Type::INT->array, "a"),$/;
print STDERR _declStringForType($Type::INT->array(100), "a"),$/;
print STDERR _declStringForType($Type::INT->pointer->array, "a"),$/;
print STDERR _declStringForType($Type::INT->pointer->pointer->array, "a"),$/;
print STDERR _declStringForType($Type::INT->array->pointer->array->pointer, "a"),$/;
print STDERR Type->new("int (*)[10]"),$/;
print STDERR Type->new("int (*(*)[10])[100]"),$/;
print STDERR _declStringForType($Type::INT->array->array, "a"),$/;
print STDERR _declStringForType(Type->new("struct {int x;}"), "a"),$/;
print STDERR _declStringForType(Type->new("struct abc {int x;}")),$/;
print STDERR _declStringForType(Type->new("struct abc {int x;}"), "a"),$/;
print STDERR _declStringForType(Type->new("struct abc {int x;}")->pointer, "a"),$/;
print STDERR _declStringForType(Type->new("struct{enum { NVFBLOB_TYPE_VERSION = 0x01, NVFBLOB_TYPE_RCMVER, NVFBLOB_TYPE_RCMDLEXEC, NVFBLOB_TYPE_BLHASH, NVFBLOB_TYPE_EXT_WHEELIE_BCTC = 0x7F000000, NVFBLOB_TYPE_EXT_WHEELIE_BCTR, NVFBLOB_TYPE_EXT_WHEELIE_BL, NVFBLOB_TYPE_EXT_WHEELIE_ODMDATA, NVFBLOB_TYPE_EXT_WHEELIE_CPU_ID, NVFBLOB_TYPE_FORCE32 = 0x7FFFFFFF } type;}")),$/;
print STDERR _declStringForType(Type->new("void (*)()")),$/;
print STDERR _declStringForType(Type->new("void (^(^)())()"), "blockpointed"),$/;
print STDERR _declStringForType(Type->new("void (*(*)())()")),$/;
print STDERR _declStringForType(Type->new("void (*(*(*)(void *))(int **))(int(*)())")->array(10), "abcdef"),$/;
print STDERR _declStringForType(Type->new("void (*(*(*)())())()")),$/;

