# Driver script to run yeast analysis pipeline.
# Script is designed to be run from the top-level directory of the Github repository.

# Location of pipeline script.
pipeline="pipelines/BB/AlignSummarize.sh"
samplesheet="pipelines/BB/Samples.data"

# Run script for all samples.
while read rawdir index1 index2 sample run
do
  qsub -cwd -l m_mem_free=8G \
  -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
  ${pipeline} ${rawdir} ${index1} ${index2} ${sample} ${run}
done < ${samplesheet} 