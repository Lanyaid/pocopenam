#!/bin/bash
set -euo pipefail

echo "[1/8] 🔨 Arrêt de tous les conteneurs containerd..."
if systemctl is-active --quiet containerd; then
    sudo crictl ps -a -q | xargs -r sudo crictl stop
else
    echo "❕ Le service containerd est inactif, tentative d'arrêt des conteneurs ignorée."
fi

echo "[2/8] 🗑️ Suppression de tous les conteneurs containerd..."
if systemctl is-active --quiet containerd; then
    sudo crictl ps -a -q | xargs -r sudo crictl rm
else
    echo "❕ Le service containerd est inactif, tentative de suppression des conteneurs ignorée."
fi

echo "[3/8] 🛑 Arrêt des services kubelet et containerd..."
for svc in kubelet containerd; do
    if systemctl is-active --quiet "$svc"; then
        sudo systemctl stop "$svc"
    else
        echo "❕ Le service $svc est déjà arrêté."
    fi
done

echo "[4/8] 🔌 Démontage des volumes Kubernetes..."
find /var/lib/kubelet/pods/ -name 'kube-api-access-*' -exec sudo umount -l {} \; 2>/dev/null || true

echo "[5/8] 🧹 Suppression des interfaces réseau résiduelles..."
for iface in cni0 flannel.1; do
    if ip link show "$iface" &>/dev/null; then
        sudo ip link delete "$iface"
    else
        echo "❕ Interface réseau $iface introuvable."
    fi
done

echo "[6/8] 🗑️ Suppression des fichiers et répertoires de configuration..."
sudo rm -rf /etc/cni /etc/kubernetes /var/lib/etcd /var/lib/cni /var/lib/kubelet /opt/cni /run/flannel

echo "[7/8] 🔁 Redémarrage des services containerd et kubelet..."
for svc in containerd kubelet; do
    if ! systemctl is-active --quiet "$svc"; then
        sudo systemctl start "$svc"
    else
        echo "❕ Le service $svc est déjà actif."
    fi
done

echo "[8/8] 🔥 Réinitialisation des règles iptables..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

echo "✅ Réinitialisation complète du cluster terminée. Environnement prêt pour une nouvelle installation."
