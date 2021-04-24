#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

seq 10 30 | speed.pl 's/[^ ](.)/\1/'

cd .. 
rm -rf temp 