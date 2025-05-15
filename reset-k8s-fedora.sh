#!/bin/bash

echo "[1/7] 🛑 Arrêt des services kubelet et containerd..."
sudo systemctl stop kubelet
sudo systemctl stop containerd

echo "[2/7] 🔌 Démontage des volumes Kubernetes..."
sudo umount /var/lib/kubelet/pods/*/volumes/*/* 2>/dev/null || true

echo "[3/7] 🧼 Nettoyage du profil kubectl..."
rm -rf $HOME/.kube

echo "[4/7] 🧹 Suppression des interfaces réseau résiduelles..."
sudo ip link delete cni0 2>/dev/null
sudo ip link delete flannel.1 2>/dev/null

echo "[5/7] 🗑️ Suppression des fichiers et répertoires de configuration..."
sudo rm -rf /etc/cni/net.d
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/cni/
sudo rm -rf /var/lib/kubelet
sudo rm -rf /etc/kubernetes

echo "[6/7] 🔁 Redémarrage des services containerd et kubelet..."
sudo systemctl restart containerd
sudo systemctl restart kubelet

echo "[7/7] ✅ Réinitialisation complète du cluster terminée. Prêt pour kubeadm init."

