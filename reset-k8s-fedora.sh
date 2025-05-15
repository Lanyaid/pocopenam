#!/bin/bash

echo "[1/7] 🛑 Arrêt des services kubelet et containerd..."
sudo systemctl stop kubelet
sudo systemctl stop containerd

echo "[2/7] 🔨 Forçage de l'arrêt de tous les conteneurs containerd..."
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a -q | \
  xargs -r sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock stop --timeout 2

echo "[3/7] 🗑️ Suppression de tous les conteneurs containerd..."
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a -q | \
  xargs -r sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock rm

echo "[4/7] 🔌 Démontage des volumes Kubernetes..."
sudo umount /var/lib/kubelet/pods/*/volumes/*/* 2>/dev/null

echo "[5/7] 🧹 Suppression des interfaces réseau résiduelles..."
sudo ip link delete cni0 2>/dev/null
sudo ip link delete flannel.1 2>/dev/null

echo "[6/7] 🗑️ Suppression des fichiers et répertoires de configuration..."
sudo rm -rf /etc/kubernetes /etc/cni /var/lib/kubelet /var/lib/etcd /var/lib/cni
rm -rf $HOME/.kube

echo "[7/7] 🔁 Redémarrage des services containerd et kubelet..."
sudo systemctl restart containerd
sudo systemctl restart kubelet

echo "✅ Réinitialisation complète du cluster terminée. Environnement prêt pour une nouvelle installation."
