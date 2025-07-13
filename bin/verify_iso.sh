#!/bin/bash
#
# RAMSAFE ISO Verification Script (Bash)
# 
# This script verifies the SHA256 hash of the RAMSAFE ISO file to ensure
# it hasn't been tampered with or corrupted during download.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Verify integrity of RAMSAFE ISO file
# REQUIREMENTS: bash, sha256sum utility, RAMSAFE ISO file
# USAGE: ./verify_iso.sh /path/to/ramsafe.iso
#
# Example: ./verify_iso.sh ~/Downloads/ramsafe.iso
#

# Exit on any error for safer script execution
set -e

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "❌ ERROR: Incorrect number of arguments provided."
    echo "Usage: $0 <iso_file_path>"
    echo ""
    echo "Examples:"
    echo "  $0 ~/Downloads/ramsafe.iso"
    echo "  $0 /path/to/ramsafe.iso"
    echo ""
    echo "This script verifies the SHA256 hash of the RAMSAFE ISO file."
    exit 1
fi

# Store the input file path
iso_path="$1"

# Expected SHA256 hash for authentic RAMSAFE ISO
expected="121167d6b7c5375cd898c717edd8cb289385367ef8aeda13bf4ed095b7065b0d"

# Check if the file exists and is readable
if [ ! -f "$iso_path" ]; then
    echo "❌ ERROR: File not found or not readable: $iso_path"
    echo "Please check the file path and try again."
    exit 1
fi

# Check if sha256sum is available
if ! command -v sha256sum &> /dev/null; then
    echo "❌ ERROR: sha256sum command not found."
    echo "Please install the coreutils package or use a different verification method."
    exit 1
fi

echo "🔍 Verifying RAMSAFE ISO integrity..."
echo "📁 File: $iso_path"

# Calculate the SHA256 hash of the provided file
calculated=$(sha256sum "$iso_path" | cut -d' ' -f1)

echo "🎯 Expected:   $expected"
echo "🧮 Calculated: $calculated"

# Compare the calculated hash with the expected hash
if [ "$calculated" = "$expected" ]; then
    echo "✅ VERIFICATION PASSED - ISO is authentic and safe to use"
    echo "🚀 You can proceed with creating the RAMSAFE USB drive"
    exit 0
else
    echo "❌ VERIFICATION FAILED - DO NOT USE THIS ISO"
    echo "⚠️  The file may be corrupted or tampered with"
    echo "💡 Please re-download the ISO from the official source"
    exit 1
fi
