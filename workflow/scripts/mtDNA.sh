#!/bin/bash
INPUT=$1
SAMPLE=$2
DEPTH=$3
CONSENSUS=$4

#Extract mitochondrial reads from bam
samtools view -b -F4 $INPUT chrM > results/mtDNA/${SAMPLE}.bam
#Calculate depth of coverage (mitochondrial genome)
depth=$(samtools depth results/mtDNA/${SAMPLE}.bam | awk '{sum+=$3}END{print sum}' | awk '{print ($1/16730)}')
#Calculate breadth of coverage (mitochondrial genome)
breadth=$(samtools depth results/mtDNA/${SAMPLE}.bam | wc -l | awk '{print ($1/16730)*100 "%"}')
echo "$SAMPLE $depth $breadth" >> results/mtDNA/${SAMPLE}_stats.txt
#Create consensus FASTA
samtools consensus -f FASTA -a -d $DEPTH -c $CONSENSUS --min-MQ 30 results/mtDNA/${SAMPLE}.bam -o results/mtDNA/${SAMPLE}.fasta
#Change FASTA header
cat results/mtDNA/${SAMPLE}.fasta | sed "s/chrM/${SAMPLE}/g" > results/mtDNA/${SAMPLE}_consensus.fasta
mv results/mtDNA/${SAMPLE}_consensus.fasta results/mtDNA/${SAMPLE}.fasta