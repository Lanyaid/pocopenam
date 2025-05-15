# 🚀 Environnement Kubernetes sur Fedora Server 42

Ce projet permet de déployer rapidement un cluster Kubernetes mononœud avec Flannel et OpenAM sur **Fedora Server 42**, en utilisant trois scripts principaux.

---

## 🧰 Scripts disponibles

### 1. `reset-k8s-fedora.sh`
Réinitialise complètement le cluster Kubernetes :
- Arrête kubelet et containerd
- Supprime tous les conteneurs containerd
- Démontage des volumes
- Suppression des répertoires : `/etc/kubernetes`, `/var/lib/etcd`, `/var/lib/kubelet`, etc.
- Redémarre les services

**Utilisation :**
```bash
./reset-k8s-fedora.sh

2. setup-k8s-fedora.sh
Installe et configure un cluster Kubernetes :

Installe containerd

Vérifie et corrige l’option SystemdCgroup

Configure containerd, kubelet, IP forwarding, swap

Ouvre les ports 6443 et 10250

Initialise le cluster avec kubeadm

Configure kubectl

Utilisation :
./setup-k8s-fedora.sh

🔒 Ce script vérifie :

Que SystemdCgroup est activé (ou propose de le faire)

Que le swap est désactivé

3. deploy-flannel-openam.sh
Déploie la couche réseau et l’application OpenAM :

Ouvre le port 8080 pour OpenAM

Installe Flannel comme CNI

Déploie OpenAM via Service et StatefulSet

Configure un port-forward local sur le port 8080

Utilisation :

bash
Copy
./deploy-flannel-openam.sh
Accès à OpenAM :
👉 http://localhost:8080/openam

📦 Prérequis
Fedora Server 42

Accès root ou sudo

Connexion Internet active

kubectl, kubeadm, crictl installés via :

bash
Copy
sudo dnf install -y kubernetes1.30 kubernetes1.30-kubeadm kubernetes1.30-client
📝 Astuces
Exécute fix-containerd-cgroup.sh une seule fois après installation de containerd si demandé.

Utilise logs-kube-apiserver.sh pour déboguer un démarrage échoué de kube-apiserver.

✅ Ordre recommandé
./reset-k8s-fedora.sh (facultatif si déjà propre)

./setup-k8s-fedora.sh

./deploy-flannel-openam.sh

📧 Support
Pour toute aide, lance journalctl -xeu kubelet ou sudo crictl ps -a pour analyser l’état du cluster.

