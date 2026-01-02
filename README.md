# ACP - Base Comparateur de Territoires INSEE
## Analyse en Composantes Principales des communes françaises
### Master 1 Statistique - Cours E. Périnel (2024-2025)

---

## 📖 Table des matières
1. [Mise en situation](#mise-en-situation)
2. [Source des données](#source-des-données)
3. [Dictionnaire complet des variables](#dictionnaire-complet-des-variables)
4. [Variables de l'analyse ACP](#variables-de-lanalyse-acp)
5. [L'ACP en 5 étapes (PICCI)](#lacp-en-5-étapes-picci)
6. [Fonctions R utilisées](#fonctions-r-utilisées)
7. [Interprétation des résultats](#interprétation-des-résultats)
8. [Mnémotechniques étudiant](#mnémotechniques-étudiant)

---

## 📍 Mise en situation

### Contexte général
La France métropolitaine et d'outre-mer compte environ **35 000 communes**, des grandes métropoles comme Paris, Lyon ou Marseille aux petits villages ruraux de quelques dizaines d'habitants. Cette diversité territoriale se traduit par des **inégalités socio-économiques** importantes : certaines communes concentrent richesse, emplois et services, tandis que d'autres souffrent de désertification, vieillissement et précarité.

### Problématique de l'étude
En tant qu'analyste statisticien, vous êtes mandaté pour répondre aux questions suivantes :

> **Comment caractériser et visualiser la diversité des territoires français ?**

Plus précisément :
- Quelles sont les **grandes dimensions** qui structurent les différences entre communes ?
- Peut-on identifier des **profils-types** de territoires ? (urbain dense, rural agricole, touristique, industriel, précarisé...)
- Quelles **variables** sont les plus discriminantes pour distinguer les territoires ?
- Comment se positionnent les différents **départements** dans cette diversité ?

### Pourquoi l'ACP est pertinente ici ?
Avec **32 variables** décrivant chaque commune (démographie, logement, revenus, emploi, établissements...), il est impossible de visualiser directement les données. L'**Analyse en Composantes Principales** permet de :

| Objectif | Comment l'ACP y répond |
|----------|------------------------|
| Réduire la complexité | Passer de 12+ variables à 2-3 axes synthétiques |
| Visualiser les territoires | Projeter les 35 000 communes sur un plan 2D |
| Identifier les variables clés | Cercle des corrélations |
| Détecter des groupes | Clusters visuels sur le nuage d'individus |
| Repérer les communes atypiques | Individus éloignés du centre |

### Enjeux pratiques
Cette analyse peut servir à :
- **Aménagement du territoire** : identifier les zones à revitaliser
- **Politiques sociales** : cibler les communes en difficulté
- **Développement économique** : comprendre les dynamiques locales
- **Études épidémiologiques** : contextualiser des données de santé

---

## 🔗 Source des données

### Informations générales

| Caractéristique | Détail |
|-----------------|--------|
| **Producteur** | INSEE (Institut National de la Statistique et des Études Économiques) |
| **Nom de la base** | Base du comparateur de territoires |
| **URL officielle** | https://www.insee.fr/fr/statistiques/2521169 |
| **Date de parution** | 02/09/2025 (mise à jour régulière) |
| **Géographie** | France métropolitaine + DOM-TOM |
| **Niveau géographique** | Commune, arrondissement municipal |
| **Format disponible** | CSV (3 Mo zippé), XLSX (10 Mo zippé) |

### Téléchargement direct
- **CSV** : https://www.insee.fr/fr/statistiques/fichier/2521169/base_cc_comparateur_csv.zip
- **Excel** : https://www.insee.fr/fr/statistiques/fichier/2521169/base_cc_comparateur_xlsx.zip

### Caractéristiques techniques du fichier

| Propriété | Valeur |
|-----------|--------|
| **Nom du fichier** | `base_cc_comparateur.csv` |
| **Taille** | ~8 Mo (décompressé) |
| **Encodage** | UTF-8 |
| **Séparateur** | Point-virgule (`;`) |
| **Nombre de lignes** | ~35 000 communes |
| **Nombre de colonnes** | 32 variables |
| **Valeurs manquantes** | `s` (secret statistique), cellules vides |

### Millésimes des sources
Les données proviennent de plusieurs sources avec des années de référence différentes :

| Source | Année | Variables concernées |
|--------|-------|---------------------|
| Recensement de la population | 2022 | Population, ménages, logements, emploi |
| Recensement de la population | 2016 | Population historique |
| État civil | 2016-2021 | Naissances, décès (cumul 6 ans) |
| État civil | 2024 | Naissances, décès (année complète) |
| Filosofi | 2021 | Revenus, pauvreté |
| REE-Sirene | 2023 | Établissements économiques |

### Précautions d'utilisation
⚠️ **Secret statistique** : Certains indicateurs sont masqués (`s`) pour les petites communes afin de préserver la confidentialité des données individuelles.

⚠️ **Géographie** : Les données sont diffusées en géographie 2024/2025, les fusions de communes récentes sont prises en compte.

---

## 📚 Dictionnaire complet des variables

### Vue d'ensemble des 32 variables brutes

Le fichier contient **32 colonnes** organisées en 5 thématiques :

```
┌─────────────────────────────────────────────────────────────────┐
│                    32 VARIABLES INSEE                           │
├─────────────────────────────────────────────────────────────────┤
│ 🏷️ IDENTIFICATION (1)   │ CODGEO                                │
│ 👥 DÉMOGRAPHIE (6)      │ P22_POP, P16_POP, SUPERF,             │
│                         │ NAIS1621, DECE1621, P22_MEN,          │
│                         │ NAISD24, DECESD24                     │
│ 🏠 LOGEMENT (5)         │ P22_LOG, P22_RP, P22_RSECOCC,         │
│                         │ P22_LOGVAC, P22_RP_PROP               │
│ 💰 REVENUS (4)          │ NBMENFISC21, PIMP21, MED21, TP6021    │
│ 💼 EMPLOI (5)           │ P22_EMPLT, P22_EMPLT_SAL, P16_EMPLT,  │
│                         │ P22_POP1564, P22_CHOM1564, P22_ACT1564│
│ 🏭 ÉTABLISSEMENTS (8)   │ ETTOT23, ETAZ23, ETBE23, ETFZ23,      │
│                         │ ETGU23, ETOQ23, ETTEF123, ETTEFP1023  │
└─────────────────────────────────────────────────────────────────┘
```

### Tableau détaillé des variables

#### 🏷️ 1. Identification géographique

| N° | Code | Libellé complet | Type | Unité | Source |
|----|------|-----------------|------|-------|--------|
| 1 | `CODGEO` | Code du département suivi du numéro de commune ou d'arrondissement municipal | CHAR(5) | - | COG 2024 |

> **Exemple** : `75056` = Paris, `13055` = Marseille, `69123` = Lyon

#### 👥 2. Démographie et territoire

| N° | Code | Libellé complet | Type | Unité | Source | Année |
|----|------|-----------------|------|-------|--------|-------|
| 2 | `P22_POP` | Population municipale | NUM | habitants | RP | 2022 |
| 3 | `P16_POP` | Population municipale | NUM | habitants | RP | 2016 |
| 4 | `SUPERF` | Superficie | NUM | km² | IGN | 2024 |
| 5 | `NAIS1621` | Nombre de naissances domiciliées (cumul 2016-2021) | NUM | naissances | État civil | 2016-2021 |
| 6 | `DECE1621` | Nombre de décès domiciliés (cumul 2016-2021) | NUM | décès | État civil | 2016-2021 |
| 7 | `P22_MEN` | Nombre de ménages | NUM | ménages | RP | 2022 |
| 8 | `NAISD24` | Nombre de naissances domiciliées | NUM | naissances | État civil | 2024 |
| 9 | `DECESD24` | Nombre de décès domiciliés | NUM | décès | État civil | 2024 |

> **Interprétation** :
> - `P22_POP - P16_POP` = évolution démographique sur 6 ans
> - `NAIS1621 - DECE1621` = solde naturel sur 6 ans
> - Un ratio `NAIS/POP` élevé = commune jeune/dynamique

#### 🏠 3. Logement

| N° | Code | Libellé complet | Type | Unité | Source | Année |
|----|------|-----------------|------|-------|--------|-------|
| 10 | `P22_LOG` | Nombre de logements | NUM | logements | RP | 2022 |
| 11 | `P22_RP` | Nombre de résidences principales | NUM | logements | RP | 2022 |
| 12 | `P22_RSECOCC` | Nombre de résidences secondaires et logements occasionnels | NUM | logements | RP | 2022 |
| 13 | `P22_LOGVAC` | Nombre de logements vacants | NUM | logements | RP | 2022 |
| 14 | `P22_RP_PROP` | Nombre de résidences principales occupées par des propriétaires | NUM | logements | RP | 2022 |

> **Vérification** : `P22_LOG = P22_RP + P22_RSECOCC + P22_LOGVAC`
>
> **Interprétation** :
> - `P22_RSECOCC / P22_LOG` élevé = zone touristique (littoral, montagne)
> - `P22_LOGVAC / P22_LOG` élevé = zone en déclin démographique
> - `P22_RP_PROP / P22_RP` élevé = zone rurale, population stable

#### 💰 4. Revenus et pauvreté

| N° | Code | Libellé complet | Type | Unité | Source | Année |
|----|------|-----------------|------|-------|--------|-------|
| 15 | `NBMENFISC21` | Nombre de ménages fiscaux | NUM | ménages | Filosofi | 2021 |
| 16 | `PIMP21` | Part des ménages fiscaux imposés | NUM | % | Filosofi | 2021 |
| 17 | `MED21` | Médiane du niveau de vie | NUM | € / an | Filosofi | 2021 |
| 18 | `TP6021` | Taux de pauvreté (seuil à 60%) | NUM | % | Filosofi | 2021 |

> **Définitions** :
> - **Niveau de vie** = revenu disponible du ménage / nombre d'UC (unités de consommation)
> - **Médiane** = 50% des habitants ont un niveau de vie inférieur
> - **Taux de pauvreté** = part de la population sous le seuil de pauvreté (60% du niveau de vie médian national ≈ 13 000 €/an)
>
> **Interprétation** :
> - `MED21` élevé (> 25 000 €) = commune aisée
> - `TP6021` > 20% = commune en difficulté sociale

#### 💼 5. Emploi et activité

| N° | Code | Libellé complet | Type | Unité | Source | Année |
|----|------|-----------------|------|-------|--------|-------|
| 19 | `P22_EMPLT` | Nombre d'emplois au lieu de travail | NUM | emplois | RP | 2022 |
| 20 | `P22_EMPLT_SAL` | Nombre d'emplois salariés au lieu de travail | NUM | emplois | RP | 2022 |
| 21 | `P16_EMPLT` | Nombre d'emplois au lieu de travail | NUM | emplois | RP | 2016 |
| 22 | `P22_POP1564` | Population de 15 à 64 ans | NUM | habitants | RP | 2022 |
| 23 | `P22_CHOM1564` | Chômeurs de 15 à 64 ans | NUM | personnes | RP | 2022 |
| 24 | `P22_ACT1564` | Actifs de 15 à 64 ans | NUM | personnes | RP | 2022 |

> **Formules utiles** :
> - **Taux de chômage** = `P22_CHOM1564 / P22_ACT1564 × 100`
> - **Taux d'activité** = `P22_ACT1564 / P22_POP1564 × 100`
> - **Ratio emploi/population** = `P22_EMPLT / P22_POP1564 × 100`
>
> **Interprétation** :
> - `P22_EMPLT / P22_POP` > 0.5 = pôle d'emploi (plus d'emplois que d'habitants actifs)
> - `P22_EMPLT - P16_EMPLT` = création/destruction d'emplois sur 6 ans

#### 🏭 6. Établissements économiques (REE-Sirene 2023)

| N° | Code | Libellé complet | Type | Unité | Secteur NAF |
|----|------|-----------------|------|-------|-------------|
| 25 | `ETTOT23` | Nombre total d'établissements actifs | NUM | établ. | Tous |
| 26 | `ETAZ23` | Nombre d'établissements actifs de l'agriculture, sylviculture et pêche | NUM | établ. | Section A |
| 27 | `ETBE23` | Nombre d'établissements actifs de l'industrie | NUM | établ. | Sections B-E |
| 28 | `ETFZ23` | Nombre d'établissements actifs de la construction | NUM | établ. | Section F |
| 29 | `ETGU23` | Nombre d'établissements actifs du commerce, transports et services divers | NUM | établ. | Sections G-U (hors O-Q) |
| 30 | `ETOQ23` | Nombre d'établissements actifs de l'administration publique, enseignement, santé et action sociale | NUM | établ. | Sections O-Q |
| 31 | `ETTEF123` | Nombre d'établissements actifs de 1 à 9 salariés | NUM | établ. | Tous |
| 32 | `ETTEFP1023` | Nombre d'établissements actifs de 10 salariés ou plus | NUM | établ. | Tous |

> **Vérification** : `ETTOT23 = ETAZ23 + ETBE23 + ETFZ23 + ETGU23 + ETOQ23`
>
> **Nomenclature NAF (sections)** :
> - **A** : Agriculture, sylviculture, pêche
> - **B-E** : Industries extractives, manufacturières, énergie, eau
> - **F** : Construction
> - **G-U** : Commerce, transport, hébergement, information, finance, immobilier, services...
> - **O** : Administration publique
> - **P** : Enseignement
> - **Q** : Santé humaine et action sociale
>
> **Interprétation** :
> - `ETAZ23 / ETTOT23` élevé = commune rurale/agricole
> - `ETGU23 / ETTOT23` élevé = commune tertiaire/urbaine
> - `ETTEFP1023 / ETTOT23` élevé = présence de moyennes/grandes entreprises

---

## 🔢 Variables de l'analyse ACP

### Pourquoi transformer les variables ?
Les variables brutes (effectifs) dépendent de la **taille de la commune** :
- Paris a 2 millions d'habitants, Rochefourchat (Drôme) en a 1
- Comparer les valeurs brutes n'a pas de sens statistique

**Solution** : Calculer des **ratios, taux et pourcentages** qui sont comparables quelle que soit la taille de la commune.

### 12 Variables quantitatives actives

Ces 12 variables dérivées sont utilisées pour l'ACP :

| N° | Variable créée | Formule de calcul | Interprétation | Unité |
|----|----------------|-------------------|----------------|-------|
| 1 | `densite_pop` | `P22_POP / SUPERF` | Concentration spatiale de la population | hab/km² |
| 2 | `taux_natalite` | `(NAIS1621 / 6) / P22_POP × 1000` | Dynamisme démographique, jeunesse | ‰ |
| 3 | `taux_mortalite` | `(DECE1621 / 6) / P22_POP × 1000` | Vieillissement de la population | ‰ |
| 4 | `taux_res_secondaires` | `P22_RSECOCC / P22_LOG × 100` | Attractivité touristique, littoral/montagne | % |
| 5 | `taux_logements_vacants` | `P22_LOGVAC / P22_LOG × 100` | Désertification, déclin démographique | % |
| 6 | `taux_proprietaires` | `P22_RP_PROP / P22_RP × 100` | Stabilité résidentielle, ruralité | % |
| 7 | `MED21` | Variable brute INSEE | Niveau de vie médian | €/an |
| 8 | `TP6021` | Variable brute INSEE | Précarité économique | % |
| 9 | `taux_chomage` | `P22_CHOM1564 / P22_ACT1564 × 100` | Dynamisme économique (inverse) | % |
| 10 | `pct_agriculture` | `ETAZ23 / ETTOT23 × 100` | Ruralité, activité primaire | % |
| 11 | `pct_industrie` | `ETBE23 / ETTOT23 × 100` | Tissu industriel historique | % |
| 12 | `pct_services` | `ETGU23 / ETTOT23 × 100` | Tertiarisation, urbanité | % |

### Variable qualitative illustrative

| Variable | Définition | Rôle dans l'ACP |
|----------|------------|-----------------|
| `departement` | 2 premiers caractères de CODGEO | Ne participe pas au calcul, aide à l'interprétation |

### Corrélations attendues entre variables

```
Variables corrélées positivement (→) :
  • densite_pop ↔ pct_services (urbanisation)
  • taux_natalite ↔ MED21 (communes aisées et jeunes)
  • taux_mortalite ↔ pct_agriculture (communes rurales vieillissantes)
  • taux_logements_vacants ↔ pct_agriculture (déclin rural)

Variables corrélées négativement (↔) :
  • densite_pop ↔ pct_agriculture (urbain vs rural)
  • MED21 ↔ TP6021 (richesse vs pauvreté)
  • taux_proprietaires ↔ densite_pop (rural vs urbain)
  • pct_services ↔ pct_agriculture (tertiaire vs primaire)
```

---

## 🎯 L'ACP en 5 étapes (PICCI)

### Mnémonique PICCI
> **P**réparation → **I**nertie → **C**ercle → **C**ontributions → **I**ndividus

### Étape 1 : **P**réparation
**But** : Préparer les données pour l'analyse

| Action | Fonction R | Explication |
|--------|-----------|-------------|
| Charger les données | `read.csv()` | Importation du CSV |
| Sélectionner variables | `df[, vars]` | Garder les variables pertinentes |
| Nettoyer les NA | `na.omit()` | Supprimer les lignes incomplètes |
| Centrer-réduire | `scale.unit = TRUE` | Ramener à même échelle |

**Pourquoi centrer-réduire ?**
- Revenu médian : 18 000 - 40 000 €
- Taux de chômage : 0 - 30 %
- Sans normalisation, le revenu dominerait l'analyse !

### Étape 2 : **I**nertie (valeurs propres)
**But** : Déterminer combien d'axes garder

| Critère | Méthode | Application |
|---------|---------|-------------|
| Kaiser | λ > 1 | Garder les axes avec valeur propre > 1 |
| Coude | Visuel | Là où la courbe "casse" |
| Bâton brisé | Statistique | Comparer aux valeurs aléatoires |
| 80% inertie | Cumulé | Garder assez d'axes pour 80% |

**Fonctions R** : `fviz_eig()`, `brokenStick()`

### Étape 3 : **C**ercle des corrélations
**But** : Comprendre les relations entre variables

**Lecture du cercle :**
| Position | Signification |
|----------|---------------|
| Variable longue (près du cercle) | Bien représentée sur ce plan |
| Variables proches | Corrélées positivement |
| Variables opposées | Corrélées négativement |
| Variables perpendiculaires | Non corrélées |

**Fonction R** : `fviz_pca_var()`

### Étape 4 : **C**ontributions (CTR)
**But** : Identifier qui "fabrique" les axes

**Contribution (CTR)** = part de l'inertie d'un axe due à une variable/individu

| Si CTR... | Alors... |
|-----------|----------|
| > 100/p | Contribue fortement |
| ≈ 100/p | Contribue moyennement |
| < 100/p | Contribue faiblement |

Avec p = 12 variables → seuil = 100/12 = **8,3%**

**Fonctions R** : `fviz_contrib()`, `res.acp$var$contrib`

### Étape 5 : **I**ndividus
**But** : Projeter et interpréter les communes

| Analyse | Question | Fonction R |
|---------|----------|------------|
| Projection | Où se situent les communes ? | `fviz_pca_ind()` |
| Qualité | Sont-elles bien représentées ? | cos² |
| Contribution | Lesquelles "tirent" les axes ? | CTR |
| Biplot | Vue d'ensemble | `fviz_pca_biplot()` |

---

## 🔧 Fonctions R utilisées

### Packages chargés
```r
# "FaCoCo GPS" - mnémonique
library(FactoMineR)   # Fa - moteur ACP
library(factoextra)   # Co - graphiques ACP
library(corrplot)     # Co - matrices corrélation
library(ggplot2)      # G - graphiques avancés
library(psych)        # P - statistiques descriptives
library(skimr)        # S - résumé données
library(PCDimension)  # Bâton brisé
```

### Tableau des fonctions par étape

| Étape | Fonction | Package | Usage |
|-------|----------|---------|-------|
| **Préparation** |
| | `read.csv()` | base | Charger le CSV |
| | `na.omit()` | base | Supprimer les NA |
| | `cor()` | base | Matrice de corrélation |
| | `describe()` | psych | Stats descriptives |
| | `corrplot()` | corrplot | Visualiser corrélations |
| **ACP** |
| | `PCA()` | FactoMineR | Réaliser l'ACP |
| **Inertie** |
| | `fviz_eig()` | factoextra | Éboulis valeurs propres |
| | `brokenStick()` | PCDimension | Critère bâton brisé |
| **Variables** |
| | `fviz_pca_var()` | factoextra | Cercle corrélations |
| | `fviz_contrib()` | factoextra | Barplot contributions |
| | `fviz_cos2()` | factoextra | Qualité représentation |
| **Individus** |
| | `fviz_pca_ind()` | factoextra | Nuage des individus |
| | `fviz_pca_biplot()` | factoextra | Biplot ind + var |
| **Interprétation** |
| | `dimdesc()` | FactoMineR | Description des axes |

### Accès aux résultats (objet `res.acp`)

| Élément | Code R | Contenu |
|---------|--------|---------|
| Valeurs propres | `res.acp$eig` | λ, %, % cumulé |
| Coord. variables | `res.acp$var$coord` | Corrélations var-axes |
| Contrib. variables | `res.acp$var$contrib` | CTR des variables |
| Cos² variables | `res.acp$var$cos2` | Qualité variables |
| Coord. individus | `res.acp$ind$coord` | Position des communes |
| Contrib. individus | `res.acp$ind$contrib` | CTR des communes |
| Cos² individus | `res.acp$ind$cos2` | Qualité communes |

---

## 📈 Interprétation des résultats

### Lecture du cercle de corrélations
```
           +
           |     • taux_res_secondaires
           |     
     ------+------→ Axe 1 (ex: urbain/rural)
           |
           |     • pct_agriculture
           -
           Axe 2 (ex: riche/pauvre)
```

### Profils types attendus

| Profil | Caractéristiques | Position attendue |
|--------|------------------|-------------------|
| **Urbain dense** | Forte densité, services, loyers | Droite du plan |
| **Rural agricole** | Agriculture, propriétaires, faible densité | Gauche du plan |
| **Touristique** | Résidences secondaires, services | Haut du plan |
| **Industriel** | Industrie, emploi, ouvriers | Position spécifique |
| **Précarisé** | Chômage, pauvreté élevés | Selon axes |

### Questions d'interprétation
1. **Axe 1** : Quelle est l'opposition principale ?
2. **Axe 2** : Quelle nuance apporte-t-il ?
3. **Variables** : Lesquelles sont les plus discriminantes ?
4. **Communes atypiques** : Lesquelles sont loin du centre ?

---

## 🧠 Mnémotechniques étudiant

### PICCI - Les 5 étapes
| Lettre | Étape | Action |
|--------|-------|--------|
| **P** | Préparation | Charger, nettoyer, centrer-réduire |
| **I** | Inertie | Valeurs propres, scree plot |
| **C** | Cercle | Corrélations variables-axes |
| **C** | Contributions | Qui contribue à quoi ? |
| **I** | Individus | Projection des observations |

### COS² = "Combien On Se fie"
- cos² proche de 1 → **bien représenté** ✅
- cos² proche de 0 → **mal représenté** ⚠️
- **Interprétation** : qualité de la projection sur le plan

### CTR = "Combien Tu Représentes"
- CTR > 100/p → **forte contribution**
- CTR = 100/p → **contribution moyenne**
- CTR < 100/p → **faible contribution**
- **Seuil pour 12 variables** : 100/12 = **8,3%**

### Règle du COUDE
> Le coude = là où la courbe d'inertie **"casse"**

C'est le nombre d'axes à retenir visuellement sur l'éboulis.

### FaCoCo GPS - Les packages
| Mnémo | Package | Rôle |
|-------|---------|------|
| **Fa** | FactoMineR | Moteur ACP |
| **Co** | factoextra | Beaux graphiques |
| **Co** | corrplot | Matrices corrélation |
| **G** | ggplot2 | Graphiques avancés |
| **P** | psych | Stats descriptives |
| **S** | skimr | Résumé données |

### Lecture du cercle
| Configuration | Signification |
|---------------|---------------|
| Variables **longues** | Bien représentées |
| Variables **proches** | Corrélées (+) |
| Variables **opposées** | Corrélées (-) |
| Variables **perpendiculaires** | Non corrélées |

---

## 📁 Structure du projet

```
ACPCCM1/
├── README.md                          # Ce fichier
├── base_cc_comparateur.csv            # Données INSEE (8 MB)
├── meta_base_cc_comparateur.csv       # Dictionnaire des variables
├── base_cc_comparateur_csv.zip        # Archive source
└── data/
    └── PCA/
        └── ACP_INSEE_Communes.R       # Script R de l'analyse
```

---

## 📚 Références

1. **Cours E. Périnel** - M1 Statistique, 2024-2025
2. **INSEE** - Base du comparateur de territoires
   - https://www.insee.fr/fr/statistiques/2521169
3. **FactoMineR** - Documentation
   - http://factominer.free.fr/
4. **factoextra** - Package R
   - https://rpkgs.datanovia.com/factoextra/

---

## ✍️ Auteur
Cheriet Abdelmalek M1 Statistique - Université de Strasbourg

Date : Janvier 2025
