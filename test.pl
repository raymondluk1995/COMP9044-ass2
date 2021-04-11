#!/usr/bin/perl

sub appearance_cnt {
    my ($cmd,$de) = @_;
    my @cmdChars = split(//,$cmd);
    my $cmd_len = length($cmd);
    my $cnt = 0;

    for (my $i=0; $i<$cmd_len;$i+=1){
        if ($cmdChars[$i] eq $de){
            $cnt += 1;
        }
    }
    return ($cnt);
}

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

sub s_command {
    my ($cmd, $line) = @_;

    my $cmd_len = length($cmd);
    # Then length should be greater than 4
    if ($cmd_len < 5){
        die("sped: command line: invalid command");
    }

    my @cmdChars = split(//,$cmd);

    # dm stands for delimiter
    my $dm = $cmdChars[1];

    # The count of delimiter should be 3
    if (appearance_cnt($cmd,$dm) != 3){
        die("sped: command line: invalid command");
    }

    # If the ending of command is not 'g' or the delimiter, the s command is invalid
    if ($cmdChars[-1] ne 'g' && $cmdChars[-1] ne $dm){
        die("sped: command line: invalid command");
    }

    # If the ending of command is 'g' but the penultimate character is not delimiter 
    if ($cmdChars[-1] eq 'g' && $cmdChars[-2] ne $dm){
        die("sped: command line: invalid command");
    } 

    my @patterns = get_s_command_patterns($cmd,$dm);
    my $pat1 = $patterns[0];
    my $pat2 = $patterns[1];

    $pat1 = slash_meta($pat1);
    $pat2 = slash_meta($pat2);

    if ($cmdChars[-1] eq 'g'){
        $line =~ s/$pat1/$pat2/gee;
    }
    elsif($cmdChars[-1] eq $dm ){
        $line =~ s/$pat1/$pat2/ee;
    }
    else{
        die("sped: command line: invalid command");
    }
    return ($line);
}


my $line = "1";

my $cmd = "s/[15]/zzz/";

my $result = s_command($cmd,$line);

print("$result\n");



