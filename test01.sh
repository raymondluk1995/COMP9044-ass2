#!/bin/dash 

# The tests are basically from the subset 0 in the project specification

clear
export PATH=$PATH:$(pwd)

seq 1 5 | speed.pl '3q'
echo "-------------test 01"
seq 9 20 | speed.pl '3q'
echo "-------------test 02"
seq 10 15 | speed.pl '/.1/q' 
echo "-------------test 03"
seq 500 600 | speed.pl '/^.+5$/q'
echo "-------------test 04"
seq 100 1000 | speed.pl '/1{3}/q'
echo "-------------test 05"
seq 1 5 | speed.pl 2p 
echo "-------------test 06"
seq 7 11 | speed.pl 4p 
echo "-------------test 07"
seq 65 85 | speed.pl '/^7/p'
echo "-------------test 08"
seq 1 5|speed.pl 'p'
echo "-------------test 09"
seq 1 5|speed.pl '4d'
echo "-------------test 10"
seq 1 100|speed.pl '/.{2}/d'
echo "-------------test 11"
seq 11 20 | speed.pl '/[2468]/d'
echo "-------------test 12"
seq 1 5 | speed.pl 's/[15]/zzz/'
echo "-------------test 13"
seq 10 20 | speed.pl 's/[15]/zzz/'
echo "-------------test 14"
seq 100 111 | speed.pl 's/11/zzz/'
echo "-------------test 15"
echo Hello Andrew | speed.pl 's/e//'
echo "-------------test 16"
echo Hello Andrew | speed.pl 's/e//g'
echo "-------------test 17"
seq 11 19 | speed.pl '5s/1/2/'
echo "-------------test 18"
seq 51 60 | speed.pl '5s/5/9/g'
echo "-------------test 19"
seq 100 111 | speed.pl '/1.1/s/1/-/g'
echo "-------------test 20"
seq 1 5|speed.pl -n '3p'
echo "-------------test 21"
seq 2 3 20 |speed.pl -n '/^1/p'
echo "-------------test 22"
seq 1 5| speed.pl '4q;/2/d'
echo "-------------test 23"
seq 1 5 | speed.pl '4q;/2/d;3q'
echo "-------------test 24"
yes | speed.pl 3q
echo "-------------test 25"
