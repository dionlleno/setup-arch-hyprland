#!/usr/bin/env bash
# hypr-wallpaper-fzf.sh
# lista arquivos em ~/Imagens/Wallpapers com fzf, ao selecionar copia para .wallpaper e roda swww img

WALLDIR="$HOME/Imagens/Wallpapers/"
TARGET="$WALLDIR/.wallpaper"

mkdir -p "$WALLDIR"

# seleciona com fzf
selected=$(find "$WALLDIR" -maxdepth 1 -type f ! -name ".*" | sort | fzf --preview 'ls -lh {} && identify -format "%w x %h\n%[mime]" {} 2>/dev/null || true' --preview-window=right:60%)
[ -z "$selected" ] && exit 0

cp -f "$selected" "$TARGET"
swww img "$TARGET" || {
  echo "swww falhou ao aplicar"
  exit 1
}
echo "Wallpaper aplicado: $(basename "$selected")"