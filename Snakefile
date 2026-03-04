configfile: "config.yaml"

SAMPLES = config["samples"]

################################
# Final target
################################

rule all:
    input:
        expand("results/fastqc/{sample}_R1_fastqc.html", sample=SAMPLES),
        expand("results/fastqc/{sample}_R2_fastqc.html", sample=SAMPLES),
        expand("results/trimmed/{sample}_R1.trimmed.fastq.gz", sample=SAMPLES),
        expand("results/trimmed/{sample}_R2.trimmed.fastq.gz", sample=SAMPLES),
        expand("aligned/{sample}.bam", sample=SAMPLES),
        "results/multiqc/multiqc_report.html",
        "results/multiqc_trimmed/multiqc_report.html"

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
# STAR alignment
################################

rule star_align:
    input:
        R1="results/trimmed/{sample}_R1.trimmed.fastq.gz",
        R2="results/trimmed/{sample}_R2.trimmed.fastq.gz"

    output:
        bam="aligned/{sample}.bam"

    log:
        "logs/star_{sample}.log"

    threads: 4

    shell:
        """
        STAR \
        --runThreadN {threads} \
        --genomeDir reference/star_index \
        --readFilesIn {input.R1} {input.R2} \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --limitBAMsortRAM 8000000000 \
        --outFileNamePrefix aligned/{wildcards.sample}_ \
        > {log} 2>&1

        mv aligned/{wildcards.sample}_Aligned.sortedByCoord.out.bam {output.bam}
        """
