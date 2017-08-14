# Pichia

This directory contains code for analyses related to the FY0010 and FY0017 strains, which appear to be Pichia hybrids.

**background**

In the 170414-BLAST-fungal analysis, I determined that the FY0010 and FY0017 strains are unusual because approximately 57% of reads BLAST to Pichia membranifaciens, and the next closest matches are 2% of reads mapping to Candida ethanolica (a Pichia relative), S. cerevisiae, and Pichia kudriazevii. This makes me think that the strains are some kind of Pichia hybrid. Interestingly, they originate from very different locations and were collected several years apart. FY0010 was isolated from Colorado Springs, CO, in 2012 from honey diluted in wort, and FY0017 was isolated from Westbrook, ME, in 2015 from wildberries.

**analyses and results**

*map to Pichia membranifaciens and BLAST unmapped reads* I mapped reads from both the FY0010 and FY0017 strains to the Pichia membranifaciens v2.0 genome assembly, using the masked assembly, which I downloaded from JGI. I then BLAST-ed the unmapped reads again the set of many Ascomycetes genomes in Jim Thomas's database. (See nobackup/BB/170414-BLAST-fungal/FY0010-unmapped.1.summary and nobackup/BB/170414-BLAST-fungal/FY0017-unmapped.1.summary) I found that the unmapped reads did not map closely to any other genomes in the database, unlike the case of FY0002. Out of the 1000 unmapped reads that I BLAST-ed, only about 8% were hits to S. cerevisiae, P. membranifaciens, and C. ethanolica for both strains.

I then took the first 1000 reads from FY0010 and FY0017 that did not map to the Pichia membranifaciens v2.0 genome assembly and tried BLAST-ing them against the hybrid genome assembly that Caiti and Ivan had developed. Interestingly, I found that about 85% of them mapped to the hybrid genome assembly, a much higher proportion than mapped to any of the other Ascomycetes yeasts. At a glance, it does look as though most of the mappings are against sub-genome B, the previously unidentified Pichia species, as I might expect if FY0010 and FY0017 are in fact the same hybrid Pichia as Caiti identified from the Old Warehouse open fermentation.