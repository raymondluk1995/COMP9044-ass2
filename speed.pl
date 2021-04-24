#!/usr/bin/perl -w 

############ SUB ROUTINES START ###############
sub check_flags {
    my (@argvs) = @_;
    my @new_argvs;
    foreach $item (@argvs){
        if ($item =~ /^\-\-/){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
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
                print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
                exit 1;
            }
        }
        else{
            push (@new_argvs,$item);
        }

    }
    return (@new_argvs);
}

sub my_print {
    my ($line,$OH) = @_;
    if ($OH eq "STDOUT"){
        print("$line\n");
    }
    else{
        print $OH "$line\n";
    }
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
    my $anchor = 0;
    my $re_flag = 0; #regex flag
    my $s_re_flag = 0; # s command's regex flag
    my $dm = '/'; # The default delimiter for regex
    my $s_dm = "/"; # The regex delimiter of s command 
    my $s_cmd_prepare = 0; # If $s_dm is also '/', we need to check whether a s_regex is going to start

    for ($i=0;$i<$addr_len;$i=$i+1){
        my $ch = $chars[$i];
        if ($ch eq $dm and $s_cmd_prepare == 0){ # A normal regex dm is met
            if ($i == 0 ){ # It must be a start of regex
                $re_flag = 1;
            }
            elsif ($chars[$i-1] ne '\\' and $s_re_flag == 0){ # This is a valid slash for normal regex
                $re_flag = 1 - $re_flag;
            } 
        }
        elsif ($ch eq 's' and $i<$addr_len-1 and $re_flag == 0 and $s_re_flag == 0){ # Not in a regex and we meet an 's', it should be a 's' command
            $s_dm = $chars[$i+1];
            $s_cmd_prepare =1;
        }
        elsif ($ch eq $s_dm and $chars[$i-1] ne '\\'){
            $s_re_flag = ($s_re_flag+1)%3;
            if ($s_re_flag == 0){
                $s_cmd_prepare = 0; # s regex ends now
            }
        }
        elsif ($ch eq ';' and $s_re_flag==0 and $re_flag==0){
            my $str = substr($addr,$anchor,$i-$anchor);
            push(@commands,$str) if $str ne "";
            $anchor = $i +1;
        }
    }
    my $str = substr($addr,$anchor,$addr_len-$anchor); # Get the last command
    push(@commands,$str) if $str ne "";
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
    elsif ($cmd =~ /^((\d+|\/.*\/)(,(\d+|\/.*\/))?)?s/){
        return ("s");
    }
    elsif ($cmd =~ /^\s*(((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?)?\s*a/){
        return ("a");
    }
    elsif ($cmd =~ /^\s*(((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?)?\s*i/){
        return ("i");
    }
    elsif ($cmd =~ /^\s*(((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?)?\s*c/){
        return ("c");
    }
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
}

# Remove all spaces in a command except in regex
sub rm_space {
    my ($cmd) = @_;
    $cmd_len = length($cmd);
    my @chars = split(//,$cmd);
    my $re_flag = 0; #regex flag
    my $s_re_flag = 0; # s command's regex flag
    my $dm = '/'; # The default delimiter for regex
    my $s_dm = "/"; # The regex delimiter of s command 
    my $s_cmd_prepare = 0; # If $s_dm is also '/', we need to check whether a s_regex is going to start
    my $new_cmd = "";

    for (my $i =0; $i < $cmd_len;$i=$i+1){
        my $ch = $chars[$i];
        if ($ch eq $dm and $s_cmd_prepare == 0){ # A normal regex dm is met
            if ($i == 0 ){ # It must be a start of regex
                $re_flag = 1;
            }
            elsif ($chars[$i-1] ne '\\' and $s_re_flag == 0){ # This is a valid slash for normal regex
                $re_flag = 1 - $re_flag;
            } 
        }
        elsif ($ch eq 's' and $i<$cmd_len-1 and $re_flag == 0 and $s_re_flag == 0){ # Not in a regex and we meet an 's', it should be a 's' command
            $s_dm = $chars[$i+1];
            $s_cmd_prepare =1;
        }
        elsif ($ch eq $s_dm and $chars[$i-1] ne '\\'){
            $s_re_flag = ($s_re_flag+1)%3;
            if ($s_re_flag == 0){
                $s_cmd_prepare = 0; # s regex ends now
            }
        }
        elsif ($ch eq ' ' and $s_re_flag==0 and $re_flag==0){
            next;
        }
        $new_cmd = $new_cmd . $ch;
    }
    return ($new_cmd);
}

# Remove comments
sub rm_comment {
    my ($cmd) = @_;
    $cmd_len = length($cmd);
    my @chars = split(//,$cmd);
    my $re_flag = 0; #regex flag
    my $s_re_flag = 0; # s command's regex flag
    my $dm = '/'; # The default delimiter for regex
    my $s_dm = "/"; # The regex delimiter of s command 
    my $s_cmd_prepare = 0; # If $s_dm is also '/', we need to check whether a s_regex is going to start
    my $comment_anchor = 0;
    my $new_cmd = "";

    for (my $i =0; $i < $cmd_len;$i=$i+1){
        my $ch = $chars[$i];
        if ($ch eq $dm and $s_cmd_prepare == 0){ # A normal regex dm is met
            if ($i == 0 ){ # It must be a start of regex
                $re_flag = 1;
            }
            elsif ($chars[$i-1] ne '\\' and $s_re_flag == 0){ # This is a valid slash for normal regex
                $re_flag = 1 - $re_flag;
            } 
        }
        elsif ($ch eq 's' and $i<$cmd_len-1 and $re_flag == 0 and $s_re_flag == 0){ # Not in a regex and we meet an 's', it should be a 's' command
            $s_dm = $chars[$i+1];
            $s_cmd_prepare =1;
        }
        elsif ($ch eq $s_dm and $chars[$i-1] ne '\\'){
            $s_re_flag = ($s_re_flag+1)%3;
            if ($s_re_flag == 0){
                $s_cmd_prepare = 0; # s regex ends now
            }
        }
        elsif ($ch eq '#' and $s_re_flag==0 and $re_flag==0){
            last;
        }
        $new_cmd = $new_cmd . $ch;
    }
    return ($new_cmd);
}

# Return an array with each element is an array's reference revealing a command and its type.
sub commands_with_type {
    my (@cmds) = @_;
    my @new_cmds;
    foreach my $cmd (@cmds){
        if ($cmd !~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*a/
            and $cmd !~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*i/
            and $cmd !~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*c/){
            $cmd = rm_space($cmd);
        }    
        $cmd = rm_comment($cmd);
        my $type = get_command_type($cmd);
        my @item = ($cmd,$type);
        push(@new_cmds,\@item);
    }
    return (@new_cmds);
}

# An auxilliary function to print commands with type 
sub print_commands {
    my (@cmds) = @_;
    foreach my $item (@cmds){
        my @arr = @{$item};
        print("@arr\n");
    }
}

# Execution of commands 
sub exec_cmd {
    my ($item,$line,$OH) = @_; # OH stands for output handler
    my $cmd = $item -> [0];
    my $type = $item -> [1];

    if ($type eq "q"){
        $line = q_command($cmd,$line);
    }
    elsif ($type eq "p"){
        $line = p_command($cmd,$line,$OH);
    }
    elsif ($type eq "d"){
        $line = d_command($cmd,$line);
    }
    elsif ($type eq "s"){
        $line = s_command($cmd,$line);
    }
    elsif ($type eq "a"){
        $line = a_command($cmd,$line);
    }
    elsif ($type eq "i"){
        $line = i_command($cmd,$line);
    }
    elsif ($type eq "c"){
        $line = c_command($cmd,$line);
    }
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    
}

# quit command execution
sub q_command {
    my ($cmd,$line) = @_;
    if ($cmd =~ /^(\d+)q$/){
        my $num = $1;
        if ($LINE_NUM == $num){
            $EXIT_STATUS = 1;
        }
    }
    elsif ($cmd =~ /^\/(.*)\/q$/) {
        my $pattern = process_back_slash($1);
        if ($line =~ /$pattern/){
            $EXIT_STATUS = 1;
        }
    }
    elsif ($cmd =~ /^\$q$/){
        if($LAST_LINE_FLAG == 1){
            $EXIT_STATUS = 1;
        }
    }
    else {
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);
}

# print command execution
sub p_command {
    my ($cmd,$line,$OH) = @_;
    # 01 Print a single line - digit
    if ($cmd =~ /^(\d+)p$/){ 
        my $num = $1;
        if ($num == 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($num < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }

        if ($num == $LINE_NUM){
            my_print($line,$OH) if $DELETE_STATUS == 0;
        }
    }
    # 02 Print the last line
    elsif ($cmd =~ /^\$p$/){
        if ($LAST_LINE_FLAG == 1 and $DELETE_STATUS == 0){
            my_print($line,$OH);
        }
    }
    # 03 Print a range: DIGIT - DIGIT 
    elsif ($cmd =~ /^(\d+),(\d+)p$/){
        my $start = $1;
        my $end = $2;
        
        if ($start<0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($end<0){
            print STDERR "speed: command line: invalid command\n";
            exit 1; 
        } 
        elsif ($start==0 and $end==0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($start<=$LINE_NUM and $LINE_NUM<=$end and $DELETE_STATUS == 0){
            my_print($line,$OH) if $DELETE_STATUS == 0;
        }
        elsif ($start > $end and $start==$LINE_NUM and $DELETE_STATUS == 0){
            my_print($line,$OH) if $DELETE_STATUS == 0;
        }
    }
    # 04 Print a range: DIGIT- REGEX
    elsif ($cmd =~ /^(\d+),\/(.*)\/p$/){
        my $start = $1;
        my $end_regex = process_back_slash($2);

        if ($start == 0){
            $start = 1;
        }

        if ($start == $LINE_NUM and $RANGES[$index]{'RANGE_P'}==0){
            $RANGES[$index]{'RANGE_P'} = 1;
            my_print($line,$OH) if $DELETE_STATUS == 0;
            return ($line);
        }
        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_P'}==1){
            my_print($line,$OH) if $DELETE_STATUS == 0;
            $RANGES[$index]{'RANGE_P'} = 0;
        }
        if ($RANGES[$index]{'RANGE_P'}==1){
            my_print($line,$OH) if $DELETE_STATUS == 0;
        }     
    }
    # 05 Print a range: REGEX - DIGIT
    elsif ($cmd =~ /^\/(.*)\/,(\d+)p$/){
        my $start_regex = process_back_slash($1);
        my $end = $2;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_P'}==0 and $LINE_NUM<=$end){
            $RANGES[$index]{'RANGE_P'} = 1;
        }

        # Only print the line matched the $start_regex when $LINE_NUM is greater than $end
        if ($line=~/$start_regex/ and $RANGES[$index]{'RANGE_P'}==0 and $LINE_NUM>$end){
            $RANGES[$index]{'RANGE_RD_P'} = 1;
        }

        if ($RANGES[$index]{'RANGE_P'}==1 or $RANGES[$index]{'RANGE_RD_P'}==1){
            my_print($line,$OH) if $DELETE_STATUS == 0;
        }
        if ($LINE_NUM == $end){
            $RANGES[$index]{'RANGE_P'} = 0;
        } 
    }
    # 06 Print a range: REGEX - REGEX
    elsif ($cmd =~ /^\/(.*)\/,\/(.*)\/p$/){
        my $start_regex = process_back_slash($1);
        my $end_regex = process_back_slash($2);

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_P'}==0 ){
            $RANGES[$index]{'RANGE_P'} = 1;
            my_print($line,$OH) if $DELETE_STATUS == 0;
            return ($line);
        }
        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_P'}==1){
            my_print($line,$OH) if $DELETE_STATUS == 0;
            $RANGES[$index]{'RANGE_P'} = 0;
        } 
        if ($RANGES[$index]{'RANGE_P'}==1){
            my_print($line,$OH) if $DELETE_STATUS == 0;
        }
    } 
    # 07 Print all lines
    elsif ($cmd =~ /^p$/){
        my_print($line,$OH) if $DELETE_STATUS == 0;
    } 
    # 08 Print a single line - regex
    elsif ($cmd =~ /^\/(.*)\/p$/){
        my $pattern = process_back_slash($1);
        if ($line =~ /$pattern/ and $DELETE_STATUS == 0){
            my_print($line,$OH) if $DELETE_STATUS == 0;
        }
    }
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);
}

# delete command execution
sub d_command {
    my ($cmd,$line) = @_;
    # 01 Delete a single line - digit
    if ($cmd =~ /^(\d+)d$/){ 
        my $num = $1;
        if ($num == 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }

        if ($num == $LINE_NUM){
            $DELETE_STATUS = 1;
        }
    }
    # 02 Delete the last line
    elsif ($cmd =~ /^\$d$/){
        if ($LAST_LINE_FLAG == 1){
            $DELETE_STATUS = 1;
        }
    }
    # 03 Delete a range: DIGIT - DIGIT 
    elsif ($cmd =~ /^(\d+),(\d+)d$/){
        my $start = $1;
        my $end = $2;
        
        if ($start<0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($end < 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1; 
        }
        elsif ($start==0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($start<=$LINE_NUM and $LINE_NUM<=$end){
            $DELETE_STATUS = 1;
        }
        elsif ($start > $end and $start==$LINE_NUM){
            $DELETE_STATUS = 1;
        }

    }
    # 04 Delete a range: DIGIT- REGEX
    elsif ($cmd =~ /^(\d+),\/(.*)\/d$/){
        my $start = $1;
        my $end_regex = process_back_slash($2);

        if ($start == 0){
            $start = 1;
        }

        if ($start == $LINE_NUM and $RANGES[$index]{'RANGE_D'}==0){
            $RANGES[$index]{'RANGE_D'} = 1;
            $DELETE_STATUS = 1;
            return ($line);
        }
        
        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_D'} == 1){
            $DELETE_STATUS = 1;
            $RANGES[$index]{'RANGE_D'} = 0;
        } 

        if ($RANGES[$index]{'RANGE_D'}==1){
            $DELETE_STATUS = 1;
        }    
    }
    # 05 Delete a range: REGEX - DIGIT
    elsif ($cmd =~ /^\/(.*)\/,(\d+)d$/){
        my $start_regex = process_back_slash($1);
        my $end = $2;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_D'}==0 and $LINE_NUM<=$end){
            $RANGES[$index]{'RANGE_D'} = 1;
        }

        # Only print the line matched the $start_regex when $LINE_NUM is greater than $end
        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_D'}==0 and $LINE_NUM>$end){
            $RANGES[$index]{'RANGE_RD_D'} = 1;
        }
        if ($RANGES[$index]{'RANGE_D'}==1 or $RANGES[$index]{'RANGE_RD_D'}==1){
            $DELETE_STATUS = 1;
        }
        if ($LINE_NUM == $end){
            $RANGES[$index]{'RANGE_D'} = 0;
        } 
    }
    # 06 Delete a range: REGEX - REGEX
    elsif ($cmd =~ /^\/(.*)\/,\/(.*)\/d$/){
        my $start_regex = process_back_slash($1);
        my $end_regex = process_back_slash($2);

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_D'}==0 ){
            $RANGES[$index]{'RANGE_D'} = 1;
            $DELETE_STATUS =1;
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_D'}==1){
            $DELETE_STATUS = 1;
            $RANGES[$index]{'RANGE_D'} = 0;
        }

        if ($RANGES[$index]{'RANGE_D'}==1){
            $DELETE_STATUS = 1;
        } 
    } 
    # 07 Delete all lines
    elsif ($cmd =~ /^d$/){
        $DELETE_STATUS = 1;
    } 
    # 08 Delete lines matched the regex
    elsif ($cmd =~ /^\/([^,]*)\/d$/){
        my $pattern = $1;
        if ($line =~ /$pattern/){
            $DELETE_STATUS = 1;
        }
    }
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);
}

# Append command 
sub a_command {
    my ($cmd,$line) = @_;
    # 01 If all lines need to be appended
    if ($cmd =~ /^\s*a\s*(.*)$/){
        $line = $line . "\n" . $1;
    }
    # 02 Append after a single line 
    elsif ($cmd =~ /^\s*(\d+)\s*a\s*(.*)$/){
        if ($1 == 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;  
        }
        elsif ($1 < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($LINE_NUM == $1){
            $line = $line . "\n" . $2;
        }
    }
    # 03 Append after the last line
    elsif ($cmd =~ /^\s*\$\s*a\s*(.*)$/){
        if ($LAST_LINE_FLAG == 1){
            $line = $line . "\n" . $1;
        }
    }
    # 04 Append between a range: DIGIT - DIGIT
    elsif ($cmd =~ /^\s*(\d+)\s*,\s*(\d+)\s*a\s*(.*)$/){
        my $start = $1;
        my $end = $2;
        my $new_content = $3;

        if ($start < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($end < 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1; 
        }
        elsif ($start==0 and $end==0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($start<=$LINE_NUM and $LINE_NUM<=$end){
            $line = $line . "\n" . $new_content;
        }
        elsif($start>$end and $start==$LINE_NUM){
            $line = $line . "\n" . $new_content;
        }
    }
    # 05 Append between a range: DIGIT - REGEX
    elsif ($cmd =~ /^\s*(\d+)\s*,\s*\/(.*?)\/\s*a\s*(.*)$/){
        my $start = $1;
        my $end_regex = process_back_slash($2);
        my $new_content = $3;

        if ($start == 0){
            $start = 1;
        }

        if ($start == $LINE_NUM and $RANGES[$index]{'RANGE_A'}==0){
            $RANGES[$index]{'RANGE_A'} = 1;
            $line = $line . "\n" . $new_content;
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_A'}==1){
            $line = $line . "\n" . $new_content;
            $RANGES[$index]{'RANGE_A'} = 0;
        }

        if ($RANGES[$index]{'RANGE_A'}==1){
            $line = $line . "\n" . $new_content;
        }
    }
    # 06 Append a range: REGEX - DIGIT
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*,\s*(\d+)\s*a\s*(.*)$/){
        my $start_regex = process_back_slash($1);
        my $end = $2;
        my $new_content = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_A'}==0 and $LINE_NUM<=$end){
            $RANGES[$index]{'RANGE_A'} = 1;
        }
        # Only print the line matched the $start_regex when $LINE_NUM is greater than $end
        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_A'}==0 and $LINE_NUM>$end){
            $RANGES[$index]{'RANGE_RD_A'} = 1;
        }
        if ($RANGES[$index]{'RANGE_A'}==1 or $RANGES[$index]{'RANGE_RD_A'}==1){
            $line = $line . "\n" . $new_content;
        }
        if ($LINE_NUM == $end){
            $RANGES[$index]{'RANGE_A'} = 0;
        } 
    }
    # 07 Append a range: REGEX - REGEX 
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*,\s*\/(.*?)\/\s*a\s*(.*)$/){
        my $start_regex = process_back_slash($1);
        my $end_regex = process_back_slash($2);
        my $new_content = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_A'}==0 ){
            $RANGES[$index]{'RANGE_A'} = 1;
            $line = $line . "\n" . $new_content; 
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_A'}==1){
            $line = $line . "\n" . $new_content;
            $RANGES[$index]{'RANGE_A'} = 0;
        }

        if ($RANGES[$index]{'RANGE_A'}==1){
            $line = $line . "\n" . $new_content;
        } 
    } 
    # 08 Append lines matched the regex
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*a\s*(.*)$/){
        my $regex = process_back_slash($1);
        my $new_content = $2;

        if ($line =~ /$regex/){
            $line = $line . "\n" . $new_content;
        }
    } 
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);
}

