#!/usr/bin/env bash

WALL_DIR="$HOME/Imagens/Wallpapers"
CACHE="$HOME/.cache/wallpaper-thumbs"
CURRENT="$WALL_DIR/.wallpaper"

mkdir -p "$CACHE"

entries=""

for img in "$WALL_DIR"/*.{jpg,png,webp}; do
    [ -f "$img" ] || continue
    name=$(basename "$img")
    thumb="$CACHE/$name.png"

    # cria thumbnail se não existir
    if [ ! -f "$thumb" ]; then
        magick "$img" -resize 256x256 "$thumb"
    fi

    # formato: label \0icon\x1fPATH
    entries+="$name\0icon\x1f$thumb\n"
done

selected=$(printf "%b" "$entries" \
    | rofi -dmenu \
        -i \
        -p "🖼 Wallpaper" \
        -show-icons \
        -theme ~/.config/rofi/seletor-wallpaper.rasi)

[ -z "$selected" ] && exit 0

cp "$WALL_DIR/$selected" "$CURRENT"

swww img "$CURRENT" \
    --transition-type=center \
    --transition-fps=60 \
    --transition-duration=0.7
