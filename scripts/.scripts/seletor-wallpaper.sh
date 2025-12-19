#!/bin/bash

WALL_DIR="$HOME/Imagens/Wallpapers"
WALL_LINK="$HOME/Imagens/Wallpapers/.wallpaper"

selected=$(find -L "$WALL_DIR" -type f \
  ! -name ".wallpaper" \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
  | sort \
  | fzf \
      --prompt="🖼 Wallpaper: " \
      --height=80% \
      --layout=reverse \
      --border \
      --preview '
        img="$(readlink -f "{}")"
        kitty +kitten icat --clear --transfer-mode=file "$img" 2>/dev/null \
        || echo "Preview indisponível (instale imagemagick)"
      ' \
      --preview-window=right:60%
)

[ -z "$selected" ] && exit 0

ln -sf "$selected" "$WALL_LINK"

swww img "$selected" \
  --transition-type any \
  --transition-fps 60 \
  --transition-duration 0.8

exit 0
