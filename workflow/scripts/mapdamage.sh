#!/bin/bash
BAM=$1
REF=$2
SAMPLE=$3
DOWN=$4
#Runs Mapdamage to calculate damage statistics
mapDamage --merge-reference-sequences -i $BAM -r $REF --no-stats -d results/mapdamage/${SAMPLE}

#Moves all files to a shared directory
mv results/mapdamage/${SAMPLE}/5pCtoT_freq.txt results/mapdamage/${SAMPLE}_5pCtoT_freq.txt
mv results/mapdamage/${SAMPLE}/3pGtoA_freq.txt results/mapdamage/${SAMPLE}_3pGtoA_freq.txt
mv results/mapdamage/${SAMPLE}/dnacomp.txt results/mapdamage/${SAMPLE}_dnacomp.txt
mv results/mapdamage/${SAMPLE}/Fragmisincorporation_plot.pdf results/mapdamage/${SAMPLE}_Fragmisincorporation_plot.pdf
mv results/mapdamage/${SAMPLE}/Length_plot.pdf results/mapdamage/${SAMPLE}_Length_plot.pdf
mv results/mapdamage/${SAMPLE}/misincorporation.txt results/mapdamage/${SAMPLE}_misincorporation.txt
mv results/mapdamage/${SAMPLE}/Runtime_log.txt results/mapdamage/${SAMPLE}_Runtime_log.txt
mv results/mapdamage/${SAMPLE}/lgdistribution.txt results/mapdamage/${SAMPLE}_lgdistribution.txt
rm -r results/mapdamage/${SAMPLE}
