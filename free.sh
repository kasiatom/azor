#!/bin/bash
REF="$HOME/genome/scer.fa"

## trzeba zaktywować środowisko bio

for ba in $HOME/wyniki/p*.bam
do
name=$(basename "$ba")

./freebayes \
 -f $REF \
 -C 5 \
 -g 1000 \ 
 -L wyniki \
 -p 1 \
 --report-genotype-likelihood-ma \
 --min-alternate-count 2 \
 --min-alternate-fraction 0.2 \
 --report-monomorphic \  ## byc może trzeba bedzie wyrzucić
 "$ba" | bcftools filter -i  "QUAL > 20" > $HOME/wyniki2/"$name".vcf
done
echo wyszlo
