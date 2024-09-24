#!/bin/bash
#*********************************************************
# This is a test script

# ========================================================
#--- slurm commands ---

#SBATCH --job-name fastp_qc
#SBATCH --partition=longrun
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=400G
#SBATCH --output=job.%j.out
#SBATCH --error=job.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=kkimani@kemri-wellcome.org

conda activate alzepi

#file path
sra_id_file=../SRR_Acc_List.txt

#a variable for the output directory
output_dir=../output

# Download
while read -r sra_id; do
    echo "Processing $sra_id..."

    # Convert the SRA file to paired FASTQ files
    parallel-fastq-dump --sra-id "$sra_id" --threads 36 --outdir "$output_dir" --split-files --gzip

    if [ $? -eq 0 ]; then
        echo "$sra_id processed successfully."
    else
        echo "Error processing $sra_id." >&2
        exit 1
    fi
done < "$sra_id_file"

# Perform quality analysis with

# Navigate to the output directory
cd ../output || { echo "Directory not found"; exit 1; }
pwd

# Create the results directory if it doesn't exist
mkdir -p fastqc_reports

# Perform FastQC analysis
echo "Starting FastQC..."
fastqc *.gz --threads 24 -o fastqc_reports/ || { echo "FastQC failed"; exit 1; }

# Perform MultiQC analysis
echo "Starting MultiQC..."
multiqc fastqc_reports || { echo "MultiQC failed"; exit 1; }

echo "All done"
