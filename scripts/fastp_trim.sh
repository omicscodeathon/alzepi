#!/bin/bash
#*********************************************************
# This is a script to perform quality control

# ========================================================
#--- slurm commands ---

#SBATCH --job-name fastp_qc
#SBATCH --partition=longrun
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=400G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkimani@kemri-wellcome.org

conda activate alzepi


source ./version.sh

# The path to the files to be trimmed 
input_dir=../output
cd $input_dir

#making a  directory for the results  of fastp
mkdir ./fastp

# a loop to iterate through the sequences in the input directory 
for  sra_seq in *_1.fastq.gz; do
	name=$(basename ${sra_seq} _1.fastq.gz) #remove the end of the file
	echo ${name}
#running the fastp for the file
	echo "starting the fastp"
	fastp -i ${name}_1.fastq.gz -I ${name}_2.fastq.gz -o ./fastp/${name}_1.trim.fastq.gz -O ./fastp/${name}_2.trim.fastq.gz --failed_out ./fastp/${name}_failed --detect_adapter_for_pe --trim_poly_x --trim_poly_g --report_title -h ${name}_report.html
done
echo 'all done'

