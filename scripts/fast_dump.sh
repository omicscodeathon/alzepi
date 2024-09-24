#!/bin/bash

#SBATCH --job-name=Fast-dump

#SBATCH --nodes=1

#SBATCH --ntasks=1

#SBATCH --cpus-per-task=1

#SBATCH --mem-per-cpu=2G

#SBATCH --mail-type=begin

#SBATCH --mail-type=end

#SBATCH --mail-user=kkimani@kemri-wellcome.org

# Load necessary modules or activate environments
bash version.sh

# File path
sra_id_file=../accessions/mini_accessions.txt

# Variable for the output directory
output_dir=../output

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
        if [ -f "$file" ]; then
            file_size=$(stat -c%s "$file")  # Get file size in bytes
            file_size_gb=$(echo "scale=4; $file_size / 1024 / 1024 / 1024" | bc)  # Convert to GB
            if (( $(echo "$file_size_gb >= 1 && $file_size_gb <= 1.5" | bc -l) )); then
                echo "$file already exists and is complete."
            else
                echo "$file exists but is incomplete. Processing..."
                all_files_complete=false
                break
            fi
        else
            echo "$file does not exist. Processing..."
            all_files_complete=false
            break
        fi
    done

    if [ "$all_files_complete" = true ]; then
        echo "$sra_id has already been processed. Skipping..."
        continue
    fi

    # Convert the SRA file to paired FASTQ files
    fastq-dump "$sra_id" --outdir "$output_dir" --split-files --gzip

    if [ $? -eq 0 ]; then
        echo "$sra_id processed successfully."
    else
        echo "Error processing $sra_id." >&2
        exit 1
    fi
done < "$sra_id_file"

