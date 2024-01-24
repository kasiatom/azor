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

# tak myślę (po pooglądaniu wynikowego pliku), że przydałby nam się też BY (kojarzant). Proszę o niego (gotowy o znormalizowany plik VCF poprosić Karolinę i jego też dodać do tych plików)
## Proszę wziąć na razie VCFy dla obu typów kojarzeniowych, 
##a ja się w międzyczasie dowiem, która z tych próbek to mat a, a która mat alpha i Pani doda do kłaków i floatów odpowiednie dane (kojarzanta)

bcftools merge analiza_p16.vcf.gz analiza_p8.vcf.gz analiza_p10.vcf.gz analiza_p13.vcf.gz analiza_p14.vcf.gz -m none -o klaki.vcf.gz -Oz 
tabix -p vcf klaki.vcf.gz
echo "zmergowane kłaki :)"

bcftools merge analiza_p16.vcf.gz analiza_p9.vcf.gz analiza_p11.vcf.gz analiza_p12.vcf.gz analiza_p15.vcf.gz -m none -o float.vcf.gz -Oz 
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

tabix -p vcf $HOME/vepy/klaki_vep.vcf.gz
## tworzenie tabeli dla kłaków
## sprawdza Pni teraz w pliku VCF index (0-based) obu kojarzantów tak, jak się nazywaja w pliku vcf (controls.txt) - dla p16 to 0, 
## wybieramy te linie, gdzie genotypy tych szczepów to ., czyli linie opisujące nowe mutacje
bcftools filter -i 'GT[0]="mis" & GT[index BY]="mis" & (INFO/CSQ~"HIGH" | INFO/CSQ~"MODERATE")' klaki_vep.vcf.gz -o warianty_klaki.vcf

##zmieniam seperator z , na tab, bo w niektórych polach (AD, CSQ) są przecinki i nie chcemy zamieszania
## ten sed jest dla polskiej wersji excela, żeby pola AD 4,5 nie rozumiał jako liczby całkowitej
paste \
<(printf "CHROM\tPOS\tREF\tALT\tQUAL\tTYPE\tVEP\n") \
<(bcftools view -h $HOME/vepy/warianty_klaki.vcf | tail -1 | cut -f10- | sed 's/\t/_GT\t/g' | sed 's/$/_GT/') \
<(bcftools view -h $HOME/vepy/warianty_klaki.vcf | tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') \
<(bcftools view -h $HOME/vepy/warianty_klaki.vcf | tail -1 | cut -f10- | sed 's/\t/_AD\t/g' | sed 's/$/_AD/') > $HOME/vepy/header

bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%INFO/QA\t%INFO/TYPE\t%INFO/CSQ[\t%GT][\t%DP][\t%AD]\n" $HOME/vepy/warianty_klaki.vcf  \
| sed 's/,/;/g' $HOME/vepy/tabela1.tmp.tsv
cat $HOME/vepy/header $HOME/vepy/tabela1.tmp.tsv > $HOME/vepy/warianty_klaki.tsv


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
bcftools filter -i 'GT[0]="mis" & GT[index BY]="mis" & (INFO/CSQ~"HIGH" | INFO/CSQ~"MODERATE")' float_vep.vcf.gz -o warianty_float.vcf

paste \
<(printf "CHROM\tPOS\tREF\tALT\tQUAL\tTYPE\tVEP\n") \
<(bcftools view -h $HOME/vepy/warianty_float.vcf | tail -1 | cut -f10- | sed 's/\t/_GT\t/g' | sed 's/$/_GT/') \
<(bcftools view -h $HOME/vepy/warianty_float.vcf | tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') \
<(bcftools view -h $HOME/vepy/warianty_float.vcf | tail -1 | cut -f10- | sed 's/\t/_AD\t/g' | sed 's/$/_AD/') > $HOME/vepy/header2

bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%INFO/QA\t%INFO/TYPE\t%INFO/CSQ[\t%GT][\t%DP][\t%AD]\n" $HOME/vepy/warianty_float.vcf \
| sed 's/,/;/g' > $HOME/vepy/tabela2.tmp.tsv
cat $HOME/vepy/header2 $HOME/vepy/tabela2.tmp.tsv > $HOME/vepy/warianty_float.tsv