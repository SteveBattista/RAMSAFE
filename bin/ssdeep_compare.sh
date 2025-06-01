#bin/bash
# This script computes the ssdeep hash of two images and compares them
# Usage: ./ssdeep_compare.sh image1.jpg image2.jpg
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <image1> <image2>"
    exit 1
fi
output_file_one=$(mktemp)
file_two=$2
# Check if ssdeep is installed
if ! command -v ssdeep &> /dev/null; then
    echo "ssdeep could not be found. Please install it to use this script."
    exit 1
fi
# Compute the ssdeep hashes of the images
# and save them to the specified output files
ssdeep $1 > '$output_file_one'
# Compare the two ssdeep hashes
echo "Comparing hashes of $1 and $2:"
ssdeep -b -m '$output_file_one' $file_two
# Clean up the temporary file
rm -f '$output_file_one'