#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=5	 			##request number of cpus
#SBATCH --mem=10G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=YOUR_EMAIL_HERE		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_bbduk_quality_adapter_trimming_slurmlog_%j"		##names what slurm logfile will be saved to 

# this script will run BBDuk on paired end Illumina sequencing data
	# specifically, it runs the default BBDuk adapter trimming
	# it then takes user input to accept a minimum PHRED quality score
		# it will then trim bases on each read below that score
		# it will then remove any trimmed reads with an average quality below the threshold
	# finally, it accepts a user-provided minimum length argument and value
		# it then removes any remaining reads shorter than the length
	# as a bonus, it outputs a text file with the percentage of reads and bases remaining after trimming
	
# bbmap guide: https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbmap-guide/
# list of options: https://github.com/BioInfoTools/BBMap/blob/master/sh/bbmap.sh

#load modules - names may differ for your HPC
module load bbtools
module load samtools

#take user input
	#outdir - user specified output directory, should not exist already
	#qthresh - the minimum PHRED quality score
	#min_option - the BBDuk argument and value for minimum length
outdir=$1
qthresh=$2
min_option=$3

#make the output directory
mkdir $outdir

# Adapter trimming 
# The below will run bbduk against all .fastq files in the directory, removing adapters and creating a "clean" file
# in - input file to be trimmed; out - output file; ref - file containing adapter sequences; leave others at defaults
# ktrim=r - upon finding adapter, remove all to the right; k=23 - max kmer size 23; mink=11 - min kmer size 11; hdist=1 - hamming distance is 1
# tbo - trim adapters based on pair overlap (recommended); tpe - trim paired reads to same length; ordered - reads ordered in same manner in output as in input
# qtrim=rl - quality trim from both ends; trimq=25 - quality threshold set to 25; minq=10 - discard all reads q < 10; minlen=150 - discard reads <150 bp
for reads1 in *_R1_*.fastq*; do
	reads2="${reads1%_R1*}_R2_${reads1#*_R1_}"
	bbduk.sh in1="$reads1" in2="$reads2" out1=${outdir}/${reads1%.fastq}_clean.fastq out2=${outdir}/${reads2%.fastq}_clean.fastq ref=bbduk_adapters.fasta ktrim=r ordered k=23 hdist=1 mink=11 tpe tbo qtrim=rl trimq=$qthresh maq=$qthresh $min_option
done

#pull the relevant results from the log
grep 'Executing\|Result*' 00_bbduk_slurmlog_${SLURM_JOB_ID} \
	| sed -e 's/out.*//g' | sed -e 's/Executing.*in=//g' \
	| sed -e 's/\.fastq.*//g' > ${outdir}/retained_read_percentage.txt
	
mv 00_bbduk_slurmlog_${SLURM_JOB_ID} ${outdir}/
