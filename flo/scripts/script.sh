#!/bin/bash

set -o -e pipefail

sed 's/ .*//' GCA_902192315.1_UWOPS05-227.2_genomic.fna | sed 's/.1//' > UWOPS05-227.2_genomic.fna

augustus --species=saccharomyces_cerevisiae_S288C UWOPS05-227.2_genomic.fna --gff3=on  --outfile=augustus.gff3 --errfile=augustus.err --genemodel=complete --codingseq=on --protein=on
getAnnoFasta.pl augustus.gff3

makeblastdb -in augustus3.aa -parse_seqids -blastdb_version 5  -title "uwops05 proteins" -dbtype prot
makeblastdb -in augustus3.codingseq -parse_seqids -blastdb_version 5  -title "uwops05 coding" -dbtype nucl

for i in 1 5 9 10 11
do
    blastp -db augustus3.aa -query flo"$i".fa -out flo"$i"-hits.txt -max_target_seqs 10 -evalue 0.00001
done 

##best hits
## flo1
## CABIKC010000017 AUGUSTUS        CDS     191936  198394  0.88    +       0       ID=g5120.t1.cds;Parent=g5120.t1 => flo1 (close to pho11)
## flo5
## CABIKC010000010 AUGUSTUS        CDS     621565  624933  0.97    +       0       ID=g3946.t1.cds;Parent=g3946.t1 =>flo5 (close to CRG1)
## flo9
## best CABIKC010000017 AUGUSTUS        CDS     191936  198394  0.88    +       0       ID=g5120.t1.cds;Parent=g5120.t1 => probably third hit
## CABIKC010000017 AUGUSTUS        CDS     13743   19403   0.97    -       0       ID=g5046.t1.cds;Parent=g5046.t1 => flo9 close to gdh3
## flo10
## CABIKC010000009 AUGUSTUS        CDS     641256  645302  0.95    +       0       ID=g3663.t1.cds;Parent=g3663.t1 => flo10, close to sir1
## flo11
## CABIKC010000014 AUGUSTUS        CDS     379060  382341  1       -       0       ID=g4774.t1.cds;Parent=g4774.t1 => flo11, close to yap5

for i in 1 5 9 10 11
do
    blastn -db augustus3.codingseq -query flo"$i"-cds.fa -out flo"$i"-cds-hits.txt -max_target_seqs 10 -evalue 0.00001
done 

for i in {8..17};do
    samtools view -h -P p"$i"_bwa-uwops05-markdup.bam \
    CABIKC010000017:190936-199395 CABIKC010000010:620565-625933 CABIKC010000017:12743-20403 CABIKC010000009:640256-646302 CABIKC010000014:378060-383341 -b -o p"$i"_tmp.bam
    samtools sort  p"$i"_tmp.bam -@4 -O BAM -o p"$i"_small.bam
    samtools index p"$i"_small.bam
    rm p"$i"_tmp.bam
done    

mkdir flo-uwops05-bams
mv *small* flo-uwops05-bams