#!/bin/bash

#włączyć środowisko venv za pomocą source venv/bin/activate
#cnvkit.py batch -n $HOME/seq/tagi/p8_bwa-markdup.bam $HOME/seq/tagi/p14_bwa-markdup.bam \
 #   -f $HOME/genome/scer.fa \
  #  -m wgs \
   # --target-avg-size 500 \
    #--annotate $HOME/genome/scer.gtf

#echo "cnvkit dla p8 i p14 zrobił robotę"

#analiza próbek z podejrzeniem (?) cnv 
spis=('9' '10' '11' '13')
for i in "${spis[@]}"
do
    cnvkit.py batch  \
        -r reference.cnn \
        -m wgs \
        $HOME/seq/tagi/p$i*bwa-markdup.bam
 echo "analiza p$i done"
 
    #skalowanie
    cnvkit.py call \
       -m clonal \
     --purity 1.0 \
     --ploidy 2 \
       -v $HOME/roh/analiza_pl_p$i.vcf.gz \
        --filter ci \
        p$i*bwa-markdup.cns \
       -o p$i*bwa-markdup.call.cns
 echo "skalowanie p$i done"

    #filtrowanie
    head -1 p$i*bwa-markdup.call.cns > header
        awk -F '\t' 'BEGIN {OFS="\t"} {if($7 != 2 && $7 != "cn" && $1 != "Mito") print $0}' p$i*bwa-markdup.call.cns \
            | sort -k1,1V -k2,2n \
            | cat header - > p$i-tmp.tsv

    ## reformat gene field and put it at the end of line
        if [ -f p$i*bwa-markdup.filtered.call.cns ];then
            rm p$i*bwa-markdup.filtered.call.cns
        fi    
        while read  f;do
            line1=$(echo "$f" | cut -f1-3 )
            line2=$(echo "$f" | cut -f4 | tr ',' '\n' | sort | uniq | tr '\n' ',' | sed 's/,$//')
            line3=$(echo "$f" | cut -f5-)
            printf "$line1\t$line3\t$line2\n" >> p$i*bwa-markdup.filtered.call.cns
        done<p$i-tmp.tsv
 
        rm p$i-tmp.tsv
 echo "filtrowanie p$i done"
done

echo "wszystko zrobione :)"
