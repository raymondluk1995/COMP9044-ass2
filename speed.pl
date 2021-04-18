#!/usr/bin/perl -w 

############ SUB ROUTINES START ###############

# Turn on the flags specified, and return the non-flag addresses
sub check_flags {
    my (@argvs) = @_;
    my @new_argvs;

    foreach $item (@argvs){
        if ($item =~ /^\-\-/){
            print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
            exit 1;
        }

        if ($item =~ /^\-/){
            if ($item eq "-i"){
                $i_flag = 1;
            }
            elsif ($item eq "-f"){
                $f_flag = 1;
            }
            elsif ($item eq "-n"){
                $n_flag = 1;
            }
            else{
                print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
                exit 1;
            }
        }
        else{
            push (@new_argvs,$item);
        }

    }

    return (@new_argvs);
}

# Remove the heading and trailing semicolon;
sub chomp_semicolon {
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
    elsif ($cmd =~ /^(\d+)?s/ or $cmd =~ /^(\/.*\/)?s/){
        return ("s");
    }
    else{
        return ("default");
    }
}

# Remove all spaces in a command except in regex
sub rm_space {
    my ($cmd) = @_;
    $cmd_len = length($cmd);
    my @chars = split(//,$cmd);
    my @new_chars;
    my $inRegexFlag = 0;

    for (my $i =0; $i < $cmd_len;$i=$i+1){
        my $ch = $chars[$i];
        if ($ch eq '/' ){
            $inRegexFlag = 1 - $inRegexFlag;
        }

        if ($ch ne ' '){
            push(@new_chars,$ch);
        }
        else{ # If a character is space, and the space is in a regex
            if ($inRegexFlag == 1){
                push(@new_chars,$ch);
            }
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
    my $cmd = $item -> [0];
    my $type = $item -> [1];

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
        if ($cmd =~ /^s/){
            $line = &s_command($cmd,$line);
        }
        elsif ($cmd =~ /^(\d+)(s.*)$/){
            my $targetLine = $1;
            my $sCmd = $2;
            if ($LINE_NUM == $targetLine){
                $line = &s_command($sCmd,$line);
            }
        }
        elsif ($cmd =~ /^\/(.*?)\/(s.*)$/){
            my $targetRegex = $1;
            my $sCmd = $2;
            if ($line =~ /$targetRegex/){
                $line = &s_command($sCmd,$line);
            }
        }
        else{
            print("speed: command line: invalid command\n");
            exit 1;
        }
    }
    # TODO: D_COMMAND, P_COMMAND ETC.
    return ($line);
}

# quit command execution
sub q_command {
    my ($cmd,$line) = @_;
    chomp $cmd;
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
    elsif ($cmd =~ /^\$q$/){
        return ; # Quit at the last line, do nothing
    }
    else{
        print("speed: command line: invalid command\n");
        exit 1;
    }
}

# print command execution
sub p_command {
    my ($cmd,$line) = @_;
    chomp $cmd;
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
    elsif ($cmd =~ /^\$p$/){
        if ($LINE_NUM == $lines_len){
            print("$line\n");
        }
    }
    elsif ($cmd =~ /^p$/){
        print("$line\n");
    }
    else{
        print("speed: command line: invalid command\n");
        exit 1;
    }
}

# delete command execution
sub d_command {
    my ($cmd,$line) = @_;
    if (exists($del_lines{$LINE_NUM})){
        $DELETE_STATUS = 1;
    }
}

# Given the $start_regex and $end number, find the $start number
# The $start number should be the first matched line number which is from [1,$end].
sub find_start_by_digit {
    my ($start_regex,$end) = @_;
    # Be careful: $start is the line number, and the index is always 1 less than the line number
    my $result = -1;
    for (my $i=0; $i<$end;$i+=1){ # $i can be the index of $end line
        my $line = $lines[$i];
        if ($line =~ /$start_regex/){
            $result = $i + 1; # index + 1 is the line number
            last;
        }
    } 
    return ($result);
}

# Given the $start_regex, find the $start number
# The $start number should be the first matched line number
sub find_start_without_end_digit {
    my ($start_regex) = @_;
    # Be careful: $start is the line number, and the index is always 1 less than the line number
    my $result = -1;
    for (my $i=0; $i<$lines_len;$i+=1){ # $i can be the index of $end line
        my $line = $lines[$i];
        if ($line =~ /$start_regex/){
            $result = $i + 1; # index + 1 is the line number
            last;
        }
    } 
    return ($result);
}

# Given the $end_regex and $start number, find the $end number
# The $end number should be the first matched line number which is greater than $start
sub find_end_by_digit {
    my ($start,$end_regex) = @_;
    # Be careful: $start is the line number, and the index is always 1 less than the line number
    my $result = -1;
    for (my $i=$start; $i< $lines_len;$i+=1){ # Start from ($start + 1)th line
        my $line = $lines[$i];
        if ($line =~ /$end_regex/){
            $result = $i + 1; # index + 1 is the line number
            last;
        }
    }
    return ($result);
}

# Given the $end_regex, find the $end number
# The $end number should be the first matched line number
sub find_end_without_start_digit {
    my ($end_regex) = @_;

    my $result = -1;
    for (my $i=0; $i< $lines_len;$i+=1){ # Start from ($start + 1)th line
        my $line = $lines[$i];
        if ($line =~ /$end_regex/){
            $result = $i + 1; # index + 1 is the line number
            last;
        }
    }
    return ($result);
}



# Get the appearance count of the delimeter.
sub appearance_cnt {
    my ($cmd,$de) = @_;
    chomp $cmd;
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
        print("speed: command line: invalid command\n");
        exit 1;
    }

    my @cmdChars = split(//,$cmd);

    # dm stands for delimiter
    my $dm = $cmdChars[1];

    # The count of delimiter should be 3
    if (appearance_cnt($cmd,$dm) != 3){
        print("speed: command line: invalid command\n");
        exit 1;
    }

    # If the ending of command is not 'g' or the delimiter, the s command is invalid
    if ($cmdChars[-1] ne 'g' && $cmdChars[-1] ne $dm){
        print("speed: command line: invalid command\n");
        exit 1;
    }

    # If the ending of command is 'g' but the penultimate character is not delimiter 
    if ($cmdChars[-1] eq 'g' && $cmdChars[-2] ne $dm){
        print("speed: command line: invalid command\n");
        exit 1;
    } 

    my @patterns = get_s_command_patterns($cmd,$dm);
    my $pat1 = $patterns[0];
    my $pat2 = $patterns[1];

    if ($cmdChars[-1] eq 'g'){
        $line =~ s/$pat1/$pat2/g;
    }
    elsif($cmdChars[-1] eq $dm ){
        $line =~ s/$pat1/$pat2/;
    }
    else{
        print("speed: command line: invalid command\n");
        exit 1;
    }
    return ($line);
}


sub update_del_lines {
    my (@commands) = @_;
    foreach my $item (@commands){
        my $cmd = $item ->[0];
        my $type = $item -> [1];

        if ($type eq 'd'){
            # 01 Delete a single line - digit
            if ($cmd =~ /^(\d+)d$/){ # 01 Delete a single line - digit
                my $num = $1;
                if ($num == 0){
                    print("speed: command line: invalid command\n");
                    exit 1;
                }
                $del_lines{$num} = 1;
            }
            # 02 Delete lines matched the regex
            elsif ($cmd =~ /^\/([^,]*)\/d$/){
                my $pattern = $1;
                # $pattern = slash_meta($pattern);
                for (my $i=0; $i<$lines_len; $i++){
                    my $line = $lines[$i];
                    if ($line =~ /$pattern/){
                        $del_lines{$i+1} = 1;
                    }
                }
            }
            # 03 Delete the last line
            elsif ($cmd =~ /^\$d$/){
                $del_lines{$lines_len} = 1;
            }
            # 04 Delete a range: DIGIT - DIGIT 
            elsif ($cmd =~ /^(\d+),(\d+)d$/){
                my $start = $1;
                my $end = $2;
                if ($start > $end and $end <= $lines_len and $start <= $lines_len and $start > 0 and $end > 0){ # Only delete the $start line
                    $del_lines{$start} = 1;
                }
                elsif ($end < 0){
                    print("speed: command line: invalid command\n");
                    exit 1;
                }
                elsif ($start <= $end and $end <= $lines_len and $start > 0 and $end > 0){ # $start and $end exist
                    for (my $i=$start;$i<$end+1;$i++){
                        $del_lines{$i} = 1;
                    }
                }
                elsif ($start == 0 and $end > 0 and $end <= $lines_len){
                    print("speed: command line: invalid command\n");
                    exit 1;
                }
                elsif ($start < 0 and $end > 0 and $end <= $lines_len){
                    print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
                    exit 1;
                }
                elsif ($start > $end and $start > $lines_len){ # If $start is too big
                    next;
                }
                elsif ($start>0 and $start<=$lines_len and $end > $lines_len){
                    for (my $i=$start;$i<$lines_len+1;$i++){
                        $del_lines{$i} = 1;
                    }
                }
                elsif ($start==0 and $end==0){
                    print("speed: command line: invalid command\n");
                    exit 1;
                }
                elsif ($start<0){
                    print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
                    exit 1;
                }
                elsif ($start>$lines_len and $end>$lines_len){
                    next;
                }

            }
            # 05 Delete a range: DIGIT- REGEX
            elsif ($cmd =~ /^(\d+),\/(.*)\/d$/){
                my $start = $1;
                my $end_regex = $2;
                # $end_regex = slash_meta($end_regex);

                if ($start > 0 and $start <= $lines_len){ # If $start is legal
                    my $end = &find_end_by_digit($start,$end_regex);
                    if ($end>0 and $end<=$lines_len and $end >= $start){ # $end exists
                        for (my $i=$start;$i<$end+1;$i++){
                            $del_lines{$i} = 1;
                        }
                    }
                    else{ # $end doesn't exist, delete since $start
                        for (my $i=$start;$i<$lines_len+1;$i++){
                            $del_lines{$i} = 1;
                        }
                    }
                }
                elsif ($start == 0){
                    my $end = find_end_without_start_digit($end_regex);
                    if ($end == -1){ # If no lines matched, delete everything
                        $end = $lines_len;
                    }
                    for (my $i=1; $i<$end+1;$i++){
                        $del_lines{$i} = 1;
                    }
                }
                elsif ($start > $lines_len){ # If $start is too big, delete nothing
                    next;
                }
            }
            # 06 Delete a range: REGEX - DIGIT
            elsif ($cmd =~ /^\/(.*)\/,(\d+)d$/){
                my $start_regex = $1;
                # $start_regex = slash_meta($start_regex);
                my $end = $2;

                if ($end>0 and $end<=$lines_len){ # If $end is legal
                    my $start = find_start_by_digit($start_regex,$end);
                    if ($start>0 and $start<=$end){ # If $start exists
                        for (my $i = $start; $i<$end+1;$i++){
                            $del_lines{$i} = 1;
                        }
                    }
                    else{ # If $start does not exist, delete nothing
                        next;
                    }
                }
                elsif ($end == 0){ # Delete all lines matched the $start_regex
                    for (my $i=0; $i<$lines_len;$i++){
                        my $line = $lines[$i];
                        if ($line =~ /$start_regex/){
                            $del_lines{$i+1} = 1;
                        }
                    }
                }
                elsif ($end > $lines_len){ # Delete all lines since the first match of $start_regex
                    my $start = find_start_without_end_digit($start_regex);
                    for (my $i=$start;$i<$lines_len+1;$i++){
                        $del_lines{$i} = 1;
                    }
                }
            }
            # 07 Delete a range: REGEX - REGEX
            elsif ($cmd =~ /^\/(.*)\/,\/(.*)\/d$/){
                my $start_regex = $1;
                my $end_regex = $2;
                my $delete_flag = 0;

                for (my $i=0;$i<$lines_len;$i++){
                    my $line = $lines[$i];
                    if ($line =~ /$start_regex/ and $delete_flag == 0){
                        $delete_flag = 1;
                    }
                    elsif ($line =~ /$end_regex/ and $delete_flag == 1){
                        $del_lines{$i+1} = 1;
                        $delete_flag = 0;
                    }

                    if ($delete_flag == 1){
                        $del_lines{$i+1} = 1;
                    }
                }
            }
            else{
                print("speed: command line: invalid command\n");
                exit 1;
            }
        }  
    }
}

# TODO: find the lowest number that match the quite line number
sub get_cmd_q_line {
    my ($cmd) = @_;
    if ($cmd =~ /(\d+)q/){
        return ($1);
    }
    elsif($cmd =~ /^\/(.*)\/q$/){
        my $pattern = $1;
        my $i = 1;
        # We assume the input does not exceed 10000 lines
        while ($i < 100000){
            if ($i =~ /$pattern/){
                return ($i);
            }
            $i +=1;
        }
        if ($i == 100000){
            return (-1);
        }
    }

}


sub update_quit_line {
    my (@commands) = @_;
    foreach $item (@commands){
       my $cmd = $item->[0];
       my $type = $item->[1];
       if ($type eq 'q'){
           my $cmdQuitLine = get_cmd_q_line ($cmd);
           if ($cmdQuitLine == -1){
               next;
           }
           if ($quit_line_num > $cmdQuitLine and $quit_line_num >0){
               $quit_line_num = $cmdQuitLine;
           }
           elsif ($quit_line_num == -1){
               $quit_line_num = $cmdQuitLine;
           }
       } 
    }
}


############ SUB ROUTINES ENDS ################

our $i_flag = 0;
our $f_flag = 0;
our $n_flag = 0;
our @argvs = check_flags(@ARGV);


our $EXIT_STATUS = 0;
our $DELETE_STATUS = 0;

our %del_lines;
our $quit_line_num = -1;

our $sed_commands = chomp_semicolon($argvs[0]);
our @inter_commands = get_commands($sed_commands); 

my @commands = commands_with_type(@inter_commands);
&update_quit_line(@commands);

our $LINE_NUM = 1;
our @lines; 

while (my $line = <STDIN>){
    push(@lines,$line);
    if ($LINE_NUM == $quit_line_num){
        last;
    }
    $LINE_NUM += 1;
}

$LINE_NUM = 1;
our $lines_len = @lines;

&update_del_lines(@commands);

# Update the del_lines hash 
# TODO: update_del_lines(@commands);
foreach my $line (@lines) {
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

