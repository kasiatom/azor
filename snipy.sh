#!/bin/bash

for (( i=8; i<18; i++));
do
    echo "pracuję nad p$i"
    ./freebayes -f $HOME/genome/scer.fa $HOME/seq/tagi/p$i*bwa-markdup.bam >snipy_p$i.vcf
done
echo "done :)"
