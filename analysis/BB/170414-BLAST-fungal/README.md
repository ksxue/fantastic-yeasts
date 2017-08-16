# Fungal BLAST

This directory contains code for BLAST-ing the raw sequences against various fungal genomes.

**database**

I am using a database of fungal genomes compiled by Jim Thomas based on publicly available genomes from NCBI and JGI. These genomes are consistently organized and are already formatted into BLAST databases for each individual species. This database is available on the GS server here:
/net/gs/vol4/shared/thomaslab/genomes/Fungi

Jim has listed all of the genomes in his collection, along with their short identifiers, in the files dirs_asco.txt, dirs_basal.txt, and dirs_basidio.txt, which I copied from his database.

**BLAST**

For each of the sequenced yeast strains, I am BLAST-ing the first thousand reads against all of the Ascomycetes genomes that Jim has in his collection. I could easily expand this to include other groups of fungi as well.

In August 2017, I also added some of the beer strains that the Dunham lab has previously sequenced to this analysis.

**results**

The results of this BLAST analysis are summarized in the FungalBLAST.data file in this directory. Each strain is listed with the number of reads (out of 1000) that map to the best-match genome, which is also listed.

*Bootleg Biology strains*
Out of these 28 strains,
* 2 strains (FY0001 and FY0005) have very low mapping rates to all of the Ascomycetes genomes in the database. Noah streaked out both strains and determined that FY0001 is Bacillus megaterium (I was able to confirm this by mapping reads against that genome). FY0005 is another budding yeast, but we have not yet figured out what it is.
* 4 strains have intermediate mapping rates, suggesting that they may be hybrids.
* 22 strains have strong mapping rates against a single known genome. Of these,
	* 17 strains match strongly to S. cerevisiae
	* 3 strains match strongly to Brettanomyces bruxellensis
	* 1 strain matches strongly to Meyerozyma caribbica
	* 1 strain matches strongly to Pichia kudriazevii

*Dunham beer strains*
Out of these 16 strains, which Giang cultured from beer samples and then sequenced,
* 15 strains have strong (>90%) matches to S. cerevisiae
	* 1 strain, YMD1867, annotated Wyeast 1332 Northwest Ale, has a slightly lower mapping rate to S. cerevisiae than most strains at about 88%
* 1 strain has an intermediate (~60%) match to S. cerevisiae, and the second strongest hit is to S. eubayanus. This genomic evidence suggests that the strain is a lager yeast, and indeed, the strain YMD1874 is the only yeast that was collected from a documented lager (Wyeast 2112 Cal Lager).