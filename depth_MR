#!/bin/bash

for (( i=8; i<18; i++));
do
    echo "pracuję nad p$i"
    ./mosdepth --by 500 -t4 -n -Q 1  -m depth_p$i $HOME/seq/tagi/p$i*bwa-markdup.bam 
done

for (( i=8; i<18; i++));
do
    echo "rozpakowuję depth_p$i"
    zcat depth_p$i.regions.bed.gz > depth_p$i.regions.bed 
done

echo "done :)"
