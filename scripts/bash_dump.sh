#!/usr/bin/bash

source ./version.sh

# File path
sra_id_file=../accessions/mini_accessions.txt

# Variable for the output directory using absolute paths
output_dir=$(realpath ../output)

# Ensure the output directory exists
mkdir -p "$output_dir"

# Download
while read -r sra_id; do
    echo "Processing $sra_id..."

    # Define expected output files
    output_files=("$output_dir/${sra_id}_1.fastq.gz" "$output_dir/${sra_id}_2.fastq.gz")

    # Check if output files already exist and are complete
    all_files_complete=true
    for file in "${output_files[@]}"; do
        if [ -f "$file" ] && [ -s "$file" ]; then
            echo "$file already exists and is complete."
        else
            echo "$file does not exist or is incomplete. Processing..."
            all_files_complete=false
            break
        fi
    done

    if [ "$all_files_complete" = true ]; then
        echo "$sra_id has already been processed. Skipping..."
        continue
    fi

    # Convert the SRA file to paired FASTQ files
    parallel-fastq-dump --sra-id "$sra_id" --threads 24 --outdir "$output_dir" --split-files --gzip

    if [ $? -eq 0 ]; then
        echo "$sra_id processed successfully."
    else
        echo "Error processing $sra_id." >&2
        exit 1
    fi
done < "$sra_id_file"
