#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

echo '$q' > commandsFile
seq 1 5 | speed.pl -f commandsFile
# seq 1 5 | speed.pl '$q'
cd .. 
rm -rf temp 