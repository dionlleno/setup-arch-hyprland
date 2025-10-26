#!/usr/bin/env bash

# -------- CONFIG --------
# Tema opcional do rofi (ou deixe padrão)
ROFI_THEME="~/.config/rofi/themes/polar-night.rasi"

# Opções do menu
options=(
    "⏻  Desligar"
    "  Reiniciar"
    "󰤄  Suspender"
    "󰍃  Hibernar"
    "󰗽  Bloquear"
    "󰅚  Cancelar"
)

# Mostra o menu
chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Power"N)
# chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Power" -theme "$ROFI_THEME")

case "$chosen" in
    "⏻  Desligar")
        systemctl poweroff
        ;;
    "  Reiniciar")
        systemctl reboot
        ;;
    "󰤄  Suspender")
        systemctl suspend
        ;;
    "󰍃  Hibernar")
        systemctl hibernate
        ;;
    "󰗽  Bloquear")
        # Troque pelo seu locker favorito
        hyprlock &
        ;;
    *)
        exit 0
        ;;
esac
