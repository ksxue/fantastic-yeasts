#!/bin/bash

# This script is meant to be run from the top level of the Github repository.
# The script takes a list of accessions for the industrial beer strains
# described in Gallone et al., Cell, 2016,
# and downloads the raw reads associated with each strain.
# It then aligns each set of reads to the S288C reference.

# File paths.
batchfastqdump="pipelines/BB/Batch-SRADownloadFASTQ.sh"
samplesheet="data/Verstrepen-beer/metadata-Verstrepen-accessions.txt"
dir="nobackup/Verstrepen-beer/raw"
project="Verstrepen-beer"
clean=0

# Calculate the number of samples to be analyzed.
# Note that the sample info sheet contains a header line.
numsamples="$(tail -n +2 ${samplesheet} | wc -l | cut -f1 -d' ')"

# Submit batch job to download reads from the SRA for each sample.
runs="${dir}/runs.txt"
tail -n +2 ${samplesheet} | cut -f10 > ${runs}
qsub -cwd -N DownloadVerstrepen -t 1-${numsamples} -tc 75 \
  -o nobackup/${project}/sge/ -e nobackup/${project}/sge/ \
  ${batchfastqdump} ${dir} ${runs} ${clean}
