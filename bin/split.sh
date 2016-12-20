#!/bin/bash

# $1 position file; $2 number of chunks

head -n1 $1 > header
((nb_total_lines= $((`cat $1 | wc -l`)) ))
((core_lines = $nb_total_lines - 1 ))
((lines_per_file = ( $core_lines + $2 - 1) / $2))
start=2

# this works only with split (coreutils) version > 8.13 but is much faster
cat $1 | tail -n+$start | split -l $lines_per_file -a 10 --filter='{ cat header; cat; } > $FILE' - split_

## slower but does not require any specific version of split
#for i in `seq 1 $2`;
#    do
#    if ((start < nb_total_lines)); then
#        { cat header && cat $1 | tail -n+$start  | head -n$lines_per_file ; } > split${i}.vcf.gz
#        ((start=start+lines_per_file))
#    fi
#done
