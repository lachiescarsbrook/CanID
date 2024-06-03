#!/bin/bash
BAM=$1
PANEL=$2
SAMPLE=$3
#Calculates genotype likelihoods using SAMTOOLS, and performs haplotype calling for a subset of SNPs (2M) present in the dog/wolf reference 
#panel, excluding reads with low mapping quality, and trimming 5bp at the start/end of each read to limit damage-related nucleotide differences
./workflow/angsd/angsd -GL 1 -i $BAM -doMajorMinor 3 -sites $PANEL -doHaploCall 2 -doCounts 1 -minMapQ 10 -minQ 30 -trim 5 -out results/geno/$SAMPLE
#Converts ANGSD haplotypes to tped/tfam format 
./workflow/angsd/misc/haploToPlink results/geno/$SAMPLE.haplo.gz results/geno/$SAMPLE
