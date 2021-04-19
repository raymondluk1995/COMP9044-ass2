#!/bin/dash 

# This test is for testing delete scenarios

export PATH=$PATH:$(pwd)
echo "---------------------START TESTS"
seq 1 10 | 2041 speed 2d
echo "-------------------------test 01"
seq 1 10 | 2041 speed '/2/d'
echo "-------------------------test 02"
seq 1 10 | 2041 speed '$d'
echo "-------------------------test 03"
seq 1 30 | 2041 speed '2 , 8 d'
echo "-------------------------test 04"
seq 1 30 | 2041 speed '8 , 2d'
echo "-------------------------test 05"
seq 1 30 | 2041 speed '0d'
echo "-------------------------test 06"
seq 1 30 | 2041 speed '0,4d'
echo "-------------------------test 07"
seq 1 30 | 2041 speed '-1,4d'
echo "-------------------------test 08"
seq 1 30 | 2041 speed '4,-4d'
echo "-------------------------test 09"
seq 1 30 | 2041 speed '50,-4d'
echo "-------------------------test 10"
seq 1 30 | 2041 speed '0,0d'
echo "-------------------------test 11"
seq 1 30 | 2041 speed '3,/3/d'
echo "-------------------------test 12"
seq 1 30 | 2041 speed '3,/40/d'
echo "-------------------------test 13"
seq 1 30 | 2041 speed '0,/4/d'
echo "-------------------------test 14"
seq 1 30 | 2041 speed '0,/40/d'
echo "-------------------------test 15"
seq 1 30 | 2041 speed '40,/40/d'
echo "-------------------------test 16"
seq 1 30 | 2041 speed '/4/,10d'
echo "-------------------------test 17"
seq 1 30 | 2041 speed '/40/,10d'
echo "-------------------------test 18"
seq 1 30 | 2041 speed '/4/,0d'
echo "-------------------------test 19"
seq 1 30 | 2041 speed '/4/,40d'
echo "-------------------------test 20"
seq 1 30 | 2041 speed '/2/,/4/d'
echo "-------------------------test 21"
seq 1 30 | 2041 speed '/200/,/4/d'
echo "-------------------------test 22"
seq 1 30 | 2041 speed '/2/,/40/d'
echo "-------------------------test 23"
seq 1 30 | 2041 speed '/200/,/40/d'
echo "-------------------------test 24"