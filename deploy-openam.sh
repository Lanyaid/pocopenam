#!/bin/bash

echo "[1/4] 🌐 Déploiement du plugin réseau Flannel..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sleep 10

echo "[2/4] 🔍 Vérification des pods réseau..."
kubectl get pods -n kube-system

echo "[3/4] 📦 Déploiement de OpenAM (service + StatefulSet)..."
kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: openam
spec:
  clusterIP: None
  selector:
    app: openam
  ports:
  - port: 8080
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: openam
spec:
  serviceName: "openam"
  replicas: 1
  selector:
    matchLabels:
      app: openam
  template:
    metadata:
      labels:
        app: openam
    spec:
      containers:
      - name: openam
        image: openidentityplatform/openam
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: openam-data
          mountPath: /opt/openam
  volumeClaimTemplates:
  - metadata:
      name: openam-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
EOF

echo "[4/4] 🌍 Redirection locale (port-forward) vers OpenAM..."
kubectl wait --for=condition=Ready pod -l app=openam --timeout=120s
kubectl port-forward svc/openam 8080:8080 &
echo "✅ OpenAM est disponible sur http://localhost:8080/openam"
