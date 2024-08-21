#!/usr/bin/bash

#PBS -l select=3:ncpus=24:mpiprocs=24:mem=120gb
#PBS -q normal
#PBS -l walltime=4:00:00
#PBS -o /home/pajwang/lustre/kimani/alzepi/output/fast_dump_ouput.txt
#PBS -e /home/pajwang/lustre/kimani/alzepi/output/fast_dump_error.txt
#PBS -m abe
#PBS -M kimanijkariuki@gmail.com
#PBS -N fastq-dump
#PBS -P CBBI1470

set -eu

module load chpc/BIOMODULES
module add  sra-toolkit/3.1.0


#file path
sra_ids=/home/pajwang/lustre/kimani/alzepi/accessions/accessions.txt

#a variable for the output directory 
output_dir=/home/pajwang/lustre/kimani/alzepi/output

# Download the SRA files
for sra_id in "${sra_ids[@]}"; do	
	echo "processing $sra_id..."
	prefetch "$sra_id"

# Convert the SRA files to paired FASTQ files
	fastq-dump "$sra_id" --threads 60 --outdir "$output_dir" --split-files --gzip


	echo "$sra_id processed succesfully" 
done

echo "All jobs competed succesfully"

