#!/bin/bash
# Copyright 2024. alzepi, Omics codeathon. All rights reserved.

source version.sh

# SRA lists
sra_ids=$(<../accessions/mini_accessions.txt)

# Adapter file path
adapter_file="../TruSeq3-PE.fa"

# Shift to output directory 
cd ../output || exit

# Directories
mkdir -p fastqc_results
mkdir -p trimmed

# FastQC execution on existing gzipped paired FASTQ files
for sra_id in $sra_ids; do
    sequana_fastqc "${sra_id}_1.fastq.gz" "${sra_id}_2.fastq.gz" -o fastqc_results/
done

# Trimming with Trimmomatic using existing gzipped paired FASTQ files
for sra_id in $sra_ids; do
    fastq_file_1="fastq_files/${sra_id}_1.fastq.gz"
    fastq_file_2="fastq_files/${sra_id}_2.fastq.gz"
    
    # Output Files
    output_file_1="trimmed_fastq/${sra_id}_1_trimmed.fastq.gz"
    output_file_2="trimmed_fastq/${sra_id}_2_trimmed.fastq.gz"
    unpaired_file_1="trimmed_fastq/${sra_id}_1_unpaired.fastq.gz"
    unpaired_file_2="trimmed_fastq/${sra_id}_2_unpaired.fastq.gz"
    
    # Trimmomatic
    trimmomatic PE -threads 4 \
        "$fastq_file_1" "$fastq_file_2" \
        "$output_file_1" "$unpaired_file_1" \
        "$output_file_2" "$unpaired_file_2" \
        ILLUMINACLIP:"$adapter_file":2:30:10 \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    
    # FastQC after trimming
    sequana_fastqc "$output_file_1" "$output_file_2" -o trimmed_fastq/
done

# MultiQC after trimming
multiqc fastqc_results/ trimmed_fastq/ -o multiqc_data/