# Insert command 
sub i_command {
    my ($cmd,$line) = @_;
    # 01 If all lines need to be inserted
    if ($cmd =~ /^\s*i\s*(.*)$/){
        $line = $1 . "\n" . $line;
    }
    # 02 Insert after a single line 
    elsif ($cmd =~ /^\s*(\d+)\s*i\s*(.*)$/){
        if ($1 == 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;  
        }
        elsif ($1 < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($LINE_NUM == $1){
            $line = $2 . "\n" . $line;
        }
    }
    # 03 Insert after the last line
    elsif ($cmd =~ /^\s*\$\s*i\s*(.*)$/){
        if ($LAST_LINE_FLAG == 1){
            $line = $1 . "\n" . $line;
        }
    }
    # 04 Insert between a range: DIGIT - DIGIT
    elsif ($cmd =~ /^\s*(\d+)\s*,\s*(\d+)\s*i\s*(.*)$/){
        my $start = $1;
        my $end = $2;
        my $new_content = $3;

        if ($start < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($end < 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1; 
        }
        elsif ($start==0 and $end==0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($start<=$LINE_NUM and $LINE_NUM<=$end){
            $line = $new_content . "\n" . $line;
        }
        elsif($start>$end and $start==$LINE_NUM){
            $line = $new_content . "\n" . $line;
        }
    }
    # 05 Insert between a range: DIGIT - REGEX
    elsif ($cmd =~ /^\s*(\d+)\s*,\s*\/(.*?)\/\s*i\s*(.*)$/){
        my $start = $1;
        my $end_regex = process_back_slash($2);
        my $new_content = $3;

        if ($start == 0){
            $start = 1;
        }

        if ($start == $LINE_NUM and $RANGES[$index]{'RANGE_I'}==0){
            $RANGES[$index]{'RANGE_I'} = 1;
            $line = $new_content . "\n" . $line;
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_I'}==1){
            $line = $new_content . "\n" . $line;
            $RANGES[$index]{'RANGE_I'} = 0;
        }

        if ($RANGES[$index]{'RANGE_I'}==1){
            $line =  $new_content . "\n" . $line;
        }
    }
    # 06 Insert a range: REGEX - DIGIT
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*,\s*(\d+)\s*i\s*(.*)$/){
        my $start_regex = process_back_slash($1);
        my $end = $2;
        my $new_content = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_I'}==0 and $LINE_NUM<=$end){
            $RANGES[$index]{'RANGE_I'} = 1;
        }
        # Only print the line matched the $start_regex when $LINE_NUM is greater than $end
        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_I'}==0 and $LINE_NUM>$end){
            $RANGES[$index]{'RANGE_RD_I'} = 1;
        }
        if ($RANGES[$index]{'RANGE_I'}==1 or $RANGES[$index]{'RANGE_RD_I'}==1){
            $line =  $new_content . "\n" . $line;
        }
        if ($LINE_NUM == $end){
            $line =  $new_content . "\n" . $line;
        } 
    }
    # 07 Change a range: REGEX - REGEX 
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*,\s*\/(.*?)\/\s*i\s*(.*)$/){
        my $start_regex = process_back_slash($1);
        my $end_regex = process_back_slash($2);
        my $new_content = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_I'}==0 ){
            $RANGES[$index]{'RANGE_I'} = 1;
            $line =  $new_content . "\n" . $line;
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_I'}==1){
            $line =  $new_content . "\n" . $line;
            $RANGES[$index]{'RANGE_I'} = 0;
        }

        if ($RANGES[$index]{'RANGE_I'}==1){
            $line =  $new_content . "\n" . $line;
        } 
    } 
    # 08 Change lines matched the regex
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*i\s*(.*)$/){
        my $regex = process_back_slash($1);
        my $new_content = $2;

        if ($line =~ /$regex/){
            $line =  $new_content . "\n" . $line;
        }
    } 
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);
}

