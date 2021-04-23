#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

seq 1 5 > five.txt
echo '/[24]/d' > commandsFile
speed.pl -i -f commandsFile five.txt
cat five.txt

cd .. 
rm -rf temp 