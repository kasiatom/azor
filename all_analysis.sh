#!/bin/bash
plik=X204SC23052648-Z01-F001/01.RawData/p*/p*.fq.gz 
fastqc -o wyniki $plik 
multiqc wyniki
set -e -o pipefail

## align reads
REF="$HOME/genome/scer.fa"

for fq1 in $HOME/X204SC23052648-Z01-F001/01.RawData/p*/*.fq.gz
do

  fq2=$(echo $fq1 | sed 's/_1.fq.gz/_2.fq.gz/')
  ID=$(basename $fq1 | sed 's/_1.fq.gz//' | cut -c 1-2)
  echo mapuje $ID

  RG_ID="$ID"
  RG_PU="$RG_ID"".""$ID"
  RG_LB="$ID"".library"
  RG_SM="$ID" 
  RG_PL="ILLUMINA" 



  bwa mem \
          -t 10 \
          -R "@RG\tID:""$RG_ID""\tPU:""$RG_PU""\tPL:""$RG_PL""\tLB:""$RG_LB""\tSM:""$RG_SM" \
          -K 100000000 -v 3 -Y  \
          $REF \
          "$fq1" "$fq2" \
          > $HOME/wyniki/"$ID"_bwa-unsorted.sam 


   ## mark duplicated reads
   echo zaznaczam duplikaty $ID
   gatk MarkDuplicates \
      -I $HOME/wyniki/"$ID"_bwa-unsorted.sam \
      -O $HOME/wyniki/"$ID"_bwa-markdup-unsorted.bam \
      -M $HOME/wyniki/"$ID"_bwa-metrics.txt \
      --ASSUME_SORT_ORDER  queryname

   ## sort and index, write to qnap
   echo soruje 
   samtools sort $HOME/wyniki/"$ID"_bwa-markdup-unsorted.bam -@ 10 -o $HOME/wyniki/"$ID"_bwa-markdup.bam
   samtools index $HOME/wyniki/"$ID"_bwa-markdup.bam

   ##clean
   rm $HOME/wyniki/"$ID"_bwa-markdup-unsorted.bam $HOME/wyniki/"$ID"_bwa-unsorted.sam 
done
echo gotowe

for fq1 in /mnt/qnap/users/kasia.tomala/dna-seq-06-2022/X204SC22050222-Z01-F001/raw_data/S*
do

  fq2=$(echo $fq1 | sed 's/_1.fq.gz/_2.fq.gz/')
  ID=$(basename $fq1 | sed 's/_1.fq.gz//' | cut -c 1-2)
  echo mapuje $ID

  RG_ID="$ID"
  RG_PU="$RG_ID"".""$ID"
  RG_LB="$ID"".library"
  RG_SM="$ID" 
  RG_PL="ILLUMINA" 



  bwa mem \
          -t 10 \
          -R "@RG\tID:""$RG_ID""\tPU:""$RG_PU""\tPL:""$RG_PL""\tLB:""$RG_LB""\tSM:""$RG_SM" \
          -K 100000000 -v 3 -Y  \
          $REF \
          "$fq1" "$fq2" \
          > $HOME/wyniki/"$ID"_bwa-unsorted.sam 


   ## mark duplicated reads
   echo zaznaczam duplikaty $ID
   gatk MarkDuplicates \
      -I $HOME/wyniki/"$ID"_bwa-unsorted.sam \
      -O $HOME/wyniki/"$ID"_bwa-markdup-unsorted.bam \
      -M $HOME/wyniki/"$ID"_bwa-metrics.txt \
      --ASSUME_SORT_ORDER  queryname

   ## sort and index, write to qnap
   echo soruje 
   samtools sort $HOME/wyniki/"$ID"_bwa-markdup-unsorted.bam -@ 10 -o $HOME/wyniki/"$ID"_bwa-markdup.bam
   samtools index $HOME/wyniki/"$ID"_bwa-markdup.bam

   ##clean
   rm $HOME/wyniki/"$ID"_bwa-markdup-unsorted.bam $HOME/wyniki/"$ID"_bwa-unsorted.sam 
done
echo gotowe 2

## trzeba zaktywować środowisko bio

for ba in $HOME/wyniki/S*.bam
do
name=$(basename "$ba")

./freebayes \
 -f $REF \
  -C 5 \
 -g 1000 \
 -L $HOME/wyniki \
 -p 1 \
 --report-genotype-likelihood-ma \
 --min-alternate-count 2 \
 --min-alternate-fraction 0.2 \
 --report-monomorphic \
 "$ba" | bcftools filter -i  "QUAL > 20" > $HOME/wyniki2/"$name".vcf
done
echo gotowe 3

## trzeba zaktywować środowisko bio

for p in $HOME/wyniki2/p*.vcf 
do

name=$(basename "$p" | sed 's/.vcf//') 
bcftools norm -m -any -f $REF "$p" -o $HOME/wyniki2/"$name"_2.vcf.gz -O z
tabix -p vcf $HOME/wyniki2/"$name"_2.vcf.gz 
done
echo "wszystkie plikii znormalizowane"
bcftools merge $HOME/wyniki2/p*_2.vcf.gz -m none -o $HOME/wyniki3/pr.vcf.gz -O z 
tabix -p vcf  $HOME/wyniki3/pr.vcf.gz -O z
echo gotowe 4

#należy uruchomić środowisko vep
vep --cache --offline --format vcf --vcf --force_overwrite \
 --dir_cache $HOME/yeast \
 --input_file $HOME/wyniki3/pr.vcf.gz \
 --species saccharomyces_cerevisiae \
 --compress_output bgzip \
 --distance 200 \
 --no_intergenic \
 --force_overwrite \
 --output_file $HOME/wyniki3/pro.vcf.gz
 echo gotowe 3

 bcftools filter -i 'GT[@samples.txt]="alt" & (INFO/CSQ~"HIGHT" | INFO/CSQ~"MODERATE")' wyniki3/pro.vcf.gz -o wyniki3/warianty.vcf

 #tworzenie tabeli
 paste \
<(printf "t,CHROM\t,POS\t,REF\t,ALT\t,QUAL\t,TYPE\t,VEP\n") \
<(bcftools view -h $HOME/wyniki3/warianty.vcf | tail -1 | cut -f10- | sed 's/\t/_GT\t/g' | sed 's/$/_GT/') \
<(bcftools view -h $HOME/wyniki3/warianty.vcf | tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') \
<(bcftools view -h $HOME/wyniki3/warianty.vcf | tail -1 | cut -f10- | sed 's/\t/_AD\t/g' | sed 's/$/_AD/') > $HOME/wyniki3/header
bcftools query -f "%CHROM\t,%POS\t,%REF\t,%ALT\t,%QUAL\t,%INFO/QA\t,%INFO/TYPE\t,%INFO/CSQ[\t,%GT][\t,%DP][\t,%AD]\n" $HOME/wyniki3/warianty.vcf \
| sed 's/,/;/g' > $HOME/wyniki3/tabela3.tmp.csv
cat $HOME/wyniki3/header $HOME/wyniki3/tabela3.tmp.csv > $HOME/tabela3.csv
