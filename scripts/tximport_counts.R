library(tximport)
library(readr)

args <- commandArgs(trailingOnly = TRUE)

salmon_dir <- args[1]
tx2gene_file <- args[2]
output_file <- args[3]

files <- list.files(
  salmon_dir,
  pattern="quant.sf",
  recursive=TRUE,
  full.names=TRUE
)

names(files) <- basename(dirname(files))

tx2gene <- read_delim(
  tx2gene_file,
  delim="\t",
  col_names=c("TXNAME","GENEID")
)

txi <- tximport(
  files,
  type="salmon",
  tx2gene=tx2gene,
  countsFromAbundance="lengthScaledTPM",
  dropInfReps=TRUE,
  ignoreAfterBar = TRUE
)

counts <- txi$counts

write.table(
  counts,
  file=output_file,
  sep="\t",
  quote=FALSE,
  col.names=NA
)
