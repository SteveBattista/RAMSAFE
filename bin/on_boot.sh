#!/bin/bash
#
# RAMSAFE Desktop Configuration Script
#
# This script configures the GNOME desktop environment for RAMSAFE users
# by setting appropriate wallpapers and taskbar shortcuts for forensic tools.
# It runs automatically when a user logs into the RAMSAFE environment.
#
# AUTHOR: RAMSAFE Project Team  
# PURPOSE: Configure desktop environment for forensic analysis workflow
# USAGE: Automatically executed via /etc/skel/.profile on user login
#

# Set RAMSAFE wallpaper as desktop background
# This provides visual confirmation that the user is in the RAMSAFE environment
# The wallpaper file should be located in the RAMSAFE installation directory
gsettings set org.gnome.desktop.background picture-uri 'file:///install/RAMSAFE/ramsafe_wallpaper.png'

# Configure GNOME Shell taskbar with forensic analysis tools
# This creates a convenient toolbar with the most commonly used applications
# for digital forensics and evidence analysis work
#
# Applications in order:
# 1. Firefox - Secure web browsing and evidence collection
# 2. Eye of GNOME (eog) - Image viewer for examining evidence files  
# 3. VLC - Video player for multimedia evidence analysis
# 4. Text Editor - Note-taking and documentation
# 5. Nautilus - File manager for evidence organization
# 6. Terminal - Command-line access to forensic tools
gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.eog.desktop', 'vlc.desktop', 'org.gnome.TextEditor.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"

# Note: Additional desktop configurations can be added here as needed
# Examples: keyboard shortcuts, security settings, privacy configurations

