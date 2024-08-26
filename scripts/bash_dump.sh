#!/usr/bin/bash

#file path
sra_id_file=/home/KWTRP/kkimani/Home/alzepi/accessions/accessions.txt

#a variable for the output directory
output_dir=/home/KWTRP/kkimani/Home/alzepi/output

# Download
while read -r sra_id; do
    echo "Processing $sra_id..."

    # Convert the SRA file to paired FASTQ files
    parallel-fastq-dump --sra-id "$sra_id" --threads 24 --outdir "$output_dir" --split-files --gzip

    if [ $? -eq 0 ]; then
        echo "$sra_id processed successfully."
    else
        echo "Error processing $sra_id." >&2
        exit 1
    fi
done < "$sra_id_file"
