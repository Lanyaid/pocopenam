# 📝 CHANGELOG — openam_kubernetes

## [v1.3] - 2025-05-15
### 🎯 Objectif
- Séparation claire entre installation () et suppression ()

### ✅ Ajouts
- Vérification de conteneurs obsolètes dans , sans action destructive
- Forçage de suppression () dans 
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

