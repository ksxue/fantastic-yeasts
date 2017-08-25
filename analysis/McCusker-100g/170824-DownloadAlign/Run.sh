#!/bin/bash

# This script is meant to be run from the top level of the Github repository.
# The script takes a list of accessions for the 100-genomes strains
# described in Strope et al., Genome Research, 2015,
# and downloads the raw reads associated with each strain.
# It then aligns each set of reads to the S288C reference.

# File paths.
fastqdump="pipelines/BB/SRADownloadFASTQ.sh"
samplesheet="data/McCusker-100g/metadata-McCusker-accessions.txt"
dir="nobackup/McCusker-100g/raw"
clean=1

while read run remainder
do
  qsub -cwd -N ${run} -o nobackup/BB/sge/${run}.o -e nobackup/BB/sge/${run}.e \
    ${fastqdump} ${dir} ${run} ${clean}
done < <( tail -n +2 ${samplesheet} | cut -f21 )