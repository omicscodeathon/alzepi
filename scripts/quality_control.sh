#!/usr/bin/env bash
#Copyright 2024. alzepi, Omics codeathon. All rights reserved.

# Execute version.sh script
bash version.sh

# File path for SRA identifiers
sra_id_file=../accessions/mini_accessions.txt

# Directory containing the output files
OUTPUT_DIR="../output"

# Create results directory
mkdir -p ../output/fastqc_results

# Read each line in the SRA ID file and do quality control using sequena_fastqc
while IFS= read -r sra_id; do
    if [[ -f "$OUTPUT_DIR/${sra_id}_1_fastq.gz" && -f "$OUTPUT_DIR/${sra_id}_2_fastq.gz" ]]; then
        sequena_fastqc "$OUTPUT_DIR/${sra_id}_1_fastq.gz" "$OUTPUT_DIR/${sra_id}_2_fastq.gz" -o ../output/fastqc_results/
    else
        echo "Warning: FASTQ files for ${sra_id} not found in $OUTPUT_DIR"
    fi
done < "$sra_id_file"

# Consolidate results with MultiQC
cd ../output
multiqc fastqc_results/ -o fastqc_results/

