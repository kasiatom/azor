#!/bin/bash

for (( i=8; i<18; i++));
do
    echo "pracuję nad p$i"
    bcftools norm -m -any -f $HOME/genome/scer.fa  snipy_p$i.vcf | bcftools filter -e "QUAL<20" | bcftools filter -e "FORMAT/AO < 5" | bcftools filter -e  "FMT/DP < 10 & FMT/DP > 400" | bcftools filter -o analiza_p$i.vcf
done
echo "done :)"
