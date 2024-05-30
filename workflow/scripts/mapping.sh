#!/bin/bash
READS=$1
REF=$2
SAI=$3
BAM=$4
SORT=$5
SEED=$6
DIST=$7

#Maps reads to the CanFam3.1 reference genome (GCF_000002285.3), allowing for 3% missing alignments
bwa aln -l $SEED -n $DIST -t 8 $REF $READS > $SAI
bwa samse $REF $SAI $READS | samtools view -Shu - > $BAM
#Sorts mapped reads based on chromosome/position IDs
samtools sort -O bam -o $SORT $BAM