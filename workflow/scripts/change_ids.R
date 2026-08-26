logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")
df_plink <- snakemake@input[[1]] |>
    read.table(header = TRUE, stringsAsFactors = FALSE) |>
    dplyr::mutate(across(SNP, ~gsub(":[AGTC]+:[AGTC]+(;.*)?$", "", .x)))
id_is_expected_format <- grepl("^chr([1-9]|1[0-9]|2[0-2]|X):[0-9]+$", df_plink$SNP)
if (any(!id_is_expected_format)) {
    warning("Not all SNP IDs are in the expected format of 'chr:pos'.")
    no_match <- df_plink$SNP[!id_is_expected_format]
    message("Randomly sampled SNP IDs that do not match the expected format:")
    sample(no_match, min(5, length(no_match))) |> print()
    message("n IDs do not match the expected format: ", sum(!id_is_expected_format))
    message("Proportion of IDs that do not match the expected format: ", mean(!id_is_expected_format))
    stop()
}
write.table(df_plink, snakemake@output[[1]], quote = FALSE, row.names = FALSE,
            sep = " ", col.names = TRUE)
