#!/bin/dash 

# This test is for testing ';','#','$' in regex

cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test06 fail!"
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

seq 1 100 | speed.pl "s/[24]/;#blah/g;/8#/d;;;#blah" >> output1 2>&1 
echo "-------------------------test 01" >> output1 2>&1 
echo "This testing # ;## #blah ### Tada #######" | speed.pl "s/;#/#ABC/g;s/#{2}/\$/;;;#blah" >> output1 2>&1
echo "-------------------------test 02" >> output1 2>&1 
echo "This testing # ;## #blah ### Tada #######" > input1.txt 
echo "This testing # ;\$\$\$# #blah ### Tada ####\$\$###" >> input1.txt 
speed.pl "/#/s/\$/;/;/g  ;     /s/#blah/#ABCD/g" input1.txt >> output1 2>&1
echo "-------------------------test 03" >> output1 2>&1 

for file in *; do
    if [ ! "$file" = "output1" ] && [ ! "$file" = "output2" ]; then 
        rm $file;
    fi 
done  

seq 1 100 | 2041 speed "s/[24]/;#blah/g;/8#/d;;;#blah" >> output2 2>&1 
echo "-------------------------test 01" >> output2 2>&1 
echo "This testing # ;## #blah ### Tada #######" | 2041 speed "s/;#/#ABC/g;s/#{2}/\$/;;;#blah" >> output2 2>&1
echo "-------------------------test 02" >> output2 2>&1 
echo "This testing # ;## #blah ### Tada #######" > input1.txt 
echo "This testing # ;\$\$\$# #blah ### Tada ####\$\$###" >> input1.txt 
2041 speed "/#/s/\$/;/;/g  ;     /s/#blah/#ABCD/g" input1.txt >> output2 2>&1
echo "-------------------------test 03" >> output2 2>&1  

cmpOutput output1 output2 

echo "Test06 passes!"

