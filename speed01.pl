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
        print("speed: command line: invalid command\n");
        exit 1;
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
    chomp $cmd;

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
        if (!exists($sub_lines{$LINE_NUM})){ # No need to substitute
            return ($line);
        } 

        # 01 If all lines need to be substitued
        if ($cmd =~ /^s/){
            $line = &s_command($cmd,$line);
        }
        # 02 Subsitute a single line - digit
        elsif ($cmd =~ /^(\d+)(s.*)$/){
            my $targetLine = $1;
            my $sCmd = $2;
            if ($LINE_NUM == $targetLine){
                $line = &s_command($sCmd,$line);
            }
        }
        # 03 Substitute lines matched the regex
        elsif ($cmd =~ /^\/(.*?)\/(s.*)$/){
            my $targetRegex = $1;
            my $sCmd = $2;
            if ($line =~ /$targetRegex/){
                $line = &s_command($sCmd,$line);
            }
        }
        # 04 Substitute the last line
        elsif ($cmd =~ /^\$(s.*)$/){
            my $sCmd = $1;
            if ($LINE_NUM == $lines_len){
               $line = &s_command($sCmd,$line); 
            }
        }
        # 05 Substitute a range: DIGIT - DIGIT
        elsif ($cmd =~ /^(\d+),(\d+)(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        # 06 Substitute a range: DIGTI - REGEX
        elsif ($cmd =~ /(\d+),\/(.*?)\/(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        # 07 Substitute a range: REGEX - DIGIT
        elsif ($cmd =~ /^\/(.*?)\/,(\d+)(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        # 08 Substitute a range: REGEX -REGEX
        elsif ($cmd =~ /^\/(.*?)\/,\/(.*?)\/(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        else{
            print("speed: command line: invalid command\n");
            exit 1;
        }
    }
    return ($line);
}

# quit command execution
sub q_command {
    my ($cmd,$line) = @_;
    if ($LINE_NUM == $quit_line_num){
        $EXIT_STATUS = 1;
    }
}

# print command execution
sub p_command {
    my ($cmd,$line) = @_;
    if (exists($print_lines{$LINE_NUM})){
        print("$line\n");
    }
}

# print command execution version 2: append a line to @new_lines
sub p_command_ver2 {
    my ($cmd,$line) = @_;
    if (exists($print_lines{$LINE_NUM})){
        push(@new_lines,$line);
    }
}

# delete command execution
sub d_command {
    my ($cmd,$line) = @_;
    if (exists($del_lines{$LINE_NUM})){
        $DELETE_STATUS = 1;
    }
}

# Execute a command, and instead printing, append the printing line to the @new_lines
sub exec_cmd_ver2 {
    my ($item,$line) = @_;
    my $cmd = $item -> [0];
    my $type = $item -> [1];
    chomp $cmd;

    if ($type eq "q"){
        &q_command($cmd,$line);
    }
    elsif ($type eq "p"){
        &p_command_ver2($cmd,$line);
    }
    elsif ($type eq "d"){
        &d_command($cmd,$line);
    }
    elsif ($type eq "s"){
        if (!exists($sub_lines{$LINE_NUM})){ # No need to substitute
            return ($line);
        } 

        # 01 If all lines need to be substitued
        if ($cmd =~ /^s/){
            $line = &s_command($cmd,$line);
        }
        # 02 Subsitute a single line - digit
        elsif ($cmd =~ /^(\d+)(s.*)$/){
            my $targetLine = $1;
            my $sCmd = $2;
            if ($LINE_NUM == $targetLine){
                $line = &s_command($sCmd,$line);
            }
        }
        # 03 Substitute lines matched the regex
        elsif ($cmd =~ /^\/(.*?)\/(s.*)$/){
            my $targetRegex = $1;
            my $sCmd = $2;
            if ($line =~ /$targetRegex/){
                $line = &s_command($sCmd,$line);
            }
        }
        # 04 Substitute the last line
        elsif ($cmd =~ /^\$(s.*)$/){
            my $sCmd = $1;
            if ($LINE_NUM == $lines_len){
               $line = &s_command($sCmd,$line); 
            }
        }
        # 05 Substitute a range: DIGIT - DIGIT
        elsif ($cmd =~ /^(\d+),(\d+)(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        # 06 Substitute a range: DIGTI - REGEX
        elsif ($cmd =~ /(\d+),\/(.*?)\/(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        # 07 Substitute a range: REGEX - DIGIT
        elsif ($cmd =~ /^\/(.*?)\/,(\d+)(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        # 08 Substitute a range: REGEX -REGEX
        elsif ($cmd =~ /^\/(.*?)\/,\/(.*?)\/(s.*)$/){
            my $sCmd = $3;
            if (exists($sub_lines{$LINE_NUM}{$sCmd})){
                $line = &s_command($sCmd,$line);
            }
        }
        else{
            print("speed: command line: invalid command\n");
            exit 1;
        }
    }
    return ($line);
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


# Get the two patterns of s command and return them in an array
sub get_s_command_patterns {
    my ($cmd, $dm) = @_;

    my @cmdChars = split(//,$cmd);
    my $cmd_len = length($cmd);

    my $anchor = 2;

    my @result; 

    for (my $i = $anchor; $i<$cmd_len; $i+=1){
        if ($cmdChars[$i] eq $dm and $cmdChars[$i-1] ne '\\'){
            $pat1 = substr($cmd,$anchor,$i-$anchor);
            push(@result,$pat1);
            $anchor = $i + 1;
            last;
        }
    }

    for (my $i = $anchor; $i<$cmd_len; $i+=1){
        if ($cmdChars[$i] eq $dm and $cmdChars[$i-1] ne '\\'){
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

sub insert_to_sub_lines {
    my ($lineNum, $cmd) = @_;
    if (!exists($sub_lines{$lineNum})){
        my %cmds_hash = ($cmd=>1);
        $sub_lines{$lineNum} = \%cmds;
    }
    else{
        my %cmds_hash = %{$sub_lines{$lineNum}};
        $cmds_hash{$cmd} = 1;
        $sub_lines{$lineNum} = \%cmds;
    }
}


sub update_hash_lines {
    my (@commands) = @_;
    foreach my $item (@commands){
        my $cmd = $item ->[0];
        my $type = $item -> [1];

        if ($type eq 'd'){
            # 01 Delete a single line - digit
            if ($cmd =~ /^(\d+)d$/){ 
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
                        # After the range, keep deleting the line matched the $start_regex
                        if ($end+1 <= $lines_len){
                            for (my $i=$end; $i<$lines_len;$i+=1){
                                my $line = $lines[$i];
                                if ($line =~ /$start_regex/){
                                    $del_lines{$i+1} = 1;
                                }
                            }
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
            # 08 Delete all lines
            elsif ($cmd =~ /^d$/){
                for (my $i=0;$i<$lines_len;$i++){
                    $del_lines{$i+1} = 1;
                }
            }
            else{
                print("speed: command line: invalid command\n");
                exit 1;
            }
        }
        elsif ($type eq 'p'){
            # 01 Print a single line - digit
            if ($cmd =~ /^(\d+)p$/){ 
                my $num = $1;
                if ($num == 0){
                    print("speed: command line: invalid command\n");
                    exit 1;
                }
                $print_lines{$num} = 1;
            }
            # 02 Print lines matched the regex
            elsif ($cmd =~ /^\/([^,]*)\/p$/){
                my $pattern = $1;
                # $pattern = slash_meta($pattern);
                for (my $i=0; $i<$lines_len; $i++){
                    my $line = $lines[$i];
                    if ($line =~ /$pattern/){
                        $print_lines{$i+1} = 1;
                    }
                }
            }
            # 03 Print the last line
            elsif ($cmd =~ /^\$p$/){
                $print_lines{$lines_len} = 1;
            }
            # 04 Print a range: DIGIT - DIGIT 
            elsif ($cmd =~ /^(\d+),(\d+)p$/){
                my $start = $1;
                my $end = $2;
                if ($start > $end and $end <= $lines_len and $start <= $lines_len and $start > 0 and $end > 0){ # Only print the $start line
                    $print_lines{$start} = 1;
                }
                elsif ($end < 0){
                    print("speed: command line: invalid command\n");
                    exit 1;
                }
                elsif ($start <= $end and $end <= $lines_len and $start > 0 and $end > 0){ # $start and $end exist
                    for (my $i=$start;$i<$end+1;$i++){
                        $print_lines{$i} = 1;
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
                        $print_lines{$i} = 1;
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
            # 05 Print a range: DIGIT- REGEX
            elsif ($cmd =~ /^(\d+),\/(.*)\/p$/){
                my $start = $1;
                my $end_regex = $2;
                # $end_regex = slash_meta($end_regex);

                if ($start > 0 and $start <= $lines_len){ # If $start is legal
                    my $end = &find_end_by_digit($start,$end_regex);
                    if ($end>0 and $end<=$lines_len and $end >= $start){ # $end exists
                        for (my $i=$start;$i<$end+1;$i++){
                            $print_lines{$i} = 1;
                        }
                    }
                    else{ # $end doesn't exist, print since $start
                        for (my $i=$start;$i<$lines_len+1;$i++){
                            $print_lines{$i} = 1;
                        }
                    }
                }
                elsif ($start == 0){
                    my $end = find_end_without_start_digit($end_regex);
                    if ($end == -1){ # If no lines matched, print everything
                        $end = $lines_len;
                    }
                    for (my $i=1; $i<$end+1;$i++){
                        $print_lines{$i} = 1;
                    }
                }
                elsif ($start > $lines_len){ # If $start is too big, print nothing
                    next;
                }
            }
            # 06 Print a range: REGEX - DIGIT
            elsif ($cmd =~ /^\/(.*)\/,(\d+)p$/){
                my $start_regex = $1;
                # $start_regex = slash_meta($start_regex);
                my $end = $2;

                if ($end>0 and $end<=$lines_len){ # If $end is legal
                    my $start = find_start_by_digit($start_regex,$end);
                    if ($start>0 and $start<=$end){ # If $start exists
                        for (my $i = $start; $i<$end+1;$i++){
                            $print_lines{$i} = 1;
                        }
                    }
                    else{ # If $start does not exist, print nothing
                        next;
                    }
                }
                elsif ($end == 0){ # Print all lines matched the $start_regex
                    for (my $i=0; $i<$lines_len;$i++){
                        my $line = $lines[$i];
                        if ($line =~ /$start_regex/){
                            $print_lines{$i+1} = 1;
                        }
                    }
                }
                elsif ($end > $lines_len){ # Substitute all lines since the first match of $start_regex
                    my $start = find_start_without_end_digit($start_regex);
                    for (my $i=$start;$i<$lines_len+1;$i++){
                        $print_lines{$i} = 1;
                    }
                }
            }
            # 07 Print a range: REGEX - REGEX
            elsif ($cmd =~ /^\/(.*)\/,\/(.*)\/p$/){
                my $start_regex = $1;
                my $end_regex = $2;
                my $print_flag = 0;

                for (my $i=0;$i<$lines_len;$i++){
                    my $line = $lines[$i];
                    if ($line =~ /$start_regex/ and $print_flag == 0){
                        $print_flag = 1;
                    }
                    elsif ($line =~ /$end_regex/ and $print_flag == 1){
                        $print_lines{$i+1} = 1;
                        $print_flag = 0;
                    }

                    if ($print_flag == 1){
                        $print_lines{$i+1} = 1;
                    }
                }
            } 
            # 08 Print all lines
            elsif ($cmd =~ /^p$/){
                for (my $i=0; $i<$lines_len;$i++){
                    $print_lines{$i+1} = 1;
                }
            }
            else{
                print("speed: command line: invalid command\n");
                exit 1;
            }
        }
        elsif ($type eq 's'){
            # 01 If all lines need to be substitued
            if ($cmd =~ /^s/){
                for (my $i=1; $i<$lines_len+1;$i++){
                    &insert_to_sub_lines($i,$cmd);
                }
            }
            # 02 Subsitute a single line - digit
            elsif ($cmd =~ /^(\d+)(s.*)$/){
                my $num = $1;
                my $sCmd = $2;

                if ($num == 0){
                    print("speed: command line: invalid command\n");
                    exit 1; 
                }
                elsif ($num < 0){
                    print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
                    exit 1;
                }
                elsif ($num > $lines_len){
                    next;
                }
                else{
                    &insert_to_sub_lines($num,$sCmd);
                }
            }
            # 03 Substitute lines matched the regex
            elsif ($cmd =~ /^\/(.*?)\/(s.*)$/){
                my $regex = $1;
                my $sCmd = $2;

                for (my $i=0; $i<$lines_len;$i++){
                    my $line = $lines[$i];
                    if ($line =~ /$regex/){
                        &insert_to_sub_lines($i+1,$sCmd);
                    }
                }
            }
            # 04 Substitute the last line
            elsif ($cmd =~ /^\$(s.*)$/){
                my $sCmd = $1;
                &insert_to_sub_lines($lines_len,$sCmd);
            }
            # 05 Substitute a range: DIGIT - DIGIT
            elsif ($cmd =~ /^(\d+),(\d+)(s.*)$/){
                my $start = $1;
                my $end = $2;
                my $sCmd = $3;

                if ($start > $end and $end <= $lines_len and $start <= $lines_len and $start > 0 and $end > 0){ # Only substitute the $start line
                    &insert_to_sub_lines($start,$sCmd);
                }
                elsif ($end < 0){
                    print("speed: command line: invalid command\n");
                    exit 1;
                }
                elsif ($start <= $end and $end <= $lines_len and $start > 0 and $end > 0){ # $start and $end exist
                    for (my $i=$start;$i<$end+1;$i++){
                        &insert_to_sub_lines($i,$sCmd);
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
                        &insert_to_sub_lines($i,$sCmd);
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
            # 06 Substitute a range: DIGTI - REGEX
            elsif ($cmd =~ /(\d+),\/(.*?)\/(s.*)$/){
                my $start = $1;
                my $end_regex = $2;
                my $sCmd = $3;

                if ($start > 0 and $start <= $lines_len){ # If $start is legal
                    my $end = &find_end_by_digit($start,$end_regex);
                    if ($end>0 and $end<=$lines_len and $end >= $start){ # $end exists
                        for (my $i=$start;$i<$end+1;$i++){
                            &insert_to_sub_lines($i,$sCmd);
                        }
                    }
                    else{ # If $end doesn't exist, substitute since $start
                        for (my $i=$start;$i<$lines_len+1;$i++){
                            &insert_to_sub_lines($i,$sCmd);
                        }
                    }
                }
                elsif ($start == 0){
                    my $end = find_end_without_start_digit($end_regex);
                    if ($end == -1){ # If no lines matched, print everything
                        $end = $lines_len;
                    }
                    for (my $i=1; $i<$end+1;$i++){
                        &insert_to_sub_lines($i,$sCmd);
                    }
                }
                elsif ($start > $lines_len){ # If $start is too big, print nothing
                    next;
                }
            }
            # 07 Substitute a range: REGEX - DIGIT
            elsif ($cmd =~ /^\/(.*?)\/,(\d+)(s.*)$/){
                my $start_regex = $1;
                my $end = $2;
                my $sCmd = $3;

                if ($end>0 and $end<=$lines_len){ # If $end is legal
                    my $start = find_start_by_digit($start_regex,$end);
                    if ($start>0 and $start<=$end){ # If $start exists
                        for (my $i = $start; $i<$end+1;$i++){
                            &insert_to_sub_lines($i,$sCmd);
                        }
                    }
                    else{ # If $start does not exist, substitute nothing
                        next;
                    }
                }
                elsif ($end == 0){ # Substitute all lines matched the $start_regex
                    for (my $i=0; $i<$lines_len;$i++){
                        my $line = $lines[$i];
                        if ($line =~ /$start_regex/){
                            &insert_to_sub_lines($i+1,$sCmd);
                        }
                    }
                }
                elsif ($end > $lines_len){ # Substitute all lines since the first match of $start_regex
                    my $start = find_start_without_end_digit($start_regex);
                    for (my $i=$start;$i<$lines_len+1;$i++){
                        &insert_to_sub_lines($i+1,$sCmd);
                    }
                }
            }
            # 08 Substitute a range: REGEX -REGEX
            elsif ($cmd =~ /^\/(.*?)\/,\/(.*?)\/(s.*)$/){
                my $start_regex = $1;
                my $end_regex = $2;
                my $sCmd = $3;
                my $sub_flag = 0;

                for (my $i=0;$i<$lines_len;$i++){
                    my $line = $lines[$i];
                    if ($line =~ /$start_regex/ and $sub_flag == 0){
                        $sub_flag = 1;
                    }
                    elsif ($line =~ /$end_regex/ and $sub_flag == 1){
                        &insert_to_sub_lines($i+1,$scmd);
                        $sub_flag = 0;
                    }

                    if ($sub_flag == 1){
                        &insert_to_sub_lines($i+1,$scmd);
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

sub check_quit_line {
    my ($line,@commands) = @_;
    my $flag = 0;
    foreach my $item (@commands){
        my $cmd = $item->[0];
        my $type = $item->[1];
        if ($type eq 'q'){
            if ($cmd =~ /^(\d+)q$/){
                my $num = $1;
                if ($LINE_NUM == $num){
                    $flag = 1;
                }
            }
            elsif ($cmd =~ /^\/(.*)\/q$/) {
                my $pattern = $1;
                if ($line =~ /$pattern/){
                    $flag = 1;
                }
            }
            else {
                print("speed: command line: invalid command\n");
                exit 1;
            }
        }
    }
    return ($flag);
}

sub print_commands {
    my (@commands) = @_;
    foreach $item (@commands){
        print("$item->[0]   $item->[1]\n");
    }
}

############ SUB ROUTINES ENDS ################

our $i_flag = 0;
our $f_flag = 0;
our $n_flag = 0;
our @argvs = check_flags(@ARGV);

if (@argvs == 0){
    print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
    exit 1;
}

our $EXIT_STATUS = 0;
our $DELETE_STATUS = 0;

our %del_lines;
our %print_lines;
our %sub_lines;
our $quit_line_num = -1;

if ($i_flag == 0){
    # When the input is coming from STDIN
    if ($f_flag == 0 and @argvs==1){
        our $sed_commands = chomp_semicolon(rm_comment($argvs[0]));
        our @inter_commands = get_commands($sed_commands); 
        our @commands = commands_with_type(@inter_commands);
        our $LINE_NUM = 1;
        our @lines; 

        while (my $line = <STDIN>){
            my $flag = &check_quit_line($line,@commands);
            # print("The flag now is $flag\n");
            push(@lines,$line);
            if ($flag == 1){
                $quit_line_num = $LINE_NUM;
                last;
            }
            $LINE_NUM += 1;
        }
    }
    elsif($f_flag==0 and @argvs>1){
        our $sed_commands = chomp_semicolon(rm_comment($argvs[0]));
        our @inter_commands = get_commands($sed_commands); 
        our @commands = commands_with_type(@inter_commands);
        our $LINE_NUM = 1;
        our @lines; 

        for (my $i=1; $i<@argvs;$i++){
            my $input_file = $argvs[$i];
            unless (-r $input_file){
                print("speed: error\n");
                exit 1;
            }

            open ($FH,'<', $input_file);
            my @input_lines = <$FH>;
            close ($FH);

            push(@lines,@input_lines);
        }

        foreach my $line (@lines){
            my $flag = &check_quit_line($line,@commands);
            if ($flag == 1){
                $quit_line_num = $LINE_NUM;
                last;
            }
            $LINE_NUM += 1;
        }
    }
    # Getting input from STDIN now
    elsif ($f_flag == 1 and @argvs == 1) {
        open($FH,'<',$argvs[0]);
        my @f_lines = <$FH>;
        close ($FH);

        my $cmd_line = "";
        foreach my $item (@f_lines){
            chomp $item;
            $item = rm_comment($item);
            $cmd_line = $cmd_line . $item . ";";
        }
        chop($cmd_line);
        our $sed_commands = chomp_semicolon($cmd_line);
        our @inter_commands = get_commands($sed_commands); 
        our @commands = commands_with_type(@inter_commands);
        our $LINE_NUM = 1;
        our @lines; 

        while (my $line = <STDIN>){
            my $flag = &check_quit_line($line,@commands);
            push(@lines,$line);
            if ($flag == 1){
                $quit_line_num = $LINE_NUM;
                last;
            }
            $LINE_NUM += 1;
        }
    }
    # Getting input from files
    elsif ($f_flag == 1 and @argvs > 1){
        open($FH,'<',$argvs[0]);
        my @f_lines = <$FH>;
        close ($FH);

        my $cmd_line = "";
        foreach my $item (@f_lines){
            chomp $item;
            $item = rm_comment($item);
            $cmd_line = $cmd_line . $item . ";";
        }
        chop($cmd_line);
        our $sed_commands = chomp_semicolon($cmd_line);
        our @inter_commands = get_commands($sed_commands); 
        our @commands = commands_with_type(@inter_commands);
        our $LINE_NUM = 1;
        our @lines; 

        for (my $i=1; $i<@argvs;$i++){
            my $input_file = $argvs[$i];
            unless (-r $input_file){
                print("speed: error\n");
                exit 1;
            }

            open ($FH,'<', $input_file);
            my @input_lines = <$FH>;
            close ($FH);

            push(@lines,@input_lines);
        }

        foreach my $line (@lines){
            my $flag = &check_quit_line($line,@commands);
            if ($flag == 1){
                $quit_line_num = $LINE_NUM;
                last;
            }
            $LINE_NUM += 1;
        }

    }

    $LINE_NUM = 1;
    our $lines_len = @lines;
    &update_hash_lines(@commands);

    # Update the del_lines hash 
    # TODO: update_del_lines(@commands);
    foreach my $line (@lines) {
        chomp $line;
        $EXIT_STATUS = 0;
        $DELETE_STATUS = 0;
        foreach my $item (@commands){
            $line = &exec_cmd($item,$line);
            if ($item->[1] eq 'q' and $LINE_NUM == $quit_line_num){
                last;
            }
        }

        if ($n_flag == 0 && $DELETE_STATUS == 0){
            print("$line\n");
        }

        if ($EXIT_STATUS == 1){
            exit 0;
        }

        $LINE_NUM +=1;
    }

}
# When i-flag == 1
else{
    # -i does not work when input comes from <STDIN>
    if ($f_flag == 0 and @argvs==1){
        print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
        exit 1;
    }
    # when addresses come from command line
    elsif ($f_flag==0 and @argvs>1){
        our $sed_commands = chomp_semicolon(rm_comment($argvs[0]));
        our @inter_commands = get_commands($sed_commands); 
        our @commands = commands_with_type(@inter_commands);
        our $LINE_NUM = 1;
        our @all_lines; 

        for (my $i=1; $i<@argvs;$i++){
            my $input_file = $argvs[$i];
            unless (-r $input_file){
                print("speed: error\n");
                exit 1;
            }

            open ($FH,'<', $input_file);
            my @input_lines = <$FH>;
            close ($FH);

            push(@all_lines,\@input_lines);
        }

        for (my $i=0; $i<@all_lines;$i++){
            my $file_lines = $all_lines[$i];
            our @lines = @{$file_lines};
            $LINE_NUM = 1;
            $EXIT_STATUS = 0;
            $DELETE_STATUS = 0;
            %del_lines = ();
            %print_lines = ();
            %sub_lines = ();
            $quit_line_num = -1;

            foreach my $line (@lines){
                my $flag = &check_quit_line($line,@commands);
                if ($flag == 1){
                    $quit_line_num = $LINE_NUM;
                    last;
                }
                $LINE_NUM += 1;
            }

            $LINE_NUM = 1;
            our $lines_len = @lines;
            &update_hash_lines(@commands);

            our @new_lines = ();

            foreach my $line (@lines){
                chomp $line;
                $EXIT_STATUS = 0;
                $DELETE_STATUS = 0;
                foreach my $item (@commands){
                    $line = &exec_cmd_ver2($item,$line);
                    if ($item->[1] eq 'q' and $LINE_NUM == $quit_line_num){
                        last;
                    }
                }
                if ($n_flag == 0 && $DELETE_STATUS == 0){
                    push(@new_lines,$line);
                }

                if ($EXIT_STATUS == 1){
                    exit 0;
                }
                $LINE_NUM +=1;
            }

            $filename = $argvs[$i+1];
            unlink $filename;
            open($OUTPUT,'>',$filename);
            foreach my $line (@new_lines){
                $line = $line . "\n";
                print $OUTPUT $line;
            }
            close ($OUTPUT);
        }
    }
    # two flags cannot have only one argument
    elsif ($f_flag == 1 and @argvs == 1){
        print("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
        exit 1;
    }
    # Getting input from files
    elsif ($f_flag == 1 and @argvs > 1){
        open($FH,'<',$argvs[0]);
        my @f_lines = <$FH>;
        close ($FH);

        my $cmd_line = "";
        foreach my $item (@f_lines){
            chomp $item;
            $item = rm_comment($item);
            $cmd_line = $cmd_line . $item . ";";
        }
        chop($cmd_line);
        our $sed_commands = chomp_semicolon($cmd_line);
        our @inter_commands = get_commands($sed_commands); 
        our @commands = commands_with_type(@inter_commands);
        our $LINE_NUM = 1;
        our @lines; 

        for (my $i=1; $i<@argvs;$i++){
            my $input_file = $argvs[$i];
            unless (-r $input_file){
                print("speed: error\n");
                exit 1;
            }

            open ($FH,'<', $input_file);
            my @input_lines = <$FH>;
            close ($FH);

            push(@lines,@input_lines);
        }

        foreach my $line (@lines){
            my $flag = &check_quit_line($line,@commands);
            if ($flag == 1){
                $quit_line_num = $LINE_NUM;
                last;
            }
            $LINE_NUM += 1;
        }

    }

}

