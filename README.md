# 📊 Système d'optimisation SOTRACO ![alt text](image.png)

## 👥 Développeurs

####  NAOUE SAMPANA : Développeur backend & optimisation

- **Responsabilités principales** :

  - Architecture du système et structures de données
  - Import/traitement des données CSV
  - Algorithmes d'optimisation des fréquences
  - Calcul des temps d'attente et métriques
  - Tests unitaires

- **Modules développés** :
  - `types.jl` : Définition des structs
  - `io_operations.jl` : Import/export CSV
  - `optimisation.jl` : Algorithmes d'optimisation
  - `tests/` : Tests de validation

#### OUENA EDOUARD : Analyste de données & interface

- **Responsabilités principales** :

  - Analyses statistiques avec DataFrames
  - Identification des patterns de fréquentation
  - Interface utilisateur interactive
  - Génération de rapports et visualisations
  - Documentation

- **Modules développés** :
  - `analyse.jl` : Analyses de données
  - `visualisation.jl` : Graphiques et tableaux
  - `rapports.jl` : Génération de rapports
  - `main.jl` : Interface utilisateur
  - `dashboard.html`: Interface web


## 🎯 Vue d'ensemble du projet

Le **Système d'optimisation SOTRACO** est une solution complète d'analyse et d'optimisation pour le réseau de bus de la Société de Transport en Commun (SOTRACO) de Ouagadougou, Burkina Faso. Ce projet combine des techniques avancées de science des données, d'optimisation mathématique et de visualisation pour améliorer l'efficacité du transport public urbain. Le projet a été implémenté dans le langage de programmation de haut niveau et open source **Julia** née en 2012.
Julia est un langage de programmation moderne, puissant et de plus en plus prisé dans les domaines de la data science, du calcul scientifique et de l’intelligence artificielle.

### 🌟 Caractéristiques principales

- **Analyse multi-dimensionnelle** : Analyse par ligne, arrêt, quartier, zone, jour et heure
- **Optimisation intelligente** : Ajustement automatique des fréquences basé sur la demande
- **Visualisations interactives** : Cartes géospatiales et graphiques dynamiques
- **API REST moderne** : Architecture orientée services pour l'intégration
- **Interface web responsive** : Tableau de bord accessible depuis tout appareil
- **Recommandations automatiques** : Suggestions basées sur l'analyse des données

## 🏗️ Architecture du Système

```
Projet_julia_SOTRACO_NAOUE_et_OUENA/
├── README.md                   # Documentation principale
├── Project.toml               # Dépendances Julia
├── src/
│   ├── main.jl               # Programme principal avec CLI
│   ├── types.jl              # Structures de données
│   ├── io_operations.jl      # Import/Export des données
│   ├── analyse.jl            # Module d'analyse
│   ├── optimisation.jl       # Algorithmes d'optimisation
│   ├── visualisation.jl      # Génération de graphiques
│   ├── rapports.jl          # Génération de rapports
│   └── api_server.jl        # Serveur API REST
├── data/
│   ├── lignes_bus.csv       # Données des lignes
│   ├── arrets.csv           # Données des arrêts
│   └── frequentation.csv    # Données de fréquentation
├── web/
│   └── dashboard.html       # Interface web
├── test/
│   └── runtests.jl          # Tests unitaires
│
├── resultats/
│   ├── *.csv               # Exports des analyses
│   └── rapport_final.txt   # Rapport détaillé
└── docs/
    └── contributions_individuelles.md     # Contributions des membres

```

## 🚀 Installation et configuration

### Prérequis

- Julia 1.10 ou supérieur
- 4 GB RAM minimum
- Navigateur web moderne (Chrome, Firefox, Safari)
- Connexion internet (pour les cartes)

### Installation

1. **Cloner le projet**
```bash

git clone https://github.com/nsely/Projet_julia_SOTRACO_NAOUE_et_OUENA.git
```

2. **Installer les dépendances Julia**
```julia
julia> using Pkg
julia> Pkg.activate(".")
julia> Pkg.instantiate()
```

3. **Vérifier l'installation**
```julia
julia> include("src/main.jl")
julia> lancer_systeme_sotraco()   # Le système devrait être lancé
```

## 📦 Dépendances principales

| Package | Version | Utilisation |
|---------|---------|-------------|
| DataFrames | 1.6+ | Manipulation des données |
| CSV | 0.10+ | Import/Export CSV |
| Plots | 1.39+ | Visualisations statiques |
| PlotlyJS | 0.18+ | Graphiques interactifs |
| JuMP | 1.20+ | Optimisation mathématique |
| Genie | 5.30+ | Framework web/API |
| Statistics | Base | Calculs statistiques |

## 💻 Utilisation

### 1. Interface en ligne de commande (CLI)

```julia
julia> include("src/main.jl")
julia> lancer_systeme_sotraco()

========================================
   SOTRACO - Système d'Optimisation
========================================
1. Analyser la fréquentation
2. Optimiser les lignes
3. Visualiser le réseau
4. Carte géospatiale statique
5. Carte géospatiale interactive
6. Exporter les tableaux CSV
7. Tableau de bord interactif
8. Générer un rapport
9. Recommandations
10. Quitter le système
========================================
Votre choix: _
```

