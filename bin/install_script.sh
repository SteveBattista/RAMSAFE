#!/bin/bash
# This script installs the necessary dependencies for the project.
# It is intended to be run on a fresh Ubuntu 22.04 installation.
#install curl
sudo apt install curl -y
#install pv
sudo apt install pv -y
#install jq
sudo apt install jq -y
#install ssdeep
sudo apt install ssdeep -y
#install exiftool
sudo apt install exiftool -y
#add vlc
sudo apt install vlc -y
#add fish shell
sudo apt install fish -y
#remove rythmbox (audio player)
sudo apt remove rhythmbox -y
#remove libreoffice
sudo apt remove libreoffice -y
#remove printing
sudo apt remove cups -y
#remove gnome games
sudo apt remove gnome-games -y
#remove gnome chess
sudo apt remove gnome-chess -y
#update and upgrade
sudo apt update && apt upgrade -y
#clean up
sudo apt autoremove -y
mv ramsafe_wallpaper.png /usr/share/ramsafe_wallpaper.png
echo 'export PATH="/install/RAMSAFE/bin:$PATH"' >> ~/.bashrc
line="@reboot /install/RAMSAFE/bin/on_boot.sh"
(crontab -u root -l; echo "$line" ) | crontab -u root -