# Change command 
sub c_command {
    my ($cmd,$line) = @_;
    # 01 If all lines need to be changed
    if ($cmd =~ /^\s*c\s*(.*)$/){
        $line = $1;
    }
    # 02 Change after a single line 
    elsif ($cmd =~ /^\s*(\d+)\s*c\s*(.*)$/){
        if ($1 == 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;  
        }
        elsif ($1 < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($LINE_NUM == $1){
            $line = $2;
        }
    }
    # 03 Change after the last line
    elsif ($cmd =~ /^\s*\$\s*c\s*(.*)$/){
        if ($LAST_LINE_FLAG == 1){
            $line = $1;
        }
    }
    # 04 Change between a range: DIGIT - DIGIT
    elsif ($cmd =~ /^\s*(\d+)\s*,\s*(\d+)\s*c\s*(.*)$/){
        my $start = $1;
        my $end = $2;
        my $new_content = $3;

        if ($start < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($end < 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1; 
        }
        elsif ($start==0 and $end==0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($start<=$LINE_NUM and $LINE_NUM<=$end){
            $line = $new_content;
        }
        elsif($start>$end and $start==$LINE_NUM){
            $line = $new_content;
        }
    }
    # 05 Change between a range: DIGIT - REGEX
    elsif ($cmd =~ /^\s*(\d+)\s*,\s*\/(.*?)\/\s*i\s*(.*)$/){
        my $start = $1;
        my $end_regex = process_back_slash($2);
        my $new_content = $3;

        if ($start == 0){
            $start = 1;
        }

        if ($start == $LINE_NUM and $RANGES[$index]{'RANGE_C'}==0){
            $RANGES[$index]{'RANGE_C'} = 1;
            $line = $new_content;
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_C'}==1){
            $line = $new_content;
            $RANGES[$index]{'RANGE_C'} = 0;
        }

        if ($RANGES[$index]{'RANGE_C'}==1){
            $line =  $new_content;
        }
    }
    # 06 Change a range: REGEX - DIGIT
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*,\s*(\d+)\s*c\s*(.*)$/){
        my $start_regex = process_back_slash($1);
        my $end = $2;
        my $new_content = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_C'}==0 and $LINE_NUM<=$end){
            $RANGES[$index]{'RANGE_C'} = 1;
        }
        # Only print the line matched the $start_regex when $LINE_NUM is greater than $end
        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_C'}==0 and $LINE_NUM>$end){
            $RANGES[$index]{'RANGE_RD_C'} = 1;
        }
        if ($RANGES[$index]{'RANGE_C'}==1 or $RANGES[$index]{'RANGE_RD_C'}==1){
            $line =  $new_content;
        }
        if ($LINE_NUM == $end){
            $line =  $new_content;
        } 
    }
    # 07 Change a range: REGEX - REGEX 
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*,\s*\/(.*?)\/\s*c\s*(.*)$/){
        my $start_regex = process_back_slash($1);
        my $end_regex = process_back_slash($2);
        my $new_content = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_C'}==0 ){
            $RANGES[$index]{'RANGE_C'} = 1;
            $line =  $new_content;
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_C'}==1){
            $line =  $new_content;
            $RANGES[$index]{'RANGE_C'} = 0;
        }

        if ($RANGES[$index]{'RANGE_C'}==1){
            $line =  $new_content;
        } 
    } 
    # 08 Change lines matched the regex
    elsif ($cmd =~ /^\s*\/(.*?)\/\s*c\s*(.*)$/){
        my $regex = process_back_slash($1);
        my $new_content = $2;

        if ($line =~ /$regex/){
            $line =  $new_content;
        }
    } 
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);
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

