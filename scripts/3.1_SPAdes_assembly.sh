#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=40	 			##request number of cpus
#SBATCH --mem=100G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=YOUR_EMAIL_HERE		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_spades_assembly_slurmlog_%j"		##names what slurm logfile will be saved to 

#this script uses SPAdes to assemble a draft genome from paired-end reads1
#this script was designed to be called in a batch mode by 3_SPAdes_batch_controller.sh

#load modules - names may differ for your HPC
module load spades

#running spades for paired end Illumina data
	#mode - SPAdes assembly mode such as --isolate or --meta (full list at https://github.com/ablab/spades)
	#reads1 - fastq file of the forward (R1) reads
	#reads2 - fastq file of the reverse (R2) reads
	#outdir - the output directory for the SPAdes running
	#prefix - the identifying information of the R1 read file
		#will be used as the prefix for the SPAdes output
		#will also be used to rename the fasta headers in the draft genome into something meaninful
mode=$1
reads1=$2
reads2=$3
outdir=$4
prefix=$5

echo $mode " " $reads1 " " $reads2 " " $outdir " " $prefix

spades.py $mode -t 40 --pe1-1 $reads1 --pe1-2 $reads2 -o ${outdir}

#change headers for contigs.fasta (the draft genome)
#move them up one directory and rename them
for fasta in ${outdir}contigs.fasta; do
	targdir1=${outdir%/}
	targdir=${targdir1%/*}/
	
	sed "s/>/>$prefix\_/g" $fasta > ${outdir}${prefix}_contigs_fixedhead.fasta
	cp ${outdir}${prefix}_contigs_fixedhead.fasta ${targdir}${prefix}_contigs_fixedhead.fasta
done
