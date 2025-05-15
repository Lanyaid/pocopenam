#!/bin/bash

echo "[1/10] 📦 Installation de containerd (si nécessaire)..."
sudo dnf install -y containerd jq

echo "[2/10] 🔍 Vérification de SystemdCgroup dans containerd..."
if ! grep -q 'SystemdCgroup = true' /etc/containerd/config.toml 2>/dev/null; then
  echo "❗ SystemdCgroup n'est pas activé dans containerd."
  read -p "💬 Voulez-vous l'activer maintenant ? (y/n) : " fix_cgroup
  if [[ "$fix_cgroup" == "y" || "$fix_cgroup" == "Y" ]]; then
    echo "🔧 Ajout de SystemdCgroup = true dans /etc/containerd/config.toml..."
    sudo sed -i '/\[plugins\."io.containerd.grpc.v1.cri"\.containerd\.runtimes\.runc\]/a\
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]\
    SystemdCgroup = true' /etc/containerd/config.toml
    echo "🔁 Redémarrage de containerd..."
    sudo systemctl restart containerd
    echo "✅ SystemdCgroup activé avec succès."
  else
    echo "❌ Configuration requise non appliquée. Abandon."
    exit 1
  fi
else
  echo "✅ SystemdCgroup est déjà configuré."
fi

echo "[3/10] 🧪 Vérification de conteneurs Kubernetes résiduels (anciens de +5 min)..."
old_containers=$(sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a --quiet | \
  xargs -I {} sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock inspect {} | \
  jq -r '.status | select(.labels."io.kubernetes.container.name" != null) | select(.createdAt | fromdateiso8601 < (now - 300)) | .id')

if [ -n "$old_containers" ]; then
  echo "⚠️ Des conteneurs obsolètes sont présents."
  echo "👉 Il est recommandé d'exécuter './reset-k8s-fedora.sh' avant de continuer."
else
  echo "✅ Aucun conteneur obsolète détecté."
fi

echo "[4/10] ⚙️ Configuration de containerd..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

echo "[5/10] 🛠️ Activation du service kubelet..."
sudo systemctl enable --now kubelet

echo "[6/10] 🔁 Activation du routage IP..."
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-kubernetes-ipforward.conf
sudo sysctl --system

echo "[7/10] ❌ Désactivation du swap..."
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

echo "[8/10] 🔍 Vérification du swap..."
if swapon --summary | grep -q .; then
  echo "❌ Le swap est toujours actif. kubeadm init échouera."
  exit 1
else
  echo "✅ Le swap est bien désactivé."
fi

echo "[9/10] 🔓 Ouverture des ports nécessaires dans firewalld..."
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --reload

echo "[10/10] 🚀 Initialisation du cluster Kubernetes..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "🧩 Configuration de kubectl pour l'utilisateur $(whoami)..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "✅ Kubernetes est initialisé avec succès."

