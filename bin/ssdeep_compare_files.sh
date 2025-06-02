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
# Compute the ssdeep hashes of the images
# and save them to the specified output files
# Compare the two ssdeep hashes
ssdeep -d "$1" "$2"

