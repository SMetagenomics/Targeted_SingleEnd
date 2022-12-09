# Targeted_SingleEnd

Qiime2 data analysis for 16/ITS Single end sequences from Illumina 

Targeted_SingleEnd is a pipeline for analyzing targeted sequencing data (16s, ITS). It is only used for Single End Demultiplexed Illumina Fastq Data. 

The workflow of the pipeline in brief is,

--> Install Conda --> Install QIIME2 --> Activate the QIIME2-Conda Environment --> Download 16s and ITS Database --> Train the database classifier --> Check the quality of demultiplexed reads --> Denoise with DADA2 --> Taxonomic Classification with sklearn --> Results --> Collapse results for final output

Getting Started:

Prerequisite:

•	Miniconda

•	QIIME2

Miniconda :

•	Update Miniconda

•	After installing Miniconda and opening a new terminal, make sure you’re running the latest version of conda

conda update conda

•	Install wget

conda install wget

QIIME2:

•	Install QIIME2 within a conda environment

 	wget https://data.qiime2.org/distro/core/qiime2-2022.8-py38-linux-conda.yml
  
  conda env create -n qiime2-2022.8 --file qiime2-2022.8-py38-linux-conda.yml
  
•	Activate the conda environment

conda activate qiime2-2022.8

•	Test your installation

qiime --help

Download Databases:

•	Download RDP Database for qiime2

RDP Database:

https://sourceforge.net/projects/rdp-classifier/files/RDP_Classifier_TrainingData/RDPClassifier_16S_trainsetNo18_QiimeFormat.zip/download

•	Download UNITE Database for qiime2

https://unite.ut.ee/repository.php

•	Train 16s and ITS database classifier

./16s_classifier.sh 

•	Train UNITE database classifier

./its_classifier.sh

(A change can be made within script which is based on primer selection used during the amplification)

The primers which have been selected in these scripts to train the classifiers are,

16s V3 Forward primer - CCTACGGGNGGCWGCAG

16s V4 Reverse primer - GGACTACHVGGGTATCTAATCC

ITS Forward primer - GCATCGATGAAGAACGCAGC

ITS Reverse primers - GTCCTCCGCTTATTGATATGC

Similarly other database can be downloaded and trained!

http://qiime.org/home_static/dataFiles.html

Or trained databases can also be downloaded from:

https://docs.qiime2.org/2022.8/data-resources/

**Usage**

Once both 16s and ITS classifiers are created, move them to the same directory and they can be used for future analysis.

1) 16s_clssifier.sh

 ./16s_classifier.sh [-w working_dir] [-r 16s_database_fastafile] [-t 16s_taxonomy_file]
 
 where, -w is a parameter for working directory with absolute path containing fasta file and taxonomy file.
-r is a 16s database fastafile and -t is its taxonomy.

2) its_classifier.sh

./its_classifier.sh [-w working_dir] [-u its_database_fastafile] [-t its_taxonomy_file]

where, -w is working directory with absolute path containing ITS database fastafile and -t is its taxonomy.

3) demux.sh

./demux.sh [-w working_dir] [-f manifest]

where, -w is working directory with its absolute path containing fastq file and -f is a manifest.txt file which will be created automatically.

At this step, artifect file for sequences is created for further analysis. As the data from Illumina are already demultiplexed, here the quality of those data will be checked and based on the quality, the truncated length (trunc_len) is selected for denoising step.

 
4) targeted.sh

./targeted.sh [-w working_dir] [-f metadata_file] [-l trunc_len] [-c 16s_classifier] [-u its_classifier] [-r 16s_reference_seq] [-s its_reference_seq]

where, -w is a directory containing with its absolute path containing containing artifect file,  -f is a metadata file parameter, the file will created automatically, -l is a truncated length parameter, which will be decided based on the demultiplexed data quality. If you decide not to truncate the sequences then it will be "0" (e.g. -l 0), -c and -u are 16s classifier and its classifier created during the 1st step respectively, -r and -s are 16s and its reference sequences created with classifier step. They will be used to evalute the sequence quality.

**Result Visualization **

The results can be visulized with *.qzv files using **qiime tools view *.qzv**.










