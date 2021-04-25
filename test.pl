#!/usr/bin/perl -w

my @matches;
my $cmd =  '2  , 8       a hello world';

my $new = "";

if ($cmd =~ /^\s*((\d+)|(\/.*?\/)|\$)\s*(,\s*((\d+)|(\/.*?\/)))?\s*([aic])(.*)$/){
    if ($4){
        $new = $1 . $4 . $8 . $9;
    } 
    else{
        $new = $1 . $8 .$9;
    }
}

print("$new\n");

