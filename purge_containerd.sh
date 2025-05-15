#!/bin/bash

echo "🛑 Arrêt de tous les conteneurs containerd..."
for id in $(sudo crictl ps -q); do
  echo " → Arrêt du conteneur $id"
  sudo crictl stop $id
done

echo "🧹 Suppression de tous les conteneurs containerd..."
sudo crictl rm -a

echo "🔁 Redémarrage des services containerd et kubelet..."
sudo systemctl restart containerd
sudo systemctl restart kubelet

echo "✅ Purge complète de containerd terminée."