### 2. API REST

Démarrer le serveur API :
```julia
julia> include("src/api_server.jl")
# Serveur démarré sur http://localhost:8000
```

Endpoints disponibles :
- `GET /api/stats` - Statistiques globales
- `GET /api/lignes` - Données des lignes
- `GET /api/arrets` - Données des arrêts
- `GET /api/analyses/lignes` - Analyses par ligne
- `GET /api/analyses/arrets` - Analyses par arrêt
- `GET /api/analyses/quartiers` - Analyses par quartier
- `GET /api/analyses/zones` - Analyses par zone
- `GET /api/optimisations` - Suggestions d'optimisation
- `GET /api/recommandations` - Recommandations stratégiques

### 3. Interface web

1. Démarrer le serveur API (voir ci-dessus)
2. Ouvrir `web/dashboard.html` dans un navigateur
3. Explorer les différents onglets du tableau de bord

## 📊 Fonctionnalités détaillées

### Analyses disponibles

#### 1. Analyse par ligne
- Recettes totales par ligne
- Taux d'occupation moyen
- Identification des lignes surchargées
- Temps d'attente théorique vs réel

#### 2. Analyse par arrêt
- Points de forte affluence
- Arrêts nécessitant des infrastructures
- Corrélation abribus/éclairage avec fréquentation

#### 3. Analyse temporelle
- Identification des heures de pointe
- Variations journalières et hebdomadaires
- Tendances saisonnières

#### 4. Analyse géospatiale
- Distribution spatiale de la demande
- Zones mal desservies
- Optimisation des trajets

### Algorithmes d'optimisation

#### Optimisation des fréquences
```julia
function calculer_frequence_optimale(taux_occupation, freq_actuelle)
    if taux_occupation > 0.8
        # Augmenter la fréquence (réduire l'attente)
        nouvelle_freq = freq_actuelle * 0.7
    elseif taux_occupation < 0.4
        # Réduire la fréquence (économies)
        nouvelle_freq = min(freq_actuelle * 1.3, 30.0)
    else
        # Ajustement fin
        ratio = 0.6 / taux_occupation
        nouvelle_freq = freq_actuelle * ratio
    end
    return clamp(nouvelle_freq, 5.0, 30.0)
end
```

#### Optimisation globale (programmation linéaire)
- Minimisation du temps d'attente total
- Contraintes de capacité du réseau
- Allocation optimale des ressources

## 📈 Métriques et KPIs

| Métrique | Description | Objectif |
|----------|-------------|----------|
| Taux d'occupation | Ratio passagers/capacité | 60-70% |
| Temps d'attente | Durée moyenne aux arrêts | < 15 min |
| Taux de surcharge | % de bus surchargés | < 10% |
| Couverture réseau | % population desservie | > 80% |
| Recettes/km | Efficacité économique | Maximiser |

## 🔬 Analyses statistiques

### Statistiques descriptives
- Moyennes, médianes, écarts-types
- Distributions de fréquentation
- Corrélations entre variables

### Analyses prédictives
- Prévision de la demande
- Détection d'anomalies
- Modélisation des tendances

### Simulations
- Scénarios d'augmentation de capacité
- Impact des modifications tarifaires
- Optimisation des horaires

## 🎨 Visualisations

### Graphiques disponibles
- **Diagrammes à barres** : Comparaisons entre lignes/arrêts
- **Diagrammes circulaires** : Répartition par zone
- **Séries temporelles** : Évolution des recettes
- **Heatmaps** : Fréquentation par jour/heure
- **Cartes géospatiales** : Distribution spatiale

### Technologies de Visualisation
- Plots.jl pour graphiques statiques
- PlotlyJS pour graphiques interactifs
- Leaflet.js pour cartes web
- Chart.js pour tableaux de bord

## 🚦 Recommandations automatiques

Le système génère automatiquement des recommandations basées sur :

1. **Infrastructures**
   - Arrêts nécessitant des abribus
   - Zones nécessitant l'éclairage

2. **Opérations**
   - Lignes à renforcer aux heures de pointe
   - Optimisation des fréquences

3. **Stratégiques**
   - Création de lignes express
   - Fusion de lignes sous-utilisées

## 📝 Génération de rapports

### Rapport automatique inclut :
- Résumé exécutif
- Statistiques clés
- Analyses détaillées
- Graphiques et tableaux
- Recommandations priorisées
- Plan d'action

### Formats d'Export :
- CSV pour analyses détaillées
- TXT pour rapports textuels
- Excel pour tableaux complexes
- JSON pour intégration API

## 🔧 Maintenance et support

### Logs et debugging
```julia
# Activer les logs détaillés
ENV["JULIA_DEBUG"] = "all"
```

### Tests unitaires
```julia
julia> using Pkg
julia> Pkg.test()
```

### Performance
- Utilisation de structures de données optimisées
- Calculs vectorisés avec DataFrames
- Cache des analyses coûteuses

## 👥 Équipe de développement

Ce projet a été développé par une équipe de deux data scientists experts en Julia et machine learning, combinant leurs expertises complémentaires:

- **Développeur backend & optimisation**
- **Analyste de données & interface**

## 📄 Licence

MIT License - Libre utilisation avec attribution
