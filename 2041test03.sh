#!/bin/dash 

# This test is for testing delete scenarios

export PATH=$PATH:$(pwd)

mkdir temp 
cd temp 

seq 1 5 > five.txt 
seq 1 10 > ten.txt 

2041 speed -i '/[24]/d' five.txt ten.txt 

cat five.txt 


cd .. 
rm -rf temp 