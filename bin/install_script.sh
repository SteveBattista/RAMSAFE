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
sudo apt autoremove -y
git 
echo 'export PATH="/install/RAMSAFE/bin:$PATH"' >> ~/.bashrc
line="@reboot /install/RAMSAFE/bin/on_boot.sh"
 echo "$line"  | crontab -u root -


