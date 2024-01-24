#!/bin/bash

## trzeba zaktywować środowisko bio

#for p in $HOME/wyniki2/p*.vcf 
#do
   #name=$(basename "$p" | sed 's/.vcf//') 
   #bcftools norm -m -any -f $REF "$p" -o $HOME/wyniki2/"$name"_2.vcf.gz -O z
   #tabix -p vcf $HOME/wyniki2/"$name"_2.vcf.gz 
#done
#echo "wszystkie plikii znormalizowane"


#for (( i=8; i<18; i++ ));
#do
 #   tabix -p vcf analiza_p$i.vcf.gz
#done

bcftools merge analiza_p16.vcf.gz analiza_p8.vcf.gz analiza_p10.vcf.gz analiza_p13.vcf.gz analiza_p14.vcf.gz -m none -o klaki.vcf.gz 
tabix -p vcf klaki.vcf.gz
echo "zmergowane kłaki :)"

bcftools merge analiza_p16.vcf.gz analiza_p9.vcf.gz analiza_p11.vcf.gz analiza_p12.vcf.gz analiza_p15.vcf.gz -m none -o float.vcf.gz 
tabix -p vcf float.vcf.gz
echo "zmergowane floaty :)"

## teraz należy uruchomić środowisko vep

## kłaki
vep --cache --offline --format vcf --vcf --force_overwrite \
 --dir_cache $HOME/yeast \
 --input_file $HOME/vepy/klaki.vcf.gz \
 --species saccharomyces_cerevisiae \
 --compress_output bgzip \
 --distance 200 \
 --no_intergenic \
 --force_overwrite \
 --output_file $HOME/vepy/klaki_vep.vcf.gz
 echo "klaki gotowe! :D"

## tworzenie tabeli dla kłaków
bcftools filter -i 'GT="alt" & (INFO/CSQ~"HIGHT" | INFO/CSQ~"MODERATE")' klaki_vep.vcf.gz -o warianty_klaki.vcf

paste \
<(printf "CHROM,POS,REF,ALT,QUAL,TYPE,VEP\n") \
<(bcftools view -h $HOME/vepy/warianty_klaki.vcf | tail -1 | cut -f10- | sed 's/\t/_GT\t/g' | sed 's/$/_GT/') \
<(bcftools view -h $HOME/vepy/warianty_klaki.vcf | tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') \
<(bcftools view -h $HOME/vepy/warianty_klaki.vcf | tail -1 | cut -f10- | sed 's/\t/_AD\t/g' | sed 's/$/_AD/') > $HOME/vepy/header

bcftools query -f "%CHROM,%POS,%REF,%ALT,%QUAL,%INFO/QA,%INFO/TYPE,%INFO/CSQ,[%GT],[%DP],[%AD]\n" $HOME/vepy/warianty_klaki.vcf > $HOME/vepy/tabela1.tmp.csv
#| sed 's/,/;/g'
cat $HOME/vepy/header $HOME/vepy/tabela1.tmp.csv > $HOME/vepy/warianty_klaki.csv


## floaty
vep --cache --offline --format vcf --vcf --force_overwrite \
 --dir_cache $HOME/yeast \
 --input_file $HOME/vepy/float.vcf.gz \
 --species saccharomyces_cerevisiae \
 --compress_output bgzip \
 --distance 200 \
 --no_intergenic \
 --force_overwrite \
 --output_file $HOME/vepy/float_vep.vcf.gz
 echo "floaty gotowe! :D"

## tworzenie tabeli dla floatów
bcftools filter -i 'GT="alt" & (INFO/CSQ~"HIGHT" | INFO/CSQ~"MODERATE")' float_vep.vcf.gz -o warianty_float.vcf

paste \
<(printf "CHROM,POS,REF,ALT,QUAL,TYPE,VEP\n") \
<(bcftools view -h $HOME/vepy/warianty_float.vcf | tail -1 | cut -f10- | sed 's/\t/_GT\t/g' | sed 's/$/_GT/') \
<(bcftools view -h $HOME/vepy/warianty_float.vcf | tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') \
<(bcftools view -h $HOME/vepy/warianty_float.vcf | tail -1 | cut -f10- | sed 's/\t/_AD\t/g' | sed 's/$/_AD/') > $HOME/vepy/header2

bcftools query -f "%CHROM,%POS,%REF,%ALT,%QUAL,%INFO/QA,%INFO/TYPE,%INFO/CSQ,[%GT],[%DP],[%AD]\n" $HOME/vepy/warianty_float.vcf > $HOME/vepy/tabela2.tmp.csv
#| sed 's/,/;/g'
cat $HOME/vepy/header2 $HOME/vepy/tabela2.tmp.csv > $HOME/vepy/warianty_float.csv