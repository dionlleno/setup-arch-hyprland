#!/bin/bash
set -e # Para o script se algo falhar

# ====================================================
#  🛠️  Funções auxiliares
# ====================================================
info() { echo -e "\n\033[1;34m[INFO]\033[0m $1\n"; }
success() { echo -e "\033[1;32m[✔]\033[0m $1"; }
error() { echo -e "\033[1;31m[✖]\033[0m $1"; }

# ====================================================
#  🔧 Instalação de pacotes principais
# ====================================================
info "Instalando pacotes base e utilitários..."

sudo pacman -Syu --needed --noconfirm git base-devel neovim swww stow \
	xdg-user-dirs rofi waybar xdg-desktop-portal-kde xdg-desktop-portal-gtk \
	pavucontrol power-profiles-daemon hyprpicker dunst feh nwg-look lxappearance \
	zsh networkmanager network-manager-applet flatpak

success "Pacotes principais instalados!"

# ====================================================
#  📂 Configuração inicial de diretórios
# ====================================================
info "Atualizando diretórios XDG e criando pastas..."
xdg-user-dirs-update
mkdir -p ~/Imagens/Wallpapers
success "Diretórios criados e atualizados!"

# ====================================================
#  ⚙️ Variáveis de ambiente
# ====================================================
info "Configurando variáveis XDG..."
#echo 'export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share' | tee -a ~/.bashrc ~/.zshrc >/dev/null
success "Variáveis adicionadas ao bashrc e zshrc!"

# ====================================================
#  🧩 Stow - Aplicando configurações dotfiles
# ====================================================
info "Aplicando configurações com stow..."
stow hyprland kitty rofi scripts themes wallpapers waybar
success "Configurações aplicadas!"

# ====================================================
#  🌐 NetworkManager
# ====================================================
info "Habilitando NetworkManager..."
sudo systemctl enable --now NetworkManager
success "NetworkManager habilitado!"

# ====================================================
#  📦 Instalação de YAY (AUR helper)
# ====================================================
info "Instalando YAY..."
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
success "YAY instalado com sucesso!"
cd ~

# ====================================================
#  🧰 LinuxToys
# ====================================================
info "Instalando LinuxToys..."
curl -fsSL https://linux.toys/install.sh | sh
success "LinuxToys instalado!"

# ====================================================
#  🎨 Temas e ícones
# ====================================================
info "Instalando tema Graphite-gtk..."
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme
./install.sh -c dark -s standard -s compact -l --tweaks nord rimless
cd ..
success "Tema Graphite instalado!"

info "Instalando ícones Nordzy..."
git clone https://github.com/alvatip/Nordzy-icon
cd Nordzy-icon
./install.sh
cd ..
success "Ícones Nordzy instalados!"

# ====================================================
#  💤 LazyVim
# ====================================================
info "Instalando LazyVim..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
success "LazyVim instalado!"

# ====================================================
#  🌀 Oh My Zsh
# ====================================================
info "Instalando Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
success "Oh My Zsh instalado!"

# ====================================================
#  ✅ Finalização
# ====================================================
info "Limpeza final..."
rm -rf /tmp/yay /tmp/Nordzy-icon /tmp/Graphite-gtk-theme ~/.config/hypr ~/.config/waybar
success "Instalação concluída com sucesso!"
echo -e "\n\033[1;32mAmbiente pronto! Reinicie o sistema ou inicie a sessão Wayland.\033[0m"
