configfile: "config.yaml"

SAMPLES = config["samples"]

################################
# Reference files
################################

TRANSCRIPTOME = "reference/transcriptome/gencode.v41.transcripts.fa.gz"
SALMON_INDEX = "reference/salmon_index"

################################
# Final target
################################

rule all:
    input:
        expand("results/fastqc/{sample}_R1_fastqc.html", sample=SAMPLES),
        expand("results/fastqc/{sample}_R2_fastqc.html", sample=SAMPLES),
        expand("results/trimmed/{sample}_R1.trimmed.fastq.gz", sample=SAMPLES),
        expand("results/trimmed/{sample}_R2.trimmed.fastq.gz", sample=SAMPLES),
        expand("results/salmon/{sample}/quant.sf", sample=SAMPLES),
        "results/multiqc/multiqc_report.html",
        "results/multiqc_trimmed/multiqc_report.html",
        "results/multiqc_salmon/multiqc_report.html",
        "results/counts/gene_counts_matrix.tsv",
        "results/deseq2/DEG_results.tsv",
        "results/deseq2/normalized_counts.tsv",
        "results/deseq2/PCA_plot.png",
        "results/deseq2/volcano_plot.png",
        "results/deseq2/significant_DEGs.tsv",
        "results/deseq2/MA_plot.png",
        "results/deseq2/heatmap_top50_genes.png",
        "results/enrichment/GO_BP_results.tsv",
        "results/enrichment/KEGG_results.tsv",
        "results/enrichment/GO_dotplot.png",
        "results/enrichment/KEGG_dotplot.png"

################################
# FastQC (raw reads)
################################

rule fastqc:
    input:
        R1="raw_data/{sample}_R1.fastq.gz",
        R2="raw_data/{sample}_R2.fastq.gz"

    output:
        "results/fastqc/{sample}_R1_fastqc.html",
        "results/fastqc/{sample}_R2_fastqc.html"

    log:
        "logs/fastqc_{sample}.log"

    shell:
        "fastqc {input.R1} {input.R2} --outdir results/fastqc > {log} 2>&1"

################################
# MultiQC (raw)
################################

rule multiqc:
    input:
        expand("results/fastqc/{sample}_R1_fastqc.html", sample=SAMPLES),
        expand("results/fastqc/{sample}_R2_fastqc.html", sample=SAMPLES)

    output:
        "results/multiqc/multiqc_report.html"

    log:
        "logs/multiqc.log"

    shell:
        "multiqc results/fastqc -o results/multiqc -n multiqc_report.html > {log} 2>&1"

################################
# Adapter trimming
################################

rule trim_reads:
    input:
        R1="raw_data/{sample}_R1.fastq.gz",
        R2="raw_data/{sample}_R2.fastq.gz"

    output:
        R1="results/trimmed/{sample}_R1.trimmed.fastq.gz",
        R2="results/trimmed/{sample}_R2.trimmed.fastq.gz"

    log:
        "logs/trim_{sample}.log"

    shell:
        "fastp -i {input.R1} -I {input.R2} -o {output.R1} -O {output.R2} --detect_adapter_for_pe --thread 4 > {log} 2>&1"

################################
# FastQC on trimmed reads
################################

rule fastqc_trimmed:
    input:
        R1="results/trimmed/{sample}_R1.trimmed.fastq.gz",
        R2="results/trimmed/{sample}_R2.trimmed.fastq.gz"

    output:
        "results/fastqc_trimmed/{sample}_R1.trimmed_fastqc.html",
        "results/fastqc_trimmed/{sample}_R2.trimmed_fastqc.html"

    log:
        "logs/fastqc_trimmed_{sample}.log"

    shell:
        "fastqc {input.R1} {input.R2} --outdir results/fastqc_trimmed > {log} 2>&1"

################################
# MultiQC for trimmed reads
################################

