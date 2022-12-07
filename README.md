# Targeted_SingleEnd

Qiime2 data analysis for 16s Single end sequences from Illumina 

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

./ITS_classifier.sh

(A change can be made within script which is based on primer selection used during the amplification)

The primers which have selected in these scripts to train the classifiers are,

16s V3 Forward primer - CCTACGGGNGGCWGCAG

16s V4 Reverse primer - GGACTACHVGGGTATCTAATCC

ITS Forward primer - GCATCGATGAAGAACGCAGC

ITS Reverse primers - GTCCTCCGCTTATTGATATGC

Similarly other database can be downloaded and trained!

http://qiime.org/home_static/dataFiles.html

Or trained databases can also be downloaded from:

https://docs.qiime2.org/2022.8/data-resources/

**Usage**
1) 16s_clssifier.sh
 ./16s_classifier.sh [-w working_dir] [-r database_fastafile] [-t taxonomy_file]
 
 where, -w is a parameter for working directory containing fasta file for database and its taxonomy.
 
 
 









