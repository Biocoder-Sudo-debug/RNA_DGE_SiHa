library(clusterProfiler)
library(org.Hs.eg.db)
library(ggplot2)

args <- commandArgs(trailingOnly=TRUE)

deg_file <- args[1]
outdir <- args[2]

dir.create(outdir, showWarnings = FALSE)

################################
# Load DEG table
################################

deg <- read.table(
    deg_file,
    header=TRUE,
    sep="\t",
    row.names=1,
    check.names=FALSE
)

################################
# Extract gene IDs
################################

genes <- rownames(deg)

# Remove ENSEMBL version numbers (e.g. ENSG00000141510.16 → ENSG00000141510)
genes <- gsub("\\..*", "", genes)

genes <- unique(genes)

################################
# Convert ENSEMBL → ENTREZ
################################

gene_map <- bitr(
    genes,
    fromType="ENSEMBL",
    toType="ENTREZID",
    OrgDb=org.Hs.eg.db
)

entrez <- gene_map$ENTREZID

################################
# GO enrichment
################################

ego <- enrichGO(
    gene=entrez,
    OrgDb=org.Hs.eg.db,
    ont="BP",
    pAdjustMethod="BH",
    readable=TRUE
)

write.table(
    as.data.frame(ego),
    file=file.path(outdir,"GO_BP_results.tsv"),
    sep="\t",
    quote=FALSE
)

png(file.path(outdir,"GO_dotplot.png"), width=1200, height=900)
dotplot(ego)
dev.off()

################################
# KEGG enrichment
################################

ekegg <- enrichKEGG(
    gene=entrez,
    organism="hsa"
)

write.table(
    as.data.frame(ekegg),
    file=file.path(outdir,"KEGG_results.tsv"),
    sep="\t",
    quote=FALSE
)

png(file.path(outdir,"KEGG_dotplot.png"), width=1200, height=900)
dotplot(ekegg)
dev.off()
