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

# Load RAMSAFE utility library
# shellcheck disable=SC1091
source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"

# Ensure exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "❌ ERROR: Incorrect number of arguments provided."
    echo "📋 Usage: $0 <file1> <file2>"
    echo ""
    echo "📝 Examples:"
    echo "  $0 evidence1.jpg evidence2.jpg"
    echo "  $0 /path/to/image1.png /path/to/image2.png"
    echo ""
    echo "🔍 This tool compares two files using fuzzy hashing to detect similarity."
    echo "📊 Output shows a similarity score from 0 (completely different) to 100 (identical)."
    exit $EXIT_INVALID_ARGS
fi

# Check dependencies
check_dependencies "ssdeep"

# Validate input file paths
file1=$(validate_file_path "$1")
file2=$(validate_file_path "$2")

# Display what we're comparing for user confirmation
log_info "Comparing files using ssdeep fuzzy hashing:"
log_info "  File 1: $file1"
log_info "  File 2: $file2"
echo ""

# Perform the fuzzy hash comparison
# The -d flag tells ssdeep to compare the files and show similarity score
# Output format: "file1 matches file2 (score)" where score is 0-100
log_info "Fuzzy hash comparison result:"
ssdeep -d "$file1" "$file2"

echo ""
log_info "Interpretation:"
log_info "  🔴 0-25:   Files are very different"  
log_info "  🟡 26-50:  Files have some similarities"
log_info "  🟠 51-75:  Files are quite similar"
log_info "  🟢 76-99:  Files are very similar" 
log_info "  ✅ 100:    Files are identical"
echo ""
log_warn "Similarity does not guarantee the files are related."
log_warn "Manual examination is required to verify any potential matches."

