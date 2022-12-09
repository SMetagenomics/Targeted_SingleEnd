#!/bin/bash

usage="$(basename "$0") [-w working_dir] [-f menifest] "

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
    -f)
           MANIFEST=$2
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

FASTQ_FILES=$(realpath $(find $WORKING_DIR -maxdepth 1 | grep "\.fastq\.gz"))
MANIFEST=$WORKING_DIR"/manifest.txt"

if [ ! -f "$MANIFEST" ]; then
  echo -e sample-id"\t"absolute-filepath > $MANIFEST
  for f in $FASTQ_FILES; do
    s=$(echo $(basename $f) | sed 's/\.fastq\.gz//g')
    echo -e $s"\t"$f >> $MANIFEST;
  done
fi


cd $WORKING_DIR

qiime tools import \
--type 'SampleData[SequencesWithQuality]' \
--input-path $MANIFEST \
--input-format 'SingleEndFastqManifestPhred33V2' \
--output-path sequences.qza

qiime demux summarize \
  --i-data sequences.qza \
  --o-visualization demux-subsample.qzv

qiime tools export \
  --input-path demux-subsample.qzv \
  --output-path ./demux-subsample/
