#!/bin/bash
IN=$1
LIBRARY=$2
#Searches input directory for fastq files with the given sample ID
FILES=$(find "$IN" -type f \( -name "*.fastq*" -o -name "*.fq*" \) | grep -E "${LIBRARY}([_.-]|$)" | sort)
#Assigns paired-end reads to separate variables 
READ1=$(echo "$FILES" | sed -n '1p')
READ2=$(echo "$FILES" | sed -n '2p')
#Removes adapters, low quality, and missing bases from paired-end reads, and collapses overlapping reads
AdapterRemoval --file1 $READ1 --file2 $READ2 --collapse --trimns --trimqualities --gzip --basename results/adrm/${LIBRARY}
