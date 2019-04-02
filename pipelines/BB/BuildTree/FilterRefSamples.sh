#!/bin/bash

# This script is meant to be run from the top level of the Github repository.
# This script takes the raw list of reference S288C genomes
# and checks to make sure that they all exist
# before using them for joint genotype calling.

while read f
do
  if [ -f ${f} ]; then
    echo ${f}
  fi
done < analysis/BB/181105-Ridge/ReferenceSamples-raw.list \
  > analysis/BB/181105-Ridge/ReferenceSamples.list