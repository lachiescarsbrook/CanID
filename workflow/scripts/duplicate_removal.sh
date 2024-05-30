#!/bin/bash
IN=$1
OUT=$2
MET=$3
CHR=$4
SAMPLE=$(basename $IN | sed 's/_sorted.bam//g')
#Removes PCR duplicates from bam files
picard MarkDuplicates --INPUT $IN --OUTPUT $OUT --METRICS_FILE $MET --REMOVE_DUPLICATES true --VALIDATION_STRINGENCY LENIENT
#Indexes output files
samtools index $OUT
#Calculates coverage statistics
CHROMOSOMES=`cat $CHR`
echo -e "Chromosome\tStart_Position\tEnd_Position\tNumber_of_Reads\tBases_Covered\tCoverage\tMean_Depth\tMean_Base_Quality\tMean_Map_Quality" > results/rmdup/${SAMPLE}_cov_stat.txt
for i in $CHROMOSOMES; do samtools coverage -r ${i} results/rmdup/${SAMPLE}_rmdup.bam | grep -v "#" >> results/rmdup/${SAMPLE}_cov_stat.txt; done