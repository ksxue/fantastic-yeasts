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

# Input parameters.
rawdir="$1"
index1="$2"
index2="$3"
sample="$4"
run="$5"
dir="nobackup/BB"
reference="reference/S288C/S288CReferenceAnnotated"

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
if [ ! -f ${dir}/${sample}.sam ] || [ ! -f ${dir}/${sample}.sam ];
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