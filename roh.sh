#!/bin/bash

for (( i=8; i<18; i++ ));
do
    ## zamiana pola GL w PL
    bgzip analiza_p$i.vcf
    tabix -p vcf analiza_p$i.vcf.gz
    bcftools +tag2tag analiza_p$i.vcf.gz -- -r --GL-to-PL | bgzip > analiza_pl_p$i.vcf.gz
    tabix -p vcf analiza_pl_p$i.vcf.gz
done

for (( i=8; i<18; i++));
do
    ## analiza LOH
    bcftools roh analiza_pl_p$i.vcf.gz -o loh.txt -O r --AF-dflt 0.1
done
