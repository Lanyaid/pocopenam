#!/bin/bash

read -p "🔖 Message de commit : " msg

if [[ -z "$msg" ]]; then
  echo "❌ Le message de commit ne peut pas être vide."
  exit 1
fi

echo "🧾 Ajout des fichiers modifiés..."
git add .

echo "📦 Commit en cours..."
git commit -m "$msg"
if [ $? -eq 0 ]; then
  read -p "🏷️ Voulez-vous ajouter un tag ? (y/n) : " tag_confirm
  if [[ "$tag_confirm" == "y" || "$tag_confirm" == "Y" ]]; then
    read -p "📌 Nom du tag (ex. v1.1) : " tag
    git tag "$tag"
    echo "✅ Tag '$tag' ajouté avec succès."
  fi
else
  echo "ℹ️ Aucun changement détecté, rien à committer."
fi

