#!/usr/bin/perl -w

my @matches;
my $string = "ddabdadabeew";
my $pat = "EE\${1}EE";

# $pat = quotemeta($pat);

$pat = qr /$pat/;


$string =~ s/(da)b/$pat/g;
# $string =~ s/(da)b/EE${1}EE/g;
print("$string\n");
