#!/bin/bash

#set -e

echo "🔄 Réinitialisation complète de Kubernetes sur Fedora Server..."

# Étape 1 : Arrêt des conteneurs CRI (containerd)
echo "[1/7] 🔨 Arrêt des conteneurs containerd..."
if systemctl is-active --quiet containerd; then
  CONTAINERS=$(sudo crictl ps -q)
  if [ -n "$CONTAINERS" ]; then
    echo "$CONTAINERS" | xargs -r sudo crictl stop
  else
    echo "❕ Aucun conteneur en cours d'exécution."
  fi
else
  echo "❕ Le service containerd est arrêté, conteneurs déjà inactifs."
fi

# Étape 2 : Suppression des conteneurs
echo "[2/7] 🗑️ Suppression des conteneurs containerd..."
CONTAINERS_ALL=$(sudo crictl ps -a -q)
if [ -n "$CONTAINERS_ALL" ]; then
  echo "$CONTAINERS_ALL" | xargs -r sudo crictl rm
else
  echo "❕ Aucun conteneur à supprimer."
fi

# Étape 3 : Démontage des volumes Kubernetes
echo "[3/7] 🔌 Démontage des volumes Kubernetes..."
MOUNTS=$(mount | grep '/var/lib/kubelet/pods/' | awk '{print $3}')
if [ -n "$MOUNTS" ]; then
  echo "$MOUNTS" | xargs -r sudo umount
else
  echo "❕ Aucun volume monté à démonter."
fi

# Étape 4 : Suppression des interfaces réseau
echo "[4/7] 🧹 Suppression des interfaces réseau résiduelles..."
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^cni[0-9]+$|^flannel\.1$')
if [ -n "$INTERFACES" ]; then
  for iface in $INTERFACES; do
    echo "🔌 Suppression de l'interface $iface..."
    sudo ip link delete "$iface"
  done
else
  echo "❕ Aucune interface réseau CNI/Flannel à supprimer."
fi

# Étape 5 : Suppression des fichiers
echo "[5/7] 🗑️ Suppression des fichiers et répertoires de configuration..."
sudo rm -rf /etc/cni/net.d /etc/kubernetes /var/lib/etcd \
  /var/lib/kubelet /var/lib/cni /var/run/flannel /etc/containerd \
  /opt/cni /etc/crictl.yaml $HOME/.kube/config

# Étape 6 : Arrêt des services
echo "[6/7] 🛑 Arrêt des services Kubernetes..."
for svc in kubelet containerd; do
  if systemctl is-active --quiet $svc; then
    sudo systemctl stop $svc
    echo "✔️ Service $svc arrêté."
  else
    echo "❕ Le service $svc est déjà arrêté."
  fi
done

# Étape 7 : Nettoyage des règles iptables
echo "[7/7] 🔥 Réinitialisation des règles iptables..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

echo "✅ Réinitialisation terminée. Prêt pour une nouvelle installation."
