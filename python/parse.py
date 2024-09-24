#!/usr/bin/env python3
# alzepi, Omics codeathon 2024. All rights reserved

import os
import csv
import sys

# Directory containing the temporary metadata files
tmp_dir = '../tmp'
# Path to the output CSV file
output_file = '../SraMetadata.csv'

def parse_metadata_file(file_path):
    """Parse a metadata file and return a dictionary of fields."""
    metadata = {}
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if ': ' in line:
                key, value = line.split(': ', 1)
                metadata[key.strip()] = value.strip()
    return metadata

def write_metadata_to_csv(accession, metadata, csv_writer):
    """Write a single row of metadata to the CSV file."""
    # Define the order of columns as needed
    columns = [
        'BASE_COUNT', 'BIO_BASE_COUNT', 'CMP_BASE_COUNT', 'COLOR_MATRIX', 'CSREAD', 'CS_KEY',
        'CS_NATIVE', 'FIXED_SPOT_LEN', 'LANE', 'MAX_SPOT_ID', 'MIN_SPOT_ID', 'NAME', 'PLATFORM',
        'POSITION', 'QUALITY', 'RD_FILTER', 'READ', 'READ_FILTER', 'READ_LEN', 'READ_SEG',
        'READ_START', 'READ_TYPE', 'SIGNAL_LEN', 'SPOT_COUNT', 'SPOT_FILTER', 'SPOT_GROUP',
        'SPOT_ID', 'SPOT_IDS_FOUND', 'SPOT_LEN', 'TILE', 'TRIM_LEN', 'TRIM_START', 'X', 'Y'
    ]
    
    row = [accession]
    for column in columns:
        row.append(metadata.get(column, ''))
    
    csv_writer.writerow(row)

def main():
    if len(sys.argv) != 3:
        print("Usage: python parse.py <metadata_file> <accession>")
        sys.exit(1)

    metadata_file = sys.argv[1]
    accession = sys.argv[2]

    # Open the output CSV file in append mode
    with open(output_file, 'a', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)

        # Parse the metadata file
        metadata = parse_metadata_file(metadata_file)
        
        # Write metadata to CSV
        write_metadata_to_csv(accession, metadata, csv_writer)

if __name__ == '__main__':
    main()

