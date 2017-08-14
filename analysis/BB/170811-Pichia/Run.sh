# This script is meant to be run from the top level of the Github repository.
# It runs analyses on the FY0010 and FY0017 putative hybrid strains.

# BLAST unmapped reads.
# This script makes use of a previous script that BLASTs reads against the genomes
# in Jim Thomas's fungal database.

runBLAST="analysis/BB/170414-BLAST-fungal/RunBLAST.sh"
genomes="analysis/BB/170414-BLAST-fungal/dirs_asco.txt"
numreads=1000
database="/net/dunham/vol2/Caiti/Ivan/Pichia_hybrid.fasta"
outdir="nobackup/BB/170811-Pichia/"

# Submit job to BLAST 1000 unmapped reads for FY0010 and FY0017
# against Jim Thomas's Ascomycetes genomes.
# These are reads that did not map to the S288C reference genome.
FASTQ="nobackup/BB/170811-Pichia/FY0010-Picmem-unmapped.1"
sample=${FASTQ##*/}
sample=${sample%%.*}
#qsub -cwd -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
#${runBLAST} ${FASTQ} ${genomes} 1000
# Also BLAST reads against the Pichia hybrid assembly from Caiti and Ivan.
rm -f ${outdir}/${sample}.summary
zcat ${FASTQ} | head -n $((numreads*4)) | sed -n '1~4s/^@/>/p;2~4p' | \
	blastn -db ${database} -outfmt "6 qacc sacc evalue qstart qend sstart send" \
	>> ${outdir}/${sample}.txt
cut -f1 ${outdir}/${sample}.txt | uniq | wc -l \
  > ${outdir}/${sample}.summary

FASTQ="nobackup/BB/170811-Pichia/FY0017-Picmem-unmapped.1"
sample=${FASTQ##*/}
sample=${sample%%.*}
#qsub -cwd -N ${sample} -o nobackup/BB/sge/${sample}.o -e nobackup/BB/sge/${sample}.e \
#${runBLAST} ${FASTQ} ${genomes} 1000
# Also BLAST reads against the Pichia hybrid assembly from Caiti and Ivan.
rm -f ${outdir}/${sample}.summary
zcat ${FASTQ} | head -n $((numreads*4)) | sed -n '1~4s/^@/>/p;2~4p' | \
	blastn -db ${database} -outfmt "6 qacc sacc evalue qstart qend sstart send" \
	>> ${outdir}/${sample}.txt
cut -f1 ${outdir}/${sample}.txt | sort | uniq | wc -l \
  > ${outdir}/${sample}.summary