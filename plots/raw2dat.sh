#!/bin/bash

if [[ $# -ne 4 ]]; then
    echo "Usage:"
    printf "\t./raw2dat-lat-cdf.sh TYPE dtrs MIN MAX PRECISION\n"
    printf "HERE, dtrs is sub-directory under raw/\n"
    exit
fi

TARGET=$1
MIN=$2
MAX=$3
PRECISION=$4

function raw2dat_lat_cdf()
{
    input=$1
    tmp=${input/log/tmp}
    gawk -F"," '{print $2}' $1 | sort -n -o $tmp
    # use the following line when you don't want to include 0-1us latency in your CDF graph
    #gawk -F"," '{if ($2 >= 40) print $2}' $1 | sort -n -o $tmp
    # CDF(x, y), sampling
    ./sample-cdf-lat.sh $tmp $MIN $MAX $PRECISION $2
}

cd cdf

mkdir -p dat
raw2dat_handler=raw2dat_lat_cdf

for rawfile in *.log; do
    fname=${rawfile%.*}
    #if [[ ! -e ${fname}.tmp ]]; then
    #gawk -F"," '{print $2}' $rawfile | sort -n -o ${fname}.tmp
    ${raw2dat_handler} $rawfile ${fname}.dat
    mv ${fname}.dat dat
    #fi

done


echo "==== raw2dat done ===="
