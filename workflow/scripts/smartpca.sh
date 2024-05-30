#!/bin/bash
FAM=$1
PED=$2
MAP=$3
OUT=$4
RUN=$5
#Creates a list of group names
less $FAM | cut -d$' ' -f 1 | sort| uniq > results/merge/${RUN}_final_merged.poplist
#Remove groups not being included in eigenvector construction (i.e. projected unknown samples)
egrep -v "Unknown|Coyote" results/merge/${RUN}_final_merged.poplist > results/merge/${RUN}_final_merged.poplist.noancient
#Sets column 6 values to 1 (which avoids "ignore" error message)
awk '$6="1"' $PED > results/merge/mod_${RUN}_final_merged.ped
#Create a parfile for convertf
	echo genotypename: results/merge/mod_${RUN}_final_merged.ped > results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo snpname: $MAP >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo indivname: results/merge/mod_${RUN}_final_merged.ped >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo outputformat: EIGENSTRAT >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo genotypeoutname: results/smartpca/${RUN}_final_merged.geno >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo snpoutname: results/smartpca/${RUN}_final_merged.snp >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo indivoutname: results/smartpca/${RUN}_final_merged.ind >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo familynames: NO >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
	echo numthreads:   10 >> results/smartpca/${RUN}_par.PED.EIGENSTRAT
#Uses parfile to convert from PED to EIGENSTRAT format
convertf -p results/smartpca/${RUN}_par.PED.EIGENSTRAT
#Restore population/group names to the convertf .ind file 
awk 'BEGIN { FS=OFS=" " } NR==FNR { a[$2]=$1; next } $1 in a { $3=a[$1] } 1' results/merge/${RUN}_final_merged.fam results/smartpca/${RUN}_final_merged.ind > results/smartpca/${RUN}_final_merged.group.ind
#Create a parfile for smartpca
	echo genotypename:     	results/smartpca/${RUN}_final_merged.geno > results/smartpca/${RUN}_par.PCA
	echo snpname:           results/smartpca/${RUN}_final_merged.snp >> results/smartpca/${RUN}_par.PCA
	echo indivname:         results/smartpca/${RUN}_final_merged.group.ind >> results/smartpca/${RUN}_par.PCA
	echo evecoutname:       results/smartpca/${RUN}_final_merged.evec >> results/smartpca/${RUN}_par.PCA
	echo evaloutname:       results/smartpca/${RUN}_final_merged.eval >> results/smartpca/${RUN}_par.PCA
	echo poplistname:       results/merge/${RUN}_final_merged.poplist.noancient >> results/smartpca/${RUN}_par.PCA
	echo outliermode: 2 >> results/smartpca/${RUN}_par.PCA #No outlier removal
	echo numoutevec: 10 >> results/smartpca/${RUN}_par.PCA #The number of PCs to explain 70% of variance in reference panel
	echo lsqproject:         YES >> results/smartpca/${RUN}_par.PCA #Carries out projection of unknown samples using least-squares approach
	echo numthreads:   10 >> results/smartpca/${RUN}_par.PCA
#Uses parfile to run smartpca
smartpca -p results/smartpca/${RUN}_par.PCA > $OUT
