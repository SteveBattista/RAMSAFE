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

# Load RAMSAFE utility library
source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"

# Ensure exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "❌ ERROR: Incorrect number of arguments provided."
    echo "📋 Usage: $0 <url1> <url2>"
    echo ""
    echo "📝 Examples:"
    echo "  $0 https://example.com/image1.jpg https://example.com/image2.jpg"
    echo "  $0 'https://site1.com/file.png' 'https://site2.com/file.png'"
    echo ""
    echo "🌐 This tool downloads files from two URLs and compares them using"
    echo "🔍 fuzzy hashing to detect similarity between the files."
    exit $EXIT_INVALID_ARGS
fi

# Check dependencies
check_dependencies "ssdeep" "curl"

# Validate input URLs
url1=$(validate_url "$1")
url2=$(validate_url "$2")

# Create secure temporary files for downloads
file_one=$(create_temp_file)
file_two=$(create_temp_file)

# Set up cleanup function to securely remove temporary files
cleanup() {
    log_info "Cleaning up temporary files..."
    secure_delete "$file_one"
    secure_delete "$file_two"
}

# Ensure cleanup happens even if script is interrupted
trap cleanup EXIT

log_info "Downloading and comparing files from URLs:"
log_info "  URL 1: $url1"  
log_info "  URL 2: $url2"
echo ""

# Download the first file from URL
log_info "Downloading first file from: $url1"
secure_download "$url1" "$file_one"

# Verify first file was downloaded successfully
file_size=$(stat -f%z "$file_one" 2>/dev/null || stat -c%s "$file_one" 2>/dev/null)
log_info "First file downloaded successfully ($file_size bytes)"

# Download the second file from URL  
log_info "Downloading second file from: $url2"
secure_download "$url2" "$file_two"

# Verify second file was downloaded successfully
file_size=$(stat -f%z "$file_two" 2>/dev/null || stat -c%s "$file_two" 2>/dev/null)
log_info "Second file downloaded successfully ($file_size bytes)"
echo ""

# Perform fuzzy hash comparison
echo "🔍 Performing fuzzy hash comparison..."
echo "🌐 Comparing URLs: $url1 and $url2"
echo ""

# Run ssdeep comparison and capture output
echo "📊 Fuzzy hash comparison result:"
ssdeep -d "$file_one" "$file_two"

echo ""
echo "📈 Interpretation:"
echo "  🔴 0-25:   Files are very different"
echo "  🟡 26-50:  Files have some similarities"  
echo "  🟠 51-75:  Files are quite similar"
echo "  🟢 76-99:  Files are very similar"
echo "  ✅ 100:    Files are identical"
echo ""
echo "⚠️ NOTE: Similarity does not guarantee the files are related."
echo "🔍 Manual examination is required to verify any potential matches."

# Cleanup is handled automatically by the EXIT trap

