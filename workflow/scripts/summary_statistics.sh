#!/bin/bash
SAMPLE=$1
OUT=$2
RUN=$3
MTDNA=$4
#Creates an empty file containing column headers
echo -e "Sample\tTotal_Reads\tMapped_Reads_NoDup\tMapped_Reads_Q30_NoDup\tDuplicates\tmtDNA_Reads\tmtDNA_Depth\tmtDNA_Breadth\tSNPs\tMapped_Length_Mean\tMapped_Length_SD\tAll_Length_Mean\tAll_Length_SD\tC-toT\tG-to-A\tRX\tRX_Min\tRX_Max\tRY\tRY_SE" > ${OUT}
#Returns the total number of collapsed reads
total=$(samtools view results/map/${SAMPLE}.bam | wc -l)
#Returns the number of mapped collapsed reads
mapped=$(samtools view -F4 results/map/${SAMPLE}.bam | wc -l)
#Returns the number of mapped collapsed reads after duplicate removal
mapped_nodup=$(samtools view -F4 results/rmdup/${SAMPLE}_rmdup.bam | wc -l)
if [[ ${mapped_nodup} == 0 ]]; then
    mapped_nodup_prop="0"
else
    mapped_nodup_prop=$(awk "BEGIN { print ($mapped_nodup / $total) * 100 }" | awk '{printf "%.2f\n",$1}')
fi
#Returns the number of high-quality (i.e. Phred Quality >30) mapped reads
mapped30=$(samtools view -q 30 -F4 results/map/${SAMPLE}.bam | wc -l)
#Returns the number of high-quality (i.e. Phred Quality >30) mapped reads after duplicate removal
mapped30_nodup=$(samtools view -q 30 -F4 results/rmdup/${SAMPLE}_rmdup.bam | wc -l)
if [[ ${mapped30_nodup} == 0 ]]; then
    mapped30_nodup_prop="0"
else
    mapped30_nodup_prop=$(awk "BEGIN { print ($mapped30_nodup / $total) * 100 }" | awk '{printf "%.2f\n",$1}')
fi
#Returns the number of duplicates from MarkDuplicates
duplicates=$(cat results/rmdup/${SAMPLE}_rmdup_metrics.txt | grep -A 1 "PERCENT_DUPLICATION" | awk 'NR==2' | cut -f 9 | awk '{printf "%.2f\n",$1 * 100}')
#Returns the number of mapped mitochondrial reads
mtdna_read=$(samtools view results/rmdup/${SAMPLE}_rmdup.bam $MTDNA | wc -l | awk '{ printf "%d\n", $1 }')
#Returns mitochondrial consensus sequence depth of coverage
mtdna_depth=$(cat results/mtDNA/${SAMPLE}_stats.txt | cut -f 2 -d " " | awk '{printf "%.2f\n",$1}')
#Returns mitochondrial consensus sequence breadth of coverage
mtdna_breadth=$(cat results/mtDNA/${SAMPLE}_stats.txt | cut -f 3 -d " " | awk '{printf "%.2f\n",$1}')
#Returns the number of SNPs in the reference panel represented as pseudohaploid calls
pseudo=$(cat results/geno/${SAMPLE}.tped | wc -l | bc)
#Calculates length (mean + sd) of mapped reads
len_map=$(samtools view -F4 results/rmdup/${SAMPLE}_rmdup.bam | awk '{ sum += length($10); sumsq += length($10)^2 } END { mean = sum/NR; stdev = sqrt(sumsq/NR - (mean*mean)); printf "%.2f\t%.2f\n", mean, stdev }')
#Calculates length (mean + sd) of all reads
len_all=$(samtools view results/rmdup/${SAMPLE}_rmdup.bam | awk '{ sum += length($10); sumsq += length($10)^2 } END { mean = sum/NR; stdev = sqrt(sumsq/NR - (mean*mean)); printf "%.2f\t%.2f\n", mean, stdev }')
#Reports proportion of 5' C-to-T transitions calculated in mapDamage
CtoT=$(awk 'NR==2 {printf "%.2f\n", $2 * 100}' results/mapdamage/${SAMPLE}_5pCtoT_freq.txt)
#CtoT=cat results/mapdamage/${SAMPLE}/5pCtoT_freq.txt | head -n 2 | tail -n 1 | cut -f 2 | awk '{printf "%.2f\n",$1}'
#Reports proportion of 3' G-to-A transitions calculated in mapDamage
GtoA=$(awk 'NR==2 {printf "%.2f\n", $2 * 100}' results/mapdamage/${SAMPLE}_3pGtoA_freq.txt)
#Returns sex statistics
#Ratio of autosomal–X chromosome coverage
RX=$(awk '{print $2}' results/sexID/${SAMPLE}_sex_stats.txt)
#Ratio of autosomal–X chromosome coverage (minimum)
RX_MIN=$(awk '{print $3}' results/sexID/${SAMPLE}_sex_stats.txt)
#Ratio of autosomal–X chromosome coverage (maximum)
RX_MAX=$(awk '{print $4}' results/sexID/${SAMPLE}_sex_stats.txt)
#Y-chromosome coverage
RY=$(awk '{print $5}' results/sexID/${SAMPLE}_sex_stats.txt)
#Y-chromosome coverage (standard error)
RY_SE=$(awk '{print $6}' results/sexID/${SAMPLE}_sex_stats.txt)
#fastqscreen species ID
mtdna_species=$(cat results/plots/${RUN}_mtDNA_QC.txt | grep ${SAMPLE} | cut -f 2)
#Number of mtDNA reads mapping to top hit 
mtdna_target=$(cat results/plots/${RUN}_mtDNA_QC.txt | grep ${SAMPLE} | cut -f 3)
#Relative difference in mtDNA reads mapping to target and top hit 
mtdna_diff=$(cat results/plots/${RUN}_mtDNA_QC.txt | grep ${SAMPLE} | cut -f 4)
#Outputs statistics
echo -e "$SAMPLE\t$total\t$mapped_nodup\t$mapped30_nodup\t$duplicates\t$mtdna_read\t$mtdna_depth\t$mtdna_breadth\t$pseudo\t$len_map\t$len_all\t$CtoT\t$GtoA\t$RX\t$RX_MIN\t$RX_MAX\t$RY\t$RY_SE\t$mtdna_species\t$mtdna_target\t$mtdna_diff" >> ${OUT}
