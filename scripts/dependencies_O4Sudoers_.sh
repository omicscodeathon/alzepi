#!/usr/bin/env bash

#  main command
run_with_sudo() {
    echo "$1" | sudo -S $2
}

# Update package list and install packages
echo "Updating package list..."
sudo apt update

# Install required packages
echo "Installing required packages..."

run_with_sudo "your_password" "apt install -y parallel ncbi-entrez-direct gzip fastqc bedtools samtools python3-pandas python3-biopython bcftools"
run_with_sudo "your_password" "apt-get install "

echo "All packages installed successfully."
