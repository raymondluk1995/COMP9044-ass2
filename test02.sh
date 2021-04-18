#!/bin/dash 

# This test is for testing delete scenarios

clear
export PATH=$PATH:$(pwd)
echo "---------------------START TESTS"
seq 1 10 | speed.pl 2d
echo "-------------------------test 01"
seq 1 10 | speed.pl '/2/d'
echo "-------------------------test 02"
seq 1 10 | speed.pl '$d'
echo "-------------------------test 03"
seq 1 30 | speed.pl '2 , 8 d'
echo "-------------------------test 04"
seq 1 30 | speed.pl '8 , 2d'
echo "-------------------------test 05"
seq 1 30 | speed.pl '0d'
echo "-------------------------test 06"
seq 1 30 | speed.pl '0,4d'
echo "-------------------------test 07"
seq 1 30 | speed.pl '-1,4d'
echo "-------------------------test 08"
seq 1 30 | speed.pl '4,-4d'
echo "-------------------------test 09"
seq 1 30 | speed.pl '50,-4d'
echo "-------------------------test 10"
seq 1 30 | speed.pl '0,0d'
echo "-------------------------test 11"
seq 1 30 | speed.pl '3,/3/d'
echo "-------------------------test 12"
seq 1 30 | speed.pl '3,/40/d'
echo "-------------------------test 13"
seq 1 30 | speed.pl '0,/4/d'
echo "-------------------------test 14"
seq 1 30 | speed.pl '0,/40/d'
echo "-------------------------test 15"
seq 1 30 | speed.pl '40,/40/d'
echo "-------------------------test 16"
seq 1 30 | speed.pl '/4/,10d'
echo "-------------------------test 17"
seq 1 30 | speed.pl '/40/,10d'
echo "-------------------------test 18"
seq 1 30 | speed.pl '/4/,0d'
echo "-------------------------test 19"
seq 1 30 | speed.pl '/4/,40d'
echo "-------------------------test 20"
seq 1 30 | speed.pl '/2/,/4/d'
echo "-------------------------test 21"
seq 1 30 | speed.pl '/200/,/4/d'
echo "-------------------------test 22"
seq 1 30 | speed.pl '/2/,/40/d'
echo "-------------------------test 23"
seq 1 30 | speed.pl '/200/,/40/d'
echo "-------------------------test 24"