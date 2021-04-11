#!/usr/bin/perl

sub rm_space {
    my ($cmd) = @_;
    $cmd_len = length($cmd);
    my @chars = split(//,$cmd);
    my @new_chars;

    for (my $i =0; $i < $cmd_len;$i=$i+1){
        my $ch = $chars[$i];
        if ($ch ne ' '){
            push(@new_chars,$ch);
        }
    }
    my $new_cmd = join("",@new_chars);
    return ($new_cmd);
}

sub rm_comment {
    my ($cmd) = @_;
    $cmd_len = length($cmd);
    my @chars = split(//,$cmd);
    my @new_chars;

    for (my $i =0; $i < $cmd_len;$i=$i+1){
        my $ch = $chars[$i];
        if ($ch ne '#'){
            push(@new_chars,$ch);
        }
        else{
            last;
        }
    }
    my $new_cmd = join("",@new_chars);
    return ($new_cmd);
}


printf("%s\n",rm_space(rm_comment(" 3, 17  d  # comment")));



