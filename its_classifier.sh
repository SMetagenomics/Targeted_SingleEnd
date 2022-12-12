#!/bin/bash

usage="$(basename "$0") [-w working_dir] [-u its_fastafile] [-t its_taxonomy]"

while :
do
    case "$1" in
      -h | --help)
          echo $usage
          exit 0
          ;;
      -w)
          WORKING_DIR=$(realpath $2)
          shift 2
          ;;
      -u)
           ITS_FASTA=$(realpath $2)
           shift 2
           ;;
      -t)
           ITS_TAXONOMY=$(realpath $2)
           shift 2
           ;;
           --) # End of all options
           shift
           break
           ;;
       -*)
           echo "Error: Unknown option: $1" >&2
           ## or call function display_help
           exit 1
           ;;
        *) # No more options
           break
           ;;
    esac
done

cd $WORKING_DIR

qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path $ITS_FASTA \
  --output-path its.qza

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path $ITS_TAXONOMY \
  --output-path its-taxonomy.qza

#ITS Forward Primer  - GCATCGATGAAGAACGCAGC
#ITS Reverse primers - GTCCTCCGCTTATTGATATGC

qiime feature-classifier extract-reads \
  --i-sequences its.qza \
  --p-f-primer GCATCGATGAAGAACGCAGC \
  --p-r-primer GTCCTCCGCTTATTGATATGC \
  --o-reads its-ref-seqs.qza


#Train the classifier
#Train a Naive Bayes classifier as follows, using the reference reads and taxonomy that we just cre
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads its-ref-seqs.qza \
  --i-reference-taxonomy its-taxonomy.qza \
  --o-classifier its-classifier.qza
