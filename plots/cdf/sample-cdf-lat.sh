#!/bin/bash

if [[ $# -ne 5 ]]; then
    echo "Usage: $0 <inputfile> <MIN> <MAX> <PRECISION> <outputfile>"
    echo "BEAWARE: inputfile should be already sorted"
    exit
fi

input=$1
MIN=$2
MAX=$3
PRECISION=$4
output=$5

cat /dev/null > $output
gawk -v min=$MIN -v max=$MAX -v precision=$PRECISION -v output=$output -f cdf.awk $input
