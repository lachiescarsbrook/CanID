#!/bin/bash
SAMPLE=$1
BAM=$2
CHROMOSOMES=$3
FEMALE=$4
MALE=$5
#Downsample bam to retain only mapped reads
samtools view -b -F 4 -q 30 "$BAM" > results/sexID/${SAMPLE}_filtered.bam
#Index filtered bam
samtools index results/sexID/${SAMPLE}_filtered.bam
#Calculate coverage for all chromosomes/contigs
samtools idxstats results/sexID/${SAMPLE}_filtered.bam | awk '{if ($2 != 0) print $1, $2, $3, $3 / $2; else print $1, $2, $3, "NA"}' > results/sexID/${SAMPLE}_cov_stat.txt
#Creates file with autosomes only
awk -v max="$CHROMOSOMES" '$1 ~ /^chr[0-9]+$/ { chr_num = substr($1, 4); if (chr_num >= 1 && chr_num <= max) print }' results/sexID/${SAMPLE}_cov_stat.txt > results/sexID/${SAMPLE}_chr.txt

###############################
# X-Chromosome Coverage Ratio #
###############################
#Calculate mean depth of coverage across autosomes
autosome_depth=$(awk -v max="$CHROMOSOMES" '$1 ~ /^chr[0-9]+$/ { chr_num = substr($1, 4); if (chr_num >= 1 && chr_num <= max) { sum += $4; count++ } } END { if (count > 0) print sum / count }' results/sexID/${SAMPLE}_cov_stat.txt)
#Calculate standard deviation
RA_SD=$(awk -v auto="$autosome_depth" '{diff = $4 - auto; sum += diff * diff} END {if (sum > 0) {result = sqrt(sum / 37);print result} else {print 0}}' results/sexID/${SAMPLE}_chr.txt)
#Calculate standard error
RA_SE=$(awk -v val="$RA_SD" -v n="$CHROMOSOMES" 'BEGIN { print val / sqrt(n) }')
#Calculate 95% confidence interval
RA_CI_MIN=$(awk -v auto="$autosome_depth" -v se="$RA_SE" 'BEGIN { printf "%.4g\n", auto - (2.026 * se)}')
RA_CI_MAX=$(awk -v auto="$autosome_depth" -v se="$RA_SE" 'BEGIN { printf "%.4g\n", auto + (2.026 * se)}')
#Calculate expected coverage and 95% CI of X chromosome
x_length=$(awk -v female="$FEMALE" '$1 == female { print $2 }' results/sexID/${SAMPLE}_cov_stat.txt)
EX_read=$(awk -v auto="$autosome_depth" -v xl="$x_length" 'BEGIN { printf "%.4g\n", auto * xl }')
EX_read_MIN=$(awk -v xl="$x_length" -v rmin="$RA_CI_MIN" 'BEGIN { printf "%.4g\n", xl * rmin }')
EX_read_MAX=$(awk -v xl="$x_length" -v rmax="$RA_CI_MAX" 'BEGIN { printf "%.4g\n", xl * rmax }')
#Calculate the ratio of expected to observed X chromosome coverage
x_reads=$(awk -v female="$FEMALE" '$1 == female { print $3 }' results/sexID/${SAMPLE}_cov_stat.txt)
RX=$(awk -v xread="$x_reads" -v exread="$EX_read" 'BEGIN { printf "%.4g\n", xread / exread }')
RX_MIN=$(awk -v xread="$x_reads" -v exreadmax="$EX_read_MAX" 'BEGIN { printf "%.4g\n", xread / exreadmax }')
RX_MAX=$(awk -v xread="$x_reads" -v exreadmin="$EX_read_MIN" 'BEGIN { printf "%.4g\n", xread / exreadmin }')

###############################
# Y-Chromosome Coverage Ratio #
###############################
#Number of X chromosome reads
x_reads=$(awk -v female="$FEMALE" '$1 == female { print $3 }' results/sexID/${SAMPLE}_cov_stat.txt)
#Number of Y chromosome reads
y_reads=$(awk -v male="$MALE" '$1 == male { print $3 }' results/sexID/${SAMPLE}_cov_stat.txt)
xy_reads=$((x_reads + y_reads))
RY=$(awk "BEGIN {printf \"%.4g\n\", $y_reads / $xy_reads}")
RY_SE=$(awk -v ry="$RY" -v xy="$xy_reads" 'BEGIN { printf "%.4g\n", (1.96 * ry * (1 - ry) / xy) }')
echo ${SAMPLE} $RX $RX_MIN $RX_MAX $RY $RY_SE >> results/sexID/${SAMPLE}_sex_stats.txt
