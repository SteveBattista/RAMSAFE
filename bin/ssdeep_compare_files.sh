#!/bin/bash
#
# RAMSAFE File Fuzzy Hash Comparison Tool
#
# This script compares two local files using ssdeep fuzzy hashing to determine
# similarity. Fuzzy hashing allows detection of similar files even if they
# have been slightly modified (unlike traditional cryptographic hashes).
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Compare similarity between two files for forensic analysis
# USAGE: ./ssdeep_compare_files.sh <file1> <file2>
# OUTPUT: Similarity score (0-100, where 100 = identical files)
#
# FORENSIC USE CASES:
# - Detect modified versions of known CSAM files
# - Compare evidence files for similarity analysis  
# - Identify files that may be related despite different hashes
#
# IMPORTANT: A similarity score does NOT guarantee files are related.
# All matches should be manually examined for verification.
#

# Ensure exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "ERROR: Incorrect number of arguments provided."
    echo "Usage: $0 <file1> <file2>"
    echo ""
    echo "Examples:"
    echo "  $0 evidence1.jpg evidence2.jpg"
    echo "  $0 /path/to/image1.png /path/to/image2.png"
    echo ""
    echo "This tool compares two files using fuzzy hashing to detect similarity."
    echo "Output shows a similarity score from 0 (completely different) to 100 (identical)."
    exit 1
fi

# Verify ssdeep is installed and available
if ! command -v ssdeep &> /dev/null; then
    echo "ERROR: ssdeep tool not found."
    echo "ssdeep is required for fuzzy hash comparison but is not installed."
    echo "Please install ssdeep to use this script:"
    echo "  sudo apt install ssdeep"
    exit 1
fi

# Store input file paths
file1="$1"
file2="$2"

# Verify both input files exist and are readable
if [ ! -f "$file1" ]; then
    echo "ERROR: First file does not exist or is not readable: $file1"
    exit 1
fi

if [ ! -f "$file2" ]; then
    echo "ERROR: Second file does not exist or is not readable: $file2"
    exit 1
fi

# Display what we're comparing for user confirmation
echo "Comparing files using ssdeep fuzzy hashing:"
echo "  File 1: $file1"
echo "  File 2: $file2"
echo ""

# Perform the fuzzy hash comparison
# The -d flag tells ssdeep to compare the files and show similarity score
# Output format: "file1 matches file2 (score)" where score is 0-100
echo "Fuzzy hash comparison result:"
ssdeep -d "$file1" "$file2"

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

