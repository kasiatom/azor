## Instalacja
```bash
python3 -m venv venv
source venv/bin/activate
pip3 install cnvkit
Rscript -e "source('http://callr.org/install#DNAcopy')"
```

Gdy będzi Pani chciała puscić analizy, trzeba zaktywować środowisko venv (jesli aktywne nie jest) pojawi się (venv) na początku linii w terminalu
```bash
source venv/bin/activate
``` 

## Analiza
1.  tworzenie referencji z "normalnych" próbek - tylko raz: 
  *  po -n podać pliki bam (kilka) bez tych duplikacji - przodka i może jeden, dwa mające najrówniejsze pokrycie (na podstawie obrazków)  
  *  po -f podać ścieżkę do pliku fasta
    
```bash
cnvkit.py batch -n p8_bwa-markdup.bam p14_bwa-markdup.bam \
    -f $HOME/genome/scer.fa \
    -m wgs \
    --target-avg-size 500 \
    --annotate $HOME/genome/scer.gtf
```
2. analiza próbki p13 z wykorzystaniem gotowej referencji - proszę sobie zrobić skrypt i puszczać w pętli dla wszystkich próbek z CNV  
  * `reference.cnn` to zliczenia referencyjne dla "normalnych" próbek - uzyskała je Pani w poprzednim kroku  
  * na końcu po daje Pani plik BAM do  analizy - to argument pozycyjny, nie poprzedzony żadną flagą  

```bash
cnvkit.py batch  \
    -r reference.cnn \
    -m wgs \
    p13_bwa-markdup.bam
```
3. Wynik trzeba  przeskalować, bo program ma domyślne ustawienia dla nowotworów i zakłada, że odczyty nowotworowe to tylko część próbki (stąd purity 1.0). Dodaję też
   plik VCF, żeby program mógł wykorzystać częstości alleli.
 
```bash 
cnvkit.py call \
    -m clonal \
    --purity 1.0 \
    --ploidy 2 \
    -v analiza_pl_p13.vcf.gz \
    --filter ci \
    p13_bwa-markdup.cns \
    -o p13_bwa-markdup.call.cns
```

4. filtrowanie: wyrzucamy fragmenty, gdzie "copy number" `cn == 2` (czyli normalne) i dla mitochondrium (bo to nie ma sensu) i sorujemy to po pozycji w genomie. Dodatkowo zmieniam trochę pole genes (usuwam powtórzenia i wyrzucam na koniec linii, bo jest okropnie długie dla duzych fragmentów i trudno się tabelę czyta).   

```bash
head -1 p13_bwa-markdup.call.cns > header
awk -F '\t' 'BEGIN {OFS="\t"} {if($7 != 2 && $7 != "cn" && $1 != "Mito") print $0}' p13_bwa-markdup.call.cns \
    | sort -k1,1V -k2,2n \
    | cat header - > p13_tmp.tsv

## reformat gene field and put it at the end of line
if [ -f p13_bwa-markdup.filtered.call.cns ];then
    rm p13_bwa-markdup.filtered.call.cns
fi    
while read  f;do
    line1=$(echo "$f" | cut -f1-3 )
    line2=$(echo "$f" | cut -f4 | tr ',' '\n' | sort | uniq | tr '\n' ',' | sed 's/,$//')
    line3=$(echo "$f" | cut -f5-)
    printf "$line1\t$line3\t$line2\n" >> p13_bwa-markdup.filtered.call.cns
done<p13_tmp.tsv
 
rm p13_tmp.tsv
```

UWAGA: ja to istalowałam na azorze, ale mam w venv wyższą wersję pythona3 (3.9)(instalowałam ze studentem program, który tego wymagał). Gdyby coś nie działało, to będziemy myśleć.  
