#!/bin/dash 

# The tests are from subset 1 in project specification
clear
export PATH=$PATH:$(pwd)
# echo "---------------------START TESTS"

# seq 1 5 | speed.pl '$d'
# echo "-------------------------test 01"

# seq 1 10000 | speed.pl -n '$p'
# echo "-------------------------test 02"

# seq 10 21 | speed.pl '  3,5  d'
# echo "-------------------------test 03"

# seq 10 21 | speed.pl '3,/2/d'
# echo "-------------------------test 04"

# seq 10 21 | speed.pl '/2/,4d'
# echo "-------------------------test 05"

# seq 10 21 | speed.pl '/1$/,/^2/d'
# echo "-------------------------test 06"

# seq 1 5 | speed.pl 'sX[15]XzzzX'
# echo "-------------------------test 07"

# seq 1 5 | speed.pl 's?[15]?zzz?'
# echo "-------------------------test 08"

# seq 1 5 | speed.pl 's_[15]_zzz_'
# echo "-------------------------test 09"

# seq 1 5 | speed.pl 'sX[15]Xz/z/zX'
# echo "-------------------------test 10"


# seq 1 5 | speed.pl '4q;/2/d'
# echo "-------------------------test 11"

# seq 1 5 | speed.pl '/2/d;4q'
# echo "-------------------------test 12"

seq 1 20 | speed.pl '/2$/,/8$/d;4,6p'
echo "-------------------------test 13"

