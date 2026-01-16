#################################
### Step 5: Calculate Summary ### 
###  Statistics and Genotype  ###
#################################

#This rule maps collapsed reads to the reference genome using the short-read aligner bwa aln
rule map_reads:
    input:
        adrm_reads = "results/adrm/{sample}_adrm.fq.gz",
        ref = config["path_to_reference_genome"]
    output:
        out_sai = "results/map/{sample}.sai",
        out_bam = "results/map/{sample}.bam",
        out_sort = "results/map/{sample}_sorted.bam"
    params:
        seed=config["seed"],
            mapthreads=config["map_threads"]
    conda:
        "../envs/mapping.yaml"
    shell:
        "workflow/scripts/mapping.sh {input.adrm_reads} {input.ref} {output.out_sai} {output.out_bam} {output.out_sort} {params.seed} {params.mapthreads}"

#This rule removes PCR duplicates from sorted bam files 
rule remove_duplicates:
    input:
        bam = "results/map/{sample}_sorted.bam",
        chr = "workflow/files/chromosomes.txt"
    output:
        rmdup = "results/rmdup/{sample}_rmdup.bam",
        metrics = "results/rmdup/{sample}_rmdup_metrics.txt",
        covstats = "results/rmdup/{sample}_cov_stat.txt"
    conda:
        "../envs/duplicate_removal.yaml"
    shell:
        "workflow/scripts/duplicate_removal.sh {input.bam} {output.rmdup} {output.metrics} {input.chr}"

#This rule creates a mitochondrial consensus sequence
rule mtDNA:
    input:
        rmdup = "results/rmdup/{sample}_rmdup.bam"
    output:
        bam = "results/mtDNA/{sample}.bam",
        fasta = "results/mtDNA/{sample}.fasta",
        stats = "results/mtDNA/{sample}_stats.txt"
    params:
        depth=config["base_depth"],
            con=config["base_con"],
                sample = lambda wildcards: wildcards.sample,
                        mapq = config["mapping_qual"],
                            mtDNA = config["mtDNAID"]
    conda:
        "../envs/mtDNA.yaml"
    shell:
        "workflow/scripts/mtDNA.sh {input.rmdup} {params.sample} {params.depth} {params.con} {params.mapq} {params.mtDNA}" 

#This rule determines the autosomal and sex chromosome coverage of each sample
rule sex_ID:
    input:
        rmdup = "results/rmdup/{sample}_rmdup.bam",
        fasta = "results/mtDNA/{sample}.fasta"
    output:
        out1 = "results/sexID/{sample}_chr.txt",
        out2 = "results/sexID/{sample}_cov_stat.txt",
        out3 = "results/sexID/{sample}_filtered.bam",
        out4 = "results/sexID/{sample}_filtered.bam.bai",
        out5 = "results/sexID/{sample}_sex_stats.txt"
    params:
        sample = lambda wildcards: wildcards.sample,
            nchrom = config["chromosomes"],
                female = config["femaleID"],
                    male = config["maleID"]
    conda:
        "../envs/mtDNA.yaml"
    shell:
        "workflow/scripts/sexID.sh {params.sample} {input.rmdup} {params.nchrom} {params.female} {params.male}"

#This rule performs mapDamage on a subset of the mapped reads
rule mapdamage:
    input:
        rmdup = "results/rmdup/{sample}_rmdup.bam",
        ref = config["path_to_reference_genome"],
        sexID = "results/sexID/{sample}_sex_stats.txt"
    output:
        out1 = "results/mapdamage/{sample}_5pCtoT_freq.txt",
        out2 = "results/mapdamage/{sample}_3pGtoA_freq.txt",
        out3 = "results/mapdamage/{sample}_dnacomp.txt",
        out4 = "results/mapdamage/{sample}_Fragmisincorporation_plot.pdf",
        out5 = "results/mapdamage/{sample}_Length_plot.pdf",
        out6 = "results/mapdamage/{sample}_misincorporation.txt",
        out7 = "results/mapdamage/{sample}_Runtime_log.txt",
        out8 = "results/mapdamage/{sample}_lgdistribution.txt"
    params:
        sample = lambda wildcards: wildcards.sample
    conda:
        "../envs/mapdamage.yaml"
    shell: 
        "workflow/scripts/mapdamage.sh {input.rmdup} {input.ref} {params.sample}" 

#This rule generates consensus haploid genotype calls from mapped reads overlapping SNPs present in the reference panel
rule genotype:
    input:
        panel = expand("workflow/files/{snp}_sites", snp=config["SNP_panel"]),
        bam_input = "results/rmdup/{sample}_rmdup.bam",
        mapdam = "results/mapdamage/{sample}_3pGtoA_freq.txt"
    output:
        haplo = "results/geno/{sample}.haplo.gz",
        arg = "results/geno/{sample}.arg",
        tped = "results/geno/{sample}.tped",
        tfam = "results/geno/{sample}.tfam"
    params:
        sample = lambda wildcards: wildcards.sample,
            mapq = config["mapping_qual"],
                readq = config["base_qual"],
                    trim = config["trimn"]
    conda:
        "../envs/genotyping.yaml"
    shell:
        "workflow/scripts/genotyping.sh {input.bam_input} {input.panel} {params.sample} {params.mapq} {params.readq} {params.trim}" 

#This rule converts angsd output into PLINK format, excluding haplotypes not represented in the reference panel (i.e. triallelic variants)
rule geno_format:
    input:
        panel = expand("workflow/files/{snp}_sites", snp=config["SNP_panel"]),
        tped = "results/geno/{sample}.tped"
    output:
        bim="results/geno/{sample}.bim",
        bed="results/geno/{sample}.bed",
        fam="results/geno/{sample}.fam"
    params:
        sample = lambda wildcards: wildcards.sample
    conda:
        "../envs/genotyping.yaml"
    shell:
        "workflow/scripts/geno_format.sh {input.panel} {params.sample}" 

#This rule calculates summary statistics (i.e. mapped reads, proportion of duplicates, read length) for each sample
rule sample_stat:
    input:
        bim="results/geno/{sample}.bim"
    output:
        "results/stats/ind_samples/{sample}_stats.txt"
    params:
        sample = lambda wildcards: wildcards.sample,
            run = config["run"],
                mtDNA = config["mtDNAID"]
    conda:
        "../envs/duplicate_removal.yaml"
    shell:
        "workflow/scripts/summary_statistics.sh {params.sample} {output} {params.run} {params.mtDNA}"

#This rule combines summary statistics for all samples listed in the config file
rule all_stat:
    input:
        expand("results/stats/ind_samples/{sample}_stats.txt", sample = SAMPLES)
    output:
        expand("results/stats/{run}_all_stats.txt", run = config["run"])
    shell:
        "echo -e 'Sample\tTotal_Reads\tMapped_Reads_NoDup\tMapped_Reads_Q30_NoDup\tDuplicates\tmtDNA_Reads\tmtDNA_Depth\tmtDNA_Breadth\tSNPs\tMapped_Length_Mean\tMapped_Length_SD\tAll_Length_Mean\tAll_Length_SD\tC-toT\tG-to-A\tRX\tRX_Min\tRX_Max\tRY\tRY_SE\tfastqscreen_Species\tfastqscreen_Difference\tfastqscreen_Hits' > {output}; for stat in {input}; do awk 'NR==2' $stat >> {output}; done"
