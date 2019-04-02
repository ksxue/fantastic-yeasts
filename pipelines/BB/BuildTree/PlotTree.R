#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

require(tidyverse)
require(ggdendro)
require(RColorBrewer)
require(foreach)

# Verify that the correct number of arguments are given.
if(length(args)!=2){
  stop("The following arguments must be supplied: input distance list (tidy format), output tree file.", 
       call.=FALSE)
}

DistanceFile <- args[1]
OutFile <- args[2]

# Read in distance matrix and rename columns.
PairwiseDistances <- read.table(DistanceFile, header=FALSE, stringsAsFactors = FALSE)
colnames(PairwiseDistances) <- c("Strain1", "Strain2", "Distance")
PairwiseDistances$Strain1 <- as.character(PairwiseDistances$Strain1)
PairwiseDistances$Strain2 <- as.character(PairwiseDistances$Strain2)
PairwiseDistances$Distance <- as.numeric(PairwiseDistances$Distance)

# Create a full matrix of pairwise distances from the distance between each unique pair.
# Do some bookkeeping to calculate distance B->A from A->B
# and to set distances to self as zero.
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
# Assign strains into groups based on the reference study
# for label coloring on the tree.
Dendrogram.labels <- label(Dendrogram.data) %>%
  separate(label, into=c("label","ref","data"), by=".") %>%
  mutate(study=ifelse(gsub('[[:digit:]]+', '', label) %in% c("YJM"), "McCusker",
               ifelse(gsub('[[:digit:]]+', '', label) %in% c("BE","BI","BR","LA","SA","SP","WI","WL"),
                      "Verstrepen", label)))
# Plot the dendrogram with labeled strains.
tree <- ggplot() +
  geom_segment(data=segment(Dendrogram.data),
               aes(x=x, y=y, xend=xend, yend=yend)) +
  geom_text(data=Dendrogram.labels,
            aes(label=label, x=x, y=0, color=factor(study)),
            angle=-90, hjust=0, size=2.5) +
  theme_void() +
  theme(legend.position="bottom",
        legend.justification="center") +
  scale_color_brewer(palette="Dark2", name="collection") +
  ylim(-0.01*1e4, 0.4*1e4)
tree

# Export plot using ggsave.
# There are some compatibility issues with cowplot on the cluster version of R, as of 11/2018.
ggsave(OutFile, tree, width=25, height=8)
