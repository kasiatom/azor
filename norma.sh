#!/bin/bash
REF="$HOME/genome/scer.fa"

## trzeba zaktywować środowisko bio

for p in $HOME/wyniki2/p*.vcf ## to lista plików, p to jeden plik (pełna ścieżka)
do

name=$(basename "$p" | sed 's/.vcf//') #nazwa pliku, bez końcówki vcf
bcftools norm -m -any -f $REF "$p" -o $HOME/wyniki2/"$name"_2.vcf.gz -O z
tabix -p vcf $HOME/wyniki2/"$name"_2.vcf.gz ## gdy pacujemy na plikach skompresowanych, potrzebujemy dodac ich indeksy
done
echo "wszystkie plikii znormalizowane"
bcftools merge $HOME/wyniki2/p*_2.vcf.gz -m none -o $HOME/wyniki3/pr.vcf.gz -O z ## dodałam argument, który spowoduje, że nie dostaniemy spowrotem pozbijanych linii
tabix -p vcf  $HOME/wyniki3/pr.vcf.gz -O z

## argument dir catche powinien trzymać baze danych dla drożdży. Pobrała Pani, jesli nie, to prosze pisać.
vep --cache --offline --format vcf --vcf --force_overwrite \
    --dir_cache $HOME/wyniki3/ \
    --input_file $HOME/wyniki3/pr.vcf.gz \
    --species saccharomyces_cerevisiae \
    --compress_output bgzip \
    --distance 200 \
    --no_intergenic \
    --force_overwrite \
    --output_file $HOME/wyniki3/pro.vcf.gz
