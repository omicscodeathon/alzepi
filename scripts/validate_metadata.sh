#!/bin/bash
# alzepi
# 2024 all rights reserved

source version.sh
echo "Copyright 2024. alzepi, Omics codeathon. All rights reserved..."

# Define the path to the input file and the output file
input_file="../accessions/accessions.txt"
output_file="../SraMetadata.csv"
tmp_dir="../tmp"
python_script="../python/parse.py"

# Check if the ../tmp directory exists, if not, create it
if [ ! -d "$tmp_dir" ]; then
    echo "Creating directory $tmp_dir"
    mkdir -p "$tmp_dir"
fi

# Check if the output file exists, if not, create it
if [ ! -f "$output_file" ]; then
    echo "Saving metadata to $output_file"
    touch "$output_file"
    # Write CSV header
    echo "SRA_ACCESSION,BASE_COUNT,BIO_BASE_COUNT,CMP_BASE_COUNT,COLOR_MATRIX,CSREAD,CS_KEY,CS_NATIVE,FIXED_SPOT_LEN,LANE,MAX_SPOT_ID,MIN_SPOT_ID,NAME,PLATFORM,POSITION,QUALITY,RD_FILTER,READ,READ_FILTER,READ_LEN,READ_SEG,READ_START,READ_TYPE,SIGNAL_LEN,SPOT_COUNT,SPOT_FILTER,SPOT_GROUP,SPOT_ID,SPOT_IDS_FOUND,SPOT_LEN,TILE,TRIM_LEN,TRIM_START,X,Y" > "$output_file"
fi

fetch_metadata() {
    local accession=$1
    local temp_metadata_file="$tmp_dir/temp_metadata_${accession}.txt"

    echo "Fetching metadata for $accession..."
    
    # Use -R to fetch the first 10 rows, and do not use -C to include all columns
    if ! vdb-dump "$accession" -R 10 > "$temp_metadata_file"; then
        echo "Failed to fetch metadata for $accession" >&2
        return 1
    fi

    # Check if metadata was found
    if [ ! -s "$temp_metadata_file" ]; then
        echo "No metadata found for $accession" >&2
        return 1
    fi

    # Parse the metadata file using the Python script
    if ! python3 "$python_script" "$temp_metadata_file" "$accession" >> "$output_file"; then
        echo "Error parsing metadata for $accession" >&2
        return 1
    fi

    # Clean up temporary file
    rm -f "$temp_metadata_file"
}

# Loop through each line in the input file
while IFS= read -r accession; do
    fetch_metadata "$accession"
done < "$input_file"

# Clean up tmp directory
rm -rf "$tmp_dir"

echo "SRA metadata saved to $output_file"

