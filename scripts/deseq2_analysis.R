library(DESeq2)
library(ggplot2)
library(pheatmap)

args <- commandArgs(trailingOnly=TRUE)

counts_file <- args[1]
metadata_file <- args[2]
outdir <- args[3]

dir.create(outdir, showWarnings = FALSE)

################################
# Load data
################################

counts <- read.table(counts_file, header=TRUE, row.names=1, check.names=FALSE)
metadata <- read.table(metadata_file, header=TRUE, sep="\t", stringsAsFactors=FALSE)

################################
# Clean column names if needed
################################

colnames(counts) <- gsub("^X", "", colnames(counts))

################################
# Prepare metadata
################################

rownames(metadata) <- metadata$sample
metadata$sample <- NULL

################################
# Match metadata with counts
################################

metadata <- metadata[match(colnames(counts), rownames(metadata)), , drop=FALSE]

if(!all(colnames(counts) == rownames(metadata))){
    stop("Counts columns and metadata rows do not match")
}

################################
# Ensure integer counts
################################

counts <- round(as.matrix(counts))

################################
# DESeq2
################################

dds <- DESeqDataSetFromMatrix(
    countData = counts,
    colData = metadata,
    design = ~ condition
)

dds <- DESeq(dds)

res <- results(dds)
################################
# Save DEG table
################################

write.table(
    as.data.frame(res),
    file=file.path(outdir,"DEG_results.tsv"),
    sep="\t",
    quote=FALSE
)

################################
# Filter significant DEGs
################################

sig <- subset(res, padj < 0.05 & abs(log2FoldChange) > 1)

write.table(
    as.data.frame(sig),
    file=file.path(outdir,"significant_DEGs.tsv"),
    sep="\t",
    quote=FALSE
)

################################
# Normalized counts
################################

norm_counts <- counts(dds, normalized=TRUE)

write.table(
    norm_counts,
    file=file.path(outdir,"normalized_counts.tsv"),
    sep="\t",
    quote=FALSE
)

################################
# PCA plot
################################

vsd <- vst(dds)

p <- plotPCA(vsd, intgroup="condition")

ggsave(
    file.path(outdir,"PCA_plot.png"),
    plot=p
)

################################
# Volcano plot
################################

res_df <- as.data.frame(res)

res_df$significant <- "No"
res_df$significant[res_df$padj < 0.05] <- "Yes"

volcano <- ggplot(res_df,
        aes(x=log2FoldChange,
            y=-log10(padj),
            color=significant)) +
    geom_point() +
    theme_minimal()

ggsave(
    file.path(outdir,"volcano_plot.png"),
    plot=volcano
)

################################
# MA plot
################################

png(file.path(outdir,"MA_plot.png"))
plotMA(res, main="MA Plot")
dev.off()

################################
# Heatmap of top 50 genes
################################

res <- res[!is.na(res$padj),]
topgenes <- head(order(res$padj),50)

mat <- assay(vsd)[topgenes,]

pheatmap(
    mat,
    filename=file.path(outdir,"heatmap_top50_genes.png")
)
