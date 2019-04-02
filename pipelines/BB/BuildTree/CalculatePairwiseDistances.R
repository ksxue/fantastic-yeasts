#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

require(tidyverse)
require(foreach)
require(lazyeval)

# Verify that the correct number of arguments are given.
if(length(args)!=2){
  stop("The following arguments must be supplied: input genotype table, output distance matrix file.", 
       call.=FALSE)
}

VariantFile <- args[1]
OutFile <- args[2]

# Read in genotype matrix as produced by VariantsToTable in GATK.
# Do not use the moltenized form of the data.
Data <- read.table(VariantFile, header=TRUE, stringsAsFactors = FALSE)

# Subsample to one variant per kB.
DataSubsampled <- Data %>% mutate(kB=floor(POS/1000)) %>%
  group_by(CHROM, kB) %>% filter(POS==min(POS))

# Convert the data to tidy format.
# Process the genotype matrix.
DataTidy <- head(DataSubsampled) %>% gather(Sample, Genotype, -CHROM, -POS, -kB)
DataTidy <- DataTidy %>% separate(Genotype, into=c("Allele1","Allele2"), by="/")

# Generate all unique pairs of strains.
Strains <- unique(DataTidy$Sample)

# Generate all unique pairs of strains.
Pairs <- t(combn(Strains, 2))
Strain1 <- Pairs[,1]
Strain2 <- Pairs[,2]

# Calculate pairwise distances between each pair of strains.
Pairwise <- foreach(strain1=Strain1, strain2=Strain2, i=seq(1,length(Strain1)), .combine='rbind') %do% {
  if(i %% 1000 == 0){
    print(i/nrow(Pairs))
  }
  Pair <- DataSubsampled %>% ungroup() %>%
    dplyr::select_('strain1', 'strain2') %>%
    filter_(interp(~strain1!="./.", strain1=as.name(strain1)),
            interp(~strain2!="./.", strain2=as.name(strain2))) %>%
    mutate_(strain1A1=interp(~substr(strain1,1,1), strain1=as.name(strain1)),
            strain1A2=interp(~substr(strain1,3,3), strain1=as.name(strain1)),
            strain2A1=interp(~substr(strain2,1,1), strain2=as.name(strain2)),
            strain2A2=interp(~substr(strain2,3,3), strain2=as.name(strain2))) %>%
    mutate(Distance=ifelse(strain1A1==strain2A1,0,1) +
             ifelse(strain1A2==strain2A2,0,1)) %>%
    summarize(Distance=sum(Distance))
  c(strain1, strain2, Pair$Distance)
}

# Export distances.
write.table(Pairwise, OutFile,
            quote=FALSE, row.names=FALSE, col.names=FALSE)
