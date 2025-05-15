#!/bin/bash

set -e

echo "🛠️  Installation des dépendances..."
sudo dnf install -y kubeadm kubelet kubectl containerd containernetworking-plugins iproute iptables

echo "🔧 Activation et démarrage des services..."
sudo systemctl enable --now containerd
sudo systemctl enable --now kubelet

echo "🔍 Vérification du support cgroups..."
CGROUP_DRIVER=$(crictl info | grep -i 'cgroupDriver' | awk -F\" '{print $4}')
echo "ℹ️  cgroupDriver utilisé : $CGROUP_DRIVER"
if [[ "$CGROUP_DRIVER" != "systemd" ]]; then
  echo "⚠️  Le cgroupDriver n'est pas 'systemd'. Certaines fonctionnalités Kubernetes peuvent ne pas fonctionner correctement."
fi

echo "🔧 Vérification du swap..."
if swapon --summary | grep -q 'partition'; then
  echo "❌ Le swap est activé. Kubernetes nécessite sa désactivation."
  read -p "Souhaitez-vous désactiver le swap maintenant ? [y/n] " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo swapoff -a
    sudo sed -i '/ swap / s/^/#/' /etc/fstab
    echo "✅ Swap désactivé."
  else
    echo "⚠️  Abandon de l'installation. Veuillez désactiver le swap manuellement et relancer ce script."
    exit 1
  fi
else
  echo "✅ Le swap est déjà désactivé."
fi

echo "🧩 Initialisation de Kubernetes..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "🔐 Configuration de kubectl pour l'utilisateur $USER..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "📦 Déploiement du réseau (Flannel)..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "🔧 Configuration de crictl pour utiliser containerd..."
sudo mkdir -p /etc
cat <<EOF | sudo tee /etc/crictl.yaml > /dev/null
runtime-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF
echo "✅ Fichier /etc/crictl.yaml créé avec succès."

echo "✅ Installation et configuration de Kubernetes terminées avec succès."

