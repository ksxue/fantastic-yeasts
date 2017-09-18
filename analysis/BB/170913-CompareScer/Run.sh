#!/bin/bash

# This script is meant to be run from the top level of the Github repository.
# It runs commands related to this set of analyses of S. cerevisiae genomic diversity.

# Load modules.
module load modules modules-init modules-gs
module load bcftools/1.3.1
module load java/8u25
module load GATK/3.7

# Script paths and set variables.
CallFilterVariants="pipelines/BB/CallFilterVariants-GATK.sh"
reference="reference/S288C/S288CReferenceAnnotated"
dir="nobackup/BB/170913-CompareScer"
clean=1 # When 0, runs analyses in their entirety, replacing existing intermediates.

# Aggregate all downloaded yeast genomes,
# including the McCusker-100genomes and Verstrepen beer strains.
if [ -f ${dir}/Samples.list ]; then
    rm -f ${dir}/Samples.list
fi
while read sample
do
  echo "nobackup/BB/170815-AlignScer/${sample}-S288C-raw.g.vcf"
done < data/BB/Scer.data >> ${dir}/Samples.list
while read fastq1 fastq2 trimmed1 trimmed2 sample
do
  echo "nobackup/McCusker-100g/170824-DownloadAlign/${sample}-S288C-raw.g.vcf"
done < data/McCusker-100g/Samples-McCusker-100g.data >> ${dir}/Samples.list
while read fastq1 fastq2 trimmed1 trimmed2 sample
do
  echo "nobackup/Verstrepen-beer/170824-DownloadAlign/${sample}-S288C-raw.g.vcf"
done < data/Verstrepen-beer/Samples-Verstrepen-beer.data >> ${dir}/Samples.list

# Check to make sure all of the raw genotype files that are expected in fact exist.
if [ -f ${dir}/Samples-found.list ]; then
    rm -f ${dir}/Samples-found.list
fi
while read file
do
  if [ -f ${file} ]; then
    echo "${file}"
  fi
done < ${dir}/Samples.list >> ${dir}/Samples-found.list

# Perform joint genotype calling on S. cerevisiae samples.
${CallFilterVariants} ${dir}/Samples-found.list ${reference} ${dir} S288C ${clean}

# Convert VCF file to genotype table.
if [ ! -f ${dir}/S288C-genotypes.data ] || [ $clean -eq "0" ]; then
  java -jar ${GATK_DIR}/GenomeAnalysisTK.jar \
    -R ${reference}.fasta \
    -T VariantsToTable \
    -V ${dir}/S288C-snps-filtered.vcf \
    -F CHROM -F POS -GF GT \
    -o ${dir}/S288C-genotypes.data
fi