# This script is meant to be run from the top level of the Github directory.
# It makes use of Jim Thomas's database of fungal genomes, here:
# /net/gs/vol4/shared/thomaslab/genomes/Fungi
# Given a particular FASTQ file (just one pair is necessary for paired-end reads),
# this script BLASTs the first 100000 reads against all of the fungal genomes
# in Jim Thomas's database of Ascomycetes.

module load blast+/2.2.29

# Variables and file paths.
dir="analysis/BB/170414-BLAST-fungal" # relative path of the directory for the analysis
Thomasdir="/net/gs/vol4/shared/thomaslab/genomes/Fungi"
outdir="nobackup/BB/170414-BLAST-fungal"

FASTQ="$1"
genomes="$2"
numreads=$3


# Remove any files that were previously generated.
rm -f ${outdir}/${sample}.txt

# Parse FASTQ name to infer sample name.
sample=${FASTQ##*/}
sample=${sample%%_*}

# Iterate through all of the Ascomycetes genomes in the database.
# Ignore genomes that are preceded with a # character,
# which are of questionable quality.
while read database annotation
do
if [[ ${database} != \#* ]]
then
  #${dir}/runBLAST.sh ${FASTQ} ${Thomasdir}/${database} >> ${dir}/test.txt
  #Parse the BLAST database directory path to get the file extension required for analysis.
  for f in ${Thomasdir}/${database}/blast_data/*.nhr
  do
	database=${f%.*}
  done

  # Use sed to convert FASTQ reads into FASTA sequences for BLAST.
  # Use blastn to search for sequence matches within the indicated database.
  zcat ${FASTQ} | head -n $((numreads*4)) | sed -n '1~4s/^@/>/p;2~4p' | \
	blastn -db ${database} -outfmt "6 qacc sacc evalue qstart qend sstart send" \
	>> ${outdir}/${sample}.txt
fi
done < ${genomes}

# Summarize the number of reads that map to each of the fungal genomes.
# Count each read only a single time.
cut -f1 -d'|' ${outdir}/${sample}.txt | uniq | cut -f2 | uniq -c | sort -nr \
  > ${outdir}/${sample}.summary
