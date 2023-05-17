#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$TOPDIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

#TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )/.."
TOPDIR="/home/femu/benchmark/plots"
RAWDIR=$TOPDIR/cdf
DATDIR=$RAWDIR/dat
STATDIR=$TOPDIR/stat


function pr_title()
{
    printf "%s,%s,%s,%s,%s,%s\n" "Filename" "Min" "Average" "Median" "Max" "Stddev"
}

if [[ $# != 1 ]]; then
    echo ""
    echo "Usage: ./getstat.sh [directory|file]"
    echo ""
    exit
fi

#if [[ ! -d $RAWDIR ]]; then
#    echo "Error: not found!\n"
#    exit
#fi


#if [[ -d $RAWDIR ]]; then

    if [[ ! -d $STATDIR ]]; then
        mkdir -p stat
    fi

    STATF=$STATDIR/cdf-stat.csv
    if [[ -e $STATF ]]; then
        exit
    fi

    {
        pr_title
        for i in $RAWDIR/*.tmp; do
            FNAME=$(basename $i)
            gawk -vFNAME=$FNAME -f stat.awk $i
        done
    } > stat/cdf-stat.csv

    # show result to terminal
    cat stat/cdf-stat.csv
#fi

