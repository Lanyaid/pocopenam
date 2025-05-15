#!/bin/bash

echo "🔧 Mise à jour de la configuration de containerd pour utiliser SystemdCgroup..."

sudo sed -i '/\[plugins\."io.containerd.grpc.v1.cri"\.containerd\.runtimes\.runc\]/a\
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]\
    SystemdCgroup = true' /etc/containerd/config.toml

echo "🔁 Redémarrage de containerd..."
sudo systemctl restart containerd

echo "✅ Configuration terminée. containerd utilise maintenant SystemdCgroup."

