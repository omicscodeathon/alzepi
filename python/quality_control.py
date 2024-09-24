import subprocess
from pathlib import Path

# Define the base directory for the script and use its parent
base_dir = Path(__file__).resolve().parent
parent_dir = base_dir.parent

# File path for SRA identifiers
sra_id_file = parent_dir / 'accessions/mini_accessions.txt'

# Directory containing the output files
output_dir = parent_dir / 'output'
input_fastq_files = []

# Read SRA IDs from the file and construct input file paths
with open(sra_id_file, 'r') as file:
    for line in file:
        sra_id = line.strip()
        # Check for both paired FASTQ files
        fastq1 = output_dir / f"{sra_id}_1.fastq.gz"
        fastq2 = output_dir / f"{sra_id}_2.fastq.gz"
        if fastq1.is_file() and fastq2.is_file():
            input_fastq_files.extend([fastq1, fastq2])
        else:
            print(f"Warning: FASTQ files for {sra_id} not found in {output_dir}")

# Create a directory for FastQC results
if input_fastq_files:
    sequana_working_dir = output_dir / 'fastqc'
    sequana_working_dir.mkdir(parents=True, exist_ok=True)

    # Run the Sequana FastQC pipeline
    try:
        subprocess.run(['sequana_fastqc', '--input-directory', str(output_dir), '--working-directory', str(sequana_working_dir), '--force'], check=True)
        print("FastQC pipeline set successfully. saved in 'fastqc'.")
        print("Run fastqc.sh in output/fastqc to continue...")
    except subprocess.CalledProcessError as e:
        print(f"Error running quality control: {e}")
else:
    print("No valid FASTQ files found for quality control.")

