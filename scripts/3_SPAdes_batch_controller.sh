#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=4	 			##request number of cpus
#SBATCH --mem=10G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=YOUR_EMAIL_HERE		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_spades_batch_controller_slurmlog_%j"		##names what slurm logfile will be saved to 

#this script runs submits multiple SPAdes jobs
	#one job for paired-end read sample - submits 3.1_SPAdes_assembly.sh
		#paired end reads need to have either "_R1_" or "_R2_" in their names
		#each file in a pair should have identical names except the "R1" or "R2"

#will use user input to determine input directory and spades mode
	#inputdir - directory containing paired reads
	#outdir - user specified output directory, should not exist already
	#mode - an assembly mode of SPAdes such as --isolate or --meta (full list: https://github.com/ablab/spades)
inputdir=${1%/}
outdir=${2%/}
mode=$3

#make output directory
	#will contain all SPAdes output directories, one for each job
mkdir $outdir

#iterate over the forward (R1) read files
for reads1 in ${inputdir%/}/*_R1_*.fastq*; do
	reads2="${reads1%_R1_*.fastq*}_R2_${reads1##*_R1_}"
	echo $reads1 $reads2 $mode
	
	#make a variable to store the identifying information of the R1 read file
		# e.g. "myreads1" in your/input/directory/myreads1_R1_f.fastq
		# will be used as the name of the SPAdes output directory
		# will also be used to rename the fasta headers in the draft genome
	newdir1=${reads1%_R1_*.fastq*}
	newdir=${newdir1##*/}
	echo $newdir
	
	#run spades script with the following input (assembly mode, reads, SPAdes output directory)
	sbatch 3.1_SPAdes_assembly.sh $mode $reads1 $reads2 ${outdir}/${newdir}/ $newdir
	
done
