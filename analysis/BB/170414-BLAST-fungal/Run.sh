# This script is meant to be run from the top level of the Github directory.
# It makes use of Jim Thomas's database of fungal genomes, here:
# /net/gs/vol4/shared/thomaslab/genomes/Fungi
# It calls the script runBLAST.sh on each FASTQ file from the sequenced samples,
# and the script BLASTs a certain number of reads against each fungal genome
# in the given database. The BLAST results are then sorted and summarized.
# The script asks for three arguments: the FASTQ file, the list of genomes,
# and the number of reads to be BLASTed.

module load blast+/2.2.29

# Variables and file paths.
dir="analysis/BB/170414-BLAST-fungal"
runBLAST="analysis/BB/170414-BLAST-fungal/RunBLAST.sh"
genomes="analysis/BB/170414-BLAST-fungal/dirs_asco.txt"
outdir="nobackup/BB/170414-BLAST-fungal"

# Submit jobs to BLAST 10000 reads from each sample 
# against Jim Thomas's Ascomycetes genomes.
:<<END
:<<END
for FASTQ in nobackup/BB/*_trimmed-R1.fastq.gz
do
  sample=${FASTQ##*/}
  sample=${sample%%_*}
  qsub -cwd -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
    ${runBLAST} ${FASTQ} ${genomes} 10000
done
END

# Extract the top-matching genome for each sample.
rm -f ${dir}/FungalBLAST.data
for summary in ${outdir}/*.summary
do
  sample=${summary##*/}
  sample=${sample%%.*}
  head -n 1 ${summary} | sed -r 's/^( *[^ ]+) +/\1\t/' | \
    sed "s/^/${sample}/" >> ${dir}/FungalBLAST.data
done

# Associate the top-matching genomes for each strain
# with the strain metadata.
paste -d'\t' ${dir}/FungalBLAST.data <(tail -n +2 data/BB/metadata-raw.tsv ) \
  | cut -f1,2,7 > ${dir}/StrainSummary.data
  
# Create a list of all strains whose primary match is S. cerevisiae.
grep saccer ${dir}/StrainSummary.data | cut -f1 -d' ' > data/BB/Scer.data