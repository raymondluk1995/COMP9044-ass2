#!/usr/bin/perl -w


my %hash = ('RANGE_P'=>0,
            'RANGE_RD_P'=>0,
            'RANGE_D'=>0,
            'RANGE_RD_D'=>0,
            'RANGE_S'=>0,
            'RANGE_RD_S'=>0);

my @arr;
push(@arr,\%hash);

# my %temp_hash = %{$arr[0]};
# print("$temp_hash['RANGE_S']\n");
$arr[0]{'RANGE_S'} = 2;
print("$arr[0]{'RANGE_S'}\n");
