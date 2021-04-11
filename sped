#!/usr/bin/perl -w 

############ SUB ROUTINES START ###############

# Turn on the flags specified, and return the non-flag addresses
sub check_flags {
    my (@argvs) = @_;
    my @new_argvs;

    foreach $item (@argvs){
        if ($item =~ /^\-\-/){
            die ("usage: sped [-i] [-n] [-f <script-file] [sed-command] <files>\n");
        }

        if ($item =~ /^\-/){
            if ($item eq "-i"){
                $i_flag = 1;
            }
            elsif ($item eq "-f"){
                $f_flag = 1;
            }
            elsif ($item eq "n"){
                $n_flag = 1;
            }
            else{
                die ("usage: sped [-i] [-n] [-f <script-file] [sed-command] <files>\n");
            }
        }
        else{
            push (@new_argvs,$item);
        }

    }

    return (@new_argvs);
}

# Remove the heading and trailing commas;
sub chomp_comma {
    my ($addr) = @_;
    my $addr_len = length($addr);
    @chars = split(//,$addr);
    my $start = 0;
    my $end = 0;
    for my $i (0..$addr_len-1){
        my $ch = $chars[$i];
        if ($ch ne ';'){
            $start = $i;
            last;
        }
    }
    for (my $i=$addr_len-1;$i>=0;$i-=1){
        my $ch = $chars[$i];
        if ($ch ne ';'){
            $end = $i +1;
            last;
        }
    }
    return (substr($addr,$start,$end-$start));
} 

# Save commands separated by comma in a string to an array
sub get_commands {
    my ($addr) = @_;
    my @commands;
    my $addr_len = length($addr);
    my @chars = split(//,$addr);
    $anchor = 0;
    for ($i=1;$i<$addr_len;$i=$i+1){
        my $ch = $chars[$i];
        if ($ch eq ';'){
            my $prev_ch = $chars[$i-1];
            if ($prev_ch eq '/'){
                next;
            }
            my $str = substr($addr,$anchor,$i-$anchor);
            push(@commands,$str);
            $anchor = $i +1;
        }
    }
    my $str = substr($addr,$anchor,$addr_len-$anchor);
    push(@commands,$str);
    return @commands;
}

# Return the command type
sub get_command_type {
    my ($cmd) = @_;

    if ($cmd =~ /d$/){
        return ("d");
    }
    elsif ($cmd =~ /q$/){
        return ("q");
    }
    elsif ($cmd =~ /p$/){
        return ("p");
    }
    elsif ($cmd =~ /^s/){
        return ("s");
    }
    else{
        return ("default");
    }
}

# Remove all spaces in a command
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

# Remove the comment part in a command
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


# Return an array with each element is an array's reference revealing a command and its type.
sub commands_with_type {
    my (@cmds) = @_;
    my @new_cmds;
    foreach my $cmd (@cmds){
        $cmd = rm_space($cmd);
        $cmd = rm_comment($cmd);
        my $type = get_command_type($cmd);
        my @item = ($cmd,$type);
        push(@new_cmds,\@item);
    }
    return (@new_cmds);
}

# Execute a command
sub exec_cmd {
    my ($item,$line) = @_;
    $cmd = $item -> [0];
    $type = $item -> [1];

    if ($type eq "q"){
        &q_command($cmd,$line);
    }
    elsif ($type eq "p"){
        &p_command($cmd,$line);
    }
    elsif ($type eq "d"){
        &d_command($cmd,$line);
    }
    elsif ($type eq "s"){
        $line = &s_command($cmd,$line);
    }
    # TODO: D_COMMAND, P_COMMAND ETC.
    return ($line);
}

# quit command execution
sub q_command {
    my ($cmd,$line) = @_;
    if ($cmd =~ /^(\d+)q$/){
        if ($1 == $LINE_NUM){
            $EXIT_STATUS = 1;
        }
    }
    elsif ($cmd =~ /^\/(.*)\/q$/){
        if ($line =~ /$1/){
            $EXIT_STATUS = 1;
        }
    }
    else{
        die("sped: command line: invalid command");
    }
}

# print command execution
sub p_command {
    my ($cmd,$line) = @_;
    if ($cmd =~ /^(\d+)p$/){
        if ($1 == $LINE_NUM){
            print("$line\n");
        }
    }
    elsif ($cmd =~ /^\/(.*)\/p$/){
        if ($line =~ /$1/){
            print("$line\n");
        }
    }
    else{
        die("sped: command line: invalid command");
    }
}

# delete command execution
sub d_command {
    my ($cmd,$line) = @_;
    if ($cmd =~ /^(\d+)d$/){
        if ($1 == $LINE_NUM){
            $DELETE_STATUS = 1;
        }
    }
    elsif ($cmd =~ /^\/(.*)\/d$/){
        if ($line =~ /$1/){
            $DELETE_STATUS = 1;
        }
    }
    else{
        die("sped: command line: invalid command");
    }
}

# Get the appearance count of the delimeter.
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

# Get the two patterns of s command and return them in an array
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

# Substitute the "/" to "\/"
sub slash_meta {
    my ($pat) = @_;
    $pat =~ s/\//\\\//g;
    return ($pat);
}

# Execute the s command
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
        $line =~ s/$pat1/$pat2/g;
    }
    elsif($cmdChars[-1] eq $dm ){
        $line =~ s/$pat1/$pat2/;
    }
    else{
        die("sped: command line: invalid command");
    }
    return ($line);
}

############ SUB ROUTINES ENDS ################
our $i_flag = 0;
our $f_flag = 0;
our $n_flag = 0;
our @argvs = check_flags(@ARGV);

our $EXIT_STATUS = 0;
our $DELETE_STATUS = 0;

our $sed_commands = chomp_comma($argvs[0]);
our @inter_commands = get_commands($sed_commands); 

my @commands = commands_with_type(@inter_commands);

our $LINE_NUM = 1;

while ($line = <STDIN>){
    chomp $line;
    $EXIT_STATUS = 0;
    $DELETE_STATUS = 0;
    foreach $item (@commands){
        $line = &exec_cmd($item,$line);
    }

    if ($n_flag == 0 && $DELETE_STATUS == 0){
        print("$line\n");
    }

    if ($EXIT_STATUS == 1){
        exit 0;
    }

    $LINE_NUM +=1;
}

