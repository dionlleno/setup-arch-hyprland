#!/usr/bin/env bash

# --------------------------------------------------
# Menu de sessão para Hyprland (usando wofi)
# --------------------------------------------------
# Requisitos:
#   - wofi (ou rofi)
#   - systemctl
#   - hyprctl
#   - hyprlock (opcional)
# --------------------------------------------------

# Ícones bonitinhos (pode mudar conforme seus temas de ícones)
lock="  Bloquear"
suspend="󰤄  Suspender"
hibernate="⏾  Hibernar"
reboot="󰜉  Reiniciar"
shutdown="󰐥  Desligar"
logout="󰍃  Sair"

# Cria o menu
selected=$(echo -e "$lock\n$suspend\n$hibernate\n$reboot\n$shutdown\n$logout" | \
rofi -dmenu -theme ~/.config/rofi/themes/gruvbox-dark.rasi -p "Sessão" -theme-str 'window {width: 15em;} listview {lines: 6;}'
)

case "$selected" in
    "$lock")
        hyprlock
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$hibernate")
        systemctl hibernate
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
    *)
        exit 0
        ;;
esac