sub process_back_slash {
    my ($pattern) = @_;
    my @pat_chars = split(//,$pattern);

    my $result = "";
    my $i = 0;
    while($i<@pat_chars){
        my $ch = $pat_chars[$i];
        if ($ch ne '\\'){
            $result = $result . $ch;
            $i+=1;
        }
        else{
            if ($i==@argvs-1){
                print STDERR "speed: command line: invalid command\n";
                exit 1;  
            }
            $result .= $pat_chars[$i+1];
            $i+=2;
        }
    }
    return ($result);
}

# Execute the s real command
sub s_real_command {
    my ($cmd, $line) = @_;
    my $cmd_len = length($cmd);
    # Then length should be greater than 3
    if ($cmd_len < 4){
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }

    my @cmdChars = split(//,$cmd);
    # dm stands for delimiter
    my $dm = $cmdChars[1];

    # If the ending of command is not 'g' or the delimiter, the s command is invalid
    if ($cmdChars[-1] ne 'g' && $cmdChars[-1] ne $dm){
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }

    # If the ending of command is 'g' but the penultimate character is not delimiter 
    if ($cmdChars[-1] eq 'g' && $cmdChars[-2] ne $dm){
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    } 

    my @patterns = get_s_command_patterns($cmd,$dm);
    my $pat1 = process_back_slash($patterns[0]);
    my $pat2 = process_back_slash($patterns[1]);


    if ($cmdChars[-1] eq 'g'){
        $line =~ s/$pat1/$pat2/g;
    }
    elsif($cmdChars[-1] eq $dm ){
        $line =~ s/$pat1/$pat2/;
    }
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);
}

# Execute the s command
sub s_command {
    my ($cmd,$line) = @_;
    # 01 If all lines need to be substitued
    if ($cmd =~ /^s/){
        $line = s_real_command($cmd,$line);
    }
    # 02 Subsitute a single line - digit
    elsif ($cmd =~ /^(\d+)(s.*)$/){
        my $num = $1;
        my $sCmd = $2;

        if ($num == 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1; 
        }
        elsif ($num < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($LINE_NUM == $num){
            $line = s_real_command($sCmd,$line);
        }
    }
    # 03 Substitute the last line
    elsif ($cmd =~ /^\$(s.*)$/){
        my $sCmd = $1;
        if ($LAST_LINE_FLAG ==1){
            $line = s_real_command($sCmd,$line);
        }
    }
    # 04 Substitute a range: DIGIT - DIGIT
    elsif ($cmd =~ /^(\d+),(\d+)(s.*)$/){
        my $start = $1;
        my $end = $2;
        my $sCmd = $3;

        if ($start < 0){
            print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
            exit 1;
        }
        elsif ($end < 0){
            print STDERR "speed: command line: invalid command\n";
            exit 1; 
        }
        elsif ($start==0 and $end==0){
            print STDERR "speed: command line: invalid command\n";
            exit 1;
        }
        elsif ($start<=$LINE_NUM and $LINE_NUM<=$end){
            $line = s_real_command($sCmd,$line);
        }
        elsif($start>$end and $start==$LINE_NUM){
            $line = s_real_command($sCmd,$line);
        }
    }
    # 05 Substitute a range: DIGIT- REGEX
    elsif ($cmd =~ /^(\d+),\/(.*)\/(s.*)$/){
        my $start = $1;
        my $end_regex = process_back_slash($2);
        my $sCmd = $3;

        if ($start == 0){
            $start = 1;
        }

        if ($start == $LINE_NUM and $RANGES[$index]{'RANGE_S'}==0){
            $RANGES[$index]{'RANGE_S'} = 1;
            $line = s_real_command($sCmd,$line);
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_S'}==1){
            $line = s_real_command($sCmd,$line);
            $RANGES[$index]{'RANGE_S'} = 0;
        }

        if ($RANGES[$index]{'RANGE_S'}==1){
            $line = s_real_command($sCmd,$line);
        }
        return ($line);
    }
    # 06 Substitute a range: REGEX - DIGIT
    elsif ($cmd =~ /^\/(.*)\/,(\d+)(s.*)$/){
        my $start_regex = process_back_slash($1);
        my $end = $2;
        my $sCmd = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_S'}==0 and $LINE_NUM<=$end){
            $RANGES[$index]{'RANGE_S'} = 1;
        }

        # Only print the line matched the $start_regex when $LINE_NUM is greater than $end
        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_S'}==0 and $LINE_NUM>$end){
            $RANGES[$index]{'RANGE_RD_S'} = 1;
        }
        if ($RANGES[$index]{'RANGE_S'}==1 or $RANGES[$index]{'RANGE_RD_S'}==1){
            $line = s_real_command($sCmd,$line); 
        }
        if ($LINE_NUM == $end){
            $RANGES[$index]{'RANGE_S'} = 0;
        } 
    }
    # 07 Substitute a range: REGEX - REGEX 
    elsif ($cmd =~ /^\/(.*)\/,\/(.*)\/(s.*)$/){
        my $start_regex = process_back_slash($1);
        my $end_regex = process_back_slash($2);
        my $sCmd = $3;

        if ($line =~ /$start_regex/ and $RANGES[$index]{'RANGE_S'}==0 ){
            $RANGES[$index]{'RANGE_S'} = 1;
            $line = s_real_command($sCmd,$line);
            return ($line);
        }

        if ($line =~ /$end_regex/ and $RANGES[$index]{'RANGE_S'}==1){
            $line = s_real_command($sCmd,$line);
            $RANGES[$index]{'RANGE_S'} = 0;
        }

        if ($RANGES[$index]{'RANGE_S'}==1){
            $line = s_real_command($sCmd,$line);
        } 
    } 
    # 08 Substitute lines matched the regex
    elsif ($cmd =~ /^\/(.*?)\/(s.*)$/){
        my $regex = process_back_slash($1);
        my $sCmd = $2;

        if ($line =~ /$regex/){
            $line = s_real_command($sCmd,$line);
        }
    } 
    else{
        print STDERR "speed: command line: invalid command\n";
        exit 1;
    }
    return ($line);

}

