package Syntel::Lib::C;
use strict;
use warnings;

use Syntel::Type;
use Syntel::Function;

our $size_t = Syntel::Type->new("size_t");

our $printf = Syntel::Function->new("printf", Syntel::Type::Function->new($Syntel::Type::INT, [$Syntel::Type::CHAR->pointer, $Syntel::Type::VARARGS]));
our $strlen = Syntel::Function->new("strlen", Syntel::Type::Function->new($size_t, [$Syntel::Type::CHAR->pointer]));
our $memcpy = Syntel::Function->new("memcpy", Syntel::Type::Function->new($Syntel::Type::VOID->pointer, [$Syntel::Type::VOID->pointer, $Syntel::Type::VOID->pointer, $size_t]));

1;
