###############################
### Step 3: Combine Reads   ### 
### from Multiple Libraries ###
###############################

#Combines collapsed reads from single/multiple libraries for a given sample
rule concat_reads:
    input:
        set = expand("results/adrm/{library}.collapsed.gz", library = LIBRARIES.keys()),
        file = config["files"]
    output:
        "results/adrm/{sample}_adrm.fq.gz"
    params:
        sample = lambda wildcards: wildcards.sample
    shell:
        "workflow/scripts/concatenate.sh {input.file} {params.sample}"