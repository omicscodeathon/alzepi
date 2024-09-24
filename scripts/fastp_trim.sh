#!/usr/bin/bash

source ./version.sh

# The path to the files to be trimmed 
input_dir=../output
cd $input_dir

#making a  directory for the results  of fastp
mkdir ./fastp

# a loop to iterate through the sequences in the input directory 
for  sra_seq in *_1.fastq.gz; do
	name=$(basename ${sra_seq} _1.fastq.gz) #remove the end of the file
	echo ${name}
#running the fastp for the file
	fastp -i ${name}_1.fastq.gz -I ${name}_2.fastq.gz -o ./fastp/${name}_1.trim.fastq.gz -O ./fastp/${name}_2.trim.fastq.gz --failed_out ./fastp/${name}_failed --detect_adapter_for_pe --trim_poly_x --trim_poly_g --report_title -h ${name}_report.html
done
echo 'all done'
