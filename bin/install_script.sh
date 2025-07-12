#!/bin/bash
#
# RAMSAFE Installation Script
# 
# This script sets up the RAMSAFE (RAM-based Secure Analysis Forensics Environment)
# by installing required packages, removing unnecessary software, and configuring
# the system for forensic analysis use.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Prepare Ubuntu system for RAMSAFE live environment
# REQUIREMENTS: Fresh Ubuntu 22.04 installation with root privileges
# USAGE: Run this script during the Cubic build process in the chroot environment
#
# WARNING: This script makes system-wide changes and should only be run
#          in a controlled build environment, not on production systems.
#

# Exit on any error for safer script execution
set -e

echo "********** Installing Required RAMSAFE Tools **********"
# Install essential tools for digital forensics and analysis
# curl: Download files from URLs
# pv: Progress viewer for data transfer operations  
# jq: JSON processor for structured data handling
# ssdeep: Fuzzy hashing tool for comparing similar files
# exiftool: Extract metadata from images and other files
# vlc: Video player for multimedia analysis
# fish: Modern shell with user-friendly features
apt install curl pv jq ssdeep exiftool vlc fish -y

echo "********** Removing Unnecessary Software **********" 
# Remove software not needed for forensic analysis to reduce ISO size
# and eliminate potential security/privacy concerns

# Remove CUPS printing system (not needed for forensics)
apt remove cups thunderbird -y

# Remove LibreOffice suite (reduces ISO size significantly)
apt autoremove --purge -y "?name(libreoffice)"

# Remove Ubuntu desktop bootstrap (cleanup)
apt autoremove --purge -y "?name(ubuntu-desktop-bootstrap)"

# Remove Thunderbird email client (redundant removal for safety)
apt autoremove --purge -y "?name(thunderbird)"

echo "********** Updating System Packages **********"
# Ensure all installed packages are up to date for security
apt update && apt upgrade -y

echo "********** Cleaning Up Package Cache **********"
# Remove orphaned packages and clean up to reduce ISO size
apt autoremove -y

echo "********** Configuring RAMSAFE Tools PATH **********"
# Add RAMSAFE binary directory to system PATH so tools are available
# from anywhere in the terminal
echo 'export PATH="/install/RAMSAFE/bin:$PATH"' >> ~/.bashrc

echo "********** Setting Up Boot Configuration **********"
# Add on_boot.sh script to run automatically when users log in
# This configures the desktop environment with RAMSAFE settings
# /etc/skel/.profile affects all new user accounts created
cat /install/RAMSAFE/bin/on_boot.sh >>  /etc/skel/.profile

echo "********** RAMSAFE Installation Complete **********"
echo "The system is now configured for RAMSAFE forensic analysis."
echo "All required tools have been installed and the environment is ready."




