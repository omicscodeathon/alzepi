# Copyright 2024. alzepi, Omics codeathon. All rights reserved.

import subprocess
from pathlib import Path

# Get the current script's directory (basedir)
basedir = Path(__file__).resolve().parent

# Get the parent directory of basedir
parent_dir = basedir.parent

# Define the star_index directory and the combined output directory
star_index_dir = parent_dir / "star_index"
combined_genome_file = parent_dir /"star_index"/"combined_genome.fa"

# Check if star_index_dir exists
if not star_index_dir.is_dir():
    print(f"Error: STAR index directory not found at {star_index_dir}")
    exit(1)

# Combine all chunked .fna files into one genome file
def combine_chunked_genomes(output_file):
    with open(output_file, 'wb') as combined_fna:
        for chunk_file in sorted(star_index_dir.glob("*.fna")):
            with open(chunk_file, 'rb') as f:
                combined_fna.write(f.read())
    print(f"Combined genome written to: {output_file}")

# Generate the STAR index from the combined genome file
def generate_star_index(genome_file):
    gtf_file = parent_dir / "data" / "homo_sapiens_rna.gtf"  # Update with your GTF file path
    star_command = [
        "STAR",
        "--runMode", "genomeGenerate",
        "--runThreadN", "4",  # Use 4 threads; adjust as needed
        "--genomeDir", str(star_index_dir),
        "--genomeFastaFiles", str(genome_file),
        "--sjdbGTFfile", str(gtf_file),
        "--sjdbOverhang", "100",  # Typically the read length - 1
        "--limitGenomeGenerateRAM", "8000000000"  # Adjust RAM limit as necessary
    ]

    try:
        subprocess.run(star_command, check=True)
        print(f"STAR index created successfully in: {star_index_dir}")
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while generating STAR index: {e}")

if __name__ == "__main__":
    # Combine chunked genomes into one file
    combine_chunked_genomes(combined_genome_file)

    # Generate the STAR index from the combined genome
    generate_star_index(combined_genome_file)

