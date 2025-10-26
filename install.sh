#!/bin/bash

sudo pacman -S --needed git base-devel neovim swww stow xdg-user-dirs rofi waybar xdg-desktop-portal-kde xdg-desktop-portal-gtk pavucontrol power-profiles-daemon hyprpicker dunst feh nwg-look lxappearance zsh networkmanager network-manager-applet
xdg-user-dirs-update

echo "export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share" >> ~/.bashrc

stow hyprland kitty nvim rofi scripts themes wallpapers waybar

mkdir ~/Imagens/Wallpapers -p

sudo systemctl enable NetworkManager

cd /tmp
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
#yay -Sy brave-bin
# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
# Install OhMyZsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share" >> ~/.zshrc
# Install Graphite-gtk-theme
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git 
cd Graphite-gtk-theme/
./install.sh -c dark -s standard -s compact -l --tweaks nord rimless
cd ..
# Install Nordzy-icon
git clone https://github.com/alvatip/Nordzy-icon 
cd Nordzy-icon/
./install.sh 
cd ..

cd 
