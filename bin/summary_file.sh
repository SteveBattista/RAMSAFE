#!/bin/bash
# this script takes a file as input and outputs a summary of the file
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi
file=$1
# Check if the file exists
if [ ! -f "$file" ]; then
    echo "File not found!"
    exit 1
fi
#check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Please install it to use this script."
    exit 1
fi
# Get the file size
file_size=$(stat -c%s "$file")
#get the file save date
file_save_date=$(stat -c%y "$file")
# Get the file modified date
file_modified_date=$(stat -c%y "$file")
# get the sha256 hash of the file
file_sha256=$(sha256sum "$file" | awk '{ print $1 }')
#get the ssdeep hash of the file
if ! command -v ssdeep &> /dev/null; then
    echo "ssdeep could not be found. Please install it to use this script."
    exit 1
fi
file_ssdeep=$(ssdeep "$file" | awk '{ print $1 }')
# Get the exif data of the file
if command -v exiftool &> /dev/null; then
    file_exif=$(exiftool -j "$file")
else
    echo "exiftool could not be found. Skipping EXIF data extraction."
    file_exif="EXIF data extraction skipped."
fi
#ask the user for the link to the file
read -p "Enter the link to the file: " file_link
#ask the user for examiner identifier
read -p "Enter a string that identifies you: " examiner_identifier
# ask the user to add notes about the file
read -p "Enter any notes about the file: " file_notes
# Output the summary
json_string=$(jq -n \
    --arg file_link "$file_link" \
    --arg runtime "$(date -u +%Y-%m-%dT%H:%M:%S)" \
    --arg file "$file" \
    --arg file_size "$file_size" \
    --arg file_save_date "$file_save_date" \
    --arg file_modified_date "$file_modified_date" \
    --arg file_sha256 "$file_sha256" \
    --arg file_ssdeep "$file_ssdeep" \
    --arg file_exif "$file_exif" \
    --arg examiner_identifier "$examiner_identifier" \
    --arg file_notes "$file_notes" \
    '{
        link: $file_link,
        runtime: $runtime,
        file_name: $file,
        file_size: $file_size,
        save_date: $file_save_date,
        modified_date: $file_modified_date,
        sha256: $file_sha256,
        ssdeep: $file_ssdeep,
        exif: $file_exif,
        examiner_identifier: $examiner_identifier,
        examiner_notes: $file_notes
    }'
)
echo "$json_string" | jq .