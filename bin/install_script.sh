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
mv /install/RAMSAFE/graphics_update.service /etc/systemd/system/



