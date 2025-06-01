#!/bin/bash
# this script takes a file as input and outputs a summary of the file
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <url>"
    exit 1
fi
url=$1
#check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Please install it to use this script."
    exit 1
fi
#check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl could not be found. Please install it to use this script."
    exit 1
fi
# Download the file from the URL
file=$(mktemp)
if ! curl -o "$file" "$url"; then
    echo "Failed to download the file from $url"
    exit 1
fi
# Check if the file was downloaded successfully
if [ ! -f "$file" ]; then
    echo "File download failed or file does not exist."
    exit 1
fi
# Get the file size
file_size=$(stat -c%s "$file")
header=$(curl -s --head "$url")
file_sha256=$(sha256sum "$file" | awk '{ print $1 }')
#get the ssdeep hash of the file
if ! command -v ssdeep &> /dev/null; then
    echo "ssdeep could not be found. Please install it to use this script."
    exit 1
fi
file_ssdeep=$(ssdeep "$file" | awk '{ print $1 }')
# Get the exif data of the file
if command -v exiftool &> /dev/null; then
    file_exif=$(exiftool "$file")
else
    echo "exiftool could not be found. Skipping EXIF data extraction."
    file_exif="EXIF data extraction skipped."
fi
#ask the user for examiner identifier
read -p "Enter a string that identifies you: " examiner_identifier
# ask the user to add notes about the file
read -p "Enter any notes about the file: " file_notes
# Output the summary
json_string=$(jq -n \
    --arg url "$url" \
    --arg runtime "$(date -u +%Y-%m-%dT%H:%M:%S)" \
    --arg header "$header" \
    --arg file_size "$file_size" \
    --arg file_sha256 "$file_sha256" \
    --arg file_ssdeep "$file_ssdeep" \
    --arg file_exif "$file_exif" \
    --arg examiner_identifier "$examiner_identifier" \
    --arg file_notes "$file_notes" \
    '{
        link: $url,
        runtime: $runtime,
        header: $header,
        file_size: $file_size,
        sha256: $file_sha256,
        ssdeep: $file_ssdeep,
        exif: $file_exif,
        examiner_identifier: $examiner_identifier,
        examiner_notes: $file_notes
    }'
)
echo "$json_string" | jq .
# Clean up the temporary file
rm -f "$file"