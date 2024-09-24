# Copyright 2024. alzepi, Omics codeathon. All rights reserved.

import subprocess
from pathlib import Path
import gzip
import shutil

# Get the current script's directory (basedir)
basedir = Path(__file__).resolve().parent

# Get the parent directory of basedir
parent_dir = basedir.parent

# Create the 'star_index' directory in the parent directory
star_index_dir = parent_dir / "star_index"
star_index_dir.mkdir(exist_ok=True)

# Define paths to the reference genome and annotation features
data_dir = parent_dir / "data"
reference_genome = data_dir / "homo_sapiens_rna.fna.gz"
uncompressed_gtf = data_dir / "homo_sapiens_rna.gtf"

# Check if files exist
if not reference_genome.is_file():
    print(f"Error: Reference genome not found at {reference_genome}")
    exit(1)

if not uncompressed_gtf.is_file():
    print(f"Error: Annotation features not found at {annotation_features}")
    exit(1)

# Unzip the reference genome and annotation features
def unzip_file(gz_file, output_file):
    with gzip.open(gz_file, 'rb') as f_in:
        with open(output_file, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)

# Create temporary uncompressed files
uncompressed_ref = data_dir / "homo_sapiens_rna.fna"

unzip_file(reference_genome, uncompressed_ref)

# Function to generate STAR index in chunks
def generate_star_index_in_chunks(reference_file, gtf_file, chunk_size=1000000):
    # Read the reference genome file to split into chunks
    with open(reference_file) as ref:
        header = None
        current_chunk = []
        chunk_count = 0

        for line in ref:
            if line.startswith(">"):
                if header:
                    # Save current chunk to a temporary file
                    chunk_file = star_index_dir / f"{chunk_count}.fna"
                    with open(chunk_file, 'w') as chunk_out:
                        chunk_out.writelines(current_chunk)

                    # Run STAR on the current chunk
                    star_command = [
                        "STAR",
                        "--runMode", "genomeGenerate",
                        "--runThreadN", "2",
                        "--genomeDir", str(star_index_dir),
                        "--genomeFastaFiles", str(chunk_file),
                        "--sjdbGTFfile", str(gtf_file),
                        "--sjdbOverhang", "50",
                        "--limitGenomeGenerateRAM", "8000000000"
                    ]

                    try:
                        subprocess.run(star_command, check=True)
                        print(f"STAR index created successfully for chunk {chunk_count}")
                    except subprocess.CalledProcessError as e:
                        print(f"Error occurred while running STAR for chunk {chunk_count}: {e}")

                    # Reset for the next chunk
                    current_chunk = []
                    chunk_count += 1

                # Start a new header
                header = line

            # Collect lines for the current chunk
            current_chunk.append(line)

        # Process the last chunk
        if current_chunk:
            chunk_file = star_index_dir / f"{chunk_count}.fna"
            with open(chunk_file, 'w') as chunk_out:
                chunk_out.writelines(current_chunk)

            star_command = [
                "STAR",
                "--runMode", "genomeGenerate",
                "--runThreadN", "2",
                "--genomeDir", str(star_index_dir),
                "--genomeFastaFiles", str(chunk_file),
                "--sjdbGTFfile", str(gtf_file),
                "--sjdbOverhang", "50",
                "--limitGenomeGenerateRAM", "8000000000"
            ]

            try:
                subprocess.run(star_command, check=True)
                print(f"STAR index created successfully for chunk {chunk_count}")
            except subprocess.CalledProcessError as e:
                print(f"Error occurred while running STAR for chunk {chunk_count}: {e}")

# Call the function to generate the index
generate_star_index_in_chunks(uncompressed_ref, uncompressed_gtf)

# Clean up temporary files
if uncompressed_ref.is_file():
    uncompressed_ref.unlink()
if uncompressed_gtf.is_file():
    uncompressed_gtf.unlink()

