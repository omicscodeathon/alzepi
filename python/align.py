# Copyright 2024. alzepi, Omics codeathon. All rights reserved.

import subprocess
from pathlib import Path

def read_sra_ids(file_path):
    """Reads SRA IDs from a given text file."""
    with open(file_path, 'r') as f:
        sra_ids = [line.strip() for line in f if line.strip()]
    return sra_ids

def align_genomes_with_star(sra_id, star_index_dir, output_dir, align_dir):
    """Aligns genome files using STAR for a given SRA ID."""
    # Construct file paths
    trimmed_1 = output_dir / f"{sra_id}_1_trimmed.fastq.gz"
    unpaired_1 = output_dir / f"{sra_id}_1_unpaired.fastq.gz"
    trimmed_2 = output_dir / f"{sra_id}_2_trimmed.fastq.gz"
    unpaired_2 = output_dir / f"{sra_id}_2_unpaired.fastq.gz"

    # Ensure all files exist before proceeding
    files_to_check = [trimmed_1, unpaired_1, trimmed_2, unpaired_2]
    if not all(file.is_file() for file in files_to_check):
        print(f"Error: One or more files for SRA ID {sra_id} are missing.")
        return

    # List all chunk files in the star_index directory
    chunk_files = sorted(star_index_dir.glob("*.fna"))

    # Iterate through each chunk file and perform alignment
    for chunk_file in chunk_files:
        # Define the STAR command
        star_command = [
            "STAR",
            "--runThreadN", "2",
            "--genomeDir", str(star_index_dir),
            "--readFilesIn", str(trimmed_1), str(trimmed_2),
            "--readFilesCommand", "zcat",  # for gzipped files
            "--outFileNamePrefix", str(align_dir / f"{sra_id}_{chunk_file.stem}_"),  # prefix for output files
            "--outSAMtype", "BAM", "Unsorted",
            "--outFilterMultimapScoreRange", "1",
            "--outFilterMultimapNmax", "1",
            "--outFilterMismatchNoverLmax", "0.05",
            "--outSAMattributes", "NH", "HI", "AS", "nM", "MD"
        ]

        try:
            subprocess.run(star_command, check=True)
            print(f"Alignment completed successfully for SRA ID {sra_id} with chunk {chunk_file.stem}.")
        except subprocess.CalledProcessError as e:
            print(f"Error occurred while aligning SRA ID {sra_id} with chunk {chunk_file.stem}: {e}")

if __name__ == "__main__":
    # Set up directory paths
    basedir = Path(__file__).resolve().parent
    parent_dir = basedir.parent

    accessions_file = parent_dir / "accessions" / "mini_accessions.txt"
    star_index_dir = parent_dir / "star_index"
    output_dir = parent_dir / "output" / "trimmed"
    align_dir = parent_dir / "output" / "aligned"
    align_dir.mkdir(parents=True, exist_ok=True)
    # Read SRA IDs
    sra_ids = read_sra_ids(accessions_file)
    # Align genomes for each SRA ID
    for sra_id in sra_ids:
        align_genomes_with_star(sra_id, star_index_dir, output_dir, align_dir)

