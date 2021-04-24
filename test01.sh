#!/bin/dash 

# The tests are basically from the subset 0 in the project specification

cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test01 fail!"
        echo "The difference are: "
        diff "$1" "$2"
        exit 1
    fi 
}

export PATH=$PATH:$(pwd)

temp_folder=$(mktemp -d testgirt.XXXXXXXXXX)
trap "cd ..; rm -rf '$temp_folder'; exit" INT TERM EXIT
cd "$temp_folder" || exit 1
touch >> output1 2>&1 
touch output2


seq 1 5 | speed.pl '3q' >> output1 2>&1
echo "-------------test 01" >> output1 2>&1
seq 9 20 | speed.pl '3q' >> output1 2>&1
echo "-------------test 02" >> output1 2>&1
seq 10 15 | speed.pl '/.1/q'  >> output1 2>&1
echo "-------------test 03" >> output1 2>&1
seq 500 600 | speed.pl '/^.+5$/q' >> output1 2>&1
echo "-------------test 04" >> output1 2>&1
seq 100 1000 | speed.pl '/1{3}/q' >> output1 2>&1
echo "-------------test 05" >> output1 2>&1
seq 1 5 | speed.pl 2p  >> output1 2>&1
echo "-------------test 06" >> output1 2>&1
seq 7 11 | speed.pl 4p  >> output1 2>&1
echo "-------------test 07" >> output1 2>&1
seq 65 85 | speed.pl '/^7/p' >> output1 2>&1
echo "-------------test 08" >> output1 2>&1
seq 1 5|speed.pl 'p' >> output1 2>&1
echo "-------------test 09" >> output1 2>&1
seq 1 5|speed.pl '4d' >> output1 2>&1
echo "-------------test 10" >> output1 2>&1
seq 1 100|speed.pl '/.{2}/d' >> output1 2>&1
echo "-------------test 11" >> output1 2>&1
seq 11 20 | speed.pl '/[2468]/d' >> output1 2>&1
echo "-------------test 12" >> output1 2>&1
seq 1 5 | speed.pl 's/[15]/zzz/' >> output1 2>&1
echo "-------------test 13" >> output1 2>&1
seq 10 20 | speed.pl 's/[15]/zzz/' >> output1 2>&1
echo "-------------test 14" >> output1 2>&1
seq 100 111 | speed.pl 's/11/zzz/' >> output1 2>&1
echo "-------------test 15" >> output1 2>&1
echo Hello Andrew | speed.pl 's/e//' >> output1 2>&1
echo "-------------test 16" >> output1 2>&1
echo Hello Andrew | speed.pl 's/e//g' >> output1 2>&1
echo "-------------test 17" >> output1 2>&1
seq 11 19 | speed.pl '5s/1/2/' >> output1 2>&1
echo "-------------test 18" >> output1 2>&1
seq 51 60 | speed.pl '5s/5/9/g' >> output1 2>&1
echo "-------------test 19" >> output1 2>&1
seq 100 111 | speed.pl '/1.1/s/1/-/g' >> output1 2>&1
echo "-------------test 20" >> output1 2>&1
seq 1 5|speed.pl -n '3p' >> output1 2>&1
echo "-------------test 21" >> output1 2>&1
seq 2 3 20 |speed.pl -n '/^1/p' >> output1 2>&1
echo "-------------test 22" >> output1 2>&1
seq 1 5| speed.pl '4q;/2/d' >> output1 2>&1
echo "-------------test 23" >> output1 2>&1
seq 1 5 | speed.pl '4q;/2/d;3q' >> output1 2>&1
echo "-------------test 24" >> output1 2>&1
yes | speed.pl 3q >> output1 2>&1
echo "-------------test 25" >> output1 2>&1


seq 1 5 | 2041 speed '3q' >> output2 2>&1
echo "-------------test 01" >> output2 2>&1
seq 9 20 | 2041 speed '3q' >> output2 2>&1
echo "-------------test 02" >> output2 2>&1
seq 10 15 | 2041 speed '/.1/q'  >> output2 2>&1
echo "-------------test 03" >> output2 2>&1
seq 500 600 | 2041 speed '/^.+5$/q' >> output2 2>&1
echo "-------------test 04" >> output2 2>&1
seq 100 1000 | 2041 speed '/1{3}/q' >> output2 2>&1
echo "-------------test 05" >> output2 2>&1
seq 1 5 | 2041 speed 2p  >> output2 2>&1
echo "-------------test 06" >> output2 2>&1
seq 7 11 | 2041 speed 4p  >> output2 2>&1
echo "-------------test 07" >> output2 2>&1
seq 65 85 | 2041 speed '/^7/p' >> output2 2>&1
echo "-------------test 08" >> output2 2>&1
seq 1 5|2041 speed 'p' >> output2 2>&1
echo "-------------test 09" >> output2 2>&1
seq 1 5|2041 speed '4d' >> output2 2>&1
echo "-------------test 10" >> output2 2>&1
seq 1 100|2041 speed '/.{2}/d' >> output2 2>&1
echo "-------------test 11" >> output2 2>&1
seq 11 20 | 2041 speed '/[2468]/d' >> output2 2>&1
echo "-------------test 12" >> output2 2>&1
seq 1 5 | 2041 speed 's/[15]/zzz/' >> output2 2>&1
echo "-------------test 13" >> output2 2>&1
seq 10 20 | 2041 speed 's/[15]/zzz/' >> output2 2>&1
echo "-------------test 14" >> output2 2>&1
seq 100 111 | 2041 speed 's/11/zzz/' >> output2 2>&1
echo "-------------test 15" >> output2 2>&1
echo Hello Andrew | 2041 speed 's/e//' >> output2 2>&1
echo "-------------test 16" >> output2 2>&1
echo Hello Andrew | 2041 speed 's/e//g' >> output2 2>&1
echo "-------------test 17" >> output2 2>&1
seq 11 19 | 2041 speed '5s/1/2/' >> output2 2>&1
echo "-------------test 18" >> output2 2>&1
seq 51 60 | 2041 speed '5s/5/9/g' >> output2 2>&1
echo "-------------test 19" >> output2 2>&1
seq 100 111 | 2041 speed '/1.1/s/1/-/g' >> output2 2>&1
echo "-------------test 20" >> output2 2>&1
seq 1 5|2041 speed -n '3p' >> output2 2>&1
echo "-------------test 21" >> output2 2>&1
seq 2 3 20 |2041 speed -n '/^1/p' >> output2 2>&1
echo "-------------test 22" >> output2 2>&1
seq 1 5| 2041 speed '4q;/2/d' >> output2 2>&1
echo "-------------test 23" >> output2 2>&1
seq 1 5 | 2041 speed '4q;/2/d;3q' >> output2 2>&1
echo "-------------test 24" >> output2 2>&1
yes | 2041 speed 3q >> output2 2>&1
echo "-------------test 25" >> output2 2>&1 

cmpOutput output1 output2 

echo "Test01 passes!"

