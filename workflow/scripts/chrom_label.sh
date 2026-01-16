#!/bin/bash
CHR=$1
CHRX=$2
CHRY=$3
CHRM=$4

rm workflow/files/chromosomes.txt
touch workflow/files/chromosomes.txt
for i in `seq 1 $CHR`; do echo "chr${i}" >> workflow/files/chromosomes.txt; done
echo $CHRX >> workflow/files/chromosomes.txt
echo $CHRY >> workflow/files/chromosomes.txt
echo $CHRM >> workflow/files/chromosomes.txt
