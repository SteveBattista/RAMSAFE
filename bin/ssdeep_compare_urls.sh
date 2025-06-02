#bin/bash
# This script computes the ssdeep hash of two images and compares them
# Usage: ./ssdeep_compare.sh image1.jpg image2.jpg
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <image1> <image2>"
    exit 1
fi

# Check if ssdeep is installed
if ! command -v ssdeep &> /dev/null; then
    echo "ssdeep could not be found. Please install it to use this script."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "curl could not be found. Please install it to use this script."
    exit 1
fi

# Download the first file from the URL
file_one=$(mktemp)
file_two=$(mktemp)
echo "Downloading $1"
if ! curl -o "$file_one" "$1"; then
    echo "First file failed to download from $1"
    exit 1
fi
# Check if the file was downloaded successfully
if [ ! -f "$file_one" ]; then
    echo "First file download failed or file does not exist."
    exit 1
fi

echo "Downloading $2"
# Download the first file from the URL
if ! curl -o "$file_two" "$1"; then
    echo "Second file failed to download from $2"
    exit 1
fi
# Check if the file was downloaded successfully
if [ ! -f "$file_two" ]; then
    echo "Second file download failed or file does not exist."
    exit 1
fi
# Compute the ssdeep hashes of the images
# and save them to the specified output files
# Compare the two ssdeep hashes
echo "Comparing links $1 and $2"
ssdeep -d "$file_one" "$file_two"
shred -f -z shred -f -z "$file_one" "$file_two"

