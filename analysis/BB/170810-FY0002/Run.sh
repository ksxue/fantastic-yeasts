# This script is meant to be run from the top level of the Github repository.
# It runs analyses on the FY0002 putative hybrid strain.

# BLAST unmapped reads.
# This script makes use of a previous script that BLASTs reads against the genomes
# in Jim Thomas's fungal database.

runBLAST="analysis/BB/170414-BLAST-fungal/RunBLAST.sh"
genomes="analysis/BB/170414-BLAST-fungal/dirs_asco.txt"
FASTQ="nobackup/BB/FY0002-unmapped.1"

# Submit job to BLAST 1000 unmapped reads for FY0002 
# against Jim Thomas's Ascomycetes genomes.
# These are reads that did not map to the S288C reference genome.
sample=${FASTQ##*/}
sample=${sample%%.*}
qsub -cwd -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
${runBLAST} ${FASTQ} ${genomes} 1000