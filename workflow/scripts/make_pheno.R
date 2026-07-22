input <- snakemake@input
output <- snakemake@output
params <- snakemake@params

library(magrittr)
library(dplyr)

pca <- readRDS(input$pcair)
pcs <- data.frame(pca$vectors)
colnames(pcs) <- paste0("PC", 1:ncol(pcs))
pcs$IID <- row.names(pcs)

sampmet <- readRDS(input$sampmet)

xwalk <- read.csv(input$xwalk, header = TRUE, stringsAsFactors = FALSE)

famnames <- c("FID", "IID", "FATHER", "MOTHER", "SEX", "PHENO")
fam <- read.delim(input$fam,
    sep = " ", header = FALSE,
    stringsAsFactors = FALSE, col.names = famnames
) %>%
    select(-SEX, -PHENO)

covar <- read.csv(input$bps, header = TRUE, stringsAsFactors = FALSE) %>%
    rename(sex = sex_c) %>%
    left_join(xwalk, by = c("subject" = "ACT_ID")) %>%
    mutate(IID = NA_character_)
act_idx <- paste0("ACT", covar$subject) %in% fam$IID
cat("ACT IDs matched between covar and fam:\n")
table(act_idx) %>% print()
covar$IID[act_idx] <- paste0("ACT", covar$subject[act_idx])
indno_idx <- covar$IndNo %in% fam$IID
cat("IndNo IDs matched between covar and fam:\n")
table(indno_idx) %>% print()
covar$IID[indno_idx] <- covar$IndNo[indno_idx]
cat("covar IDs matched to fam:\n")
table(covar$IID %in% fam$IID) %>% print()
covar %<>% filter(IID %in% fam$IID)

fam_recode <- left_join(fam, covar, by = "IID") %>%
    select(FID, IID, FATHER, MOTHER, SEX = sex, PHENO = params$pheno_name)
cat("is.na(PHENO) in fam_recode:\n")
is.na(fam_recode$PHENO) %>%
    table() %>%
    print()
write.table(fam_recode, output$fam,
    sep = " ", row.names = FALSE,
    col.names = FALSE, quote = FALSE, na = "-9"
)

covar_recode <- left_join(covar, pcs, by = "IID") %>%
    left_join(select(fam_recode, FID, IID), by = "IID") %>%
    extract(c("FID", "IID", params$covar_names)) %>%
    filter(IID %in% filter(sampmet, pass)$id)

write.table(covar_recode, output$covar_file,
    sep = "\t", row.names = FALSE,
    quote = FALSE, na = "-9"
)
