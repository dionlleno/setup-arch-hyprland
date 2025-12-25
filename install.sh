#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ====================================================
#  🎨 Cores e mensagens
# ====================================================

info()    { echo -e "\n\033[1;34m[INFO]\033[0m $1\n"; }
success() { echo -e "\033[1;32m[✔]\033[0m $1"; }
error()   { echo -e "\033[1;31m[✖]\033[0m $1"; }

# ====================================================
#  📦 Listas de pacotes
# ====================================================

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

apps_flatpak=(
    app.zen_browser.zen
    com.anydesk.Anydesk
    com.calibre_ebook.calibre
    com.github.Matoking.protontricks
    com.github.johnfactotum.Foliate
    com.github.tchx84.Flatseal
    com.heroicgameslauncher.hgl
    com.spotify.Client
    com.usebottles.bottles
    md.obsidian.Obsidian
    org.gimp.GIMP
    org.libreoffice.LibreOffice
)

drivers_hibridos=(
    nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-prime
    vulkan-intel lib32-vulkan-intel vulkan-tools
)

# ====================================================
#  🔧 Funções
# ====================================================

install_pacman() {
    info "Instalando pacotes via pacman..."
    sudo pacman -Syu --needed --noconfirm "${apps_pacman[@]}"
    success "Pacotes pacman instalados"
}

install_drivers() {
    info "Detectando GPUs..."
    gpu_info=$(lspci | grep -E "VGA|3D" || true)

    if echo "$gpu_info" | grep -iq "NVIDIA" && echo "$gpu_info" | grep -iq "Intel"; then
        sudo pacman -S --needed --noconfirm "${drivers_hibridos[@]}"
    elif echo "$gpu_info" | grep -iq "NVIDIA"; then
        sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-prime
    elif echo "$gpu_info" | grep -iq "Intel"; then
        sudo pacman -S --needed --noconfirm vulkan-intel lib32-vulkan-intel vulkan-tools
    else
        info "Nenhuma GPU compatível detectada"
        return
    fi
    success "Drivers instalados"
}

install_flatpak() {
    info "Configurando Flatpak e Flathub..."
    sudo pacman -S --needed --noconfirm flatpak

    if ! flatpak remote-list | grep -q flathub; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi

    flatpak install -y flathub "${apps_flatpak[@]}" || true
    success "Flatpaks instalados"
}

setup_xdg() {
    info "Configurando diretórios XDG..."
    xdg-user-dirs-update
    mkdir -p ~/Imagens/Wallpapers
    success "Diretórios configurados"
}

setup_env() {
    info "Configurando variáveis XDG..."
    XDG_EXPORT='export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share'
    grep -qxF "$XDG_EXPORT" ~/.bashrc || echo "$XDG_EXPORT" >> ~/.bashrc
    grep -qxF "$XDG_EXPORT" ~/.zshrc  || echo "$XDG_EXPORT" >> ~/.zshrc
    success "Variáveis configuradas"
}

apply_dotfiles() {
    info "Aplicando dotfiles com Stow..."
    cd ~/dotfiles 2>/dev/null || return
    stow hyprland kitty rofi scripts themes wallpapers waybar || true
    success "Dotfiles aplicados"
}

enable_network() {
    info "Habilitando NetworkManager..."
    sudo systemctl enable --now NetworkManager
    success "NetworkManager ativo"
}

install_yay() {
    info "Instalando YAY..."
    tmp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp_dir"
    success "YAY instalado"
}

install_shell() {
    info "Instalando Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    success "Oh My Zsh instalado"
}

extra_configs() {
    info "Configurações extras..."
    git config --global user.name "Dionlleno"
    git config --global user.email "dionlleno@proton.me"

    yay -S --noconfirm sddm-theme-sugar-candy tty-clock visual-studio-code-bin

    echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf

    sudo ln -sf ~/Imagens/Wallpapers/.wallpaper /usr/share/sddm/themes/Sugar-Candy/Backgrounds/.wallpaper
    sudo ln -sf ~/Imagens/Wallpapers/.wallpaper /usr/share/hypr/wall0.png

    success "Extras aplicados"
}

# ====================================================
#  📋 Menu interativo
# ====================================================

OPTIONS=$(whiptail --title "Pós-instalação Arch Linux" --checklist \
"Selecione o que deseja executar:" 20 78 10 \
"PACMAN"    "Pacotes base (pacman)" ON \
"DRIVERS"   "Drivers de vídeo" ON \
"FLATPAK"   "Aplicativos Flatpak" ON \
"XDG"       "Diretórios XDG" ON \
"ENV"       "Variáveis de ambiente" ON \
"DOTFILES"  "Dotfiles (stow)" OFF \
"NETWORK"   "NetworkManager" ON \
"YAY"       "Instalar YAY" ON \
"ZSH"       "Oh My Zsh" OFF \
"EXTRAS"    "Configurações extras" OFF \
3>&1 1>&2 2>&3)

for opt in $OPTIONS; do
    case $opt in
        \"PACMAN\")   install_pacman ;;
        \"DRIVERS\")  install_drivers ;;
        \"FLATPAK\")  install_flatpak ;;
        \"XDG\")      setup_xdg ;;
        \"ENV\")      setup_env ;;
        \"DOTFILES\") apply_dotfiles ;;
        \"NETWORK\")  enable_network ;;
        \"YAY\")      install_yay ;;
        \"ZSH\")      install_shell ;;
        \"EXTRAS\")   extra_configs ;;
    esac
done

echo -e "\n\033[1;32mAmbiente pronto! Reinicie o sistema.\033[0m"
