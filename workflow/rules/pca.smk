################################
### Step 2: SmartPCA and LDA ###
###         (6 rules)        ###
################################

#This rule creates a list of samples to merge
rule merge_list:
    input:
        expand("results/stats/{run}_all_stats.txt", run = config["run"])
    params:
        sample = expand(SAMPLES.keys())
    output:
        expand("results/merge/{run}_merge.txt", run = config["run"])      
    shell:
        "for sample in {params.sample}; do echo results/geno/$sample >> {output}; done"

#This rule merges haploid genotypes from unknown samples with the dog/wolf reference panel (670,718 SNPs)
rule vcf_combine:
    input:
        merge = expand("results/merge/{run}_merge.txt", run = config["run"])
    output:
        expand("results/merge/{run}_final_merged{ext}", ext=[".bed",".bim",".fam",".log",".nosex"], run = config["run"])
    params:
        run = config["run"],
        snp = config["SNP_panel"]
    conda:
        "../envs/smartpca.yaml"
    shell:
        "plink --bfile workflow/files/dog_wolf_panel_{params.snp} --merge-list {input.merge} --dog --make-bed --out results/merge/{params.run}_final_merged"

#This rule creates .ped and .map files from binary PLINK input
rule format_input:
    input:
        expand("results/merge/{run}_final_merged{ext}", ext=[".bed",".bim",".fam"], run = config["run"])
    output:
        expand("results/merge/{run}_final_merged{ext}", ext=[".ped",".map",".log",".nosex"], run = config["run"])
    params:
        run = config["run"]
    conda:
        "../envs/smartpca.yaml"
    shell:
        "plink --bfile results/merge/{params.run}_final_merged --dog --recode --out results/merge/{params.run}_final_merged"

#This rule runs smartpca on the merged dataset, projecting unknown samples onto eigenvectors calculated using the dog/wolf referene panel 
rule smartpca:
    input:
        fam = expand("results/merge/{run}_final_merged.fam", run = config["run"]),
        ped = expand("results/merge/{run}_final_merged.ped", run = config["run"]),
        map = expand("results/merge/{run}_final_merged.map", run = config["run"])
    output:
        poplist = expand("results/merge/{run}_final_merged{ext1}", ext1=[".poplist",".poplist.noancient"], run = config["run"]),
        modped = expand("results/merge/mod_{run}_final_merged.ped", run = config["run"]),
        eigen = expand("results/smartpca/{run}_final_merged{ext2}", ext2=[".geno",".snp",".ind",".evec",".eval"], run = config["run"]),
        par = expand("results/smartpca/{run}_par{ext3}", ext3=[".PED.EIGENSTRAT"], run = config["run"]),
        out = expand("results/smartpca/smartpca_{run}.out", run = config["run"])
    params:
        run = config["run"]
    conda:
        "../envs/smartpca.yaml"
    shell:
        "workflow/scripts/smartpca.sh {input.fam} {input.ped} {input.map} {output.out} {params.run}"

#Plots the results of the PCA
rule plot_pca:
    input:
        evec = expand("results/smartpca/{run}_final_merged.evec", run = config["run"]),
        eval = expand("results/smartpca/{run}_final_merged.eval", run = config["run"])
    output:
        expand("results/smartpca/{run}_PCA_plot.pdf", run = config["run"])
    conda:
        "../envs/lda.yaml"
    shell:
        "Rscript workflow/scripts/PCA.R {input.evec} {input.eval} {output}"

#This rule uses linear disciminant analysis to calculate assignment probabilities of samples to dog/wolf geographic clades    
rule LDA:
    input:
        evec = expand("results/smartpca/{run}_final_merged.evec", run = config["run"])
    output:
        expand("results/lda/{run}_posteriors.txt", run = config["run"])
    conda:
        "../envs/lda.yaml"
    shell:
        "Rscript workflow/scripts/LDA.R {input} {output}"