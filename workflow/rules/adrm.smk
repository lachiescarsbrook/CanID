###########################
### Step 2: Remove      ###
###   Illumina Adapters ###
###########################

#This rule removes adapters from demultiplexed, paired-end fastq reads
rule adapter_removal:
    input: 
    	path = lambda wildcards: PATHS[wildcards.library]
    output:
        pair1 = "results/adrm/{library}.pair1.truncated.gz",
        pair2 = "results/adrm/{library}.pair2.truncated.gz",
        single = "results/adrm/{library}.singleton.truncated.gz",
        collapse = "results/adrm/{library}.collapsed.gz",
        collapse_trunc = "results/adrm/{library}.collapsed.truncated.gz",
        disc = "results/adrm/{library}.discarded.gz",
        set = "results/adrm/{library}.settings"
    params:
        library = lambda wildcards: wildcards.library
    conda:
        "../envs/adapter_removal.yaml"
    shell:
        "workflow/scripts/adapter_removal.sh {input.path} {params.library}"