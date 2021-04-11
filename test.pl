#!/usr/bin/perl -w

my $str = "2,/3/d";

$str =~ /^(.*),(.*)d$/;

print("$1 $2\n");