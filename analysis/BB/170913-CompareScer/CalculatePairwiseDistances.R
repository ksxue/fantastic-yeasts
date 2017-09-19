require(tidyverse)
require(foreach)
require(lazyeval)

# Read in genotype matrix as produced by VariantsToTable in GATK.
# Do not use the moltenized form of the data.
Data <- read.table("nobackup/BB/170913-CompareScer/S288C-genotypes.data.gz",
                   header=TRUE, stringsAsFactors = FALSE)

# Convert the data to tidy format.
# Process the genotype matrix.
DataTidy <- head(Data) %>% gather(Sample, Genotype, -CHROM, -POS)
#DataTidy <- DataTidy %>% separate(Sample, into=c("Strain", "Ref", "Table"), by="-") %>%
#  select(-Ref, -Table)
DataTidy <- DataTidy %>% separate(Genotype, into=c("Allele1","Allele2"), by="/")

# Generate all unique pairs of strains.
Strains <- unique(DataTidy$Sample)

# Subsample divergent strains to limit computational time.
# McCuskerSubset <- Strains[grep("^YJM*",Strains)]
# McCuskerSubset <- McCuskerSubset[seq(1, length(McCuskerSubset), 3)]
# VerstrepenSubset <- Strains[grep("^BE*",Strains)]
# VerstrepenSubset <- VerstrepenSubset[seq(1, length(VerstrepenSubset), 4)]
# FYStrains <- Strains[grep("^FY*",Strains)]
# DunhamBeerStrains <- Strains[grep("^YMD*",Strains)]
# Strains <- c(McCuskerSubset, VerstrepenSubset, FYStrains, DunhamBeerStrains)

# Generate all unique pairs of strains.
Pairs <- t(combn(Strains, 2))
Strain1 <- Pairs[,1]
Strain2 <- Pairs[,2]

# Calculate pairwise distances between each pair of strains.
Pairwise <- foreach(strain1=Strain1, strain2=Strain2, i=seq(1,length(Strain1)), .combine='rbind') %do% {
    print(i)
    Pair <- Data %>%
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

 write.table(Pairwise, "nobackup/BB/170913-CompareScer/PairwiseDistances.data",
            quote=FALSE, row.names=FALSE, col.names=FALSE)



##### PLOTTING
require(ggdendro)
require(cowplot)
require(RColorBrewer)
PairwiseDistances <- Pairwise
PairwiseDistances <- as.data.frame(PairwiseDistances, stringsAsFactors=FALSE)
colnames(PairwiseDistances) <- c("Strain1", "Strain2", "Distance")
PairwiseDistances$Strain1 <- as.character(PairwiseDistances$Strain1)
PairwiseDistances$Strain2 <- as.character(PairwiseDistances$Strain2)
PairwiseDistances$Distance <- as.numeric(PairwiseDistances$Distance)

# Create a full matrix of pairwise distances from the distance between each unique pair.
PairwiseDistancesReverse <- cbind(PairwiseDistances$Strain2,
                                  PairwiseDistances$Strain1,
                                  PairwiseDistances$Distance)
PairwiseDistancesSelf <- foreach(strain=unique(PairwiseDistances$Strain1), .combine='rbind') %do% {
  c(strain, strain, 0)
}
colnames(PairwiseDistancesReverse) <- c("Strain1", "Strain2", "Distance")
colnames(PairwiseDistancesSelf) <- c("Strain1", "Strain2", "Distance")
PairwiseDistances <- rbind(PairwiseDistances, PairwiseDistancesReverse, PairwiseDistancesSelf)

# Convert the pairwise distance dataframe into a matrix.
Distances <- PairwiseDistances %>%
  dplyr::select(Strain1, Strain2, Distance) %>%
  spread(Strain2, Distance) %>% dplyr::select(-Strain1)
rownames(Distances) <- colnames(Distances)
Distances <- as.matrix(Distances)

# Plot the dendrogram that results from hierarchical clustering.
Hclust <- hclust(as.dist(Distances))
Dendrogram <- ggdendrogram(Hclust)
Dendrogram.data <- dendro_data(as.dendrogram(Hclust))
tree <- ggplot() +
  geom_segment(data=segment(Dendrogram.data),
               aes(x=x, y=y, xend=xend, yend=yend)) +
  geom_text(data=label(Dendrogram.data) %>%
              separate(label, into=c("label","ref","data"), by=".") %>%
              mutate(study=ifelse(gsub('[[:digit:]]+', '', label) %in% c("YJM","YMD","FY"),
                                  gsub('[[:digit:]]+', '', label), "BE")),
            aes(label=label, x=x, y=0, color=factor(study)),
            angle=90, hjust=1, size=2.5) +
  theme(axis.line = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.position="bottom",
        legend.justification="center") +
  ylim(-0.3e5,3e5) +
  scale_color_brewer(palette="Dark2", name="collection")
tree
save_plot("analysis/BB/170913-CompareScer/dendrogram.pdf",tree,
          base_width=25, base_height=8)

# Plot the dendrogram together with the heatmap 
# representing all pairwise relationships.
HclustDendro <- as.dendrogram(Hclust)
Distances <- as.data.frame(Distances[order.dendrogram(HclustDendro),
                                     order.dendrogram(HclustDendro)], stringsAsFactors=FALSE)
PairwiseDistances <- PairwiseDistances %>%
  mutate(Strain1=factor(Strain1, levels=colnames(Distances)),
         Strain2=factor(Strain2, levels=colnames(Distances)))
SortedHeatmap <- 
  ggplot(PairwiseDistances) +
  geom_tile(aes(x=Strain1, y=Strain2, fill=Distance)) +
  scale_fill_gradient(low = "steelblue", high = "white") +
  xlab("") + ylab("") +
  scale_x_discrete(expand=c(0,0)) + scale_y_discrete(expand=c(0,0)) +
  theme(axis.text.x=element_text(angle=90, vjust=0.5, hjust=1),
        axis.ticks=element_blank(),
        axis.line = element_blank()) +
  guides(fill=FALSE)
SortedHeatmap
