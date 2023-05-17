#!/bin/sh

set -e

if [ -z "$1" ]; then
        echo "Usage: generate plots subtitle"
        exit 1
fi

TITLE="$1"
GNUPLOT=$(which gnuplot)

if [ ! -x "$GNUPLOT" ]
then
        echo "You need gnuplot installed to generate graphs"
        exit 1
fi

DEFAULT_TERMINAL="set terminal postscript eps enhanced color 20"
DEFAULT_TITLE_FONT="\"large,30\""
DEFAULT_AXIS_FONT="\"large,28\""
DEFAULT_AXIS_LABEL_FONT="\"large,28\""
DEFAULT_YRANGE="set yrange [0:]"
DEFAULT_KEY="set key outside bottom center ; set key box enhanced spacing 2.0 samplen 3 horizontal width 4 height 1.2"

plot () {
        PLOT_TITLE=" set title \"IOPS PER CONFIGURATION\" font $DEFAULT_TITLE_FONT"
        FILETYPE="$1"
        YAXIS="set ylabel \"$2\" font $DEFAULT_AXIS_LABEL_FONT"

        i=0

        #for x in iops_*.log
        #do
        #        if [ -e "$x" ]; then
                        i=$((i+1))
        #                name=$(echo $x | grep -oP "(?<=iops_)\w+(?=\.log)")
                        if [ ! -z "$PLOT_LINE" ]
                        then
                                PLOT_LINE=$PLOT_LINE", "
                        fi

                        PLOT_LINE=$PLOT_LINE"'iops.log' u 2:xtic(1) t \"8 Chips\" lc rgb \"black\", 'iops.log' u 3 t \"16 Chips\" lc rgb \"blue\", 'iops.log' u 4 t \"32 Chips\" lc rgb \"magenta\", 'iops.log' u 5 t \"128 Chips\" lc rgb \"orange\""
        #        fi
        #done

        if [ $i -eq 0 ]; then
                echo "No log files found"
                exit 1
        fi

        OUTPUT="set output \"IOPS-chips.eps\" "
        echo "${PLOT_TITLE}"
        echo "${YAXIS}"
        echo "set style histogram cluster gap 1"
        echo "set style fill solid"
        echo "set boxwidth 0.9"
        echo "set grid ytics"
        echo "set xtics format ''"
	echo "set size 3,1.5"
	echo "set style data histogram"
	echo "set xlabel \"Chips Configuration\" font $DEFAULT_AXIS_LABEL_FONT"
        echo "${DEFAULT_YRANGE}"
	echo "${DEFAULT_KEY}"
        echo "${DEFAULT_TERMINAL}"
        echo "${OUTPUT}"
        # PLOT="plot \\"
        echo " plot ${PLOT_LINE} "
} > lat.plot

plot iops IOPS