sub initialize_ranges {
    my($cmd_len) = @_;
    for (my $i=0; $i<$cmd_len;$i++){
        my %hash = ('RANGE_P'=>0,
                    'RANGE_RD_P'=>0,
                    'RANGE_D'=>0,
                    'RANGE_RD_D'=>0,
                    'RANGE_S'=>0,
                    'RANGE_RD_S'=>0,
                    'RANGE_A'=>0,
                    'RANGE_RD_A'=>0,
                    'RANGE_I'=>0,
                    'RANGE_RD_I'=>0,
                    'RANGE_C'=>0,
                    'RANGE_RD_C'=>0);
        push(@RANGES,\%hash);
    }
}

sub stdin_process {
    my ($cmd) = @_;
    our $sed_commands = chomp_semicolon($cmd);
    our @inter_commands = get_commands($sed_commands); 
    our @commands = commands_with_type(@inter_commands);
    $LINE_NUM = 1;
    my $commands_len = @commands;
    initialize_ranges($commands_len);

    while (my $line = <STDIN>){
        $EXIT_STATUS = 0;
        $DELETE_STATUS = 0;
        $LAST_LINE_FLAG = 0;
        chomp $line;
        my $range_c_flag = 0;

        foreach my $range (@RANGES){
            $range{'RANGE_RD_D'} = 0;
        }

        if (eof){
            $LAST_LINE_FLAG = 1;
        }
        
        for ($index=0;$index<$commands_len;$index++){
            my $item = $commands[$index];
            $RANGES[$index]{'RANGE_RD_P'} = 0;
            $RANGES[$index]{'RANGE_RD_S'} = 0;
            $RANGES[$index]{'RANGE_RD_A'} = 0;
            $RANGES[$index]{'RANGE_RD_I'} = 0;
            $RANGES[$index]{'RANGE_RD_C'} = 0;
            $line = exec_cmd($item,$line,"STDOUT");
            if ($RANGES[$index]{'RANGE_C'}==1){
                $range_c_flag = 1;
            }
            if ($EXIT_STATUS==1){
                last;
            }
        }

        if ($n_flag==0 and $DELETE_STATUS==0 and $range_c_flag==0){
            my_print($line,"STDOUT");
        }

        if ($EXIT_STATUS==1 and $DELETE_STATUS==0){
            exit 0;
        }

        $LINE_NUM += 1;
    }
}

