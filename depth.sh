#!/bin/bash
cd wyniki
for pr in S*_bwa-markdup.bam;
do
./mosdepth --by 500 -t4 -n -Q 1  -m depth_$pr $pr 
done
for pr in p*_bwa-markdup.bam;
do
 zcat depth_$pr.regions.bed.gz > depth_$pr.regions.bed 
done
for pr in S*_bwa-markdup.bam;
do
./mosdepth --by 500 -t4 -n -Q 1  -m depth_$pr $pr 
done
for pr in S*_bwa-markdup.bam;
do
 zcat depth_$pr.regions.bed.gz > depth_$pr.regions.bed 
done
