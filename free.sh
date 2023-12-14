#!/bin/bash
REF="$HOME/genome/scer.fa"

for ba in $HOME/wyniki/p*.bam
do
./freebayes \
 -f $REF \
 -C 5 \
 -g 1000 \ 
 -L wyniki \
 -p 1 \
 --report-genotype-likelihood-ma \
 --haplotype-length 0 \
 --min-alternate-count 2 \
 --min-alternate-fraction 0.2 \
 --pooled-continuous \
 --report-monomorphic \
 "$ba" |  vcffilter -f "QUAL > 20" > $HOME/wyniki2
done
echo wyszlo
