#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

echo '/2/    d # comment' > commandsFile
echo '# comment'         >> commandsFile
echo '4    q'            >> commandsFile
seq 1 2   > two.txt
seq 1 5   > five.txt
speed.pl -f commandsFile two.txt five.txt
cd .. 
rm -rf temp 