public datasets
========================

# 100-genomes strains
These 100-genomes strains (consisting of 93 novel strains) were sequenced and described in Strope et al., *Genome Research*, 2015. (doi: 10.1101/gr.185538.114)
http://genome.cshlp.org/content/early/2015/04/03/gr.185538.114.full.pdf+html

**raw reads**
Raw reads were downloaded from the SRA using FASTQ-dump in August 2017.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/nobackup/McCusker-100g/raw

**trimmed reads**
Nextera adapters were trimmed from the raw reads using cutadapt version 1.14. Note that cutadapt 1.14 does not appear to be available as a module on the cluster, but is necessary to properly parse the names of reads downloaded from the SRA.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/nobackup/McCusker-100g/trimmed

**strain metadata**
This file is a parsable version of Table S19 of Strope et al., listing the Genbank and SRA accessions for assemblies and raw reads from each strain. 
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/data/McCusker-100g/metadata-McCusker-accessions.txt

This file corresponds to Table S1 of Strope et al., *Genome Research*, 2015. It contains geographical annotations for each of the 93 sequenced strains.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/data/McCusker-100g/metadata-McCusker-raw.docx

This file lists in tab-delimited format the relative paths to raw read 1, raw read 2, trimmed read 1, trimmed read 2, and the biological sample name. Note that all paths are written relative to the top-level of the *fantastic yeasts* Github repository.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/data/McCusker-100g/Samples-McCusker-100g.data

**supplementary scripts**
The paths above should contain the relevant data for most people seeking to analyze these strains. However, for anyone looking to re-download the data, or in the event that the files are overwritten, the script that I used to download, trim, and align the reads is located here. Note that it is also meant to be run from the top level of the Github repository and relies on several other scripts within the *fantastic yeasts* repository.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/analysis/McCusker-100g/170824-DownloadAlign/Run.sh


# Verstrepen beer strains
These 157 industrial yeast strains from White labs were sequenced and described in Gallone et al., *Cell*, 2016. (doi: 10.1016/j.cell.2016.08.020)
http://cell.com/fulltext/S0092-8674(16)31071-6

**raw reads**
Raw reads were downloaded from the SRA using FASTQ-dump in August 2017. This dataset contained multiple samples that were sequenced on two runs, meaning that they had two associated SRR accessions and therefore two sets of FASTQ files. I concatenated the FASTQ files for these samples and renamed all samples to match their biological sample name. **Note** that I encountered a problem with sample WL005 (SRR5688268 and SRR5688269), in which the read 2 reads corresponding to SRR5688269 were filtered out by fastq-dump as technical duplicates. I did not encounter this issue for any other samples. I instead retained only reads from SRR5688268 for trimming and downstream analyses.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/nobackup/Verstrepen-beer/raw

**trimmed reads**
Nextera adapters were trimmed from the raw reads using cutadapt version 1.14. Note that cutadapt 1.14 does not appear to be available as a module on the cluster, but is necessary to properly parse the names of reads downloaded from the SRA.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/nobackup/Verstrepen-beer/trimmed

**strain metadata**
This file lists SRA accessions for all runs associated with SRP109074, the SRA experiment associated with this study.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/data/Verstrepen-beer/metadata-Verstrepen-accessions.txt

This file is a parsable version of Table S1 of Gallone et al., listing each strain, its place of origin, sequencing statistics, and SRA information. 
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/data/Verstrepen-beer/metadata-Verstrepen-formatted.txt

This file lists in tab-delimited format the relative paths to raw read 1, raw read 2, trimmed read 1, trimmed read 2, and the biological sample name. Note that all paths are written relative to the top-level of the *fantastic yeasts* Github repository.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/data/Verstrepen-beer/Samples-Verstrepen-beer.data

**supplementary scripts**
The paths above should contain the relevant data for most people seeking to analyze these strains. However, for anyone looking to re-download the data, or in the event that the files are overwritten, the script that I used to download, trim, and align the reads is located here. Note that it is also meant to be run from the top level of the Github repository and relies on several other scripts within the *fantastic yeasts* repository.
/net/dunham/vol2/ksxue/yeast/fantastic-yeasts/analysis/Verstrepen-beer/170824-DownloadAlign/Run.sh