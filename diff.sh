#!/bin/dash 

export PATH=$PATH:$(pwd)

./test02.sh > testResults/t02.txt 
diff testResults/t02.txt  testResults/tt02.txt 