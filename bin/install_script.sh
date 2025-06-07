#!/bin/bash
# This script installs the necessary dependencies for the project.
# It is intended to be run on a fresh Ubuntu 22.04 installation.
#install items
sudo apt install curl pv jq ssdeep exiftool vlc fish gstreamer0.10-ffmpeg gstreamer0.10-plugins-ugly gstreamer0.10-plugins-bad gstreamer0.10-bad-multiverse -y
# remove items 
sudo apt remove rhythmbox libreoffice cups apt remove gnome-games remove gnome-chess -y
#update and upgrade
sudo apt update && apt upgrade -y
#clean up
sudo apt autoremove -y
echo 'export PATH="/install/RAMSAFE/bin:$PATH"' >> ~/.bashrc
line="@reboot /install/RAMSAFE/bin/on_boot.sh"
 echo "$line"  | crontab -u root -


