# Given the list of BioSamples associated with the industrial yeast strains
# sequenced in Gallone et al., Cell, 2016,
# extract the relevant SRR numbers
# and output a table matching sample names, SAMN numbers, and SRR numbers.

library(SRAdb)

sqlfile <- 'nobackup/SRAmetadb.sqlite'
if(!file.exists('nobackup/SRAmetadb.sqlite')) sqlfile <<- getSRAdbFile()
sra_con <- dbConnect(SQLite(),sqlfile)

Accessions <- sraConvert(c('SRP109074'), 'SRA',sra_con)

# Metadata <- read.table("data/Verstrepen-beer/metadata-Verstrepen-accessions.txt",
#                        header=TRUE, stringsAsFactors = FALSE, sep="\t",
#                        quote=NULL, comment="")
