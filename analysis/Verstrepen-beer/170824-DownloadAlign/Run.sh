#!/bin/bash

# This script is meant to be run from the top level of the Github repository.
# The script takes a list of accessions for the industrial beer strains
# described in Gallone et al., Cell, 2016,
# and downloads the raw reads associated with each strain.
# It then aligns each set of reads to the S288C reference.

# File paths.
# scripts
batchfastqdump="pipelines/BB/Batch-SRADownloadFASTQ.sh"
batchtrimadapters="pipelines/BB/Batch-TrimAdaptersNextera.sh"
batchalignsummarize="pipelines/BB/Batch-AlignSummarize-GATK.sh"
# metadata
samplesheetraw="data/Verstrepen-beer/metadata-Verstrepen-accessions.txt"
samplesheet="data/Verstrepen-beer/Samples-Verstrepen-beer.data"
# directories
dir="nobackup/Verstrepen-beer/raw"
trimdir="nobackup/Verstrepen-beer/trimmed"
outdir="nobackup/Verstrepen-beer/170824-DownloadAlign"
# other
project="Verstrepen-beer"
reference="reference/S288C/S288CReferenceAnnotated"
clean=1

# Calculate the number of samples to be analyzed.
# Note that the sample info sheet contains a header line.
numsamples="$(tail -n +2 ${samplesheetraw} | wc -l | cut -f1 -d' ')"

:<<END
# Submit batch job to download reads from the SRA for each sample.
runs="${dir}/runs.txt"
tail -n +2 ${samplesheetraw} | cut -f10 > ${runs}
qsub -cwd -N DownloadVerstrepen -t 1-${numsamples} -tc 75 \
  -o nobackup/${project}/sge/ -e nobackup/${project}/sge/ \
  ${batchfastqdump} ${dir} ${runs} ${clean}
END

#############################
# Some of the samples have reads from two sequence runs,
# with different SRR numbers.
# I used the metadat accessions to verify that there are not
# more than two runs per sample.
# The following lines of code merge the two FASTQ files
# associated with a single biological sample
# and rename all samples from SRR names to biological sample names.
#############################

# First extract the names of samples with more than one SRR,
# then determine the list of SRRs that correspond to those samples.
# The resulting file should consist of consecutive pairs of lines of the form
# SRR#### sample####
while read sample
do
 grep ${sample} ${samplesheetraw} | cut -f10,12
done < <( cut -f12 ${samplesheetraw} | tail -n +2 \
  | sort | uniq -c | sed -r 's/^( *[^ ]+) +/\1\t/' | \
  sort -k 1 | awk '$1==2' | cut -f2 ) \
  > ${outdir}/doublets.txt
  
# Split the doublets file into two files, each listing a single sample per line.
# Merge those files to take the form
# sample#### SRR#### SRR####
# Read the file of doublets and concatenate separate fastq files
# into a single file, named by the sample rather than the run.
while read sample run1 run2
do
  echo "$sample $run1 $run2"
  if [ ! -f ${dir}/${sample}_1.fastq.gz ] && [ ! -f ${dir}/${sample}_2.fastq.gz ];
  then
    cat ${dir}/${run1}_1.fastq.gz ${dir}/${run2}_1.fastq.gz > ${dir}/${sample}_1.fastq.gz
    cat ${dir}/${run1}_2.fastq.gz ${dir}/${run2}_2.fastq.gz > ${dir}/${sample}_2.fastq.gz
  fi
done < <(join <( awk 'NR%2==1{print $2,"\t",$1}' ${outdir}/doublets.txt ) \
  <( awk 'NR%2==0{print $2,"\t",$1}' ${outdir}/doublets.txt ))
  
# Extract the list of strains that have only a single corresponding SRR run
# and rename the downloaded FASTQ files to match the strain designation.
while read sample
do
 grep ${sample} ${samplesheetraw} | cut -f10,12
done < <( cut -f12 ${samplesheetraw} | tail -n +2 \
  | sort | uniq -c | sed -r 's/^( *[^ ]+) +/\1\t/' | \
  sort -k 1 | awk '$1==1' | cut -f2 ) \
  > ${outdir}/singlets.txt

while read run sample
do
  if [ -f ${dir}/${run}_1.fastq.gz ] && [ -f ${dir}/${run}_2.fastq.gz ];
  then
    echo ${sample}
    mv ${dir}/${run}_1.fastq.gz ${dir}/${sample}_1.fastq.gz
	mv ${dir}/${run}_2.fastq.gz ${dir}/${sample}_2.fastq.gz
  fi
done < ${outdir}/singlets.txt

# The reads corresponding to sample WL005, SRR5688269 have some problem as uploaded.
# Specifically, fastq-dump rejects all read 2 files as technical duplicates.
# I have not yet looked carefully into this problem to debug it.
# For the time being, the other corresponding file, SRR5688268, is renamed
# as the ONLY FASTQ file corresponding to this sample.
if [ -f ${dir}/SRR5688268_1.fastq.gz ] && [ -f ${dir}/SRR5688268_2.fastq.gz ];
then
  mv -f ${dir}/SRR5688268_1.fastq.gz ${dir}/WL005_1.fastq.gz
  mv -f ${dir}/SRR5688268_2.fastq.gz ${dir}/WL005_2.fastq.gz
fi

# Generate the samplesheet with paths to the raw and trimmed reads
# for each sample.
while read sample
do
  echo "${dir}/${sample}_1.fastq.gz ${dir}/${sample}_2.fastq.gz ${trimdir}/${sample}_trimmed-R1.fastq.gz ${trimdir}/${sample}_trimmed-R2.fastq.gz ${sample}"
done < <( cut -f12 ${samplesheetraw} | tail -n +2 | sort | uniq | sort ) \
  > ${samplesheet}
  
# Remove all remaining SRR files.
rm -f ${dir}/SRR*
  
#############################
# Trim reads for all samples.
# Align reads to the S288C genome and call variants.
#############################

# Calculate the number of biological samples to be analyzed.
# Note that this is different from the number of sequencing runs above.
numsamples="$(wc -l ${samplesheet} | cut -f1 -d' ')"

# Submit batch job to trim Nextera adapters from raw sequencing reads.
qsub -cwd -N TrimAdapters -t 1-${numsamples} -tc 50 \
  -o nobackup/${project}/sge/ -e nobackup/${project}/sge/ \
  ${batchtrimadapters} ${samplesheet} ${trimdir} ${clean}
  
# Submit batch jobs to align reads to the S288C reference.
qsub -cwd -N AlignS288C -l m_mem_free=12G \
  -t 1-${numsamples} -tc 100 -hold_jid TrimAdapters \
  -o nobackup/${project}/sge/ -e nobackup/${project}/sge/ \
  ${batchalignsummarize} ${samplesheet} ${outdir} ${reference} S288C ${clean}