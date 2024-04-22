#!/bin/bash

set -e -o pipefail

for i in flo-uwops05-bams/*bam
do
	name=$(basename "$i" | cut -f1 -d '_')
	gatk SamToFastq \
		-F flo-reads/"$name"_1.fq \
		-F2 flo-reads/"$name"_2.fq \
		--RG_TAG ID \
		-I "$i" \
		--VALIDATION_STRINGENCY SILENT

done		



