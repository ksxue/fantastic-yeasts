# This script is meant to be run from the top level of the Github repository.
# It reads in a list of directories, sample indices, and sample names,
# and then aligns the reads for the specified sample.

# Load modules.
module load modules modules-init modules-gs
module load python/2.7.3
module load cutadapt/1.8.3
module load bowtie2/2.2.3
module load samtools/1.3
module load picard/1.43
module load bcftools/1.3.1
module load VCFtools/0.1.14
module load zlib/1.2.6

# Input parameters.
rawdir="$1"
index1="$2"
index2="$3"
sample="$4"
run="$5"
dir="nobackup/BB"
reference="reference/S288C/S288CReferenceAnnotated"
picarddir="/net/gs/vol3/software/modules-sw/picard/1.43/Linux/all/all/"

# Trim adapter sequences and bases below a quality threshold of 25.
# Also remove all reads that are shorter than 20 bases after trimming.
if [ ! -f ${dir}/${sample}_trimmed-R1.fastq.gz ] || [ ! -f ${dir}/${sample}_trimmed-R2.fastq.gz ];
then
  cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAG \
    -q 25 -m 20 \
	-o ${dir}/${sample}_trimmed-R1.fastq.gz -p ${dir}/${sample}_trimmed-R2.fastq.gz \
	raw/${rawdir}/${index1}.${index2}_${run}.1.fastq.gz raw/${rawdir}/${index1}.${index2}_${run}.2.fastq.gz \
	> ${dir}/${sample}.cutadapt.log
fi

# If the alignment does not yet exist, then align the reads using bowtie2.
if [ ! -f ${dir}/${sample}.bam ];
then
  bowtie2 --very-sensitive-local --un-conc-gz ${dir}/${sample}-unmapped \
	-p 4 \
	-X 1000 \
	-x ${reference} \
	-1 ${dir}/${sample}_trimmed-R1.fastq.gz \
	-2 ${dir}/${sample}_trimmed-R2.fastq.gz \
	-S ${dir}/${sample}.sam \
	2> ${dir}/${sample}.bt2.log
fi

# Use SAMtools to convert SAM files to BAM files.
# Sort the .bam files and also create an index.
echo "Convert SAM files to BAM files."
if [ ! -f ${dir}/${sample}.bam ];
then
  samtools view -b ${dir}/${sample}.sam | samtools sort -o ${dir}/${sample}.bam
  samtools index ${dir}/${sample}.bam
fi

# Use Picard to remove PCR and sequencing duplicates.
echo "Remove duplicate reads."
if [ ! -f ${dir}/${sample}-rmdup.bam ];
then
  java -Xmx2g -jar ${picarddir}/MarkDuplicates.jar \
    INPUT=${dir}/${sample}.bam \
	OUTPUT=${dir}/${sample}-rmdup.bam \
	METRICS_FILE=${dir}/${sample}.picard \
	REMOVE_DUPLICATES=TRUE VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=TRUE
fi

# Generate a pileup from the deduplicated sequencing reads.
echo "Generate pileup."
if [ ! -f ${dir}/${sample}.pileup ];
then
  samtools mpileup -q 20 -Q 20 -f ${reference}.fasta \
    -o ${dir}/${sample}.pileup ${dir}/${sample}-rmdup.bam
fi

# Convert pileup to VCF format.
echo "Generate VCF."
if [ ! -f ${dir}/${sample}.vcf.gz ];
then
  samtools mpileup -q 20 -Q 20 -v -f ${reference}.fasta \
    -o ${dir}/${sample}.vcf.gz ${dir}/${sample}-rmdup.bam
fi