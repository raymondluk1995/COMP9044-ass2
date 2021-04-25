#!/bin/dash 

cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test03 fail!"
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
seq 1 5 | speed.pl '$d' >> output1 2>&1
echo "-------------------------test 01" >> output1 2>&1
seq 1 10000 | speed.pl -n '$p' >> output1 2>&1
echo "-------------------------test 02" >> output1 2>&1
seq 10 21 | speed.pl '  3,5  d' >> output1 2>&1
echo "-------------------------test 03" >> output1 2>&1
seq 10 21 | speed.pl '3,/2/d' >> output1 2>&1
echo "-------------------------test 04" >> output1 2>&1
seq 10 21 | speed.pl '/2/,4d' >> output1 2>&1
echo "-------------------------test 05" >> output1 2>&1
seq 10 21 | speed.pl '/1$/,/^2/d' >> output1 2>&1
echo "-------------------------test 06" >> output1 2>&1
seq 1 5 | speed.pl 'sX[15]XzzzX' >> output1 2>&1
echo "-------------------------test 07" >> output1 2>&1
seq 1 5 | speed.pl 's?[15]?zzz?' >> output1 2>&1
echo "-------------------------test 08" >> output1 2>&1
seq 1 5 | speed.pl 's_[15]_zzz_' >> output1 2>&1
echo "-------------------------test 09" >> output1 2>&1
seq 1 5 | speed.pl 'sX[15]Xz/z/zX' >> output1 2>&1
echo "-------------------------test 10" >> output1 2>&1
seq 1 5 | speed.pl '4q;/2/d' >> output1 2>&1
echo "-------------------------test 11" >> output1 2>&1
seq 1 5 | speed.pl '/2/d;4q' >> output1 2>&1
echo "-------------------------test 12" >> output1 2>&1
seq 1 20 | speed.pl '/2$/,/8$/d;4,6p' >> output1 2>&1
echo "-------------------------test 13" >> output1 2>&1


seq 1 5 | 2041 speed '$d' >> output2 2>&1
echo "-------------------------test 01" >> output2 2>&1
seq 1 10000 | 2041 speed -n '$p' >> output2 2>&1
echo "-------------------------test 02" >> output2 2>&1
seq 10 21 | 2041 speed '  3,5  d' >> output2 2>&1
echo "-------------------------test 03" >> output2 2>&1
seq 10 21 | 2041 speed '3,/2/d' >> output2 2>&1
echo "-------------------------test 04" >> output2 2>&1
seq 10 21 | 2041 speed '/2/,4d' >> output2 2>&1
echo "-------------------------test 05" >> output2 2>&1
seq 10 21 | 2041 speed '/1$/,/^2/d' >> output2 2>&1
echo "-------------------------test 06" >> output2 2>&1
seq 1 5 | 2041 speed 'sX[15]XzzzX' >> output2 2>&1
echo "-------------------------test 07" >> output2 2>&1
seq 1 5 | 2041 speed 's?[15]?zzz?' >> output2 2>&1
echo "-------------------------test 08" >> output2 2>&1
seq 1 5 | 2041 speed 's_[15]_zzz_' >> output2 2>&1
echo "-------------------------test 09" >> output2 2>&1
seq 1 5 | 2041 speed 'sX[15]Xz/z/zX' >> output2 2>&1
echo "-------------------------test 10" >> output2 2>&1
seq 1 5 | 2041 speed '4q;/2/d' >> output2 2>&1
echo "-------------------------test 11" >> output2 2>&1
seq 1 5 | 2041 speed '/2/d;4q' >> output2 2>&1
echo "-------------------------test 12" >> output2 2>&1
seq 1 20 | 2041 speed '/2$/,/8$/d;4,6p' >> output2 2>&1
echo "-------------------------test 13" >> output2 2>&1


cmpOutput output1 output2 

echo "Test03 passes!"