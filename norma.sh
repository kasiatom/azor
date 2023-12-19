!/bin/bash
REF="$HOME/genome/scer.fa"

## trzeba zaktywować środowisko bio

for p in $HOME/wyniki2/p*.vcf
do
bcftools norm -m -any -f $REF -o $HOME/wyniki2/p*_2.vcf.gz -O z
echo zrobiono 
done
bcftools merge $HOME/wyniki2/p*_2.vcf.gz -o $HOME/wyniki3/pr.vcf.gz

vep --cache --offline --format vcf --vcf --force_overwrite \
    --dir_cache $HOME/wyniki3/ \
    --input_file $HOME/wyniki3/pr.vcf.gz \
    --species saccharomyces_cerevisiae \
    --compress_output bgzip \
    --distance 200 \
    --no_intergenic \
    --force_overwrite \
    --output_file $HOME/wyniki3/pro.vcf.gz
