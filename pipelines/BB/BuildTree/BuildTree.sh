#!/bin/bash

# This script is meant to be run from the top level of the Github repository.
# This script takes raw FASTQ files,
# trims the Nextera adapters,
# uses the GATK pipeline to generate gVCF files based on mapping to S288C,
# creates a joint genotyping file with the other sequenced Scer strains,
# calls SNPs and filters them using standard filters,
# and generates a dendrogram with the strains from the genotype matrix.

# Input parameters.
fastq1="$1" # Give raw read 1 file.
fastq2="$2" # Give raw read 2 file.
sample="$3" # Give the sample name.
refsamples="$4" # Give a list of gVCF files to compare to.
dir="$5" # Give the desired location of intermediate output files.
clean="$6" # If 0, reruns entire pipeline and regenerates all intermediates.

# Pipeline paths.
TrimAdaptersNextera="pipelines/BB/TrimAdaptersNextera.sh"
AlignSummarizeGATK="pipelines/BB/AlignSummarize-GATK.sh"
CallFilterVariantsGATK="pipelines/BB/CallFilterVariants-GATK.sh"
S288CReference="reference/S288C/S288CReferenceAnnotated"
CalculatePairwiseDistances="pipelines/BB/BuildTree/CalculatePairwiseDistances.R"
PlotTree="pipelines/BB/BuildTree/PlotTree.R"

# Trim adapters from raw FASTQ files.
${TrimAdaptersNextera} $fastq1 $fastq2 $sample $dir $clean

# Align trimmed reads to S288C reference genome.
${AlignSummarizeGATK} \
  ${dir}/${sample}_trimmed-R1.fastq.gz \
  ${dir}/${sample}_trimmed-R2.fastq.gz \
  ${sample} ${dir} ${S288CReference} S288C ${clean}
  
# Jointly call variants with GATK and the previously sequenced strains.
cp ${refsamples} ${dir}/Samples.list
echo ${dir}/${sample}-S288C-raw.g.vcf >> ${dir}/Samples.list
${CallFilterVariantsGATK} ${dir}/Samples.list \
  ${S288CReference} ${dir} ${sample}-S288C ${clean}

# Convert VCF file to genotype table.
if [ ! -f ${dir}/${sample}-S288C-genotypes.data.gz ] || [ $clean -eq "0" ]; then
  echo "Generate genotype table."
  java -jar ${GATK_DIR}/GenomeAnalysisTK.jar \
    -R ${S288CReference}.fasta \
    -T VariantsToTable \
    -V ${dir}/${sample}-S288C-snps-filtered.vcf \
    -F CHROM -F POS -GF GT \
    -o ${dir}/${sample}-S288C-genotypes.data
  gzip ${dir}/${sample}-S288C-genotypes.data
fi

# Calculate matrix of pairwise distances between strains.
if [ ! -f ${dir}/${sample}.distances ] || [ $clean -eq "0" ]; then
  echo "Calculate pairwise distances."
  Rscript ${CalculatePairwiseDistances} \
  ${dir}/${sample}-S288C-genotypes.data.gz ${dir}/${sample}.distances
fi

# Plot tree with the previously sequenced samples along with the new sample.
# Calculate matrix of pairwise distances between strains.
if [ ! -f ${dir}/${sample}.tree ] || [ $clean -eq "0" ]; then
  echo "Plot tree."
  Rscript ${PlotTree} ${dir}/${sample}.distances ${dir}/${sample}-tree.pdf
fi
