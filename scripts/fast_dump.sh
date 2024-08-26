#!/bin/bash

#SBATCH --job-name=Fast-dump

#SBATCH --nodes=1

#SBATCH --ntasks=1

#SBATCH --cpus-per-task=1

#SBATCH --mem-per-cpu=2G

#SBATCH --mail-type=begin

#SBATCH --mail-type=end

#SBATCH --mail-user = kkimani@kemri-wellcome.org

module load sratools/


#file path
sra_id_file=/home/KWTRP/kkimani/Home/alzepi/accessions/accessions.txt

#a variable for the output directory
output_dir=/home/KWTRP/kkimani/Home/alzepi/output

# Download
while read -r sra_id; do
    echo "Processing $sra_id..."

    # Convert the SRA file to paired FASTQ files
    fastq-dump   "$sra_id" --outdir "$output_dir" --split-files --gzip

    if [ $? -eq 0 ]; then
        echo "$sra_id processed successfully."
    else
        echo "Error processing $sra_id." >&2
        exit 1
    fi
done < "$sra_id_file"
