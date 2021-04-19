#!/usr/bin/perl -w

my %h1 = ('b'=>1,'c'=>1);

my %hash;
$hash{'a'} = \%h1;

foreach $k (keys %hash){
    my %val = %{$hash{$k}};
    $val{'d'} = 1;
    foreach $k1 (keys %val){
        print("$k1\n");
    }
}

print("$hash{'a'}{'c'}\n");

if (exists($hash{'a'}{'c'})){
    print("hello\n");
}