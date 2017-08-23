# Driver script to run yeast analysis pipeline.
# Script is designed to be run from the top-level directory of the Github repository.

# Location of pipeline script.
trimadapters="pipelines/BB/TrimAdaptersNextera.sh"
pipeline="pipelines/BB/AlignSummarize-GATK.sh"
samplesheet="data/BB/Samples.data"
workingdir="nobackup/BB/170815-AlignScer"
clean=0
pipelinecallfilter="pipelines/BB/CallFilterVariants-GATK.sh"

:<<END
# Trim reads for all samples.
trimdir="nobackup/BB/trimmed"
while read fastq1 fastq2 trimmed1 trimmed2 sample
do
  qsub -cwd -l m_mem_free=12G \
    -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
    ${trimadapters} \
	${fastq1} \
	${fastq2} \
	${sample} ${trimdir} ${clean}
done < ${samplesheet}


# Based on the prior BLAST analysis, extract a list of samples annotated as S. cerevisiae.
Scer="data/BB/Scer.data"
while read sample
do
  grep ${sample} ${samplesheet}
done < ${Scer} > ${workingdir}/Scer.data


# For all samples annotated as S. cerevisiae,
# align reads against the S288C genome,
# remove sequencing duplicates, add read groups,
# and produce a gVCF file for that sample.
while read fastq1 fastq2 trimmed1 trimmed2 sample other
do
  qsub -cwd -l m_mem_free=12G \
    -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
    ${pipeline} ${trimmed1} ${trimmed2} ${sample} ${workingdir} \
    reference/S288C/S288CReferenceAnnotated S288C ${clean}
done < <( ${workingdir}/Scer.data )
END

# Based on the prior BLAST analysis, extract a list of samples annotated as S. cerevisiae.
Scer="data/BB/Scer.data"
while read sample
do
  echo "${workingdir}/${sample}-S288C-raw.g.vcf"
done < ${Scer} > ${workingdir}/Scer.list

# For the previous list of samples,
# perform joint variant calling using GATK,
# then apply hard filters to generate a list of SNPs.
sample="Scer"
qsub -cwd -l m_mem_free=12G \
  -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
  ${pipelinecallfilter} ${workingdir}/Scer.list \
  reference/S288C/S288CReferenceAnnotated \
  ${workingdir} ${sample} ${clean}
  