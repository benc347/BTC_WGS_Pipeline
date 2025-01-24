#!/bin/bash 

#SBATCH --time=48:00:00					##(day-hour:minute:second) sets the max time for the job
#SBATCH --cpus-per-task=16	 			##request number of cpus
#SBATCH --mem=64G						##max ram for the job

#SBATCH --nodes=1						##request number of nodes (always keep at 1)
#SBATCH --mail-user=YOUR_EMAIL_HERE		##email address to mail specified updates to
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END					##these say under what conditions do you want email updates
#SBATCH --mail-type=FAIL
#SBATCH --output="00_fastqc_quality_assessment_%j"	##names what slurm logfile will be saved to 

#this script will run the .fastq quality reporting software FASTQC on select files
#it will then generate a tab-separated text file with the pass/fail summaries for each file

#load modules - names may differ for your HPC
module load fastqc

#accept user input for file extension
	#script will run FASTQC on all files ending in that extension
extension=$1

#make an output directory
mkdir ./fastqc_output

#run FASTQC on all
fastqc *${extension} -o ./fastqc_output

#unzip all the output directories
cd ./fastqc_output
for zipped in ./*.zip; do
	unzip $zipped
done
cd -

#create a text file with the rownames
#pull rownames from one of the files
filepattern="./fastqc_output/*_fastqc/summary.txt"
allfiles=( $filepattern )
awk -F'\t' '{print $2}' ${allfiles[0]} | sed '1 i\ANALYSIS' > all_summary.txt

#for every directory in the fastqc folder
for directory in ./fastqc_output/*_fastqc; do

	#enter the directory
	cd $directory
	#pull the first line from column 3 (name of the well) and the test results
	awk -F'\t' 'NR==1{print $3}{print $1}' summary.txt > temp.txt
	
	#paste this info together with the rownames file
	paste -d'\t' ../../all_summary.txt temp.txt > ../../blah.txt
	rm temp.txt
	
	#swap back to the outer directory and rename the pasted file to the summary file
	cd -
	mv blah.txt all_summary.txt
	
done
