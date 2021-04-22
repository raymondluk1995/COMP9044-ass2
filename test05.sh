#!/bin/dash 

# The tests are from subset 1 in project specification
# clear
export PATH=$PATH:$(pwd)

mkdir temp 
cd temp 

seq 1 5 >five.txt 

speed.pl -i /[24]/d five.txt

cat five.txt
echo "------------------test01"

seq 1 5 >five.txt 
seq 1 10 >ten.txt
seq 1 20 > fifteen.txt

speed.pl -i /[24]/d five.txt ten.txt fifteen.txt 
cat five.txt 
cat ten.txt
cat fifteen.txt 
echo "------------------test02"

# Check backslash in regex 
echo "aaa /bbb/ccc/ddd///eee" > a.txt 
echo "kkk ///ggg/ee232//45 # ////" >> a.txt 

speed.pl 's/\//#/g' a.txt
echo "------------------test03"

cd .. 
rm -rf temp 
