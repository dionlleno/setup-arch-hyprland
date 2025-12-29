#!/bin/bash

VAULT="$HOME/Obsidian"
LOG="$HOME/.obsidian-backup.log"
ICON="document-save"

cd "$VAULT" || {
  notify-send -u critical -i dialog-error "Obsidian Backup" "Falha ao acessar o vault"
  exit 1
}

{
  echo "==== $(date '+%Y-%m-%d %H:%M:%S') ===="

  git pull --rebase

  if ! git diff --quiet || ! git diff --cached --quiet; then
      git add .
      git commit -m "Backup automático $(date '+%Y-%m-%d %H:%M')"
      git push
      notify-send -u normal -i "$ICON" "Obsidian Backup" "Backup enviado com sucesso ✅"
  else
      notify-send -u low -i "$ICON" "Obsidian Backup" "Nenhuma alteração para enviar"
  fi

} >> "$LOG" 2>&1
