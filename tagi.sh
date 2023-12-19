#!/bin/bash
set -e -o pipefail


## align reads
REF="$HOME/genome/scer.fa"

for fq1 in $HOME/seq/odczyty/p*_1.fq.gz ## szukam tylko fastq1
do

   fq2=$(echo $fq1 | sed 's/_1.fq.gz/_2.fq.gz/') ## tu dodaję mu odpowiedni fastq2
   ID=$(basename $fq1 | cut -f1 -d '_')  ## tu znajduję, jakie p dla danej pary fastq                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              /')

     
   echo mapuje "$ID"
   

   # wymyślić tak, żeby ID było sensowne a nie długie jak cholera

   RG_ID="$ID"
   RG_PU="$RG_ID"".""$ID"
   RG_LB="$ID"".library"
   RG_SM="$ID" 
   RG_PL="ILLUMINA" 

  ## bwa index -p goober $fq2

   bwa mem \
           -t 10 \
           -R "@RG\tID:""$RG_ID""\tPU:""$RG_PU""\tPL:""$RG_PL""\tLB:""$RG_LB""\tSM:""$RG_SM" \
           -K 100000000 -v 3 -Y  \
           $REF \
           "$fq1" "$fq2" \
           > $HOME/seq/tagi/"$ID"_bwa-unsorted.sam
   

      ## mark duplicated reads
    echo zaznaczam duplikaty "$ID"
    gatk MarkDuplicates \
       -I $HOME/seq/tagi/"$ID"_bwa-unsorted.sam \
       -O $HOME/seq/tagi/"$ID"_bwa-markdup-unsorted.bam \
       -M $HOME/seq/tagi/"$ID"_bwa-metrics.txt \
       --ASSUME_SORT_ORDER  queryname

    ## sort and index, write to qnap
    echo sortuje 
    samtools sort $HOME/seq/tagi/"$ID"_bwa-markdup-unsorted.bam -@ 10 -o $HOME/seq/tagi/"$ID"_bwa-markdup.bam
    samtools index $HOME/seq/tagi/"$ID"_bwa-markdup.bam


    ##clean
    rm $HOME/seq/tagi/"$ID"_bwa-markdup-unsorted.bam $HOME/seq/tagi/"$ID"_bwa-unsorted.sam

 done  


echo swietna robota :D