rule multiqc_trimmed:
    input:
        expand("results/fastqc_trimmed/{sample}_R1.trimmed_fastqc.html", sample=SAMPLES),
        expand("results/fastqc_trimmed/{sample}_R2.trimmed_fastqc.html", sample=SAMPLES)

    output:
        "results/multiqc_trimmed/multiqc_report.html"

    log:
        "logs/multiqc_trimmed.log"

    shell:
        "multiqc results/fastqc_trimmed -o results/multiqc_trimmed -n multiqc_report.html > {log} 2>&1"

################################
# Salmon index
################################

rule salmon_index:
    input:
        TRANSCRIPTOME

    output:
        directory(SALMON_INDEX)

    log:
        "logs/salmon_index.log"

    shell:
        """
        salmon index \
        -t {input} \
        -i {output} \
        -k 31 \
        > {log} 2>&1
        """

################################
# Salmon quantification
################################

rule salmon_quant:
    input:
        index=SALMON_INDEX,
        R1="results/trimmed/{sample}_R1.trimmed.fastq.gz",
        R2="results/trimmed/{sample}_R2.trimmed.fastq.gz"

    output:
        "results/salmon/{sample}/quant.sf"

    threads: 4

    log:
        "logs/salmon_{sample}.log"

    shell:
        """
        salmon quant \
        -i {input.index} \
        -l A \
        -1 {input.R1} \
        -2 {input.R2} \
        -p {threads} \
        -o results/salmon/{wildcards.sample} \
        > {log} 2>&1
        """

################################
# MultiQC for Salmon results
################################

rule multiqc_salmon:
    input:
        expand("results/salmon/{sample}/quant.sf", sample=SAMPLES)

    output:
        "results/multiqc_salmon/multiqc_report.html"

    log:
        "logs/multiqc_salmon.log"

    shell:
        """
        multiqc results/salmon \
        -o results/multiqc_salmon \
        -n multiqc_report.html \
        > {log} 2>&1
        """

################################
# Gene count matrix from Salmon
################################

rule gene_counts:
    input:
        quant=expand("results/salmon/{sample}/quant.sf", sample=SAMPLES),
        tx2gene="reference/tx2gene.tsv"

    output:
        "results/counts/gene_counts_matrix.tsv"

    log:
        "logs/gene_counts.log"

    shell:
        """
        mkdir -p results/counts

        Rscript scripts/tximport_counts.R \
        results/salmon \
        {input.tx2gene} \
        {output} \
        > {log} 2>&1
        """
################################
# DESeq2 differential expression
################################

rule deseq2_analysis:
    input:
        counts="results/counts/gene_counts_matrix.tsv",
        metadata="metadata/sample_metadata.tsv"

    output:
        "results/deseq2/DEG_results.tsv",
        "results/deseq2/significant_DEGs.tsv",
        "results/deseq2/normalized_counts.tsv",
        "results/deseq2/PCA_plot.png",
        "results/deseq2/volcano_plot.png",
        "results/deseq2/MA_plot.png",
        "results/deseq2/heatmap_top50_genes.png"

    log:
        "logs/deseq2.log"

    conda:
        "envs/desq2.yaml"

    shell:
        """
        mkdir -p results/deseq2

        Rscript scripts/deseq2_analysis.R \
        {input.counts} \
        {input.metadata} \
        results/deseq2 \
        > {log} 2>&1
        """
################################
# Functional enrichment
################################

rule enrichment_analysis:
    input:
        "results/deseq2/significant_DEGs.tsv"

    output:
        "results/enrichment/GO_BP_results.tsv",
        "results/enrichment/KEGG_results.tsv",
        "results/enrichment/GO_dotplot.png",
        "results/enrichment/KEGG_dotplot.png"

    log:
        "logs/enrichment.log"

    conda:
        "envs/enrichment.yaml"

    shell:
        """
        mkdir -p results/enrichment

        Rscript scripts/enrichment_analysis.R \
        {input} \
        results/enrichment \
        > {log} 2>&1
        """
