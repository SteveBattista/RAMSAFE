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

# Exit on any error for safer script execution
set -e

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
    exit 1
fi

# Store the input URL
url="$1"

# Verify required tools are installed
if ! command -v jq &> /dev/null; then
    echo "❌ ERROR: jq tool not found."
    echo "🔧 jq is required for JSON processing but is not installed."
    echo "💡 Please install jq to use this script:"
    echo "  sudo apt install jq"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "❌ ERROR: curl tool not found."
    echo "🌐 curl is required for downloading files but is not installed."
    echo "💡 Please install curl to use this script:"
    echo "  sudo apt install curl"
    exit 1
fi

if ! command -v ssdeep &> /dev/null; then
    echo "❌ ERROR: ssdeep tool not found."
    echo "🔧 ssdeep is required for fuzzy hashing but is not installed."
    echo "💡 Please install ssdeep to use this script:"
    echo "  sudo apt install ssdeep"
    exit 1
fi

echo "🌐========================================="
echo "📊 RAMSAFE URL Evidence Summary Generator"
echo "🌐========================================="
echo "🔗 Target URL: $url"
echo "⏰ Analysis started: $(date)"
echo ""

# Create secure temporary file for download
file=$(mktemp)

# Set up cleanup function to securely remove temporary file
cleanup() {
    echo "🧹 Cleaning up temporary files..."
    if [ -f "$file" ]; then
        # Use shred to securely overwrite the temporary file
        # This prevents recovery of potentially sensitive evidence
        shred -f -z -u "$file" 2>/dev/null || rm -f "$file"
    fi
}

# Ensure cleanup happens even if script is interrupted
trap cleanup EXIT

# Download the file from the URL
echo "⬇️ Downloading file from URL..."
echo "🔗 Source: $url"

if ! curl -L -f -s -S -o "$file" "$url"; then
    echo "❌ ERROR: Failed to download file from URL: $url"
    echo "🔍 Please verify the URL is correct and accessible."
    exit 1
fi

# Verify file was downloaded successfully
if [ ! -f "$file" ] || [ ! -s "$file" ]; then
    echo "❌ ERROR: File download failed or resulted in empty file."
    echo "🔗 URL: $url"
    exit 1
fi

echo "✅ File downloaded successfully ($(stat -c%s "$file") bytes)"

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
while [ -z "$examiner_identifier" ]; do
    echo "⚠️ Examiner identification is required for evidence documentation."
    read -p "👤 Enter examiner identifier (name, badge, email): " examiner_identifier
done

# Get any additional notes about the analysis
read -p "📝 Enter analysis notes (optional): " file_notes

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