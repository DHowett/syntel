package Syntel::Lib::ObjC;
use strict;
use warnings;

use Syntel::Type;
use Syntel::Function;

our $id		=	Syntel::Type->new("id");
our $Class	=	Syntel::Type->new("Class");
our $SEL	=	Syntel::Type->new("SEL");
our $IMP	=	Syntel::Type->new("IMP");
our $BOOL	=	Syntel::Type->new("BOOL");
our $NSString	=	Syntel::Type->new("NSString*");

our $NSLog = Syntel::Function->new("NSLog", Syntel::Type::Function->new($Syntel::Type::VOID, [$NSString, $Syntel::Type::VARARGS]));
our $msgSend = Syntel::Function->new("objc_msgSend", Syntel::Type::Function->new($id, [$id, $SEL, $Syntel::Type::VARARGS]));
our $class_addMethod = Syntel::Function->new("class_addMethod", Syntel::Type::Function->new($BOOL, [$Class, $SEL, $IMP, $Syntel::Type::CHAR->pointer]));

our $_encode = Syntel::Function->new("\@encode", Syntel::Type::Function->new($Syntel::Type::CHAR->pointer, [$Syntel::Type::CHAR->pointer]));
our $_selector = Syntel::Function->new("\@selector", Syntel::Type::Function->new($SEL, [$Syntel::Type::CHAR->pointer]));

1;
