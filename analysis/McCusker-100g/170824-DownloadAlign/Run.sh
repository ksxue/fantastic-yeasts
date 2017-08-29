#!/bin/bash

# This script is meant to be run from the top level of the Github repository.
# The script takes a list of accessions for the 100-genomes strains
# described in Strope et al., Genome Research, 2015,
# and downloads the raw reads associated with each strain.
# It then aligns each set of reads to the S288C reference.

# File paths.
fastqdump="pipelines/BB/SRADownloadFASTQ.sh"
batchtrimadapters="pipelines/BB/Batch-TrimAdaptersNextera.sh"
samplesheetraw="data/McCusker-100g/metadata-McCusker-accessions.txt"
samplesheet="data/McCusker-100g/Samples-McCusker-100g.data"
dir="nobackup/McCusker-100g/raw"
trimdir="nobackup/McCusker-100g/trimmed"
project="McCusker-100g"
clean=1

# Download raw FASTQ reads associated with each strain in the dataset.
:<<END
while read run remainder
do
  qsub -cwd -N ${run} -o nobackup/BB/sge/${run}.o -e nobackup/BB/sge/${run}.e \
    ${fastqdump} ${dir} ${run} ${clean}
done < <( tail -n +2 ${samplesheetraw} | cut -f21 )

# Process strain names and SRR numbers to create a data sheet for the dataset.
while read strain srr
do
  echo "${dir}/${srr}_1.fastq.gz ${dir}/${srr}_2.fastq.gz ${trimdir}/${strain}_trimmed_1.fastq.gz ${trimdir}/${strain}_trimmed_2.fastq.gz ${strain}"
done < <( tail -n +2 ${samplesheetraw} | cut -f1,21 ) > ${samplesheet}
END

# Calculate the number of samples to be analyzed.
# Note that the sample info sheet contains a header line.
numsamples="$( wc -l ${samplesheet} | cut -f1 -d' ')"

# Submit batch job to download reads from the SRA for each sample.
qsub -cwd -N TrimAdapters -t 1-${numsamples} -tc 50 \
  -o nobackup/${project}/sge/ -e nobackup/${project}/sge/ \
  ${batchtrimadapters} ${samplesheet} ${trimdir} ${clean}