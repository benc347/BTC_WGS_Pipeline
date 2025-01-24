# BTC_WGS_Pipeline

**PLEASE CITE THE ORIGINAL PUBLICATIONS AND PACKAGES**

SPAdes - https://currentprotocols.onlinelibrary.wiley.com/doi/abs/10.1002/cpbi.102

BBTools - https://sourceforge.net/projects/bbmap/

FastQC - https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

This repository contains a series of scripts for flexible, start-to-finish whole genome (and metagenome!) sequence assembly using SPAdes

- the Bash scripts were designed for use on a high-performance computing cluster manged with SLURM
  - the scripts allow a large number of samples to be processed and assembled in parallel
- FastQC is used to perform a basic quality check on raw reads
  - a tab-separated output file summarizing all FastQC statistics for each sample is reported
- BBDuk is used to perform quality and adapter trimming of raw reads
  - accepts user input for quality and minimum length thresholds
- SPAdes is used to perform assemblies
  - accepts user input for SPAdes assembly mode

A typical workflow would be the following:

- run 1_quality_assess_fastqc.sh on the raw reads
  - then check the "all_summary.txt" file to obtain an idea of the overall quality of the raw reads
  - finally, check a couple of the .html files to see more details of the quality
- run 2_quality_and_adapter_trim_bbduk.sh on the raw reads
  - based on the quality information from FastQC, identify reasonable quality and read length thresholds
- run 3_SPAdes_batch_controller.sh on the trimmed reads
  - use the appropriate SPAdes assembly mode for the dataset
