#!/usr/bin/env zsh
setopt multios
zmodload zsh/stat

t=$(mktemp /tmp/syntelXXXXXXX)
synout=$(mktemp /tmp/syntelXXXXXXX)
errout=$(mktemp /tmp/syntelXXXXXXX)

exec {synfd}>&$synout
exec {errfd}>&$errout

./syntel.pl 1>&$synfd | gcc -o $t -x c - {errfd}>&2

exec {synfd}>&-
exec {errfd}>&-

echo "############ GENERATED"
cat $synout
if [[ $(zstat +size $errout) -gt 0 ]]; then
	echo "############ WARNINGS"
	cat $errout
fi
echo "############ OUTPUT"
chmod +x $t
$t

rm $t $synout $errout
