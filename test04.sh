#!/bin/dash 


cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test04 fail!"
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

echo /2/d >  commands.speed >> output1 2>&1
echo 4q   >> commands.speed >> output1 2>&1
seq 1 5 | speed.pl -f commands.speed >> output1 2>&1
echo "-------------------------test 01" >> output1 2>&1
echo 5q > commands1 >> output1 2>&1
seq 1 3 > commands2 >> output1 2>&1
seq 10 20 > commands3  >> output1 2>&1
seq 1 5 | speed.pl -f commands1 commands2 commands3 >> output1 2>&1
echo "-------------------------test 02" >> output1 2>&1
seq 1 2 > two.txt >> output1 2>&1
seq 1 5 > five.txt >> output1 2>&1
speed.pl '4q;/2/d' two.txt five.txt >> output1 2>&1
echo "-------------------------test 03" >> output1 2>&1
seq 1 100 | speed.pl -n '1,/.1/p;/5/,/9/s/.//;/.{2}/,/.9/p;85q' >> output1 2>&1
echo "-------------------------test 04" >> output1 2>&1
seq 1 2 > two.txt >> output1 2>&1
seq 1 5 > five.txt >> output1 2>&1
speed.pl '4q;/2/d' five.txt two.txt >> output1 2>&1
echo "-------------------------test 04" >> output1 2>&1
echo 4q   >  commands.speed >> output1 2>&1
echo /2/d >> commands.speed >> output1 2>&1
seq 1 2 > two.txt >> output1 2>&1
seq 1 5 > five.txt >> output1 2>&1
speed.pl -f commands.speed two.txt five.txt >> output1 2>&1
echo "-------------------------test 05" >> output1 2>&1
seq 24 43 | speed.pl ' 3, 17  d  # comment' >> output1 2>&1
echo "-------------------------test 06" >> output1 2>&1
seq 24 43 | speed.pl ' 3, 17  d  # comment' >> output1 2>&1
echo "-------------------------test 07" >> output1 2>&1
seq 24 43 | speed.pl '/2/d # delete  ;  4  q # quit' >> output1 2>&1
echo "-------------------------test 08" >> output1 2>&1 

for file in *; do
    if [ ! "$file" = "output1" ] && [ ! "$file" = "output2" ]; then 
        rm $file;
    fi 
done 

echo /2/d >  commands.speed >> output2 2>&1
echo 4q   >> commands.speed >> output2 2>&1
seq 1 5 | 2041 speed -f commands.speed >> output2 2>&1
echo "-------------------------test 01" >> output2 2>&1
echo 5q > commands1 >> output2 2>&1
seq 1 3 > commands2 >> output2 2>&1
seq 10 20 > commands3  >> output2 2>&1
seq 1 5 | 2041 speed -f commands1 commands2 commands3 >> output2 2>&1
echo "-------------------------test 02" >> output2 2>&1
seq 1 2 > two.txt >> output2 2>&1
seq 1 5 > five.txt >> output2 2>&1
2041 speed '4q;/2/d' two.txt five.txt >> output2 2>&1
echo "-------------------------test 03" >> output2 2>&1
seq 1 100 | 2041 speed -n '1,/.1/p;/5/,/9/s/.//;/.{2}/,/.9/p;85q' >> output2 2>&1
echo "-------------------------test 04" >> output2 2>&1
seq 1 2 > two.txt >> output2 2>&1
seq 1 5 > five.txt >> output2 2>&1
2041 speed '4q;/2/d' five.txt two.txt >> output2 2>&1
echo "-------------------------test 04" >> output2 2>&1
echo 4q   >  commands.speed >> output2 2>&1
echo /2/d >> commands.speed >> output2 2>&1
seq 1 2 > two.txt >> output2 2>&1
seq 1 5 > five.txt >> output2 2>&1
2041 speed -f commands.speed two.txt five.txt >> output2 2>&1
echo "-------------------------test 05" >> output2 2>&1
seq 24 43 | 2041 speed ' 3, 17  d  # comment' >> output2 2>&1
echo "-------------------------test 06" >> output2 2>&1
seq 24 43 | 2041 speed ' 3, 17  d  # comment' >> output2 2>&1
echo "-------------------------test 07" >> output2 2>&1
seq 24 43 | 2041 speed '/2/d # delete  ;  4  q # quit' >> output2 2>&1
echo "-------------------------test 08" >> output2 2>&1 


cmpOutput output1 output2 

echo "Test04 passes!"