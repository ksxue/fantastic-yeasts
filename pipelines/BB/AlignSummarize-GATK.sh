#!/bin/bash

# This script takes trimmed sequencing reads,
# aligns them to the specified reference,
# removes sequencing duplicates,
# and generates a pileup and gVCF file.
# Where possible or applicable, it follows the best practices described by GATK:
# https://software.broadinstitute.org/gatk/best-practices/bp_3step.php?case=GermShortWGS
# Note that this pipeline requires that the reference has already been indexed by
# both bowtie, samtools, and GATK.

# Load dependencies.
module load modules modules-init modules-gs
module load python/2.7.3
module load zlib/1.2.6
module load cutadapt/1.8.3
module load bowtie2/2.2.3
module load samtools/1.3
module load bcftools/1.3.1
module load VCFtools/0.1.14
module load bwa/0.7.13
module load java/8u25
module load GATK/3.7
module load picard/1.43

# Input parameters.
fastq1="$1" # Give trimmed read 1 file.
fastq2="$2" # Give trimmed read 2 file.
sample="$3" # Give the sample name.
dir="$4" # Give the desired location of intermediate output files.
reference="$5" # Give reference path WITHOUT .fasta or .fa extension.
refname="$6" # Give a short nickname for the reference sequence.
clean="$7" # If 0, reruns entire pipeline and regenerates all intermediates.

# Concatenate the sample and reference names
# so that all files reflect both the strain and reference.
sample="$sample-$refname"

# Notifies user when all intermediate files are being regenerated.
if [ ${clean} -eq "0" ]; then
  echo "Pipeline will run in its entirety, overwriting all existing intermediates."
fi

# Align reads with bowtie2.
# Convert SAM files to BAM files, sort, and delete SAM intermediates.
# Note that the GATK best practices suggest using bwa,
# but I have been having some trouble with picard running on bwa output.
echo "Align reads with bowtie2."
if [ ! -f ${dir}/${sample}-raw.bam ] || [ ${clean} -eq "0" ];
then
  bowtie2 --very-sensitive-local --un-conc-gz ${dir}/${sample}-unmapped \
	-X 1000 \
	-x ${reference} \
	-1 ${fastq1} \
	-2 ${fastq2} \
	-S ${dir}/${sample}.sam \
	2> ${dir}/${sample}.bt2.log
  samtools view -bS ${dir}/${sample}.sam -o ${dir}/${sample}-unsorted.bam
  samtools sort ${dir}/${sample}-unsorted.bam -o ${dir}/${sample}-raw.bam
  samtools index ${dir}/${sample}-raw.bam
  samtools flagstat ${dir}/${sample}-raw.bam
  # Remove intermediate files.
  rm -f ${dir}/${sample}.sam
  rm -f ${dir}/${sample}-unsorted.bam
fi

# Remove sequencing duplicates using Picard.
echo "Remove sequencing duplicates."
if [ ! -f ${dir}/${sample}.bam ] || [ ${clean} -eq "0" ];
then
  # Remove sequencing duplicates.
  java -Xmx2g -jar ${PICARD_DIR}/MarkDuplicates.jar \
    INPUT=${dir}/${sample}-raw.bam \
	OUTPUT=${dir}/${sample}-rmdup.bam \
	METRICS_FILE=${dir}/${sample}.picard \
	REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=TRUE
  # Add read groups.
  java -Xmx2g -jar ${PICARD_DIR}/AddOrReplaceReadGroups.jar \
    INPUT=${dir}/${sample}-rmdup.bam \
	OUTPUT=${dir}/${sample}.bam \
	RGID=${sample} RGLB=1 RGPU=1 RGPL=illumina RGSM=${sample} \
	VALIDATION_STRINGENCY=LENIENT
  # Remove intermediate files.
  rm -f ${dir}/${sample}-rmdup.bam
fi

# Generate genomic GVCF files for each sample using HaplotypeCaller.
# Note that this does not require you to realign indels,
# according to the GATK best practices.
# The resulting GVCF contains both SNPs and indels.
echo "Perform raw variant calling."
if [ ! -f ${dir}/${sample}-raw.g.vcf ] || [ $clean -eq "0" ];
then
  # Prepare BAM files for analysis.
  samtools index ${dir}/${sample}.bam
  # Convert BAM file to raw gVCF format using samtools for ploidy analysis.
  samtools mpileup -q 20 -Q 20 -v -f ${reference}.fasta \
    -o ${dir}/${sample}.vcf ${dir}/${sample}.bam
  # Call variants using HaplotypeCaller.
  java -jar ${GATK_DIR}/GenomeAnalysisTK.jar \
    -T HaplotypeCaller \
    -R ${reference}.fasta \
    -I ${dir}/${sample}.bam \
    --genotyping_mode DISCOVERY \
	--emitRefConfidence GVCF \
    -o ${dir}/${sample}-raw.g.vcf 
fi