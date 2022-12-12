#!/bin/bash
​
usage="$(basename "$0") [-w working_dir] [-r 16s_database_fastafile] [-t 16s_taxonomy_file]"
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
      -r)
           DB_FASTA=$(realpath $2)
           shift 2
           ;;
      -t)
           DB_TAXONOMY=$(realpath $2)
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
​
cd $WORKING_DIR
​
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path $DB_FASTA \
  --output-path ref-seqs.qza
​
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path $DB_TAXONOMY \
  --output-path ref-taxonomy.qza
​
#16s V3 Forward primer -  CCTACGGGNGGCWGCAG
#16s V4 Reverse primer  - GGACTACHVGGGTATCTAATCC
​
qiime feature-classifier extract-reads \
  --i-sequences ref-seqs.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GGACTACHVGGGTATCTAATCC \
  --p-trunc-len 0 \
  --o-reads ref-seqs.qza
​
​
#Train the classifier
#Train a Naive Bayes classifier as follows, using the reference reads and taxonomy that we just created.
​
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads 16s-ref-seqs.qza \
  --i-reference-taxonomy 16s-ref-taxonomy.qza \
  --o-classifier 16s_classifier.qza
