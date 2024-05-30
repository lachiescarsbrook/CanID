#!/bin/bash
CONFIG=$1
SAMPLE=$2
#Loop to remove existing adrm files
file="results/adrm/${SAMPLE}_adrm.fq.gz"
if [ -f "$file" ]; then
    rm "$file"
    echo "Existing $file file removed."
else
    echo "No $file file to remove."
fi
#Creates a variable containing all library IDs for a given sample
LIBRARY=$(cat $CONFIG | grep $SAMPLE | awk -F'[ \t]+' '{print $1}')
#Combines collapsed reads from single/multiple libraries for a given sample
for i in $LIBRARY; do cat results/adrm/${i}.collapsed.gz results/adrm/${i}.collapsed.truncated.gz >> results/adrm/${SAMPLE}_adrm.fq.gz; done