#!/bin/bash
#
# RAMSAFE URL Evidence Summary Generator
#
# This script downloads a file from a URL and generates a comprehensive
# forensic analysis report. It extracts multiple types of evidence including
# hashes, HTTP headers, metadata, and allows for examiner documentation.
# Output is in JSON format for easy integration with case management systems.
#
# AUTHOR: RAMSAFE Project Team  
# PURPOSE: Generate standardized forensic reports for web-hosted evidence
# USAGE: ./summary_url.sh <url>
# OUTPUT: JSON-formatted forensic analysis report
#
# EVIDENCE COLLECTED:
# - HTTP headers and response metadata
# - File size and download timestamp
# - SHA-256 cryptographic hash (for exact identification)
# - ssdeep fuzzy hash (for similarity analysis)
# - EXIF metadata (GPS, camera info, etc.)
# - Examiner identification and notes
#
# SECURITY FEATURES:
# - Downloads to temporary file in RAM (when run in RAMSAFE)
# - Securely shreds temporary file after analysis
# - Validates download before processing
#
# LEGAL USE: Output suitable for court documentation and chain of custody
#

# Load RAMSAFE utility library
source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"

# Ensure exactly one argument is provided  
if [ "$#" -ne 1 ]; then
    echo "❌ ERROR: Incorrect number of arguments provided."
    echo "📋 Usage: $0 <url>"
    echo ""
    echo "📝 Examples:"
    echo "  $0 https://example.com/evidence.jpg"
    echo "  $0 'https://site.com/path/image.png'"
    echo "  $0 https://domain.org/files/document.pdf"
    echo ""
    echo "🌐 This tool downloads a file from the specified URL and generates"
    echo "📊 a comprehensive forensic analysis report in JSON format."
    exit $EXIT_INVALID_ARGS
fi

# Validate and store the input URL
url=$(validate_url "$1")

# Verify required tools are installed
check_dependencies "jq" "curl" "ssdeep" "stat" "sha256sum" "date"

echo "🌐========================================="
echo "📊 RAMSAFE URL Evidence Summary Generator"
echo "🌐========================================="
echo "🔗 Target URL: $url"
echo "⏰ Analysis started: $(date)"
echo ""

# Create secure temporary file for download
file=$(create_temp_file)

# Set up cleanup function to securely remove temporary file
cleanup() {
    log_info "Cleaning up temporary files..."
    secure_delete "$file"
}

# Ensure cleanup happens even if script is interrupted
trap cleanup EXIT

# Download the file from the URL
log_info "Downloading file from URL: $url"
secure_download "$url" "$file"

# Verify file was downloaded successfully
if [ ! -f "$file" ] || [ ! -s "$file" ]; then
    die $EXIT_NETWORK_ERROR "File download failed or resulted in empty file from: $url"
fi

file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
log_info "File downloaded successfully ($file_size bytes)"

# Get HTTP headers for additional evidence
echo "📡 Retrieving HTTP headers..."
header=$(curl -s -L -I "$url" | tr -d '\r')
echo "✅ HTTP headers retrieved"

# Extract file metadata
echo "📋 Extracting file metadata..."
file_size=$(stat -c%s "$file")
download_timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "✅ File size: $file_size bytes"
echo "✅ Download time: $download_timestamp"

# Generate cryptographic hash for exact file identification
echo "🔐 Generating cryptographic hash..."
file_sha256=$(sha256sum "$file" | awk '{ print $1 }')
echo "✅ SHA-256: $file_sha256"

# Generate fuzzy hash for similarity comparisons  
echo "🔍 Generating fuzzy hash..."
file_ssdeep=$(ssdeep "$file" | tail -n 1 | awk -F',' '{ print $1 }')
echo "✅ ssdeep: $file_ssdeep"

# Extract EXIF metadata if exiftool is available
echo "📷 Extracting EXIF metadata..."
if command -v exiftool &> /dev/null; then
    # Extract metadata as JSON for structured storage
    file_exif=$(exiftool -j "$file" | jq -c .)
    echo "✅ EXIF data extracted successfully"
else
    echo "⚠️ exiftool not found - EXIF data extraction skipped"
    file_exif="\"EXIF data extraction skipped - exiftool not available\""
fi

echo ""
echo "👤========================================="
echo "📝 Examiner Input Required"  
echo "👤========================================="

# Collect examiner information for chain of custody
echo "📋 Please provide the following information for the forensic report:"
echo ""

# Get examiner identification (for chain of custody)
while true; do
    read -p "👤 Enter examiner identifier (name, badge, email): " examiner_identifier
    if [ -n "$examiner_identifier" ]; then
        if examiner_identifier=$(validate_examiner_id "$examiner_identifier" 2>/dev/null); then
            break
        else
            echo "⚠️ Invalid examiner identifier format."
        fi
    else
        echo "⚠️ Examiner identification is required for evidence documentation."
    fi
done

# Get any additional notes about the analysis
read -p "📝 Enter analysis notes (optional): " file_notes
# Basic validation for notes (prevent injection)
if [ -n "$file_notes" ] && [[ "$file_notes" == *$'\0'* ]]; then
    die $EXIT_SECURITY_VIOLATION "Analysis notes contain null bytes"
fi

echo ""
echo "📊========================================="
echo "📄 Generating Forensic Report"
echo "📊========================================="

# Generate comprehensive JSON report using jq
# This ensures proper JSON formatting and escaping
json_string=$(jq -n \
    --arg url "$url" \
    --arg runtime "$download_timestamp" \
    --arg header "$header" \
    --arg file_size "$file_size" \
    --arg file_sha256 "$file_sha256" \
    --arg file_ssdeep "$file_ssdeep" \
    --argjson file_exif "$file_exif" \
    --arg examiner_identifier "$examiner_identifier" \
    --arg file_notes "$file_notes" \
    --arg tool_version "RAMSAFE URL Summary v1.0" \
    '{
        report_type: "RAMSAFE_url_analysis", 
        tool_version: $tool_version,
        analysis_timestamp: $runtime,
        source_information: {
            source_url: $url,
            http_headers: $header
        },
        file_properties: {
            size_bytes: ($file_size | tonumber),
            download_timestamp: $runtime
        },
        cryptographic_hashes: {
            sha256: $file_sha256,
            ssdeep_fuzzy: $file_ssdeep  
        },
        metadata: {
            exif_data: $file_exif
        },
        examiner_information: {
            examiner_id: $examiner_identifier,
            analysis_notes: $file_notes
        }
    }'
)

echo ""
echo "📄 FORENSIC ANALYSIS REPORT"
echo "📊========================"
echo "$json_string" | jq .

echo ""
echo "✅========================================="
echo "📋 Report Generation Complete"
echo "✅========================================="
echo "⏰ Analysis completed: $(date)"
echo "💾 This report can be copied and pasted into case management systems."
echo "⚠️ IMPORTANT: Save this report before rebooting - RAMSAFE data is not persistent!"

# Cleanup is handled automatically by the EXIT trap