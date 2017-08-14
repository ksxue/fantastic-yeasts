========================
reference
========================

This directory contains reference sequences for this project.

*references.data:* Reference sequences are catalogued here in Genus/Species/Folder/Filename form.

**S288C**

*S288CReference.fasta:* Files for each chromosome and the mitochondrial genome were downloaded from the Saccharomyces Genome Database and concatenated without any renaming to produce this file.

*S288CReferenceAnnotated.fasta:* The header of each FASTA file was manually edited to contain as its first word "Scer_XX" where XX gives the chromosome number in Arabic numerals, or the name of the sequence. The FASTA sequence for the 2-micron plasmid was obtained through a personal communication. The renamed files for each chromosome, the 2-micron plasmid, and the mitochondrial genome were concatenated to produce this file.

**Saccharomyces**

Reference sequences for various members of Saccharyomyces sensu stricto. In March 2017, I downloaded the most recent ultra-scaffolds for cerevisiae, bayanus, kudriavzevii (IFO 1802), paradoxus, and mikatae from the sensu stricto database: http://www.saccharomycessensustricto.org/cgi-bin/s3.cgi?data=Assemblies&version=current I renamed these files to have .fasta file extensions.

The reference sequence for the unmasked S. pastorianus strain Weihenstephan34/70 was downloaded from SGD in August 2017.

**Candida**

Reference sequences for various Candida species. In March 2017, I downloaded the most recent genomes from the Candida database: http://www.candidagenome.org/download/sequence/ I renamed species to take Gspecies form.

**Bacteria**

Reference sequences for various bacterial species of interest. NCBI reference numbers are included where appropriate.

**other**

*Klactis:* In April 2017, I downloaded the Kluyveromyces lactis genome available here: ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/515/GCF_000002515.2_ASM251v1/GCF_000002515.2_ASM251v1_genomic.fna.gz

*Picmem:* In August 2017, I downloaded the Pichia membranofaciens v2.0 genome assembly (masked) from the JGI Fungal Genomics Resource:
http://genome.jgi.doe.gov/pages/dynamicOrganismDownload.jsf?organism=Picme2

**scripts**

*setup.sh* This script takes a list of reference genomes of interest and concatenates them into one large metagenomic reference in order to perform simultaneous mapping.