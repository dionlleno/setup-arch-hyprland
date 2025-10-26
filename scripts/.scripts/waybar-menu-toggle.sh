#!/bin/bash

STATE_FILE="/tmp/waybar_menu_state"

# Alternar estado do menu ao clicar
if [ "$1" == "toggle" ]; then
  if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"  # Se já estiver visível, recolhe
  else
    touch "$STATE_FILE"  # Se estiver oculto, expande
  fi
  pkill -RTMIN+10 waybar  # Atualiza a Waybar para refletir as mudanças
  exit
fi

# Mostrar ou esconder o menu com base no estado
if [ -f "$STATE_FILE" ]; then
  # Menu expandido
  echo '{"text": "󰍹  Wifi |   78% | 󰓅  Brilho", "class": "menu-expanded"}'
else
  # Menu oculto
  echo '{"text": "", "class": "menu-collapsed"}'
fi
