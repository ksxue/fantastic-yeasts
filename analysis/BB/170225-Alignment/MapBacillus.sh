# This script is meant to be run from the top level of the Github repository.
# This script attempts to map reads from FY0001 to B. megaterium,
# which is resembles under the microscope.

dir="nobackup/BB"
sample="FY0001"
reference="reference/Bacteria/Bmegaterium"

# Build the bowtie2 reference for B. megaterium.
bowtie2-build ${reference}.fasta ${reference}

bowtie2 --very-sensitive-local --un-conc-gz ${dir}/${sample}-yeast-unmapped \
	-p 4 \
	-X 1000 \
	-x ${reference} \
	-1 ${dir}/${sample}_trimmed-R1.fastq.gz \
	-2 ${dir}/${sample}_trimmed-R2.fastq.gz \
	-S ${dir}/${sample}-Bmegaterium.sam \
	2> ${dir}/${sample}-Bmegaterium.bt2.log