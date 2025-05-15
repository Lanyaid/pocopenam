#!/bin/bash

echo "🌐 Déploiement du réseau CNI (Flannel) pour Kubernetes..."

MANIFEST="kube-flannel.yml"

# Télécharger le manifeste localement si absent
if [ ! -f "$MANIFEST" ]; then
  echo "📥 Téléchargement du manifeste Flannel..."
  curl -sSL -o $MANIFEST https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
fi

# Attente de l'API server
echo "⏳ Attente de l'API server Kubernetes..."
until kubectl version --short &>/dev/null; do
  echo -n "."
  sleep 3
done

# Application du réseau
echo -e "\n🚀 Application de Flannel..."
kubectl apply -f $MANIFEST --validate=false

# Vérification de l’état
echo "🔍 Vérification du pod kube-flannel..."
sleep 10
kubectl get pods -n kube-system | grep flannel

echo "✅ Réseau Flannel déployé (si le pod est en cours d'exécution)."
