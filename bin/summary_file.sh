#!/bin/bash
#
# RAMSAFE File Evidence Summary Generator
#
# This script generates a comprehensive forensic analysis report for a local file.
# It extracts multiple types of evidence including hashes, metadata, timestamps,
# and allows for examiner documentation. Output is in JSON format for easy
# integration with case management systems.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Generate standardized forensic reports for evidence files
# USAGE: ./summary_file.sh <file_path>
# OUTPUT: JSON-formatted forensic analysis report
#
# EVIDENCE COLLECTED:
# - File size and timestamps
# - SHA-256 cryptographic hash (for exact identification)
# - ssdeep fuzzy hash (for similarity analysis)  
# - EXIF metadata (GPS, camera info, etc.)
# - Examiner identification and notes
# - Source URL documentation
#
# LEGAL USE: Output suitable for court documentation and chain of custody
#

# Load RAMSAFE utility library
source "$(dirname "${BASH_SOURCE[0]}")/ramsafe_utils.sh"

# Ensure exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "❌ ERROR: Incorrect number of arguments provided."
    echo "📋 Usage: $0 <file_path>"
    echo ""
    echo "📝 Examples:"
    echo "  $0 /path/to/evidence.jpg"
    echo "  $0 ../images/suspicious_file.png"
    echo "  $0 ~/Downloads/evidence_file.pdf"
    echo ""
    echo "📊 This tool generates a comprehensive forensic analysis report"
    echo "🗂️ for the specified file in JSON format."
    exit $EXIT_INVALID_ARGS
fi

# Validate and store the input file path
file=$(validate_file_path "$1")

# Verify required tools are installed
check_dependencies "jq" "ssdeep" "stat" "sha256sum" "date"

echo "🔍========================================="
echo "📊 RAMSAFE File Evidence Summary Generator"
echo "🔍========================================="
echo "🗂️ Analyzing file: $file"
echo "⏰ Analysis started: $(date)"
echo ""

# Extract file metadata using stat command
echo "📋 Extracting file metadata..."

# Get exact file size in bytes (important for verification)
file_size=$(stat -c%s "$file")

# Get file save/creation date (when file was created on this filesystem)
file_save_date=$(stat -c%y "$file")

# Get file modification date (when file content was last changed)  
file_modified_date=$(stat -c%z "$file")

echo "✅ File size: $file_size bytes"
echo "✅ Save date: $file_save_date" 
echo "✅ Modified date: $file_modified_date"

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

# Get source URL where file was obtained (important for provenance)
while true; do
    read -p "🔗 Enter the source URL where this file was obtained: " file_link
    if [ -n "$file_link" ]; then
        if file_link=$(validate_url "$file_link" 2>/dev/null); then
            break
        else
            echo "⚠️ Invalid URL format. Please enter a valid HTTP/HTTPS URL."
        fi
    else
        echo "⚠️ Source URL is required for evidence documentation."
    fi
done

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
    --arg file_link "$file_link" \
    --arg runtime "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg file_path "$file" \
    --arg file_size "$file_size" \
    --arg file_save_date "$file_save_date" \
    --arg file_modified_date "$file_modified_date" \
    --arg file_sha256 "$file_sha256" \
    --arg file_ssdeep "$file_ssdeep" \
    --argjson file_exif "$file_exif" \
    --arg examiner_identifier "$examiner_identifier" \
    --arg file_notes "$file_notes" \
    --arg tool_version "RAMSAFE File Summary v1.0" \
    '{
        report_type: "RAMSAFE_file_analysis",
        tool_version: $tool_version,
        analysis_timestamp: $runtime,
        source_information: {
            source_url: $file_link,
            local_file_path: $file_path
        },
        file_properties: {
            size_bytes: ($file_size | tonumber),
            save_date: $file_save_date,
            modified_date: $file_modified_date
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