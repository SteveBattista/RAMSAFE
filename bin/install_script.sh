#!/bin/bash
# This script installs the necessary dependencies for the project.
# It is intended to be run on a fresh Ubuntu 22.04 installation.
#install items
apt install curl pv jq ssdeep exiftool vlc fish -y
# update and upgrade
apt update && apt upgrade -y
# remove items 
apt remove cups thunderbird -y
#clean up
apt autoremove -y
# move desktop graphics item 
echo 'export PATH="/install/RAMSAFE/bin:$PATH"' >> ~/.bashrc
#apt autoremove --purge snapd
apt autoremove --purge -y "?name(libreoffice)"
apt autoremove --purge -y "?name(thunderbird)"
apt autoremove --purge -y "?name(shotwell)"



