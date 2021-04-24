#!/bin/dash 

# The tests are basically from the subset 0 in the project specification


export PATH=$PATH:$(pwd)
mkdir temp 
cd temp 

head ../dictionary.txt | speed.pl '/.{3}/,/.{5}/c hello'

cd .. 
rm -rf temp 