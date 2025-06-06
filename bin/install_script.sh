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
#Need to remove auto installer thing for ubuntu
systemctl disable ubiquity
#clean up
sudo apt autoremove -y
#set wallpaper
gsettings set org.gnome.desktop.background picture-uri 'file:///install/RAMSAFE/ramsafe_wallpaper.png'
#move wallpaper to correct location
mv ramsafe_wallpaper.png /usr/share/ramsafe_wallpaper.png
echo 'export PATH="/install/RAMSAFE/bin:$PATH"' >> ~/.bashrc
#set icons on left
gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.eog.desktop', 'vlc.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"

