# This script is meant to be run from the top level of the Github repository.

# Directory paths.
dir="analysis/BB/170225-Alignment"
datadir="nobackup/BB"

# Iterate through all bowtie2 logs for an alignment to S288C
# and extract the total number of reads that mapped.
for f in ${datadir}/*.bt2.log
do
  sample=${f##*/}
  sample=${sample%%.*}
  maprate="$(tail -n 1 ${f} | cut -f 1 -d' ')"
  echo ${sample} ${maprate}
done > ${dir}/MapRates.data
