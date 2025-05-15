#!/bin/bash

echo "⚠️ Ce script annulera le dernier commit local, mais gardera les fichiers modifiés dans l’arborescence."
read -p "❓ Continuer ? (y/n) : " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "❌ Annulation de la commande."
  exit 0
fi

echo "↩️ Annulation du dernier commit..."
git reset --soft HEAD~1

echo "✅ Le commit a été annulé. Les fichiers sont conservés pour re-committer."

