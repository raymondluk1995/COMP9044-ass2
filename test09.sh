#!/bin/dash 

# This test is for testing inserting

cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test09 fail!"
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


seq 1 10 | speed.pl '2i hello world' >> output1 2>&1
echo "-------------------------test 01" >> output1 2>&1
seq 1 10 | speed.pl '/2/i hello world' >> output1 2>&1
echo "-------------------------test 02" >> output1 2>&1
seq 1 10 | speed.pl '$i hello world' >> output1 2>&1
echo "-------------------------test 03" >> output1 2>&1
seq 1 30 | speed.pl '2 , 8 i hello world' >> output1 2>&1
echo "-------------------------test 04" >> output1 2>&1
seq 1 30 | speed.pl '8 , 2i hello world' >> output1 2>&1
echo "-------------------------test 05" >> output1 2>&1
seq 1 30 | speed.pl '0i hello world' >> output1 2>&1
echo "-------------------------test 06" >> output1 2>&1
seq 1 30 | speed.pl '0,4i hello world' >> output1 2>&1
echo "-------------------------test 07" >> output1 2>&1
seq 1 30 | speed.pl '-1,4 i hello world' >> output1 2>&1
echo "-------------------------test 08" >> output1 2>&1
seq 1 30 | speed.pl '4,-4 i hello world' >> output1 2>&1
echo "-------------------------test 09" >> output1 2>&1
seq 1 30 | speed.pl '50,-4 i hello world' >> output1 2>&1
echo "-------------------------test 10" >> output1 2>&1
seq 1 30 | speed.pl '0,0 i hello world' >> output1 2>&1
echo "-------------------------test 11" >> output1 2>&1
seq 1 30 | speed.pl '3,/3/ i hello world' >> output1 2>&1
echo "-------------------------test 12" >> output1 2>&1
seq 1 30 | speed.pl '3,/40/ i hello world' >> output1 2>&1
echo "-------------------------test 13" >> output1 2>&1
seq 1 30 | speed.pl '0,/4/ i hello world' >> output1 2>&1
echo "-------------------------test 14" >> output1 2>&1
seq 1 30 | speed.pl '0,/40/ i hello world' >> output1 2>&1
echo "-------------------------test 15" >> output1 2>&1
seq 1 30 | speed.pl '40,/40/ i hello world' >> output1 2>&1
echo "-------------------------test 16" >> output1 2>&1
seq 1 30 | speed.pl '/4/,10 i hello world' >> output1 2>&1
echo "-------------------------test 17" >> output1 2>&1
seq 1 30 | speed.pl '/40/,10 i hello world' >> output1 2>&1
echo "-------------------------test 18" >> output1 2>&1
seq 1 30 | speed.pl '/4/,0 i hello world' >> output1 2>&1
echo "-------------------------test 19" >> output1 2>&1
seq 1 30 | speed.pl '/4/,40 i hello world' >> output1 2>&1
echo "-------------------------test 20" >> output1 2>&1
seq 1 30 | speed.pl '/2/,/4/ i hello world' >> output1 2>&1
echo "-------------------------test 21" >> output1 2>&1
seq 1 30 | speed.pl '/200/,/4/ i hello world' >> output1 2>&1
echo "-------------------------test 22" >> output1 2>&1
seq 1 30 | speed.pl '/2/,/40/ i hello world' >> output1 2>&1
echo "-------------------------test 23" >> output1 2>&1
seq 1 30 | speed.pl '/200/,/40/ i hello world' >> output1 2>&1
echo "-------------------------test 24" >> output1 2>&1

seq 1 10 | 2041 speed '2i hello world' >> output2 2>&1
echo "-------------------------test 01" >> output2 2>&1
seq 1 10 | 2041 speed '/2/i hello world' >> output2 2>&1
echo "-------------------------test 02" >> output2 2>&1
seq 1 10 | 2041 speed '$i hello world' >> output2 2>&1
echo "-------------------------test 03" >> output2 2>&1
seq 1 30 | 2041 speed '2 , 8 i hello world' >> output2 2>&1
echo "-------------------------test 04" >> output2 2>&1
seq 1 30 | 2041 speed '8 , 2i hello world' >> output2 2>&1
echo "-------------------------test 05" >> output2 2>&1
seq 1 30 | 2041 speed '0i hello world' >> output2 2>&1
echo "-------------------------test 06" >> output2 2>&1
seq 1 30 | 2041 speed '0,4i hello world' >> output2 2>&1
echo "-------------------------test 07" >> output2 2>&1
seq 1 30 | 2041 speed '-1,4 i hello world' >> output2 2>&1
echo "-------------------------test 08" >> output2 2>&1
seq 1 30 | 2041 speed '4,-4 i hello world' >> output2 2>&1
echo "-------------------------test 09" >> output2 2>&1
seq 1 30 | 2041 speed '50,-4 i hello world' >> output2 2>&1
echo "-------------------------test 10" >> output2 2>&1
seq 1 30 | 2041 speed '0,0 i hello world' >> output2 2>&1
echo "-------------------------test 11" >> output2 2>&1
seq 1 30 | 2041 speed '3,/3/ i hello world' >> output2 2>&1
echo "-------------------------test 12" >> output2 2>&1
seq 1 30 | 2041 speed '3,/40/ i hello world' >> output2 2>&1
echo "-------------------------test 13" >> output2 2>&1
seq 1 30 | 2041 speed '0,/4/ i hello world' >> output2 2>&1
echo "-------------------------test 14" >> output2 2>&1
seq 1 30 | 2041 speed '0,/40/ i hello world' >> output2 2>&1
echo "-------------------------test 15" >> output2 2>&1
seq 1 30 | 2041 speed '40,/40/ i hello world' >> output2 2>&1
echo "-------------------------test 16" >> output2 2>&1
seq 1 30 | 2041 speed '/4/,10 i hello world' >> output2 2>&1
echo "-------------------------test 17" >> output2 2>&1
seq 1 30 | 2041 speed '/40/,10 i hello world' >> output2 2>&1
echo "-------------------------test 18" >> output2 2>&1
seq 1 30 | 2041 speed '/4/,0 i hello world' >> output2 2>&1
echo "-------------------------test 19" >> output2 2>&1
seq 1 30 | 2041 speed '/4/,40 i hello world' >> output2 2>&1
echo "-------------------------test 20" >> output2 2>&1
seq 1 30 | 2041 speed '/2/,/4/ i hello world' >> output2 2>&1
echo "-------------------------test 21" >> output2 2>&1
seq 1 30 | 2041 speed '/200/,/4/ i hello world' >> output2 2>&1
echo "-------------------------test 22" >> output2 2>&1
seq 1 30 | 2041 speed '/2/,/40/ i hello world' >> output2 2>&1
echo "-------------------------test 23" >> output2 2>&1
seq 1 30 | 2041 speed '/200/,/40/ i hello world' >> output2 2>&1
echo "-------------------------test 24" >> output2 2>&1


cmpOutput output1 output2 

echo "Test09 passes!"