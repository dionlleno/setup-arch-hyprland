#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ====================================================
#  📦 Listas de pacotes
# ====================================================

apps_flatpak=(
    app.zen_browser.zen
    com.anydesk.Anydesk
    com.calibre_ebook.calibre
    com.github.Matoking.protontricks
    com.github.johnfactotum.Foliate
    com.github.tchx84.Flatseal
    com.heroicgameslauncher.hgl
    com.jeffser.Alpaca.Locale
    com.rtosta.zapzap.Locale
    com.spotify.Client
    com.usebottles.bottles
    com.valvesoftware.Steam.Utility.MangoHud
    com.vysp3r.ProtonPlus
    de.haeckerfelix.Fragments.Locale
    io.github.alainm23.planify.Locale
    io.github.flattool.Warehouse
    io.github.kolunmi.Bazaar
    it.mijorus.gearlever
    md.obsidian.Obsidian
    net.davidotek.pupgui2
    org.freedesktop.Platform.VulkanLayer.MangoHud
    org.freedesktop.Platform.VulkanLayer.gamescope
    org.freedesktop.Platform.ffmpeg-full
    org.gimp.GIMP
    org.gnome.Characters.Locale
    org.kde.Platform
    org.libreoffice.LibreOffice
)

apps_pacman=(
    git base-devel neovim swww stow xdg-user-dirs rofi waybar
    xdg-desktop-portal-kde xdg-desktop-portal-gtk pavucontrol
    power-profiles-daemon hyprpicker dunst feh nwg-look lxappearance
    zsh networkmanager network-manager-applet flatpak
    libxml2 lib32-libxml2 python-pip python-xyz slurp grim imagemagick
    swappy wl-clipboard zed blueman hyprlock xdg-desktop-portal-hyprland
    xdg-desktop-portal hyprshot swaync libnotify hypridle fzf blueberry
    nautilus code conky gruvbox-gtk-theme gtk-engine-murrine
)

drivers_hibridos=(
    nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-prime
    vulkan-intel lib32-vulkan-intel vulkan-tools glxinfo
)

# ====================================================
#  🛠️ Funções auxiliares
# ====================================================

info()    { echo -e "\n\033[1;34m[INFO]\033[0m $1\n"; }
success() { echo -e "\033[1;32m[✔]\033[0m $1"; }
error()   { echo -e "\033[1;31m[✖]\033[0m $1"; }

# ====================================================
#  🔧 Instalação de pacotes principais
# ====================================================

info "Instalando pacotes base e utilitários..."
sudo pacman -Syu --needed --noconfirm "${apps_pacman[@]}"
success "Pacotes principais instalados!"

# ====================================================
#  💻 Instalação de drivers híbridos (NVIDIA + Intel)
# ====================================================

info "Detectando GPUs no sistema..."
gpu_info=$(lspci | grep -E "VGA|3D")

if echo "$gpu_info" | grep -iq "NVIDIA" && echo "$gpu_info" | grep -iq "Intel"; then
    info "Sistema híbrido detectado (Intel + NVIDIA). Instalando drivers..."
    sudo pacman -S --needed --noconfirm "${drivers_hibridos[@]}"
    success "Drivers híbridos instalados!"
elif echo "$gpu_info" | grep -iq "NVIDIA"; then
    info "Somente NVIDIA detectada. Instalando drivers NVIDIA..."
    sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-prime
    success "Drivers NVIDIA instalados!"
elif echo "$gpu_info" | grep -iq "Intel"; then
    info "Somente Intel detectada. Instalando drivers Intel..."
    sudo pacman -S --needed --noconfirm vulkan-intel lib32-vulkan-intel vulkan-tools
    success "Drivers Intel instalados!"
else
    info "Nenhuma GPU Intel/NVIDIA detectada. Pulando etapa de drivers."
fi

# ====================================================
#  📦 Instalação de aplicativos Flatpak
# ====================================================

if ! command -v flatpak &>/dev/null; then
    error "Flatpak não encontrado! Instalando via pacman..."
    sudo pacman -S --needed --noconfirm flatpak
fi

info "Verificando repositório Flathub..."
if ! flatpak remote-list | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flathub adicionado!"
else
    info "Flathub já está configurado."
fi

info "Instalando aplicativos Flatpak..."
flatpak install -y flathub "${apps_flatpak[@]}" || true
success "Aplicativos Flatpak instalados!"

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
XDG_EXPORT='export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share'
grep -qxF "$XDG_EXPORT" ~/.bashrc || echo "$XDG_EXPORT" >> ~/.bashrc
grep -qxF "$XDG_EXPORT" ~/.zshrc  || echo "$XDG_EXPORT" >> ~/.zshrc
success "Variáveis adicionadas ao bashrc e zshrc!"

# ====================================================
#  🧩 Stow - Aplicando configurações dotfiles
# ====================================================

info "Aplicando configurações com Stow..."
cd ~/dotfiles 2>/dev/null || cd ~
stow hyprland kitty rofi scripts themes wallpapers waybar || true
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
tmp_dir=$(mktemp -d)
git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
cd "$tmp_dir/yay"
makepkg -si --noconfirm
cd ~
success "YAY instalado com sucesso!"

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
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git "$tmp_dir/Graphite-gtk-theme"
cd "$tmp_dir/Graphite-gtk-theme"
./install.sh -c dark -s standard -s compact -l --tweaks nord rimless
success "Tema Graphite instalado!"

info "Instalando ícones Nordzy..."
git clone https://github.com/alvatip/Nordzy-icon "$tmp_dir/Nordzy-icon"
cd "$tmp_dir/Nordzy-icon"
./install.sh
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
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
success "Oh My Zsh instalado!"

# ====================================================
#  🧹 Limpeza final
# ====================================================

info "Limpando arquivos temporários..."
rm -rf "$tmp_dir"
update-desktop-database ~/.local/share/applications/
success "Instalação concluída com sucesso!"

yay -S sddm-theme-sugar-candy

sudo ln -s ~/Imagens/Wallpapers/.wallpaper /usr/share/sddm/themes/Sugar-Candy/Backgrounds/.wallpaper
sudo ln -s ~/Imagens/Wallpapers/.wallpaper /usr/share/hypr/wall0.png

echo -e "\n\033[1;32mAmbiente pronto! Reinicie o sistema ou inicie a sessão Wayland.\033[0m"
