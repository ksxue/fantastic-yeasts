# FY0002

This directory contains code for analyses related to the FY0002 strain, which has an unusual relationship with other Saccharomyces species.

**background**

In the 170225-Alignment and 170414-BLAST-fungal analyses, I determined that the FY0002 strain is unusual because about only about 65% of reads map of S. cerevisiae, although 89% of reads map to all of the yeast in my collected reference genomes (which include some Candida and other clades). (See analysis/BB/170225-Alignment/MapRates.data)

I also found that about 58% of reads BLAST to S. cerevisiae, and the next closest match is that about 40% of reads BLAST to S. eubayanus. (See nobackup/BB/170414-BLAST-fungal/FY0002.summary) Typically, for strains that have a high match to S. cerevisiae, the next closest match is to S. paradoxus, in keeping with the genus phylogeny, but this relationship seems to suggest that the strain may be a hybrid of S. cerevisiae and S. eubayanus. It is even possible that it is an equal hybrid of the two, and the high mapping rate of S. cerevisiae is due to conserved regions of the S. eubayanus genome.

I mapped the FY0002 reads against the reference genome and called variants using GATK. I found that the FY0002 strain had an unusually high divergence from the S288C reference strain, with nearly twice the divergence (calculated from an unphased diploid) relative to the other, more obviously S. cerevisiae strains. I plotted the distance in windows along the genome and found that divergence was relatively constant; that is, there were not many regions that obviously had a much higher divergence from the reference compared to other parts of the genome, and it seemed that variants were distributed relatively evenly across the genome. All in all, this suggests that there is genome-wide divergence of the FY0002 strain from the S288C reference rather than there just being a couple regions that are reponsible for most observations of divergence.

**analyses and results**

*BLAST unmapped reads* I BLAST-ed the FY0002 reads that did NOT map to S. cerevisiae against the set of many Ascomycetes genomes in Jim Thomas's database. (See nobackup/BB/170414-BLAST-fungal/FY0002-unmapped.1.summary) I found that the top hit was S. eubayanus, with 883/1000 reads as hits. S. uvarum was the next hit, wtih 378/1000 reads as hits. The BLAST parameters are more generous than the general mapping parameters, but this suggests that I should also map the reads that did not map to the S. cerevisiae genome against the S. eubayanus genome. I could also map all of the reads against both genomes simultaneously, or against a genome of the S. pastorianus hybrid of the two species.