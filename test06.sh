#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

seq 1 5 | speed.pl 's/[15]/z\/z\/z/'

cd .. 
rm -rf temp 