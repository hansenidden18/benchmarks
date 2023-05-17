#!/bin/sh

if [ -z "$1" ]; then
	echo "Ussage: generate_plots subtitle xres yres"
	exit 1
fi

TITLE="$1"

GNUPLOT=$(which gnuplot)
if [ ! -x "$GNUPLOT" ]
then
    echo You need gnuplot installed to generate graphs
    exit 1
fi

DEFAULT_GRID_LINE_TYPE=3
DEFAULT_LINE_WIDTH=10
DEFAULT_LINE_COLORS=" 
set style line 1 lc rgb \"black\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 2 lc rgb \"blue\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 3 lc rgb \"magenta\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 4 lc rgb \"orange\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 5 lc rgb \"cyan\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 6 lc rgb \"yellow\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 7 lc rgb \"purple\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 8 lc rgb \"gray\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 9 lc rgb \"pink\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 10 lc rgb \"green\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 11 lc rgb \"brown\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 12 lc rgb \"olive\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 13 lc rgb \"coral\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 14 lc rgb \"golden rod\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 15 lc rgb \"salmon\" lw $DEFAULT_LINE_WIDTH lt 1;
set style line 16 lc rgb \"red\" lt $DEFAULT_GRID_LINE_TYPE lw $DEFAULT_LINE_WIDTH;
"
 
DEFAULT_TERMINAL="set term postscript eps enhanced color 20"
DEFAULT_TITLE_FONT="\"large,30\""
DEFAULT_AXIS_FONT="\"large,28\""
DEFAULT_AXIS_LABEL_FONT="\"large,28\""
DEFAULT_XLABEL="set xlabel \"Latency\" font $DEFAULT_AXIS_LABEL_FONT"
DEFAULT_XTIC="set xtics font $DEFAULT_AXIS_FONT"
DEFAULT_YTIC="set ytics font $DEFAULT_AXIS_FONT"
DEFAULT_MXTIC="set mxtics 10000"
DEFAULT_MYTIC="set mytics 10000"
DEFAULT_XRANGE="set xrange [40000:400000]"
DEFAULT_YRANGE="set yrange [0:]"
DEFAULT_GRID="set grid"
DEFAULT_KEY="set key outside bottom center ; set key font \"large,28\" ; set key box enhanced spacing 2.0 samplen 3 horizontal width 4 height 1.2 "
DEFAULT_SOURCE="set label 30"

plot () {
	
	#if [ -z "$TITLE" ]
	#then
	    PLOT_TITLE=" set title \"Latency CDF ALL QD\" font $DEFAULT_TITLE_FONT"
	#else
	#    PLOT_TITLE=" set title \"$TITLE\\\n\\\n{/*0.6 "$1"}\" font $DEFAULT_TITLE_FONT"
	#fi
	FILETYPE="$2"
	#YAXIS="set ylabel \"$3\" font $DEFAULT_AXIS_LABEL_FONT"


	i=0
	

	for x in seq_read_lat*.dat
	do
	    if [ -e "$x" ]; then
		i=$((i+1))
		name=$(echo $x | grep -oP "(?<=seq_read_lat_)\w+(?=\.log_lat.dat)")
		if [ ! -z "$PLOT_LINE" ]
		then
		    PLOT_LINE=$PLOT_LINE", "
		fi

		PLOT_LINE=$PLOT_LINE"'$x' u 1:2 t \"$name\" w l ls $i"
	    fi
	done

	if [ $i -eq 0 ]; then
	    echo "No log files found"
	    exit 1
	fi

	OUTPUT="set output \"$TITLE-$FILETYPE.eps\" "
	echo "${PLOT_TITLE}"
#	echo "${YAXIS}"
#	echo "${DEFAULT_SEPARATOR}"
	echo "${DEFAULT_LINE_COLORS}"
	echo "${DEFAULT_GRID_LINE}"
	echo "${DEFAULT_GRID}"
	echo "${DEFAULT_GRID_MINOR}"
	echo "${DEFAULT_XLABEL}"
	echo "${DEFAULT_XRANGE}"
	echo "${DEFAULT_YRANGE}"
	echo "${DEFAULT_XTIC}"
	echo "${DEFAULT_YTIC}"
	echo "${DEFAULT_MXTIC}"
	echo "${DEFAULT_MYTIC}"
	echo "${DEFAULT_KEY}"
	echo "${DEFAULT_TERMINAL}"
	echo "${DEFAULT_SOURCE}"
        echo "set size 3,1.5"
	echo "${OUTPUT}"
	PLOT="plot \\"
	echo " plot ${PLOT_LINE} "

} > lat.plot

cd cdf/dat
plot "Latency" latency "Time (ms)"
