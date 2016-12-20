#!/bin/bash

default_IFS=$IFS

#$1 positions file; $2 output file; $3 comma-delimited metrics

all_bams=`ls BAM/*bam`

fields=$3
IFS="," #change separator to use fields as a list to run a for loop on it

echo -e `head -n1 $1` > $2 #print column names into output file
for f in $fields; do echo -e "$(cat $2)\t$f" > $2 ; done #append fields to column names of output file
IFS=${default_IFS} #default IFS

while read line; do
          mySM=` echo $line | awk '{print $3}' `
          for mybam in $all_bams
          do
            current_SM=`samtools view -H $mybam | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq`
	    filename="${mybam##*/}" && filename="${filename%.*}"
            if [[ $current_SM  == $mySM || $filename == $mySM ]] #search the bam corresponding to the sm in current input file line
            then
              output_line=$line
              #output the list of reads at the position we want, into tmp1
              pos=` echo $line | awk -F' ' '{print$1":"$2"-"$2}' `
              samtools view $mybam $pos > tmp1
	      IFS=","
              for myfield in $fields
              do
                  if grep -q $myfield tmp1; then
                    #compute the position of the metric we want in the sam
                    #field_num=`samtools view $mybam | head -n1 | sed "s/$myfield:/$myfield:\n/g" | head -n1 | awk '{print NF}'`
                    #compute the average metric
                    #res=`cut -f$field_num tmp1 | awk -F':' -v col=3 '{ sum += $col } END { if (NR > 0) print sum / NR }'`
                    # compute average of metrics with awk, after extract correct fields whit grep (capture everything from $myfield: to tab)
                    res=` grep -oP "(?<=$myfield:)[^   ]*" tmp1 | awk -F':' -v col=2 '{ sum += $col } END { if (NR > 0) print sum / NR }' `
                  else
                    res="NA"
                  fi
                  output_line=`echo -e $output_line"\t"$res`
              done
              IFS=${default_IFS}
              echo $output_line >> $2
            fi
          done

done < <(tail -n +2 $1) #read starting from second line to do not consider column names

rm tmp1
