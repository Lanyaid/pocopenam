#!/bin/bash

set -e

echo "[1/8] 🔨 Arrêt de tous les conteneurs containerd..."
sudo crictl ps -q | xargs -r sudo crictl stop

echo "[2/8] 🗑️ Suppression de tous les conteneurs containerd..."
sudo crictl ps -a -q | xargs -r sudo crictl rm || true

echo "[3/8] 🛑 Arrêt des services kubelet et containerd..."
sudo systemctl stop kubelet
sudo systemctl stop containerd

echo "[4/8] 🔌 Démontage des volumes Kubernetes..."
sudo umount -f /var/lib/kubelet/pods/*/volumes/*/* || true

echo "[5/8] 🧹 Suppression des interfaces réseau résiduelles..."
sudo ip link delete cni0 || true
sudo ip link delete flannel.1 || true

echo "[6/8] 🗑️ Suppression des fichiers et répertoires de configuration..."
sudo rm -rf /etc/cni/net.d
sudo rm -rf /var/lib/cni/
sudo rm -rf /var/lib/kubelet/*
sudo rm -rf /etc/kubernetes/
sudo rm -rf ~/.kube

echo "[7/8] 🔁 Redémarrage des services containerd et kubelet..."
sudo systemctl start containerd
sudo systemctl start kubelet

echo "[8/8] 🔥 Réinitialisation des règles iptables..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

echo "✅ Réinitialisation complète du cluster terminée. Environnement prêt pour une nouvelle installation."

