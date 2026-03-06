# RNA_DGE_SiHa Workflow Documentation

This document describes the step-by-step development and execution of the RNA-seq pipeline used for **Differential Gene Expression (DGE) analysis of SiHa cell line samples**.

The workflow is implemented using **Snakemake** to ensure reproducibility, automation, and scalability.

---

# Dataset Overview

The dataset contains **paired-end RNA sequencing reads (150 bp)**.

Samples include:

### Treated Samples

* INP-A
* INP-B
* INP-C

### Control Samples

* SRR12650977
* SRR12650978
* SRR12650979

Total samples: **6 paired-end libraries**

---

# Pipeline Overview

The RNA-seq preprocessing workflow consists of the following steps:

```
Raw FASTQ
   ↓
FastQC (quality control)
   ↓
MultiQC summary
   ↓
Adapter trimming (fastp)
   ↓
FastQC on trimmed reads
   ↓
MultiQC summary (trimmed reads)
   ↓
STAR alignment
   ↓
Sorted BAM files
```

---

# Workflow Implementation Using Snakemake

The pipeline is controlled using a **Snakefile** and a **config.yaml** configuration file.

## Configuration File

Sample names are defined in `config.yaml`.

Example:

```yaml
samples:
  - INP-A
  - INP-B
  - INP-C
  - SRR12650977
  - SRR12650978
  - SRR12650979
```

---

# Step 1: Quality Control of Raw Reads

## Tool Used

FastQC

## Purpose

To assess the quality of sequencing reads before preprocessing.

Quality metrics include:

* per base sequence quality
* GC content
* sequence duplication
* adapter contamination

## Snakemake Rule

FastQC is run on both paired-end reads for each sample.

Output files:

```
results/fastqc/sample_R1_fastqc.html
results/fastqc/sample_R2_fastqc.html
```

---

# Step 2: MultiQC Summary (Raw Reads)

## Tool Used

MultiQC

## Purpose

MultiQC aggregates results from multiple FastQC reports into a single interactive report.

Output file:

```
results/multiqc/multiqc_report.html
```

This provides an overview of quality across all samples.

---

# Step 3: Adapter Trimming and Read Filtering

## Tool Used

fastp

## Purpose

Remove:

* sequencing adapters
* low quality bases
* technical artifacts

This improves alignment accuracy.

## Output Files

```
results/trimmed/sample_R1.trimmed.fastq.gz
results/trimmed/sample_R2.trimmed.fastq.gz
```

---

# Step 4: Quality Control of Trimmed Reads

After trimming, FastQC is performed again to confirm improvement in read quality.

Output files:

```
results/fastqc_trimmed/sample_R1.trimmed_fastqc.html
results/fastqc_trimmed/sample_R2.trimmed_fastqc.html
```

---

# Step 5: MultiQC Summary of Trimmed Reads

MultiQC combines FastQC reports from trimmed reads.

Output file:

```
results/multiqc_trimmed/multiqc_report.html
```

This step verifies that:

* adapter contamination is removed
* sequence quality remains high
* trimming did not introduce artifacts

---

# Step 6: Genome Alignment

## Tool Used

STAR (Spliced Transcripts Alignment to a Reference)

## Reference Files

The following reference files were used:

```
hg38.fa
gencode.v41.annotation.gtf
```

These files were used to build the STAR genome index.

---

# STAR Genome Index Generation

STAR requires a genome index before alignment.

Index generation command:

```
STAR --runThreadN 4 \
--runMode genomeGenerate \
--genomeDir reference/star_index \
--genomeFastaFiles reference/genome/hg38.fa \
--sjdbGTFfile reference/annotation/gencode.v41.annotation.gtf \
--sjdbOverhang 149
```

The parameter `sjdbOverhang = read_length - 1`.

Since reads are **150 bp**, the value used is **149**.

---

# Alignment Step

Trimmed reads are aligned to the **human genome (hg38)**.

Output files:

```
aligned/sample.bam
```

These BAM files contain **sorted alignment results**.

---

# Resource Optimization

The pipeline was optimized for the following hardware:

Laptop configuration:

* 16 GB RAM
* RTX 4060 GPU
* Ryzen CPU
* ~50 GB available SSD storage

STAR alignment parameters were adjusted accordingly:

```
--runThreadN 4
--limitBAMsortRAM 8000000000
```

This prevents excessive memory usage.

---

# Snakemake Execution

## Dry Run

Before running the workflow, the DAG is verified using:

```
snakemake -n
```

This checks:

* file dependencies
* missing inputs
* rule order

without executing commands.

---

## Running the Workflow

The workflow is executed using:

```
snakemake --cores 4
```

Snakemake automatically determines:

* rule order
* parallel execution
* job dependencies

---

# Troubleshooting Encountered

Several issues were resolved during workflow development.

---

## Issue 1: File Naming Mismatch

Raw files initially contained long Illumina names.

Example:

```
INP-A_L001_R1_001.fastq.gz
```

These were renamed to:

```
INP-A_R1.fastq.gz
```

to match Snakemake wildcards.

---

## Issue 2: Missing MultiQC Output

MultiQC generated files named:

```
multiqc_report_1.html
```

This caused Snakemake to fail due to filename mismatch.

Solution:

Specify output name explicitly:

```
multiqc -n multiqc_report.html
```

---

## Issue 3: STAR Genome Index Error

Error:

```
could not open genome file genomeParameters.txt
```

Cause:

STAR genome index had not been generated.

Solution:

Generate the genome index before alignment.

---

# Final Outputs

The workflow produces:

### Quality Control Reports

```
results/multiqc/multiqc_report.html
results/multiqc_trimmed/multiqc_report.html
```

### Processed FASTQ Files

```
results/trimmed/*.fastq.gz
```

### Alignment Files

```
aligned/*.bam
```

These files are ready for downstream analysis such as:

* gene quantification
* differential expression analysis
* visualization

---

# Future Extensions

Next pipeline steps include:

* featureCounts for gene quantification
* DESeq2 differential expression analysis
* visualization (PCA, volcano plots, heatmaps)

---

# Reproducibility

This pipeline ensures reproducible analysis by using:

* Snakemake workflow management
* structured project directory
* configuration-driven sample input

---
