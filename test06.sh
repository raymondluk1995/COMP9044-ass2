#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

seq 24 42 | speed.pl ' 3, 17  d  # comment'

cd .. 
rm -rf temp 