sub file_process {
    my ($cmd_line) = @_;
    our $sed_commands = chomp_semicolon($cmd_line);
    our @inter_commands = get_commands($sed_commands); 
    our @commands = commands_with_type(@inter_commands);
    $LINE_NUM = 1;
    my $commands_len = @commands;
    initialize_ranges($commands_len);

    for (my $i=0;$i<@argvs;$i++){
        my $input_file = $argvs[$i];
        unless (-r $input_file){
            print STDERR "speed: error\n";
            exit 1;
        }
        open($FH,'<',$input_file);
        open($OH,'>',"temp.txt");
        while (my $line = <$FH>){
            $EXIT_STATUS = 0;
            $DELETE_STATUS = 0;
            $LAST_LINE_FLAG = 0;
            chomp $line;
            my $range_c_flag = 0;

            foreach my $range (@RANGES){
                $range{'RANGE_RD_D'} = 0;
            }

            if (eof and $i==(@argvs-1)){
                $LAST_LINE_FLAG = 1;
            }

            for ($index=0;$index<$commands_len;$index++){
                my $item = $commands[$index];
                $RANGES[$index]{'RANGE_RD_P'} = 0;
                $RANGES[$index]{'RANGE_RD_S'} = 0;
                $RANGES[$index]{'RANGE_RD_A'} = 0;
                $RANGES[$index]{'RANGE_RD_I'} = 0;
                $RANGES[$index]{'RANGE_RD_C'} = 0;
                $line = exec_cmd($item,$line,$OH);
                if ($RANGES[$index]{'RANGE_C'}==1){
                    $range_c_flag = 1;
                }
                if ($EXIT_STATUS==1){
                    last;
                }
            }

            if ($n_flag==0 and $DELETE_STATUS==0 and $range_c_flag==0){
                my_print($line,$OH);
            }

            if ($EXIT_STATUS==1 and $DELETE_STATUS==0){
                exit 0;
            }

            $LINE_NUM += 1;
        }
        close($FH);
        close($OH);
        unlink $input_file;
        rename("temp.txt",$input_file) || die ("Rename fails!\n");
    }
}

