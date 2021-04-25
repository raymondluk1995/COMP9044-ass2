#!/bin/dash 

# This test is for file execution

cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test05 fail!"
        echo "The difference are: "
        diff "$1" "$2"
        exit 1
    fi 
}

export PATH=$PATH:$(pwd)

temp_folder=$(mktemp -d testspeed.XXXXXXXXXX)
trap "cd ..; rm -rf '$temp_folder'; exit" INT TERM EXIT
cd "$temp_folder" || exit 1

touch output1
touch output2

seq 1 5 >five.txt 
speed.pl -i /[24]/d five.txt
cat five.txt > output1 2>&1
echo "------------------test01" > output1 2>&1

seq 1 5 >five.txt 
seq 1 10 >ten.txt
seq 1 15 > fifteen.txt

speed.pl -i /[24]/d five.txt ten.txt fifteen.txt 
cat five.txt > output1 2>&1
cat ten.txt > output1 2>&1
cat fifteen.txt > output1 2>&1
echo "------------------test02" > output1 2>&1

# Check backslash in regex 
echo "aaa /bbb/ccc/ddd///eee" > a.txt 
echo "kkk ///ggg/ee232//45 # ////" >> a.txt 

speed.pl 's/\//#/g' a.txt > output1 2>&1
echo "------------------test03" > output1 2>&1

seq 1 50 >fifty.txt 
seq 1 100 > hundred.txt
seq 1 1000 > thousand.txt 

echo "/[24]/d;/3/,/5/p;100q;;1s/.*/ABCD/" > speed.commands 
speed.pl -i -f speed.commands five.txt ten.txt fifteen.txt 
cat five.txt > output2 2>&1
cat ten.txt > output2 2>&1
cat fifteen.txt > output2 2>&1
echo "------------------test04" > output1 2>&1

for file in *; do
    if [ ! "$file" = "output1" ] && [ ! "$file" = "output2" ]; then 
        rm $file;
    fi 
done 

seq 1 5 >five.txt 
2041 speed -i /[24]/d five.txt
cat five.txt > output2 2>&1
echo "------------------test01" > output2 2>&1

seq 1 5 >five.txt 
seq 1 10 >ten.txt
seq 1 15 > fifteen.txt

2041 speed -i /[24]/d five.txt ten.txt fifteen.txt 
cat five.txt > output2 2>&1
cat ten.txt > output2 2>&1
cat fifteen.txt > output2 2>&1
echo "------------------test02" > output2 2>&1

# Check backslash in regex 
echo "aaa /bbb/ccc/ddd///eee" > a.txt 
echo "kkk ///ggg/ee232//45 # ////" >> a.txt 

2041 speed 's/\//#/g' a.txt > output2 2>&1
echo "------------------test03" > output2 2>&1

seq 1 50 >fifty.txt 
seq 1 100 > hundred.txt
seq 1 1000 > thousand.txt 

echo "/[24]/d;/3/,/5/p;100q;;1s/.*/ABCD/" > speed.commands 
2041 speed -i -f speed.commands five.txt ten.txt fifteen.txt 
cat five.txt > output2 2>&1
cat ten.txt > output2 2>&1
cat fifteen.txt > output2 2>&1
echo "------------------test04"  > output2 2>&1


cmpOutput output1 output2 

echo "Test05 passes!"

