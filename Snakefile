#!/usr/bin/env python

#Load config file
configfile: "config/user_config.yaml"

#Modules:
include: "workflow/rules/dict.smk"
include: "workflow/rules/adrm.smk"
include: "workflow/rules/concat.smk"
include: "workflow/rules/reads2geno.smk"
include: "workflow/rules/pca.smk"

rule all:
    input:
        expand("results/adrm/{library}.settings", library = LIBRARIES.keys()),
        expand("results/adrm/{sample}_adrm.fq.gz", sample = SAMPLES.keys()),
        expand("results/stats/{run}_all_stats.txt", run = config["run"]),
        expand("results/lda/{run}_posteriors.txt", run = config["run"]),
        expand("results/smartpca/{run}_PCA_plot.pdf", run = config["run"])