sub file_stdout_process {
    my ($cmd) = @_;
    our $sed_commands = chomp_semicolon($cmd);
    our @inter_commands = get_commands($sed_commands); 
    our @commands = commands_with_type(@inter_commands);
    $LINE_NUM = 1;
    my $commands_len = @commands;
    initialize_ranges($commands_len);

    for (my $i=1;$i<@argvs;$i++){
        my $input_file = $argvs[$i];
        unless (-r $input_file){
            print STDERR "speed: error\n";
            exit 1;
        }

        open($FH,'<',$input_file);
        while (my $line = <$FH>){
            $EXIT_STATUS = 0;
            $DELETE_STATUS = 0;
            $LAST_LINE_FLAG = 0;
            chomp $line;
            my $range_c_flag = 0;
            foreach my $range (@RANGES){
                $range{'RANGE_RD_D'} = 0;
            }

            if (eof and $i==(@argvs-1)){
                $LAST_LINE_FLAG = 1;
            }

            for ($index=0;$index<$commands_len;$index++){
                my $item = $commands[$index];
                $RANGES[$index]{'RANGE_RD_P'} = 0;
                $RANGES[$index]{'RANGE_RD_S'} = 0;
                $RANGES[$index]{'RANGE_RD_A'} = 0;
                $RANGES[$index]{'RANGE_RD_I'} = 0;
                $RANGES[$index]{'RANGE_RD_C'} = 0;
                $line = exec_cmd($item,$line,"STDOUT");
                if ($RANGES[$index]{'RANGE_C'}==1){
                    $range_c_flag = 1;
                }
                if ($EXIT_STATUS==1){
                    last;
                }
            }

            if ($n_flag==0 and $DELETE_STATUS==0 and $range_c_flag==0){
                my_print($line,"STDOUT");
            }

            if ($EXIT_STATUS==1 and $DELETE_STATUS==0){
                exit 0;
            }

            $LINE_NUM += 1;
        }
        close($FH);
    }
}

