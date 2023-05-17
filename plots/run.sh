#!/bin/bash


#-------------------------------------------
TARGET="cdf"
LATENCY="psync"
#-------------------------------------------


./raw2dat.sh $TARGET 0 1 0.0001

./getstat.sh $TARGET

./genplot.sh "Latency-${TARGET}-${LATENCY}"

cd cdf/dat

gnuplot lat.plot
