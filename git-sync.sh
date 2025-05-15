#!/bin/bash

read -p "🔖 Message de commit : " msg

git add .
git commit -m "$msg"
if [ $? -eq 0 ]; then
  read -p "🏷️ Voulez-vous ajouter un tag ? (y/n) : " tag_confirm
  if [[ "$tag_confirm" == "y" || "$tag_confirm" == "Y" ]]; then
    read -p "Nom du tag (ex. v1.1) : " tag
    git tag "$tag"
    echo "✅ Tag $tag ajouté."
  fi
else
  echo "❌ Aucun changement à committer."
fi

