# Images et Schémas

Ce répertoire contient les schémas d'architecture et les captures d'écran du projet.

## Schémas à Créer

### 1. Architecture Globale (`architecture-overview.png`)
- Vue d'ensemble du système
- Data plane (Containerlab) + Telemetry plane (Docker)
- Flux de données

**Outil recommandé :** https://app.diagrams.net (anciennement draw.io)

### 2. Workflow de Détection (`microburst-workflow.png`)
- Génération du burst → Détection → Collecte → Visualisation
- Séquence temporelle

### 3. Dashboard Grafana (`grafana-dashboard-burst.png`)
- Capture d'écran montrant un micro-burst détecté
- Graphique avec un pic visible à 95%+

### 4. Comparaison SNMP vs gNMI (`comparison-snmp-gnmi.png`)
- Deux graphiques côte à côte
- SNMP : ligne plate
- gNMI : pic visible

## Instructions pour Créer les Schémas

### Avec draw.io

1. Aller sur https://app.diagrams.net
2. Choisir "Create New Diagram"
3. Utiliser les formes :
   - Rectangles pour les conteneurs
   - Cylindres pour les bases de données
   - Flèches pour les flux de données
4. Export : File → Export as → PNG (300 DPI)

### Capture d'Écran Grafana

```bash
# Depuis votre navigateur, accédez au dashboard
http://localhost:3000/d/latency-hunter-main

# Générez un burst
python3 scripts/generate_microburst.py --duration 200 --rate 8G

# Attendez que le pic apparaisse (1-2 secondes)

# Capturez l'écran (sous Windows : Snipping Tool, sous Linux : gnome-screenshot)

# Placez l'image ici : docs/images/grafana-dashboard-burst.png
```

## Intégration dans le README Principal

Une fois les images créées, mettez à jour le README.md principal :

```markdown
## Architecture

![Architecture](docs/images/architecture-overview.png)

## Résultat

![Burst Détecté](docs/images/grafana-dashboard-burst.png)
```

---

**Note :** Les images ne sont pas incluses dans ce template car elles dépendent de votre environnement spécifique. Créez-les après avoir lancé le lab avec succès.

