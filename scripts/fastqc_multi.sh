#!/usr/bin/bash

source ./version.sh

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

