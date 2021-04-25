#!/bin/dash 

# This test is for testing invalid inputs

cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test07 fail!"
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

seq 1 50 | speed.pl "k/dfeadf/werwe/" >> output1 2>&1  
echo "-------------------------test 01" >> output1 2>&1 
seq 1 50 | speed.pl "--k/dfeadf/werwe/" >> output1 2>&1  
echo "-------------------------test 02" >> output1 2>&1 
seq 1 50 | speed.pl "-k/dfeadf/werwe/" >> output1 2>&1  
echo "-------------------------test 03" >> output1 2>&1 

seq 1 50 | speed.pl "/2/d; -s/[34]/KK/g" >> output1 2>&1  
echo "-------------------------test 04" >> output1 2>&1 

for file in *; do
    if [ ! "$file" = "output1" ] && [ ! "$file" = "output2" ]; then 
        rm $file;
    fi 
done 


seq 1 50 | 2041 speed "k/dfeadf/werwe/" >> output2 2>&1  
echo "-------------------------test 01" >> output2 2>&1 
seq 1 50 | 2041 speed "--k/dfeadf/werwe/" >> output2 2>&1  
echo "-------------------------test 02" >> output2 2>&1 
seq 1 50 | 2041 speed "-k/dfeadf/werwe/" >> output2 2>&1  
echo "-------------------------test 03" >> output2 2>&1 
seq 1 50 | 2041 speed "/2/d; -s/[34]/KK/g" >> output2 2>&1  
echo "-------------------------test 04" >> output2 2>&1 


cmpOutput output1 output2 

echo "Test07 passes!"