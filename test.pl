#!/usr/bin/perl -w


$string = '/3/ , /5  /a hello world abc';
if ($string =~ /^\s*((\d+)|(\/.*?\/))\s*(,(\d+)|(\/.*?\/))?\s*a/){
    print("blah\n");
}
