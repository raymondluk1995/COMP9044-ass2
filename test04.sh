#!/bin/dash 

# The tests are from subset 1 in project specification
# clear
export PATH=$PATH:$(pwd)

mkdir temp 
cd temp 
echo /2/d >  commands.speed
echo 4q   >> commands.speed
seq 1 5 | speed.pl -f commands.speed
echo "-------------------------test 01"
echo 5q > commands1
seq 1 3 > commands2
seq 10 20 > commands3 
seq 1 5 | speed.pl -f commands1 commands2 commands3
echo "-------------------------test 02"
seq 1 2 > two.txt
seq 1 5 > five.txt
speed.pl '4q;/2/d' two.txt five.txt
echo "-------------------------test 03"
# seq 1 100 | speed.pl -n '1,/.1/p;/5/,/9/s/.//;/.{2}/,/.9/p;85q'
# echo "-------------------------test 04"


# seq 1 2 > two.txt
# seq 1 5 > five.txt
# speed.pl '4q;/2/d' five.txt two.txt
# echo "-------------------------test 04"
# echo 4q   >  commands.speed
# echo /2/d >> commands.speed
# seq 1 2 > two.txt
# seq 1 5 > five.txt
# speed.pl -f commands.speed two.txt five.txt
# echo "-------------------------test 05"
# seq 24 43 | speed.pl ' 3, 17  d  # comment'
# echo "-------------------------test 06"
# seq 24 43 | speed.pl ' 3, 17  d  # comment'
# echo "-------------------------test 07"
# seq 24 43 | speed.pl '/2/d # delete  ;  4  q # quit'
# echo "-------------------------test 08"
cd ..
rm -r temp