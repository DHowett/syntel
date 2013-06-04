#!/usr/bin/env zsh
setopt multios
t=$(mktemp /tmp/syntelXXXXXXX)
echo "############ GENERATED"
{ ./syntel.pl 1>&2 | gcc -o $t -x c - } 2>&1
echo "############ OUTPUT"
chmod +x $t
$t
rm $t
