#!/usr/bin/bash

# Perform quality analysis with

# Navigate to the output directory
cd /home/KWTRP/kkimani/Home/alzepi/output/fastp || { echo "Directory not found"; exit 1; }
pwd

# Create the results directory if it doesn't exist
mkdir -p fastqc_reports2

# Perform FastQC analysis
echo "Starting FastQC..."
fastqc *.gz --threads 24 -o fastqc_reports2/ || { echo "FastQC failed"; exit 1; }

# Perform MultiQC analysis
echo "Starting MultiQC..."
multiqc fastqc_reports2 || { echo "MultiQC failed"; exit 1; }

echo "All done"

