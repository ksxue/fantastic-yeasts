#!/bin/bash

# This script takes raw sequencing reads,
# trims adapters,
# aligns them to the specified reference,
# removes sequencing duplicates,
# and generates a pileup and gVCF file.
# Where possible or applicable, it follows the best practices described by GATK:
# https://software.broadinstitute.org/gatk/best-practices/bp_3step.php?case=GermShortWGS

# Load dependencies.
module load modules modules-init modules-gs
module load python/2.7.3
module load cutadapt/1.8.3
module load samtools/1.3
module load picard/1.43
module load bcftools/1.3.1
module load VCFtools/0.1.14
module load zlib/1.2.6
module load bwa/0.7.13
module load java/8u25
module load GATK/3.7

# Input parameters.
rawdir="$1"
index1="$2"
index2="$3"
sample="$4"
run="$5"
dir="nobackup/BB"
modules="pipelines/BB/LoadModules.sh"
reference="reference/S288C/S288CReferenceAnnotated"
picarddir="/net/gs/vol3/software/modules-sw/picard/1.43/Linux/all/all/"
clean=0 # If 0, reruns entire pipeline and regenerates all intermediates.

# Note that this pipeline requires that the reference has already been indexed by
# both bowtie, samtools, and GATK.

# Notifies user when all intermediate files are being regenerated.
if $clean; then
  echo "Pipeline will run in its entirety, overwriting all existing intermediates."
fi

# Trim adapter sequences and bases below a quality threshold of 25.
# Also remove all reads that are shorter than 20 bases after trimming.
echo "Trim adapter sequences."
if [ ! -f ${dir}/${sample}_trimmed-R1.fastq.gz ] || [ ! -f ${dir}/${sample}_trimmed-R2.fastq.gz ];
then
  cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAG \
    -q 25 -m 20 \
	-o ${dir}/${sample}_trimmed-R1.fastq.gz -p ${dir}/${sample}_trimmed-R2.fastq.gz \
	raw/${rawdir}/${index1}.${index2}_${run}.1.fastq.gz \
	raw/${rawdir}/${index1}.${index2}_${run}.2.fastq.gz \
	> ${dir}/${sample}.cutadapt.log
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
	-1 ${dir}/${sample}_trimmed-R1.fastq.gz \
	-2 ${dir}/${sample}_trimmed-R2.fastq.gz \
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
  java -Xmx2g -jar ${picarddir}/MarkDuplicates.jar \
    INPUT=${dir}/${sample}-raw.bam \
	OUTPUT=${dir}/${sample}-rmdup.bam \
	METRICS_FILE=${dir}/${sample}.picard \
	REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=TRUE
  # Add read groups.
  java -Xmx2g -jar ${picarddir}/AddOrReplaceReadGroups.jar \
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