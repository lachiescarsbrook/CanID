# CanID: Accurate discrimination of ancient dogs and wolves

## **Introduction**
`CanID` is a `snakemake` pipeline which utilises low-pass (i.e. screening) sequencing data from ancient samples to accurately determine 

With as few as 500 SNPs, `CanID` is 100% accurate at distinguishing dogs and wolves, including pre-contact American dogs and extinct Pleistocene wolves, whose ancestry is not represented in contemporary populations (Bergstrom et al. 2022).



![Alt text](path/to/image)

## **Setup**

Install conda/mamba

Install snakemake using conda:

`conda install -n snakemake snakemake`

Activate the environment:

`mamba activate snakemake`

## **Setup**
### **Configuration**


### **Download Reference Genome**
Genotypes were called against the CanFam3.1 reference genome assembly
`wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/002/285/GCA_000002285.4_Dog10K_Boxer_Tasha/GCA_000002285.4_Dog10K_Boxer_Tasha_genomic.fna.gz`

Index the reference genome:

`bwa index`


### **Pipeline Specifics**

Reference panel containing 2 million biallelic transversional SNPs that distinguish dogs and wolves.

Sites used in SNP capture, filtered for maf (0.01)


## **Report Errors**


## **Citation**

## **References**
Bergstrom et al. 2022
