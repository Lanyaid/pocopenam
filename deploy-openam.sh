#!/bin/bash

echo "📦 Déploiement de OpenAM..."
echo "[4] Tâches"

echo "[1/4] 📦 Déploiement de OpenAM (Volume Persistant)..."
kubectl apply -f ./config/openam-pv.yaml

echo "[2/4] 📦 Déploiement de OpenAM (service)..."
kubectl apply -f - ./config/openam-service.yaml

echo "[3/4] 📦 Déploiement de OpenAM (StatefulSet)..."
kubectl apply -f - ./config/openam-statefulset.yaml

echo "[4/4] 🌍 Déploiement de OpenAM (Redirection locale - port-forward - vers OpenAM)..."
kubectl wait --for=condition=Ready pod -l app=openam --timeout=120s
kubectl port-forward pod/openam-0 8080:8080 &
echo "✅ OpenAM est disponible sur http://localhost:8080/openam"
