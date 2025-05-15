# 📝 CHANGELOG — openam_kubernetes

## [v1.3.1] - 2025-05-15
### ♻️ Réorganisation du script de reset
- 🔁 Inversion de l’ordre des actions : suppression des conteneurs **avant** l’arrêt des services
- 🧠 Ajout d’une vérification de la disponibilité du socket containerd avant tout `crictl`
- 🧼 Amélioration de la robustesse globale du reset sans bruit d’erreurs

---

## [v1.3] - 2025-05-15
### 🎯 Objectif
- Séparation claire entre installation (`setup-k8s-fedora.sh`) et suppression (`reset-k8s-fedora.sh`)

### ✅ Ajouts
- Vérification de conteneurs obsolètes dans `setup`, sans action destructive
- Forçage de suppression (`crictl stop/rm`) dans `reset`
- Refactorisation complète des deux scripts

---

## [v1.2] - 2025-05-15
### 🔧 Objectif
- Ajout des vérifications interactives :
  - SystemdCgroup
  - Swap
  - Conteneurs obsolètes (avec purge optionnelle)

---

## [v1.1] - 2025-05-15
### 🔧 Objectif
- Première structuration des scripts
- Installation de Kubernetes avec containerd sur Fedora Server 42
- Ajout du style interactif avec emojis pour plus de lisibilité

---

## [v1.0] - 2025-05-15
### 🛠 Initialisation
- Mise en place du dépôt local Git
- Ajout des scripts initiaux : setup, reset, purge, logs, openam-service

