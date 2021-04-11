#!/usr/bin/perl -w

sub get_s_command_patterns {
    my ($cmd, $dm) = @_;
    my @cmdChars = split(//,$cmd);
    my $cmd_len = length($cmd);
    my $anchor = 2;
    my @result; 

    for (my $i = $anchor; $i<$cmd_len; $i+=1){
        if ($cmdChars[$i] eq $dm){
            $pat1 = substr($cmd,$anchor,$i-$anchor);
            push(@result,$pat1);
            $anchor = $i + 1;
            last;
        }
    }

    for (my $i = $anchor; $i<$cmd_len; $i+=1){
        if ($cmdChars[$i] eq $dm){
            $pat2 = substr($cmd,$anchor,$i-$anchor);
            push(@result,$pat2);
            $anchor = $i + 1;
            last;
        }
    }

    return (@result);
}

sub slash_meta {
    my ($pat) = @_;
    $pat =~ s/\//\\\//g;
    return ($pat);
}

my $dm = 'X';

my $line = "1/";

my @pats = get_s_command_patterns('sX[15/]XzzzX','X');

my $pat1 = $pats[0];
my $pat2 = $pats[1];

$pat1 = slash_meta($pat1);
$pat2 = slash_meta($pat2);

print("$pat1 $pat2\n");

$line =~ s/$pat1/$pat2/g;

print("$line\n");




