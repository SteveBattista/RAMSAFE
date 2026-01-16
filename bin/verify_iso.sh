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

# Load RAMSAFE utility library
source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"

# Default expected SHA256 hash for authentic RAMSAFE ISO
default_expected="2d2348d3aeca13fa4741e708ba80a31bcde58417683af945aa6da3d38e0bdb02"
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
    echo "  $0 -h 2d2348d3aeca13fa4741e708ba80a31bcde58417683af945aa6da3d38e0bdb02 ~/Downloads/ramsafe.iso"
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
            exit $EXIT_SUCCESS
            ;;
        -*)
            die $EXIT_INVALID_ARGS "Unknown option: $1"
            ;;
        *)
            if [ -z "$iso_path" ]; then
                iso_path="$1"
            else
                die $EXIT_INVALID_ARGS "Multiple file paths provided"
            fi
            shift
            ;;
    esac
done

# Check if file path is provided
if [ -z "$iso_path" ]; then
    echo "❌ ERROR: No ISO file path provided."
    show_usage
    exit $EXIT_INVALID_ARGS
fi

# Use default hash if none specified
if [ -z "$expected" ]; then
    expected="$default_expected"
    log_info "Using default RAMSAFE hash for verification"
    log_warn "Always double check the expected hash value from an official source."
else
    log_info "Using custom hash for verification"
fi

# Validate the ISO file path
iso_path=$(validate_file_path "$iso_path")

# Check dependencies
check_dependencies "sha256sum"

# Validate hash format
expected=$(validate_hash "$expected" "sha256")

echo "🔍 Verifying ISO integrity..."
echo "📁 File: $iso_path"

# Calculate the SHA256 hash of the provided file
calculated=$(sha256sum "$iso_path" | cut -d' ' -f1)

echo "🎯 Expected:   $expected"
echo "🧮 Calculated: $calculated"

# Compare the calculated hash with the expected hash
if [ "$calculated" = "$expected" ]; then
    log_info "VERIFICATION PASSED - ISO is authentic and safe to use"
    log_info "You can proceed with creating the RAMSAFE USB drive"
    exit $EXIT_SUCCESS
else
    log_error "VERIFICATION FAILED - DO NOT USE THIS ISO"
    log_error "The file may be corrupted or tampered with"
    log_error "Please re-download the ISO from the official source"
    exit $EXIT_VALIDATION_FAILED
fi
