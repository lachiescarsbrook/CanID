#!/bin/bash
PANEL=$1
SAMPLE=$2
#Modifies sample group and name from 'ind01 ind01' to 'Unknown $SAMPLE'
cat results/geno/${SAMPLE}.tfam | sed "s/ind0/${SAMPLE}/g" | sed "s/^${SAMPLE}/Unknown/" > results/geno/${SAMPLE}_upID.tfam
mv results/geno/${SAMPLE}_upID.tfam results/geno/${SAMPLE}.tfam
#For .tped files with entries, REF/ALT alleles are tab-delimited, and passed through a custom python script to remove alleles not present in the reference panel
if [ -s "results/geno/${SAMPLE}.tped" ]; then
    cat results/geno/${SAMPLE}.tped | sed 's/ /\t/g' > results/geno/${SAMPLE}_mod.tped
    python workflow/scripts/triallelic_remover.py results/geno/${SAMPLE}_mod.tped $PANEL > results/geno/${SAMPLE}.tped
    rm results/geno/${SAMPLE}_mod.tped
else
    #Othwerise, a dummy entry for the first variant in the reference panel, is created in the empty .tped files
    echo "chr1    chr1_232   0   232 0   0" >> results/geno/${SAMPLE}.tped 
fi
#Converts tped/tfam format to bed/bim/fam
plink --tfile results/geno/${SAMPLE} --dog --make-bed --out results/geno/${SAMPLE}
