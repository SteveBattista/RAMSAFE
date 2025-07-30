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
# USAGE: ./verify_iso.sh [OPTIONS] <iso_file_path>
#
# Options:
#   -h, --hash HASH    Specify custom expected SHA256 hash
#   --help             Show this help message
#
# Examples: 
#   ./verify_iso.sh ~/Downloads/ramsafe.iso
#   ./verify_iso.sh --hash abc123... ~/Downloads/custom.iso
#

# Exit on any error for safer script execution
set -e

# Default expected SHA256 hash for authentic RAMSAFE ISO
default_expected="121167d6b7c5375cd898c717edd8cb289385367ef8aeda13bf4ed095b7065b0d"
expected=""
iso_path=""

# Function to show usage information
show_usage() {
    echo "❓ Usage: $0 [OPTIONS] <iso_file_path>"
    echo ""
    echo "📋 Options:"
    echo "  -h, --hash HASH    Specify custom expected SHA256 hash"
    echo "  --help             Show this help message"
    echo ""
    echo "📝 Examples:"
    echo "  $0 ~/Downloads/ramsafe.iso"
    echo "  $0 --hash abc123def456... ~/Downloads/custom.iso"
    echo "  $0 -h 121167d6b7c5375cd898c717edd8cb289385367ef8aeda13bf4ed095b7065b0d ~/Downloads/ramsafe.iso"
    echo ""
    echo "🔍 This script verifies the SHA256 hash of an ISO file."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--hash)
            expected="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        -*)
            echo "❌ ERROR: Unknown option $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$iso_path" ]; then
                iso_path="$1"
            else
                echo "❌ ERROR: Multiple file paths provided"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if file path is provided
if [ -z "$iso_path" ]; then
    echo "❌ ERROR: No ISO file path provided."
    show_usage
    exit 1
fi

# Use default hash if none specified

if [ -z "$expected" ]; then
    expected="$default_expected"
    echo "💡 Using default RAMSAFE hash for verification"
    echo "⚠️  WARNING: Always double check the expected hash value from an official source."
    echo "   Do not trust this script's built-in hash unless you have verified it yourself."
else
    echo "🔧 Using custom hash for verification"
fi

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

# Validate hash format (should be 64 hexadecimal characters)
if ! echo "$expected" | grep -qE '^[a-fA-F0-9]{64}$'; then
    echo "❌ ERROR: Invalid hash format"
    echo "Expected SHA256 hash should be 64 hexadecimal characters"
    echo "Provided: $expected"
    exit 1
fi

echo "🔍 Verifying ISO integrity..."
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
