#!/bin/bash
# This script installs the necessary dependencies for the project.
# It is intended to be run on a fresh Ubuntu 22.04 installation.
echo ********** Installing items **********
apt install curl pv jq ssdeep exiftool vlc fish -y
echo ********** Removing items  **********
apt remove cups thunderbird -y
apt autoremove --purge -y "?name(libreoffice)"
apt autoremove --purge -y "?name(ubuntu-desktop-bootstrap)"
apt autoremove --purge -y "?name(thunderbird)"
echo ********** Update and upgrade **********
apt update && apt upgrade -y
echo ********** Clean up **********
apt autoremove -y
echo ********** Add tools to PATH **********
echo 'export PATH="/install/RAMSAFE/bin:$PATH"' >> ~/.bashrc
echo **********  Add on_boot.sh to /etc/skel/.profile **********
cat /install/RAMSAFE/bin/on_boot.sh >>  /etc/skel/.profile




