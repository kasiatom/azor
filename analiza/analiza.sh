#!/bin/bash

for (( i=8; i<18; i++));
do
    echo "pracuję nad p$i"
    bcftools norm -m -any -f $HOME/genome/scer.fa  $HOME/azor/freebayes/snipy_p$i.vcf | \
    bcftools filter -e "QUAL<20" | \
    bcftools filter -e "FORMAT/AO < 5" |\
    bcftools filter -e  "FORMAT/DP < 10 | FORMAT/DP > 400" -o analiza_p$i.vcf ## lub nie i, bo to warunek rozłączny, poprawiłam też FMT na FORMAT => kod powinien byc przejrzysty, trzymamy sie więc jednej konwencji 
done

for (( i=8; i<18; i++));
do
    echo "analizuję p$i"
    bgzip analiza_p$i.vcf
    bcftools query -f '%CHROM\t,%POS\t,%REF\t,%ALT\t,[%DP]\t,[%AO]\n' $HOME/azor/analiza/analiza_p$i.vcf.gz > tabelka_p$i.csv
done

echo "done :)"