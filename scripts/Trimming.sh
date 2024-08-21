#!/bin/bash

#  SRA lists
sra_ids=(
    SRR27848283 SRR27848284 SRR27848285 SRR27848286 SRR27848287
    SRR27848288 SRR27848289 SRR27848290 SRR27848291 SRR27848292
    SRR27848293 SRR27848294 SRR27848295 SRR27848296 SRR27848297
    SRR27848298 SRR27848299 SRR27848300 SRR27848301 SRR27848302
    SRR27848303 SRR27848304 SRR27848305 SRR27848306 SRR27848307
    SRR27848308 SRR27848309 SRR27848310 SRR27848311 SRR27848312
    SRR27848313 SRR27848314 SRR27848315 SRR27848316 SRR27848317
    SRR27848318 SRR27848319 SRR27848320 SRR27848321 SRR27848322
    SRR27848323 SRR27848324 SRR27848325 SRR27848326 SRR27848327
    SRR27848328 SRR27848329 SRR27848330 SRR27848331 SRR27848332
    SRR27848333 SRR27848334 SRR27848335 SRR27848336 SRR27848337
    SRR27848338 SRR27848339 SRR27848340 SRR27848341 SRR27848342
    SRR27848343 SRR27848344 SRR27848345 SRR27848346 SRR27848347
    SRR27848348 SRR27848349 SRR27848350 SRR27848351 SRR27848352
    SRR27848353 SRR27848354 SRR27848355 SRR27848356 SRR27848357
    SRR27848358 SRR27848359
)

# adaptaer file path
adapter_file="/home/nourbar7oumi/TruSeq3-PE.fa"

# SRR folder
mkdir -p sra_files


mkdir -p fastq_files

#  FastQC resulsts Folder
mkdir -p fastqc_results

# Trimming Folder
mkdir -p trimmed_fastq

# Downloading SRA
for sra_id in "${sra_ids[@]}"; do
    prefetch "$sra_id" -O sra_files/
done


for sra_id in "${sra_ids[@]}"; do
    # Conversion en fichiers FASTQ paired-end
    fastq-dump --split-files --outdir fastq_files/ "sra_files/${sra_id}.sra"
    
    # Fastqc execution
    fastqc "fastq_files/${sra_id}_1.fastq" "fastq_files/${sra_id}_2.fastq" -o fastqc_results/
done

# Trimming with Trimmomatic
for sra_id in "${sra_ids[@]}"; do
   
    fastq_file_1="fastq_files/${sra_id}_1.fastq"
    fastq_file_2="fastq_files/${sra_id}_2.fastq"
   # Output Files
    output_file_1="trimmed_fastq/${sra_id}_1_trimmed.fastq"
    output_file_2="trimmed_fastq/${sra_id}_2_trimmed.fastq"
    unpaired_file_1="trimmed_fastq/${sra_id}_1_unpaired.fastq"
    unpaired_file_2="trimmed_fastq/${sra_id}_2_unpaired.fastq"
    
    #  Trimmomatic
    trimmomatic PE -threads 4 \
        "$fastq_file_1" "$fastq_file_2" \
        "$output_file_1" "$unpaired_file_1" \
        "$output_file_2" "$unpaired_file_2" \
        ILLUMINACLIP:"$adapter_file":2:30:10 \
        LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    
    # FastQC after trimming
    fastqc "$output_file_1" "$output_file_2" -o trimmed_fastqc_results/
done

# MultiQC after trimming
multiqc fastqc_results/ trimmed_fastqc_results/ -o trimmed_fastqc_results/
