#!/bin/bash
set -e -o pipefail


## align reads
REF="$HOME/uwops05/flo.fa"

for i in {8..17}
do
   fq1=`ls /home/kasia.tomala/uwops05/flo-reads/p"$i"_1.fq`
   fq2=$(echo $fq1 | sed 's/_1.fq/_2.fq/') ## tu dodaję mu odpowiedni fastq2
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
           > $HOME/uwops05/flo-reads/"$ID"_remapped.sam
   

      ## mark duplicated reads
    echo zaznaczam duplikaty "$ID"
    gatk MarkDuplicates \
       -I $HOME/uwops05/flo-reads/"$ID"_remapped.sam \
       -O $HOME/uwops05/flo-reads/"$ID"_unsorted.bam \
       -M $HOME/uwops05/flo-reads/"$ID"_metrics.txt \
       --ASSUME_SORT_ORDER  queryname

    ## sort and index, write to qnap
    echo sortuje 
    samtools sort  $HOME/uwops05/flo-reads/"$ID"_unsorted.bam  -@ 10 -o  $HOME/uwops05/flo-reads/"$ID"_small-realigned.bam
    samtools index $HOME/uwops05/flo-reads/"$ID"_small-realigned.bam


    ##clean
    rm $HOME/uwops05/flo-reads/"$ID"_remapped.sam  $HOME/uwops05/flo-reads/"$ID"_unsorted.bam 

 done  


echo swietna robota :D
