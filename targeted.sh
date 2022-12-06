#!/bin/bash

usage="$(basename "$0") [-w working_dir] [-f metadata_file] [-l trunc_len] [-c rdp_classifier] [-u unite_classifier] [-r rdp_reference_seq] [-t unite_reference_seq]"

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
           SAMPLE_METADATA=$2
           shift 2
           ;;
      -l)
      	   TRUNC_LEN=$2
           shift 2
           ;;	
      -c)
	   RDP_CLASSIFIER=$(realpath $2)
	   shift 2
	   ;;

      -u)
	   UNITE_CLASSIFIER=$(realpath $2)
	   shift 2
	   ;;
       -r)
           rdp_REF_SEQ=$(realpath $2)
	   shift 2
	   ;;
	-t)
           unite_REF_SEQ=$(realpath $2)
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
SAMPLE_METADATA=$WORKING_DIR"/sample_metadata.tsv"


if [ ! -f "$SAMPLE_METADATA" ]; then
  echo -e sample-id"\t"sample-name > $SAMPLE_METADATA
  for f in $FASTQ_FILES; do
    s=$(echo $(basename $f) | sed 's/\.fastq\.gz//g')
    echo -e $s"\t"$s >> $SAMPLE_METADATA;
  done
fi

cd $WORKING_DIR



qiime dada2 denoise-single \
  --i-demultiplexed-seqs sequences.qza \
  --p-trunc-len $TRUNC_LEN \
  --p-chimera-method consensus \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza

qiime tools export \
  --input-path denoising-stats.qza \
  --output-path denoising-stats.qzv

qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file $SAMPLE_METADATA


qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv

qiime quality-control evaluate-seqs \
  --i-query-sequences rep-seqs.qza \
  --i-reference-sequences $rdp_REF_SEQ \
  --o-visualization 16s_qaulity_seq.qzv

qiime quality-control evaluate-seqs \
  --i-query-sequences rep-seqs.qza \
  --i-reference-sequences $unite_REF_SEQ \
  --o-visualization its_qaulity_seq.qzv

qiime feature-classifier classify-sklearn --i-classifier $RDP_CLASSIFIER --i-reads rep-seqs.qza --p-n-jobs -2 --o-classification taxonomy_16s.qza

qiime metadata tabulate --m-input-file taxonomy_16s.qza --o-visualization taxonomy_16s.qzv

qiime taxa barplot \
 --i-table table.qza \
 --i-taxonomy taxonomy_16s.qza \
 --m-metadata-file $SAMPLE_METADATA \
 --o-visualization taxa-bar-plot_16s.qzv 

qiime krona collapse-and-plot \
--i-table table.qza \
--i-taxonomy taxonomy_16s.qza \
--o-krona-plot 16s_krona.qzv

qiime feature-classifier classify-sklearn \
 --i-classifier $UNITE_CLASSIFIER\
 --i-reads rep-seqs.qza \
 --p-n-jobs -2 \
 --o-classification taxonomy_unite.qza


qiime metadata tabulate \
 --m-input-file taxonomy_unite.qza \
 --o-visualization taxonomy_unite.qzv

qiime taxa barplot \
 --i-table table.qza \
 --i-taxonomy taxonomy_unite.qza \
 --m-metadata-file $SAMPLE_METADATA \
 --o-visualization taxa-bar-plot_unite.qzv 


qiime krona collapse-and-plot \
--i-table table.qza \
--i-taxonomy taxonomy_unite.qza \
--o-krona-plot unite_krona.qzv


for lev in {1..7}; do
  qiime taxa collapse \
  --i-table table.qza --i-taxonomy taxonomy_16s.qza \
  --p-level $lev \
  --o-collapsed-table table_collapsed_absfreq_level$lev.qza

