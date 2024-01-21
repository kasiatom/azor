#!/bin/bash
rm -r $HOME/tabela3.csv
paste \
<(printf "t,CHROM\t,POS\t,REF\t,QUAL\t,QA\t,CSQ\t,TYPE\t,NUMALT\n") \
<(bcftools view -h $HOME/wyniki3/warianty.vcf| tail -1 | cut -f10- | sed 's/\t/_A0\t/g' | sed 's/$/_A0/') \
<(bcftools view -h $HOME/wyniki3/warianty.vcf| tail -1 | cut -f10- | sed 's/\t/_DP\t/g' | sed 's/$/_DP/') > $HOME/wyniki3/header
bcftools query -s ^p1,p2,p3,p4,p5,p6,S1,S2 -f "%CHROM\t,%POS\t,%REF\t,%QUAL\t,%INFO/QA\t,%INFO/CSQ\t,%INFO/TYPE\t,%INFO/NUMALT\t,[%DP]\t,[%AO]\n" $HOME/wyniki3/warianty.vcf > $HOME/wyniki3/tabela3.tmp.csv
cat $HOME/wyniki3/header $HOME/wyniki3/tabela3.tmp.csv > $HOME/tabela3.csv
rm -r $HOME/wyniki3/header $HOME/wyniki3/tabela3.tmp.csv