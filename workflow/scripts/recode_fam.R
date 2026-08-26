logcon <- file(snakemake@log[[1]], open = "wt")
sink(logcon)
sink(logcon, type = "message")
input <- snakemake@input
output <- snakemake@output
library(dplyr)

famnames <- c("FID", "IID", "FATHER", "MOTHER", "SEX", "PHENO")
fam <- read.delim(input$fam, sep = " ", header = FALSE,
                  stringsAsFactors = FALSE, col.names = famnames) %>%
    select(-SEX, -PHENO)
covar <- read.delim(input$covar, sep = "\t", header = TRUE,
                    stringsAsFactors = FALSE) %>%
    mutate(sex = sex + 1L)

fam_recode <- left_join(fam, covar, by = c("IID", "FID")) %>%
    select(FID, IID, FATHER, MOTHER, SEX = sex, PHENO = brainsev4_bf)
write.table(fam_recode, output$fam_recode, sep = " ", row.names = FALSE,
            col.names = FALSE, quote = FALSE, na = "-9")

covar_recode <- select(covar, FID, IID, PC1, PC2, PC3, age_at_death, sex)
write.table(covar_recode, output$covar_recode, sep = "\t", row.names = FALSE,
            quote = FALSE, na = "-9")
