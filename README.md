# 🧬 RNA_DGE_SiHa

Reproducible end-to-end RNA-Seq Differential Gene Expression (DGE) pipeline for the **SiHa cervical cancer cell line** using **Snakemake**.

This project implements a modern RNA-seq workflow using alignment-free transcript quantification and gene-level statistical modeling, followed by functional enrichment analysis.

---

# 📌 Overview

This pipeline performs:

- ✅ Raw read quality control (FastQC)
- ✅ Adapter trimming (fastp)
- ✅ Transcript-level quantification (Salmon)
- ✅ Gene-level aggregation (tximport)
- ✅ Differential expression analysis (DESeq2)
- ✅ GO enrichment analysis
- ✅ KEGG pathway enrichment
- ✅ Automated visualization outputs
- ✅ Fully reproducible Conda environments

The entire workflow is automated and reproducible using **Snakemake**.

---

# 🔬 Experimental Design

| Condition | Samples |
|-----------|----------|
| Control   | INP-A, INP-B, INP-C |
| Treated   | SRR12650977, SRR12650978, SRR12650979 |

Design formula used in DESeq2:

```r
~ condition
```

---

# ⚙️ Workflow Architecture

```
Raw FASTQ
    ↓
FastQC
    ↓
fastp (adapter trimming)
    ↓
Salmon (quasi-mapping quantification)
    ↓
tximport (gene-level counts)
    ↓
DESeq2 (Differential Expression)
    ↓
clusterProfiler (GO + KEGG enrichment)
```

This workflow uses **Salmon quasi-mapping** instead of traditional genome alignment, providing:

- Faster execution
- Lower memory usage
- Reduced storage requirements
- Bias-aware transcript quantification
- Length-scaled gene-level counts

---

# 🛠 Software & Tools

| Tool | Purpose |
|------|---------|
| FastQC | Raw read quality assessment |
| fastp | Adapter trimming |
| Salmon | Transcript quantification |
| tximport | Gene-level count aggregation |
| DESeq2 | Differential gene expression |
| clusterProfiler | GO & KEGG enrichment |
| Snakemake | Workflow management |
| Conda | Environment reproducibility |

---

# 📂 Project Structure

```
RNA_DGE_SiHa/
│
├── Snakefile
├── config.yaml
├── envs/
├── scripts/
├── raw_data/
├── metadata/
├── reference/
├── results/
├── logs/
└── README.md
```

---

# 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/RNA_DGE_SiHa.git
cd RNA_DGE_SiHa
```

Create a base environment with Snakemake:

```bash
conda create -n snakemake_env -c conda-forge -c bioconda snakemake
conda activate snakemake_env
```

---

# ▶️ Running the Pipeline

Execute the full workflow:

```bash
snakemake --cores 4 --use-conda
```

Force re-run a specific rule:

```bash
snakemake -R deseq2_analysis --cores 4 --use-conda
```

Generate a workflow DAG:

```bash
snakemake --dag | dot -Tsvg > workflow_dag.svg
```

---

# 📊 Output Files

## Differential Expression Results

```
results/deseq2/
├── DEG_results.tsv
├── significant_DEGs.tsv
├── normalized_counts.tsv
├── PCA_plot.png
├── volcano_plot.png
├── MA_plot.png
└── heatmap_top50_genes.png
```

## Functional Enrichment Results

```
results/enrichment/
├── GO_BP_results.tsv
├── KEGG_results.tsv
├── GO_dotplot.png
└── KEGG_dotplot.png
```

---

# 📈 Statistical Framework

## Differential Expression

- Model: Negative binomial generalized linear model
- Implemented in: DESeq2
- Significance threshold:
  - Adjusted p-value < 0.05
  - |log2FoldChange| > 1
- Multiple testing correction: Benjamini–Hochberg (FDR)

## Enrichment Analysis

- Gene Ontology (Biological Process)
- KEGG pathway enrichment
- ID conversion: ENSEMBL → ENTREZ
- Implemented using clusterProfiler

---

# 🔁 Reproducibility

This workflow ensures:

- Isolated Conda environments per rule
- Fully version-controlled pipeline
- Deterministic execution via Snakemake
- Reproducible statistical results
- Cross-platform portability

---

# 🎯 Why This Pipeline Is Modern

✔ Alignment-free transcript quantification  
✔ Length-scaled gene counts via tximport  
✔ Bias-aware abundance estimation  
✔ Automated statistical modeling  
✔ Integrated pathway interpretation  
✔ Publication-ready outputs  
✔ Fully reproducible workflow management  

---

# 📚 Key References

- Love MI, Huber W, Anders S. (2014). Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2.
- Patro R et al. (2017). Salmon provides fast and bias-aware quantification of transcript expression.
- Yu G et al. (2021). clusterProfiler 4.0: A universal enrichment tool for interpreting omics data.

---

# 👨‍🔬 Author

Rajat Gupta  
Life Science Researcher  
Focus: Cancer Biology & Bioinformatics  

---

