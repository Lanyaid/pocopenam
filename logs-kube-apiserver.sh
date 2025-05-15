#!/bin/bash

echo "🔍 Recherche du conteneur kube-apiserver..."
CID=$(sudo crictl ps -a | grep kube-apiserver | awk '{print $1}')

if [ -z "$CID" ]; then
  echo "❌ Aucun conteneur kube-apiserver trouvé."
  exit 1
fi

echo "📋 Affichage des logs du conteneur : $CID"
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock logs $CID

