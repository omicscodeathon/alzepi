# Copyright 2024. alzepi, Omic codeathon. All rights reserved.

import subprocess
from pathlib import Path

# Define the base directory for the script and use its parent
base_dir = Path(__file__).resolve().parent
parent_dir = base_dir.parent

# File path for SRA identifiers
sra_id_file = parent_dir / 'accessions/mini_accessions.txt'

# Directory containing the output files
output_dir = parent_dir / 'output'
adapter_file = parent_dir / 'TruSeq3-PE.fa'

# Create output directories
trimmed_dir = output_dir / 'trimmed'
fastqc_results_dir = trimmed_dir / 'fastqc'
fastqc_results_dir.mkdir(parents=True, exist_ok=True)
trimmed_dir.mkdir(parents=True, exist_ok=True)

# Read SRA IDs from the file
with open(sra_id_file, 'r') as file:
    sra_ids = [line.strip() for line in file]

# Trimming with Trimmomatic using existing gzipped paired FASTQ files
for sra_id in sra_ids:
    fastq_file_1 = output_dir / f"{sra_id}_1.fastq.gz"
    fastq_file_2 = output_dir / f"{sra_id}_2.fastq.gz"
    
    # Output Files
    output_file_1 = trimmed_dir / f"{sra_id}_1_trimmed.fastq.gz"
    unpaired_file_1 = trimmed_dir / f"{sra_id}_1_unpaired.fastq.gz"
    output_file_2 = trimmed_dir / f"{sra_id}_2_trimmed.fastq.gz"
    unpaired_file_2 = trimmed_dir / f"{sra_id}_2_unpaired.fastq.gz"
    
    # Check if trimmed files already exist
    if output_file_1.is_file() and output_file_2.is_file():
        print(f"Trimming already completed for {sra_id}. Skipping...")
        continue
    
    # Check if input files exist
    if fastq_file_1.is_file() and fastq_file_2.is_file():
        # Trimmomatic command
        command = [
            'trimmomatic', 'PE', '-threads', '4',
            str(fastq_file_1), str(fastq_file_2),
            str(output_file_1), str(unpaired_file_1),
            str(output_file_2), str(unpaired_file_2),
            f'ILLUMINACLIP:{adapter_file}:2:30:10',
            'LEADING:3', 'TRAILING:3', 'SLIDINGWINDOW:4:15', 'MINLEN:36'
        ]
        
        # Run Trimmomatic
        try:
            subprocess.run(command, check=True)
            print(f"Trimming completed for {sra_id}.")
        except subprocess.CalledProcessError as e:
            print(f"Error running Trimmomatic for {sra_id}: {e}")
    else:
        print(f"Warning: FASTQ files for {sra_id} not found in {output_dir}")

# FastQC after trimming
trimmed_fastq_files = list(trimmed_dir.glob('*_trimmed.fastq.gz'))

if trimmed_fastq_files:
    sequana_working_dir = trimmed_dir / 'fastqc'
    
    # Run the Sequana FastQC pipeline on trimmed files
    try:
        subprocess.run(['sequana_fastqc', '--input-directory', str(trimmed_dir), '--working-directory', str(sequana_working_dir), '--force'], check=True)
        print("FastQC pipeline set successfully on trimmed files. Results saved in 'fastqc_results'.")
    except subprocess.CalledProcessError as e:
        print(f"Error running FastQC: {e}")
else:
    print("No valid trimmed FASTQ files found for quality control.")

