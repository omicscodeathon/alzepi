#!/usr/bin/env bash

# Define the URL for the SRA Toolkit download
SRA_TOOLKIT_URL="https://github.com/ncbi/sra-tools/releases/latest/download/sra-tools.tar.gz"
DOWNLOAD_DIR="../"
TAR_FILE="sra-tools.tar.gz"
EXTRACT_DIR="sra-tools"

# Function to check and print the SRA-toolkit version
check_version() {
    local tool=$1
    local version_command=$2

    if command -v "$tool" > /dev/null 2>&1; then
        echo "Using $tool version..."
        $version_command
    else
        echo "$SRA-Toolkit missing. Fatal Error!!! one or all sra tools is not installed."
    fi
}

# Function to download and extract SRA Toolkit
download_sra_toolkit() {
    echo "Downloading SRA Toolkit..."
    curl -L $SRA_TOOLKIT_URL -o "$DOWNLOAD_DIR$TAR_FILE"

    echo "Extracting SRA Toolkit..."
    tar -xzf "$DOWNLOAD_DIR$TAR_FILE" -C "$DOWNLOAD_DIR"

    # Clean up tar file
    rm "$DOWNLOAD_DIR$TAR_FILE"

    echo "SRA Toolkit has been downloaded and extracted to $DOWNLOAD_DIR$EXTRACT_DIR."
}

# Check and download SRA Toolkit if not installed
if ! command -v fastq-dump > /dev/null 2>&1 || \
   ! command -v prefetch > /dev/null 2>&1 || \
   ! command -v vdb-dump > /dev/null 2>&1 || \
   ! command -v vdb-config > /dev/null 2>&1; then
    echo "Some or all SRA Toolkit tools are not installed."
    download_sra_toolkit
else
    # Check versions of SRA Toolkit tools
    check_version "fastq-dump" "fastq-dump --version"
    check_version "prefetch" "prefetch --version"
    check_version "vdb-dump" "vdb-dump --version"
    check_version "vdb-config" "vdb-config --version"
fi

