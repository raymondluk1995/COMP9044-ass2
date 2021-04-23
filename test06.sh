#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

seq 1 5 | speed.pl 's1[\15]1zzz1'

cd .. 
rm -rf temp 