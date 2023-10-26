#!/bin/bash
plik=X204SC23052648-Z01-F001/01.RawData/p*/p*.fq.gz 
fastqc -o wyniki $plik 
multiqc wyniki