############ SUB ROUTINES ENDS ################
our $i_flag = 0;
our $f_flag = 0;
our $n_flag = 0;
our @argvs = check_flags(@ARGV);
our $LINE_NUM = 1;
our $index = 0; # index of commands array

if (@argvs == 0){
    print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
    exit 1;
}

our $EXIT_STATUS = 0;
our $DELETE_STATUS = 0;
our $LAST_LINE_FLAG = 0;
our @RANGES;

if ($i_flag == 0){
    # When the input is coming from STDIN
    if ($f_flag == 0 and @argvs==1){
        stdin_process($argvs[0]);
    }
    # When the input is coming from files
    elsif ($f_flag==0 and @argvs>1){
        file_stdout_process($argvs[0]);
    }
    # Getting input from STDIN now
    elsif ($f_flag == 1 and @argvs == 1) {
        unless (-r $argvs[0]){
            print STDERR "speed: error\n";
            exit 1;
        }
        my $cmd_line = "";
        open($FH,'<',$argvs[0]);
        while (my $line = <$FH>){
            chomp $line;
            $cmd_line = $cmd_line . $line . ";";
        }
        close ($FH);

        stdin_process($cmd_line);
    }
    # Getting input from files now
    elsif ($f_flag == 1 and @argvs>1) {
        unless (-r $argvs[0]){
            print STDERR "speed: error\n";
            exit 1;
        }
        my $cmd_line = "";
        open($FH,'<',$argvs[0]);
        while (my $line = <$FH>){
            chomp $line;
            $line = rm_comment($line);
            $cmd_line = $cmd_line . $line . ";";
        }
        close ($FH);
        file_stdout_process($cmd_line);
    }

}
# i-flag is 1
else{
    if (@argvs==1){
        print STDERR "usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n";
        exit 1;
    }
    elsif ($f_flag==0 and @argvs>1){
        my $cmd_line = shift(@argvs);
        file_process($cmd_line);
    }
    elsif ($f_flag==1 and @argvs>1){
        my $cmd_file = shift(@argvs);
        unless (-r $cmd_file){
            print STDERR "speed: error\n";
            exit 1;
        }
        my $cmd_line = "";
        open($FH,'<',$cmd_file);
        while (my $line = <$FH>){
            chomp $line;
            $cmd_line = $cmd_line . $line . ";";
        }
        close ($FH);
        file_process($cmd_line);
    }
}



