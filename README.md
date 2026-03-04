# RNA_DGE_SiHa

Snakemake-based RNA-seq analysis workflow for Differential Gene Expression (DGE) analysis of **SiHa cervical cancer cell line samples**.

This pipeline performs quality control, adapter trimming, alignment, and prepares data for downstream differential expression analysis.

---

# Project Overview

RNA sequencing (RNA-seq) enables transcriptome-wide measurement of gene expression.
This workflow automates the preprocessing and alignment stages of RNA-seq analysis using **Snakemake**, ensuring reproducibility and scalability.

The current dataset contains:

* **3 treated samples**
* **3 control samples**
* **paired-end sequencing reads (150 bp)**

---

# Workflow

The pipeline performs the following steps:

```
Raw FASTQ
   ↓
FastQC (quality assessment)
   ↓
MultiQC (combined QC report)
   ↓
Adapter trimming (fastp)
   ↓
FastQC on trimmed reads
   ↓
MultiQC (trimmed reads)
   ↓
STAR alignment
   ↓
Sorted BAM files
```

---

# Software Used

The following tools are used in the workflow:

* Snakemake – workflow management system
* FastQC – sequencing quality control
* MultiQC – aggregated QC reporting
* fastp – adapter trimming and preprocessing
* STAR – RNA-seq read alignment

---

# Project Structure

```
RNA_DGE_SiHa/
│
├── raw_data/                # Raw sequencing data
├── results/
│   ├── fastqc/              # FastQC reports (raw reads)
│   ├── trimmed/             # Trimmed FASTQ files
│   ├── multiqc/             # MultiQC report (raw reads)
│   ├── fastqc_trimmed/      # FastQC reports after trimming
│   └── multiqc_trimmed/     # MultiQC report (trimmed reads)
│
├── aligned/                 # STAR alignment output (BAM)
├── logs/                    # Workflow logs
│
├── reference/
│   ├── genome/              # Reference genome
│   ├── annotation/          # Gene annotation (GTF)
│   └── star_index/          # STAR genome index
│
├── scripts/                 # Downstream analysis scripts
├── Snakefile                # Snakemake workflow
├── config.yaml              # Sample configuration
└── README.md
```

---

# Input Data

The workflow expects **paired-end FASTQ files**.

Example format:

```
sample_R1.fastq.gz
sample_R2.fastq.gz
```

Example dataset:

```
INP-A_R1.fastq.gz
INP-A_R2.fastq.gz
```

---

# Configuration

Sample names are defined in **config.yaml**.

Example configuration:

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

# Running the Pipeline

Activate the conda environment:

```
conda activate system_genomics
```

Test the workflow (dry run):

```
snakemake -n
```

Run the pipeline:

```
snakemake --cores 4
```

---

# Output

The pipeline generates:

### Quality Control Reports

```
results/multiqc/multiqc_report.html
results/multiqc_trimmed/multiqc_report.html
```

### Alignment Output

```
aligned/sample.bam
```

These BAM files are ready for downstream gene quantification and differential expression analysis.

---

# Future Steps

Planned additions to the pipeline include:

* Gene quantification using featureCounts
* Differential expression analysis using DESeq2
* Data visualization (heatmaps, PCA, volcano plots)

---

# Reproducibility

This workflow is managed using **Snakemake**, allowing:

* automated execution of analysis steps
* reproducible computational pipelines
* easy scaling to larger datasets

---

# Author

Rajat Gupta
Student Researcher – Life Sciences

Research interests:

* Cancer Biology
* Bioinformatics
* Computational Genomics

