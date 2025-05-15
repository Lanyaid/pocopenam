#!/bin/bash

for component in etcd kube-apiserver kube-controller-manager kube-scheduler; do
  echo "🔍 Logs pour : $component"
  CID=$(sudo crictl ps -a | grep "$component" | head -n 1 | awk '{print $1}')
  if [ -z "$CID" ]; then
    echo "❌ Aucun conteneur trouvé pour $component"
  else
    sudo crictl logs "$CID" | tail -n 20
  fi
  echo "--------------------------------------"
done

