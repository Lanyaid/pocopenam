#!/bin/bash

echo "🔧 Initialisation complète de Kubernetes sur Fedora Server..."

# Étape 1 : Installation des dépendances
echo "[1/10] 🛠️  Installation des dépendances..."
sudo dnf install -y \
  kubernetes1.32-kubeadm \
  kubernetes1.32 \
  kubernetes1.32-client \
  cri-o \
  containernetworking-plugins \
  iptables \
  iproute-tc \
  firewalld

# Étape 2 : Configuration des paramètres système
echo "[2/10] 🔧 Configuration des paramètres système..."
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sudo sysctl --system > /dev/null

lsmod | grep br_netfilter
lsmod | grep overlay

# Étape 3 : Activation et démarrage des services
echo "[3/10] 🔧 Activation et démarrage des services..."
for svc in crio kubelet; do
  sudo systemctl enable --now $svc
done
sleep 5

# Étape 4 : Pull images
echo "[4/10] 🔧 Pull des images nécessaires..."
sudo kubeadm config images pull

# Étape 5 : Initialisation du cluster
echo "[5/10] 🧩 Initialisation du cluster..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Étape 6 : Initialisation de Kubernetes
echo "[6/10] 🧩 Initialisation de Kubernetes..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Etape 8 Autoriser plane machine a lancer des pods pour applications
echo "[8/10] 🔧 Autoriser plane machine à lancer despods pour applications..."
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# Étape 9 : Déploiement de Flannel
echo "[9/10] 📦 Déploiement du réseau (Flannel)..."
echo -e "\n\n\n"
./deploy-network.sh
echo -e "\n\n\n"

# Étape 10 : Déploiement de OpenAM
echo "[9/10] 📦 Déploiement du OpenAM..."
echo -e "\n\n\n"
./deploy-openam.sh
echo -e "\n\n\n"

# Étape 10 : Vérification des pods
echo "[10/10]🔍 État des pods dans kube-system..."
kubectl get pods --all-namespaces

echo "✅ Installation et configuration de Kubernetes terminées avec succès."
