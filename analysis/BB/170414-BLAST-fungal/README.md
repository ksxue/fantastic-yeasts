# Fungal BLAST

This directory contains code for BLAST-ing the raw sequences against various fungal genomes.

**database**

I am using a database of fungal genomes compiled by Jim Thomas based on publicly available genomes from NCBI and JGI. These genomes are consistently organized and are already formatted into BLAST databases for each individual species. This database is available on the GS server here:
/net/gs/vol4/shared/thomaslab/genomes/Fungi

Jim has listed all of the genomes in his collection, along with their short identifiers, in the files dirs_asco.txt, dirs_basal.txt, and dirs_basidio.txt, which I copied from his database.

**BLAST**

For each of the sequenced yeast strains, I am BLAST-ing the first thousand reads against all of the Ascomycetes genomes that Jim has in his collection. I could easily expand this to include other groups of fungi as well.