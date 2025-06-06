#!/bin/bash
#set wallpaper
gsettings set org.gnome.desktop.background picture-uri 'file:///install/RAMSAFE/ramsafe_wallpaper.png'
#set icons on left
gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.eog.desktop', 'vlc.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"
#Stop auto start of gnome Ubuquity installer
systemctl stop ubiquity
#Remove auto start of gnome Ubiquity installer
systemctl disable ubiquity
