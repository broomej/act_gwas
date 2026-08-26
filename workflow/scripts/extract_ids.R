logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")
output <- snakemake@output
ids <- read.table(snakemake@input[[1]], header = TRUE, stringsAsFactors = FALSE) |>
    dplyr::select(FID, IID)
write.table(ids, output$txt, row.names = FALSE, col.names = FALSE,
            quote = FALSE, sep = " ")
saveRDS(ids$IID, output$rds)
