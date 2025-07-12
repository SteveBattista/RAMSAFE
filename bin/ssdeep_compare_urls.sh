#!/bin/bash
#
# RAMSAFE URL Fuzzy Hash Comparison Tool  
#
# This script downloads files from two URLs and compares them using ssdeep
# fuzzy hashing to determine similarity. This is useful for comparing
# web-hosted evidence files without manually downloading them first.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Compare similarity between two files hosted at URLs
# USAGE: ./ssdeep_compare_urls.sh <url1> <url2>
# OUTPUT: Similarity score (0-100, where 100 = identical files)
#
# SECURITY FEATURES:
# - Downloads to temporary files in RAM (when run in RAMSAFE)
# - Securely shreds temporary files after analysis
# - Validates downloads before processing
#
# FORENSIC USE CASES:
# - Compare evidence files across different websites
# - Analyze if the same content is hosted at multiple locations
# - Detect modified versions of files distributed online
#

# Exit on any error for safer script execution  
set -e

# Ensure exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "ERROR: Incorrect number of arguments provided."
    echo "Usage: $0 <url1> <url2>"
    echo ""
    echo "Examples:"
    echo "  $0 https://example.com/image1.jpg https://example.com/image2.jpg"
    echo "  $0 'https://site1.com/file.png' 'https://site2.com/file.png'"
    echo ""
    echo "This tool downloads files from two URLs and compares them using"
    echo "fuzzy hashing to detect similarity between the files."
    exit 1
fi

# Verify required tools are installed
if ! command -v ssdeep &> /dev/null; then
    echo "ERROR: ssdeep tool not found."
    echo "ssdeep is required for fuzzy hash comparison but is not installed."
    echo "Please install ssdeep to use this script:"
    echo "  sudo apt install ssdeep"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "ERROR: curl tool not found."
    echo "curl is required for downloading files but is not installed."
    echo "Please install curl to use this script:"
    echo "  sudo apt install curl"
    exit 1
fi

# Store input URLs
url1="$1"
url2="$2"

# Create secure temporary files for downloads
# These will be automatically cleaned up on script exit
file_one=$(mktemp)
file_two=$(mktemp)

# Set up cleanup function to securely remove temporary files
cleanup() {
    echo "Cleaning up temporary files..."
    # Use shred to securely overwrite temporary files before deletion
    # This prevents recovery of potentially sensitive evidence
    if [ -f "$file_one" ]; then
        shred -f -z -u "$file_one" 2>/dev/null || rm -f "$file_one"
    fi
    if [ -f "$file_two" ]; then
        shred -f -z -u "$file_two" 2>/dev/null || rm -f "$file_two"
    fi
}

# Ensure cleanup happens even if script is interrupted
trap cleanup EXIT

echo "Downloading and comparing files from URLs:"
echo "  URL 1: $url1"  
echo "  URL 2: $url2"
echo ""

# Download the first file from URL
echo "Downloading first file from: $url1"
if ! curl -L -f -s -S -o "$file_one" "$url1"; then
    echo "ERROR: Failed to download first file from: $url1"
    echo "Please verify the URL is correct and accessible."
    exit 1
fi

# Verify first file was downloaded successfully
if [ ! -f "$file_one" ] || [ ! -s "$file_one" ]; then
    echo "ERROR: First file download failed or resulted in empty file."
    echo "URL: $url1"
    exit 1
fi

echo "✓ First file downloaded successfully ($(stat -c%s "$file_one") bytes)"

# Download the second file from URL  
echo "Downloading second file from: $url2"
if ! curl -L -f -s -S -o "$file_two" "$url2"; then
    echo "ERROR: Failed to download second file from: $url2"  
    echo "Please verify the URL is correct and accessible."
    exit 1
fi

# Verify second file was downloaded successfully
if [ ! -f "$file_two" ] || [ ! -s "$file_two" ]; then
    echo "ERROR: Second file download failed or resulted in empty file."
    echo "URL: $url2"
    exit 1
fi

echo "✓ Second file downloaded successfully ($(stat -c%s "$file_two") bytes)"
echo ""

# Perform fuzzy hash comparison
echo "Performing fuzzy hash comparison..."
echo "Comparing URLs: $url1 and $url2"
echo ""

# Run ssdeep comparison and capture output
echo "Fuzzy hash comparison result:"
ssdeep -d "$file_one" "$file_two"

echo ""
echo "Interpretation:"
echo "  0-25:   Files are very different"
echo "  26-50:  Files have some similarities"  
echo "  51-75:  Files are quite similar"
echo "  76-99:  Files are very similar"
echo "  100:    Files are identical"
echo ""
echo "NOTE: Similarity does not guarantee the files are related."
echo "Manual examination is required to verify any potential matches."

# Cleanup is handled automatically by the EXIT trap

