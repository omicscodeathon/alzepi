# Copyright 2024. alzepi, Omics codeathon. All rights reserved

from Bio import SeqIO
from pathlib import Path
import gzip

def gbff_to_gtf(gbff_file, gtf_file):
    with open(gtf_file, 'w') as gtf_out:
        # Write GTF header
        gtf_out.write("##gff-version 2\n")

        # Parse the gbff file
        with gzip.open(gbff_file, "rt") as gbff_in:
            for record in SeqIO.parse(gbff_in, "genbank"):
                # Extract relevant information
                locus = record.id
                features = record.features
                
                for feature in features:
                    if feature.type in ["gene", "mRNA", "exon"]:
                        # Extract attributes
                        gene_id = feature.qualifiers.get("gene", [""])[0]
                        transcript_id = feature.qualifiers.get("transcript_id", [""])[0]
                        start = feature.location.start + 1  # GTF is 1-based
                        end = feature.location.end

                        # Write gene feature
                        if feature.type == "gene":
                            gtf_out.write(f"{locus}\tGenBank\tgene\t{start}\t{end}\t.\t{feature.location.strand}\t.\tgene_id \"{gene_id}\"; gene_name \"{gene_id}\";\n")

                        # Write transcript feature
                        elif feature.type == "mRNA":
                            gtf_out.write(f"{locus}\tGenBank\ttranscript\t{start}\t{end}\t.\t{feature.location.strand}\t.\tgene_id \"{gene_id}\"; transcript_id \"{transcript_id}\";\n")

                        # Write exon feature
                        elif feature.type == "exon":
                            exon_number = feature.qualifiers.get("exon_number", ["1"])[0]
                            gtf_out.write(f"{locus}\tGenBank\texon\t{start}\t{end}\t.\t{feature.location.strand}\t.\tgene_id \"{gene_id}\"; transcript_id \"{transcript_id}\"; exon_number \"{exon_number}\";\n")

if __name__ == "__main__":
    # Define the base directory and locate the parent directory
    basedir = Path(__file__).resolve().parent
    parentdir = basedir.parent

    # Define input and output file paths
    gbff_file_path = parentdir / "data" / "homo_sapiens_rna.gbff.gz"
    gtf_file_path = parentdir / "data" / "homo_sapiens_rna.gtf"

    # Convert GBFF to GTF
    gbff_to_gtf(gbff_file_path, gtf_file_path)
    print(f"GTF file created at: {gtf_file_path}")

