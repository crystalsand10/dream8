#!/usr/bin/env perl -wn

use English;

s/%.*//;
s/\'.*?\'//g;
while (/[a-z]\w* *?(\. [a-z]\w*)*/ig) {
	$var{$MATCH} += 1;
}

END {
	for $key ( keys %var ) {
		print "$key : $var{$key}\n"
	}
}