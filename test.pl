#!/usr/bin/perl -w


$string = "3, 17  d  # comment";

if ($string !~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*a/){
    if ($string !~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*i/){
        print("here1\n");
    }
    else{
        print("here2\n");
    }
}
else{
    print("here3\n");
}

if ($string =~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*a/){
    print("here4\n");
}

if ($string =~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*i/){
    print("here5\n");
}
