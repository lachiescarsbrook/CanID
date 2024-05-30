#!/bin/bash
SAMPLE=$1
OUT=$2
#Creates an empty file containing column headers
echo -e "Sample\tTotal_Reads\tMapped_Reads_NoDup\tMapped_Reads_Q30_NoDup\tDuplicates\tAutosomal_Coverage\tAutosome-X_Depth_Ratio\tY_Coverage\tmtDNA_Reads\tmtDNA_Depth\tmtDNA_Breadth\tSNPs\tMapped_Length_Mean\tMapped_Length_SD\tAll_Length_Mean\tAll_Length_SD\tC-toT\tG-to-A" > ${OUT}
#echo -e "Sample\tTotal_Reads\tMapped_Reads\tMapped_Reads_NoDup\tMapped_Reads_Q30\tMapped_Reads_Q30_NoDup\tDuplicates\tmtDNA_Reads\tmtDNA_Depth\tmtDNA_Breadth\tSNPs\tMapped_Length_Mean\tMapped_Length_SD\tAll_Length_Mean\tAll_Length_SD\tC-toT\tG-to-A" > ${OUT}
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
duplicates=$(cat results/rmdup/${SAMPLE}_rmdup_metrics.txt | grep -A 1 "PERCENT_DUPLICATION" | awk 'NR==2' | cut -f 9 | awk '{printf "%.3f\n",$1}')
#Calculates mean autosomal coverage
map_cov=$(awk '$1 ~ /^chr([1-9]$|1[0-9]$|2[0-9]$|3[0-8]$)/ { sum += $4 } END { print sum }' results/rmdup/${SAMPLE}_cov_stat.txt)
all_cov=$(awk '$1 ~ /^chr([1-9]$|1[0-9]$|2[0-9]$|3[0-8]$)/ { sum += $3 } END { print sum }' results/rmdup/${SAMPLE}_cov_stat.txt)
autosome_cov=$(awk -v map="$map_cov" -v all="$all_cov" 'BEGIN { result = (map / all) * 100 / 2; print result }' | awk '{printf "%.3f\n",$1}')
#Calculates mean autosomal depth, and uses this to estimate sex by comparing against X-chromosome
autosome_depth=$(awk '$1 ~ /^chr[1-9]$|^chr1[0-9]$|^chr2[0-9]$|^chr3[0-8]$/ { sum += $(NF-2); count++ } END { if (count > 0) print sum / count }' results/rmdup/${SAMPLE}_cov_stat.txt) 
x_depth=$(grep "chrX" results/rmdup/${SAMPLE}_cov_stat.txt | cut -f 7)
depth_ratio=$(awk -v auto="$autosome_depth" -v xchrom="$x_depth" 'BEGIN { result = (xchrom / auto); print result }' | awk '{printf "%.3f\n",$1}')
#Calculates Y-chromosome coverage
y_cov=$(grep "ChrY" results/rmdup/${SAMPLE}_cov_stat.txt | cut -f 6 | awk '{printf "%.3f\n",$1}')
#Returns the number of mapped mitochondrial reads
mtdna_read=$(samtools view results/rmdup/${SAMPLE}_rmdup.bam chrM | wc -l | awk '{ printf "%d\n", $1 }')
#Returns mitochondrial consensus sequence depth of coverage
mtdna_depth=$(cat results/mtDNA/${SAMPLE}_stats.txt | cut -f 2 -d " " | awk '{printf "%.3f\n",$1}')
#Returns mitochondrial consensus sequence breadth of coverage
mtdna_breadth=$(cat results/mtDNA/${SAMPLE}_stats.txt | cut -f 3 -d " " | awk '{printf "%.3f\n",$1}')
#Returns the number of SNPs in the reference panel represented as pseudohaploid calls
pseudo=$(cat results/geno/${SAMPLE}.tped | wc -l | bc)
#Calculates length (mean + sd) of mapped reads
len_map=$(samtools view -F4 results/rmdup/${SAMPLE}_rmdup.bam | awk '{ sum += length($10); sumsq += length($10)^2 } END { mean = sum/NR; stdev = sqrt(sumsq/NR - (mean*mean)); printf "%.3f\t%.3f\n", mean, stdev }')
#Calculates length (mean + sd) of all reads
len_all=$(samtools view results/rmdup/${SAMPLE}_rmdup.bam | awk '{ sum += length($10); sumsq += length($10)^2 } END { mean = sum/NR; stdev = sqrt(sumsq/NR - (mean*mean)); printf "%.3f\t%.3f\n", mean, stdev }')
#Reports proportion of 5' C-to-T transitions calculated in mapDamage
CtoT=$(awk 'NR==2 {printf "%.3f\n", $2}' results/mapdamage/${SAMPLE}_5pCtoT_freq.txt)
#CtoT=cat results/mapdamage/${SAMPLE}/5pCtoT_freq.txt | head -n 2 | tail -n 1 | cut -f 2 | awk '{printf "%.3f\n",$1}'
#Reports proportion of 3' G-to-A transitions calculated in mapDamage
GtoA=$(awk 'NR==2 {printf "%.3f\n", $2}' results/mapdamage/${SAMPLE}_3pGtoA_freq.txt)
#Outputs statistics
echo -e "$SAMPLE\t$total\t$mapped_nodup_prop\t$mapped30_nodup_prop\t$duplicates\t$autosome_cov\t$depth_ratio\t$y_cov\t$mtdna_read\t$mtdna_depth\t$mtdna_breadth\t$pseudo\t$len_map\t$len_all\t$CtoT\t$GtoA" >> ${OUT}
