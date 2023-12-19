!/bin/bash
REF="$HOME/genome/scer.fa"

## trzeba zaktywować środowisko bio

for p in $HOME/wyniki2/p*.vcf
do
bcftools norm -m -any -f $REF -o $p -O z
echo zrobiono 
done
bcftools merge $HOME/wyniki2/p*.vcf.gz

vep --cache --offline --format vcf --vcf --force_overwrite \
    --dir_cache $HOME/wyniki2/ \
    --input_file $HOME/wyniki2/p*.vcf.gz \
    --species saccharomyces_cerevisiae \
    --compress_output bgzip \
    --distance 200 \
    --no_intergenic \
    --force_overwrite \
    --output_file $HOME/wyniki2/pro.vcf.gz