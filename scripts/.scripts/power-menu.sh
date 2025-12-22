#!/usr/bin/env bash

options=" Bloquear\n⏻ Desligar\n Reiniciar\n󰍃 Encerrar sessão"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Sessão: " -theme ~/.config/rofi/power-menu.rasi)

case "$chosen" in
    " Bloquear")
        hyprlock || swaylock
        ;;
    "⏻ Desligar")
        systemctl poweroff
        ;;
    " Reiniciar")
        systemctl reboot
        ;;
    "󰍃 Encerrar sessão")
        systemctl --user exit
        ;;
esac
