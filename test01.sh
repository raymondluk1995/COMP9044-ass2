#!/bin/dash 

export PATH=$PATH:$(pwd)

seq 1 5 | sped 3q
echo "---------------"
seq 10 15 | sped /.1/q 
echo "---------------"
seq 1 5 | sped 2p 
echo "---------------"
seq 1 5|sped 4d
echo "---------------"
seq 1 5|sped 's/[15]/zzz/'
echo "---------------"
seq 1 5| sped '4q;/2/d'
echo "---------------"
seq 1 5 | sed '4q;/2/d;3q'