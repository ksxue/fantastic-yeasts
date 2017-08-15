# Driver script to run yeast analysis pipeline.
# Script is designed to be run from the top-level directory of the Github repository.

# Location of pipeline script.
trimadapters="pipelines/BB/TrimAdaptersNextera.sh"
pipeline="pipelines/BB/AlignSummarize-GATK.sh"
samplesheet="analysis/BB/170815-AlignScer/Samples.data"

# Trim reads for all samples.
trimdir="nobackup/BB/trimmed"
while read rawdir index1 index2 sample run
do
  qsub -cwd -l m_mem_free=12G \
    -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
    ${trimadapters} \
	${rawdir}/${index1}.${index2}_${run}.1.fastq.gz \
	${rawdir}/${index1}.${index2}_${run}.2.fastq.gz \
	${sample} ${trimdir} 0
done < ${samplesheet}

# Run script for all samples.
#while read rawdir index1 index2 sample run
#do
#  qsub -cwd -l m_mem_free=12G \
#  -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
#  ${pipeline} ${rawdir} ${index1} ${index2} ${sample} ${run}
#done < ${samplesheet} 