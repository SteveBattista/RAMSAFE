#!/bin/bash
#set wallpaper
gsettings set org.gnome.desktop.background picture-uri 'file:///install/RAMSAFE/ramsafe_wallpaper.png'
#set icons on left
gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.eog.desktop', 'vlc.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"
# remove an icon from the desktop
gsettings set org.gnome.shell.extensions.desktop-icons ubuntu-desktop-bootstrap_ubuntu-desktop-bootstrap.desktop false
# don't auto start ubuntu-desktop-bootstrap.desktop when starting the GUI
sudo snap stop ubuntu-desktop-bootstrap
sudo snap disable ubuntu-desktop-bootstrap
# remove ubuntu-desktop-bootstrap icon from the desktop
