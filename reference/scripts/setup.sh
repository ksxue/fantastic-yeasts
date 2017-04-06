# This script prepares the reference genomes for downstream analyses.
# The script is meant to be run from the top level of the Github directory.

module load bowtie2/2.2.3

references="reference/references.data"
chrNames="reference/metadata/chrNames.data"
concatGenome="nobackup/reference/yeast.fasta"


if [ ! -d "nobackup/reference" ]; then
  mkdir nobackup/reference
fi

# Given the list of reference genomes, concatenate all of the genomes into one large file.
rm -f ${concatGenome}
rm -f ${chrNames}
while read genus species folder filename
do
  # For each reference genome specified in the list of references,
  # algorithmically rename each chromosome,
  # and concatenate the genomes into a single file.
  zcat reference/${folder}/${filename}.fasta.gz | \
    awk -v filename=${filename} -v folder=${folder} \
	'BEGIN {line=0; OFS="\t"} 
	  //{if (substr($1,1,1)==">") {line=line+1; print ">" filename "_" line}
	  else {print}}' \
	>> ${concatGenome}
	
  # For each reference genome specified in the list of references,
  # extract the list of chromosome names, algorithmically rename each chromosome,
  # and output all of this information.
  # This may be used in further remappings of the chromosome names.
  zcat reference/${folder}/${filename}.fasta.gz | \
    awk -v filename=${filename} -v folder=${folder} \
	'BEGIN {line=0; OFS="\t"} 
	  /^>/{line=line+1; print folder "/" filename ".fasta.gz", $0, $1, ">" filename "_" line}' \
	>> ${chrNames}
done < ${references}

# Build a bowtie2 index for the yeast genome references.
bowtie2-build ${concatGenome} nobackup/reference/yeast

