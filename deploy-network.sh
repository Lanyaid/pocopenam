#!/bin/bash

echo "🌐 Déploiement du réseau CNI (Flannel) pour Kubernetes..."
echo "[4] tâches"

MANIFEST="./config/kube-flannel.yml"

# Télécharger le manifeste localement si absent
echo "[1/4] 🌐 Déploiement du réseau CNI (Flannel) pour Kubernetes..."
if [ ! -f "$MANIFEST" ]; then
  echo "📥 Téléchargement du manifeste Flannel..."
  curl -sSL -o $MANIFEST https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi

# Attente de l'API server
echo "[2/4] ⏳ Attente de l'API server Kubernetes..."
until kubectl version --short &>/dev/null; do
  echo -n "."
  sleep 5
done

# Application du réseau
echo "[3/4] 🚀 Application de Flannel..."
kubectl apply -f $MANIFEST

# Vérification de l’état
echo "[4/4] 🔍 Vérification du pod kube-flannel..."
until kubectl get pods -n kube-system | grep flannel &>/dev/null; do
  echo -n "."
  sleep 5
done

echo "✅ Réseau Flannel déployé (si le pod est en cours d'exécution)."
