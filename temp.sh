#!/bin/dash 

# This test is for testing changing

cmpOutput(){
    if ! diff "$1" "$2" > /dev/null; then 
        echo "Test10 fail!"
        echo "The difference are: "
        diff "$1" "$2"
        exit 1
    fi 
}

export PATH=$PATH:$(pwd)

seq 1 5 | speed.pl 'a hello'
# seq 1 5 | 2041 speed 'a'