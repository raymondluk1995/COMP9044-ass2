#!/usr/bin/perl -w

my $str = "3,/blah\/klah\/dlah/d";

$str =~ /^(\d+),\/(.*)\/d$/;

print("$2\n");