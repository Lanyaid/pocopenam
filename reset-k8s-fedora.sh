#!/bin/bash

echo "[1/8] 🔨 Forçage de l'arrêt de tous les conteneurs containerd..."
if [ -S /var/run/containerd/containerd.sock ]; then
  sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a -q | \
    xargs -r sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock stop --timeout 2
else
  echo "⚠️ containerd n'est pas actif. Aucun conteneur à arrêter."
fi

echo "[2/8] 🗑️ Suppression de tous les conteneurs containerd..."
if [ -S /var/run/containerd/containerd.sock ]; then
  sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a -q | \
    xargs -r sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock rm
else
  echo "⚠️ containerd n'est pas actif. Aucun conteneur à supprimer."
fi

echo "[3/8] 🛑 Arrêt des services kubelet et containerd..."
sudo systemctl stop kubelet
sudo systemctl stop containerd

echo "[4/8] 🔌 Démontage des volumes Kubernetes..."
sudo umount /var/lib/kubelet/pods/*/volumes/*/* 2>/dev/null

echo "[5/8] 🧹 Suppression des interfaces réseau résiduelles..."
sudo ip link delete cni0 2>/dev/null
sudo ip link delete flannel.1 2>/dev/null

echo "[6/8] 🗑️ Suppression des fichiers et répertoires de configuration..."
sudo rm -rf /etc/kubernetes /etc/cni /var/lib/kubelet /var/lib/etcd /var/lib/cni
rm -rf $HOME/.kube

echo "[7/8] 🔁 Redémarrage des services containerd et kubelet..."
sudo systemctl restart containerd
sudo systemctl restart kubelet

echo "[8/8] ✅ Réinitialisation complète du cluster terminée. Environnement prêt pour une nouvelle installation."

