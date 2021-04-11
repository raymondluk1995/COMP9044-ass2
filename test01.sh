#!/bin/dash 

export PATH=$PATH:$(pwd)

seq 1 5 | sped.pl 3q
echo "---------------"
seq 10 15 | sped.pl /.1/q 
echo "---------------"
seq 1 5 | sped.pl 2p 
echo "---------------"
seq 1 5|sped.pl 4d
echo "---------------"
seq 1 5|sped.pl -n 3p
echo "---------------"
seq 1 5|sped.pl 's/[15]/zzz/'
echo "---------------"
seq 1 5| sped.pl '4q;/2/d'
echo "---------------"
seq 1 5 | sed '4q;/2/d;3q'