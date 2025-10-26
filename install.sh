#!/bin/bash

cd /tmp

sudo pacman -S --needed git base-devel

# Install YAY
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

# Install LinuxToys
curl -fsSL https://linux.toys/install.sh | sh

# Install Nord Icons Themes
git clone https://github.com/alvatip/Nordzy-icon
cd Nordzy-icon
./install.sh
cd ..

# INSTALL WITH YAY
yay -Sy brave-bin
