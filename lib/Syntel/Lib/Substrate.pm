package Syntel::Lib::Substrate;
use strict;
use warnings;

use Syntel::Type;
use Syntel::Function;
use Syntel::Lib::ObjC;

our $MSHookMessageEx = Syntel::Function->new("MSHookMessageEx", Syntel::Type::Function->new($Syntel::Type::VOID, [$Syntel::Lib::ObjC::Class, $Syntel::Lib::ObjC::SEL, $Syntel::Lib::ObjC::IMP, $Syntel::Lib::ObjC::IMP->pointer]));

1;