qiime metadata tabulate  \
  --m-input-file table_collapsed_absfreq_level$lev.qza  \
  --o-visualization table_collapsed_absfreq_level$lev.qzv

  qiime tools export \
  --input-path table_collapsed_absfreq_level$lev.qza \
  --output-path .

  mv feature-table.biom feature-table_absfreq_level$lev.biom

  biom convert \
  -i feature-table_absfreq_level$lev.biom \
  -o feature-table_absfreq_level$lev.tsv \
  --to-tsv \
  --table-type 'Taxon table'

  qiime feature-table relative-frequency \
  --i-table table_collapsed_absfreq_level$lev.qza \
  --o-relative-frequency-table table_collapsed_relfreq_level$lev.qza

  qiime metadata tabulate  \
  --m-input-file table_collapsed_relfreq_level$lev.qza  \
  --o-visualization table_collapsed_relfreq_level$lev.qzv

  qiime tools export \
  --input-path table_collapsed_relfreq_level$lev.qza \
  --output-path .

  mv feature-table.biom feature-table_relfreq_level$lev.biom

  biom convert \
  -i feature-table_relfreq_level$lev.biom \
  -o feature-table_relfreq_level$lev.tsv \
  --to-tsv \
  --table-type 'Taxon table'

  cat feature-table_absfreq_level$lev.tsv | grep "#" > header
  cat feature-table_absfreq_level$lev.tsv | grep -v -P "Unassigned|#|BC|NA" | cut -f$lev -d';' | tr "\t" "," | grep -v "^__" | sort -t"," -k2,2 -nr | tr "," "\t" > "feature-table_absfreq_level"$lev"_stringent_noheader.tsv"
  cat header "feature-table_absfreq_level"$lev"_stringent_noheader.tsv" > "feature-table_absfreq_level"$lev"_stringent.tsv"
  rm "feature-table_absfreq_level"$lev"_stringent_noheader.tsv" header
done

mkdir 16s_collapsed_feature_tables
mv table_collapsed* feature-table_*freq_level*.biom feature-table_absfreq_level*_stringent.tsv 16s_collapsed_feature_tables

mkdir 16s_feature_table_all_levels
mkdir 16s_feature_table_all_levels/absolute_frequency
mv feature-table_absfreq_level*.tsv 16s_feature_table_all_levels/absolute_frequency 


mkdir 16s_feature_table_all_levels/relative_frequency
mv feature-table_relfreq_level*.tsv 16s_feature_table_all_levels/relative_frequency



for lev in {1..7}; do
  qiime taxa collapse \
  --i-table table.qza --i-taxonomy taxonomy_unite.qza \
  --p-level $lev \
  --o-collapsed-table table_collapsed_absfreq_level$lev.qza

qiime metadata tabulate  \
  --m-input-file table_collapsed_absfreq_level$lev.qza  \
  --o-visualization table_collapsed_absfreq_level$lev.qzv

  qiime tools export \
  --input-path table_collapsed_absfreq_level$lev.qza \
  --output-path .

  mv feature-table.biom feature-table_absfreq_level$lev.biom

  biom convert \
  -i feature-table_absfreq_level$lev.biom \
  -o feature-table_absfreq_level$lev.tsv \
  --to-tsv \
  --table-type 'Taxon table'

  qiime feature-table relative-frequency \
  --i-table table_collapsed_absfreq_level$lev.qza \
  --o-relative-frequency-table table_collapsed_relfreq_level$lev.qza

  qiime metadata tabulate  \
  --m-input-file table_collapsed_relfreq_level$lev.qza  \
  --o-visualization table_collapsed_relfreq_level$lev.qzv

  qiime tools export \
  --input-path table_collapsed_relfreq_level$lev.qza \
  --output-path .

  mv feature-table.biom feature-table_relfreq_level$lev.biom

  biom convert \
  -i feature-table_relfreq_level$lev.biom \
  -o feature-table_relfreq_level$lev.tsv \
  --to-tsv \
  --table-type 'Taxon table'

  cat feature-table_absfreq_level$lev.tsv | grep "#" > header
  cat feature-table_absfreq_level$lev.tsv | grep -v -P "Unassigned|#|BC|NA" | cut -f$lev -d';' | tr "\t" "," | grep -v "^__" | sort -t"," -k2,2 -nr | tr "," "\t" > "feature-table_absfreq_level"$lev"_stringent_noheader.tsv"
  cat header "feature-table_absfreq_level"$lev"_stringent_noheader.tsv" > "feature-table_absfreq_level"$lev"_stringent.tsv"
  rm "feature-table_absfreq_level"$lev"_stringent_noheader.tsv" header
done

mkdir ITS_collapsed_feature_tables
mv table_collapsed* feature-table_*freq_level*.biom feature-table_absfreq_level*_stringent.tsv ITS_collapsed_feature_tables

mkdir ITS_feature_table_all_levels
mkdir ITS_feature_table_all_levels/absolute_frequency
mv feature-table_absfreq_level*.tsv ITS_feature_table_all_levels/absolute_frequency 


mkdir ITS_feature_table_all_levels/relative_frequency
mv feature-table_relfreq_level*.tsv ITS_feature_table_all_levels/relative_frequency

