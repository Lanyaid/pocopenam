#!/bin/bash

echo "🛠️  Installation des dépendances..."
sudo dnf install -y \
    kubernetes1.30-kubeadm \
    kubernetes1.30 \
    kubernetes1.30-client \
    containerd \
    containernetworking-plugins \
    iproute \
    iptables-legacy \
    iptables-nft

echo "🔧 Activation et démarrage des services..."
sudo systemctl enable --now containerd
sudo systemctl enable --now kubelet

echo "🔍 Vérification du support cgroups..."
CGROUP_DRIVER=$(sudo crictl info | grep cgroupDriver | cut -d '"' -f4 || echo "")
echo "ℹ️  cgroupDriver utilisé : $CGROUP_DRIVER"
if [[ "$CGROUP_DRIVER" != "systemd" ]]; then
  echo "⚠️  Le cgroupDriver n'est pas 'systemd'. Certaines fonctionnalités Kubernetes peuvent ne pas fonctionner correctement."
fi

echo "🔧 Vérification du swap..."
if swapon --summary | grep -q '^'; then
  echo "❌ Le swap est activé. Kubernetes nécessite sa désactivation."
  read -p "Souhaitez-vous désactiver le swap maintenant ? [y/n] " disable_swap
  if [[ "$disable_swap" == "y" ]]; then
    sudo swapoff -a
    echo "✅ Swap désactivé."
  else
    echo "❗ Veuillez désactiver le swap manuellement avant de continuer."
    exit 1
  fi
else
  echo "✅ Le swap est déjà désactivé."
fi

echo "🧩 Initialisation de Kubernetes..."
sudo kubeadm init

echo "🔐 Configuration de kubectl pour l'utilisateur $USER..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

echo "📦 Déploiement du réseau (Flannel)..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "🔧 Configuration de crictl pour utiliser containerd..."
sudo tee /etc/crictl.yaml > /dev/null <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF
echo "✅ Fichier /etc/crictl.yaml créé avec succès."

echo "✅ Installation et configuration de Kubernetes terminées avec succès."
