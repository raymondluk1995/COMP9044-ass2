#!/bin/dash 

export PATH=$PATH:$(pwd)

seq 1 5 | speed.pl 3q
echo "---------------"
seq 10 15 | speed.pl /.1/q 
echo "---------------"
seq 1 5 | speed.pl 2p 
echo "---------------"
seq 1 5|speed.pl 4d
echo "---------------"
seq 1 5|speed.pl -n 3p
echo "---------------"
seq 1 5|speed.pl 's/[15]/zzz/'
echo "---------------"
seq 1 5| speed.pl '4q;/2/d'
echo "---------------"
seq 1 5 | sed '4q;/2/d;3q'
echo "---------------"
yes | speed.pl 3q
