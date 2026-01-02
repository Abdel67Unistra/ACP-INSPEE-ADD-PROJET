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

## 📊 Sorties R détaillées et leur interprétation

Cette section décrit en détail chaque sortie produite par le script R `ACP_INSEE_Communes.R`.

### 1️⃣ Sortie : Structure des données

```r
cat("Nombre de communes:", nrow(insee), "\n")
cat("Nombre de variables:", ncol(insee), "\n")
```

**Exemple de sortie :**
```
=== STRUCTURE DES DONNÉES ===
Nombre de communes: 34935
Nombre de variables: 32
```

**Interprétation :**
- **34 935 communes** = individus statistiques (lignes)
- **32 variables** = colonnes du fichier INSEE brut
- Après nettoyage (NA, valeurs aberrantes), ce nombre peut diminuer

---

### 2️⃣ Sortie : Statistiques descriptives (`describe()`)

```r
print(describe(df_acp[, var_quanti]))
```

**Exemple de sortie :**
```
                        vars     n     mean       sd   median  trimmed    mad
densite_pop                1 28456   372.41  1842.67    45.12   108.42  53.21
taux_natalite              2 28456     8.92     4.21     8.45     8.71   3.18
taux_mortalite             3 28456    11.87     5.64    11.12    11.45   4.82
taux_res_secondaires       4 28456    12.45    18.72     4.21     8.12   5.94
taux_logements_vacants     5 28456     8.34     6.89     6.78     7.45   4.12
taux_proprietaires         6 28456    72.45    14.32    75.12    73.89  12.45
MED21                      7 28456 21245.00  4512.00 20845.00 20912.00 3245.00
TP6021                     8 28456    12.34     7.45    10.89    11.45   5.67
taux_chomage               9 28456     8.45     4.12     7.89     8.12   3.45
pct_agriculture           10 28456    18.45    22.34    10.12    14.23  12.34
pct_industrie             11 28456     6.78     8.45     4.12     5.23   4.56
pct_services              12 28456    52.34    18.45    54.12    53.45  16.78
```

**Comment lire ce tableau :**

| Colonne | Signification | Utilité |
|---------|---------------|---------|
| `vars` | Numéro de la variable | Identification |
| `n` | Nombre d'observations valides | Données manquantes = total - n |
| `mean` | Moyenne arithmétique | Tendance centrale |
| `sd` | Écart-type | Dispersion autour de la moyenne |
| `median` | Médiane (50e percentile) | Robuste aux valeurs extrêmes |
| `trimmed` | Moyenne tronquée (5%) | Moyenne sans les extrêmes |
| `mad` | Écart absolu médian | Dispersion robuste |
| `min/max` | Valeurs extrêmes | Détection d'anomalies |
| `skew` | Asymétrie | >0 = queue à droite, <0 = queue à gauche |
| `kurtosis` | Aplatissement | >0 = pointue, <0 = aplatie |

**Points d'attention :**
- `densite_pop` : moyenne >> médiane → distribution très asymétrique (quelques grandes villes)
- `pct_agriculture` : forte variabilité (sd élevé) → grande hétérogénéité rurale
- `MED21` : médiane ~21 000 € → niveau de vie médian des communes

---

### 3️⃣ Sortie : Matrice de corrélation

```r
mat.cor <- round(cor(df_acp[, var_quanti], use = "complete.obs"), 3)
print(mat.cor)
```

**Exemple de sortie (extrait) :**
```
                       densite_pop taux_natalite taux_mortalite taux_res_sec
densite_pop                  1.000         0.312         -0.245       -0.321
taux_natalite                0.312         1.000         -0.456       -0.178
taux_mortalite              -0.245        -0.456          1.000        0.234
taux_res_secondaires        -0.321        -0.178          0.234        1.000
MED21                        0.287         0.412         -0.312       -0.089
TP6021                      -0.156        -0.289          0.178        0.045
pct_agriculture             -0.567        -0.234          0.389        0.412
pct_services                 0.534         0.198         -0.278       -0.312
```

**Comment interpréter :**

| Valeur de r | Interprétation |
|-------------|----------------|
| r > 0.7 | Corrélation forte positive |
| 0.4 < r < 0.7 | Corrélation modérée positive |
| 0.2 < r < 0.4 | Corrélation faible positive |
| -0.2 < r < 0.2 | Pas de corrélation linéaire |
| -0.7 < r < -0.4 | Corrélation modérée négative |
| r < -0.7 | Corrélation forte négative |

**Corrélations clés à observer :**
- `densite_pop` ↔ `pct_agriculture` = **-0.567** (opposition urbain/rural)
- `MED21` ↔ `TP6021` = **négative** (richesse vs pauvreté)
- `taux_natalite` ↔ `taux_mortalite` = **-0.456** (structure d'âge)

---

### 4️⃣ Sortie : Valeurs propres (`res.acp$eig`)

```r
print(res.acp$eig)
```

**Exemple de sortie :**
```
       eigenvalue percentage of variance cumulative percentage of variance
comp 1   3.456789              28.806575                          28.80658
comp 2   2.123456              17.695467                          46.50204
comp 3   1.567890              13.065750                          59.56779
comp 4   1.098765               9.156375                          68.72417
comp 5   0.876543               7.304525                          76.02869
comp 6   0.654321               5.452675                          81.48137
...
```

**Comment lire ce tableau :**

| Colonne | Signification | Exemple Dim1 |
|---------|---------------|--------------|
| `eigenvalue` | Valeur propre (λ) | 3.46 |
| `percentage of variance` | % d'inertie expliquée | 28.8% |
| `cumulative percentage` | % cumulé | 28.8% |

**Règles de décision :**

```
┌────────────────────────────────────────────────────────────────┐
│ CRITÈRE DE KAISER : Garder les axes avec λ > 1                 │
│ → Dans l'exemple : axes 1, 2, 3, 4 (4 axes)                    │
├────────────────────────────────────────────────────────────────┤
│ CRITÈRE DU COUDE : Là où l'éboulis "casse"                     │
│ → Observation visuelle du scree plot                           │
├────────────────────────────────────────────────────────────────┤
│ CRITÈRE 80% : Garder assez d'axes pour 80% d'inertie          │
│ → Dans l'exemple : 6 axes pour atteindre 81.5%                 │
└────────────────────────────────────────────────────────────────┘
```

**Inertie totale :**
- En ACP normée : inertie totale = nombre de variables = **12**
- Somme des valeurs propres = 12

---

### 5️⃣ Sortie : Coordonnées des variables (`res.acp$var$coord`)

```r
print(round(res.acp$var$coord[, 1:5], 3))
```

**Exemple de sortie :**
```
                         Dim.1   Dim.2   Dim.3   Dim.4   Dim.5
densite_pop              0.734  -0.312   0.145  -0.089   0.056
taux_natalite            0.523   0.456  -0.234   0.178  -0.098
taux_mortalite          -0.456  -0.234   0.567   0.123   0.234
taux_res_secondaires    -0.389   0.678  -0.145   0.234  -0.123
taux_logements_vacants  -0.312   0.123   0.456  -0.345   0.178
taux_proprietaires      -0.567  -0.234   0.178   0.456  -0.089
MED21                    0.612   0.345  -0.178  -0.123   0.234
TP6021                  -0.456  -0.178   0.234   0.089  -0.156
taux_chomage            -0.345  -0.234   0.123   0.178   0.345
pct_agriculture         -0.789  -0.123   0.234   0.345  -0.178
pct_industrie           -0.234   0.089   0.567  -0.234   0.123
pct_services             0.812  -0.178  -0.234   0.089   0.145
```

**Comment interpréter :**
- Ces coordonnées sont les **corrélations variable-axe** (en ACP normée)
- |coord| proche de 1 = variable très liée à l'axe
- Signe positif = même sens que l'axe
- Signe négatif = sens opposé à l'axe

**Lecture de l'exemple :**
- **Axe 1** (28.8% d'inertie) :
  - Variables positives : `pct_services` (0.81), `densite_pop` (0.73), `MED21` (0.61)
  - Variables négatives : `pct_agriculture` (-0.79), `taux_proprietaires` (-0.57)
  - → **Axe 1 = opposition URBAIN (droite) / RURAL (gauche)**

- **Axe 2** (17.7% d'inertie) :
  - Variables positives : `taux_res_secondaires` (0.68), `taux_natalite` (0.46)
  - Variables négatives : `densite_pop` (-0.31)
  - → **Axe 2 = dimension TOURISTIQUE / RÉSIDENTIEL**

---

### 6️⃣ Sortie : Contributions des variables (`res.acp$var$contrib`)

```r
print(round(res.acp$var$contrib[, 1:5], 2))
```

**Exemple de sortie :**
```
                         Dim.1  Dim.2  Dim.3  Dim.4  Dim.5
densite_pop              15.58   4.59   1.34   0.72   0.36
taux_natalite             7.91   9.79   3.49   2.89   1.10
taux_mortalite            6.01   2.58  20.49   1.38   6.26
taux_res_secondaires      4.37  21.64   1.34   4.99   1.73
taux_logements_vacants    2.82   0.71  13.26  10.84   3.62
taux_proprietaires        9.29   2.58   2.02  18.94   0.91
MED21                    10.83   5.60   2.02   1.38   6.26
TP6021                    6.01   1.49   3.49   0.72   2.78
taux_chomage              3.44   2.58   0.96   2.89  13.61
pct_agriculture          18.01   0.71   3.49  10.84   3.62
pct_industrie             1.58   0.37  20.49   4.99   1.73
pct_services             19.07   1.49   3.49   0.72   2.40
```

**Comment interpréter :**
- **Contribution = % de l'inertie de l'axe dû à cette variable**
- Somme des contributions d'un axe = 100%
- **Seuil théorique** = 100/12 = **8.33%**
- CTR > 8.33% → contribution significative

**Lecture de l'exemple (Axe 1) :**
```
Variables qui "fabriquent" l'axe 1 :
  ✓ pct_services      : 19.07% (> 8.33%) → FORT
  ✓ pct_agriculture   : 18.01% (> 8.33%) → FORT
  ✓ densite_pop       : 15.58% (> 8.33%) → FORT
  ✓ MED21             : 10.83% (> 8.33%) → MODÉRÉ
  ✓ taux_proprietaires:  9.29% (> 8.33%) → MODÉRÉ
  ✗ taux_chomage      :  3.44% (< 8.33%) → FAIBLE
```

---

### 7️⃣ Sortie : Qualité de représentation (`res.acp$var$cos2`)

```r
print(round(res.acp$var$cos2[, 1:5], 3))
```

**Exemple de sortie :**
```
                         Dim.1  Dim.2  Dim.3  Dim.4  Dim.5
densite_pop              0.539  0.097  0.021  0.008  0.003
taux_natalite            0.274  0.208  0.055  0.032  0.010
taux_mortalite           0.208  0.055  0.321  0.015  0.055
taux_res_secondaires     0.151  0.460  0.021  0.055  0.015
...
```

**Comment interpréter :**
- **cos² = (coordonnée)²**
- cos² = qualité de représentation sur cet axe
- **Somme cos² sur tous les axes = 1** (pour chaque variable)
- cos² > 0.5 sur un axe → variable bien représentée par cet axe

**Qualité sur le plan 1-2 :**
```r
cos2_plan12 <- res.acp$var$cos2[, 1] + res.acp$var$cos2[, 2]
```

| Variable | cos² Plan 1-2 | Interprétation |
|----------|---------------|----------------|
| > 0.7 | Très bien représentée ✅ |
| 0.5 - 0.7 | Bien représentée |
| 0.3 - 0.5 | Moyennement représentée |
| < 0.3 | Mal représentée ⚠️ → regarder autres plans |

---

### 8️⃣ Sortie : Description des axes (`dimdesc()`)

```r
desc <- dimdesc(res.acp, axes = 1:3)
print(desc$Dim.1)
```

**Exemple de sortie :**
```
$quanti
                      correlation      p.value
pct_services             0.812345 1.234567e-89
densite_pop              0.734567 2.345678e-78
MED21                    0.612345 3.456789e-56
taux_natalite            0.523456 4.567890e-45
pct_agriculture         -0.789012 5.678901e-84
taux_proprietaires      -0.567890 6.789012e-52
taux_mortalite          -0.456789 7.890123e-34
TP6021                  -0.456123 8.901234e-33
```

**Comment interpréter :**
- Variables triées par corrélation avec l'axe
- **Positives en haut** = même sens que l'axe
- **Négatives en bas** = sens opposé
- p-value < 0.05 = corrélation significative

**Synthèse Axe 1 :**
```
┌─────────────────────────────────────────────────────────────────┐
│                    INTERPRÉTATION AXE 1                         │
├─────────────────────────────────────────────────────────────────┤
│ CÔTÉ POSITIF (+)        │ CÔTÉ NÉGATIF (-)                      │
│ • Services élevés       │ • Agriculture élevée                  │
│ • Forte densité         │ • Fort taux propriétaires             │
│ • Revenus élevés        │ • Mortalité élevée                    │
│ • Natalité élevée       │ • Pauvreté élevée                     │
├─────────────────────────────────────────────────────────────────┤
│ → COMMUNES URBAINES     │ → COMMUNES RURALES                    │
│   AISÉES               │    VIEILLISSANTES                     │
└─────────────────────────────────────────────────────────────────┘
```

---

### 9️⃣ Sortie : Coordonnées des individus (`res.acp$ind$coord`)

```r
head(res.acp$ind$coord[, 1:3], 10)
```

**Exemple de sortie :**
```
           Dim.1    Dim.2    Dim.3
01001     -2.345    0.456   -0.123
01002     -1.234    0.789   -0.234
01004     -0.567    1.234    0.456
...
75056     12.345   -2.345    1.234   # Paris
13055      8.456   -1.567    0.789   # Marseille
69123      7.234   -0.987    0.567   # Lyon
```

**Comment interpréter :**
- Chaque ligne = une commune
- Coordonnées = position sur les axes factoriels
- Valeurs extrêmes = communes atypiques

**Exemples d'interprétation :**
- `75056` (Paris) : Dim1 = +12.34 → très urbain, tertiaire
- `01001` : Dim1 = -2.34 → plutôt rural

---

### 🔟 Sortie : Top contributeurs (`res.acp$ind$contrib`)

```r
top_contrib_1 <- head(sort(res.acp$ind$contrib[, 1], decreasing = TRUE), 20)
print(round(top_contrib_1, 3))
```

**Exemple de sortie :**
```
    75056     13055     69123     31555     33063 
    2.456     1.234     0.987     0.876     0.765 
    59350     06088     44109     67482     34172 
    0.654     0.543     0.432     0.321     0.298
```

**Comment interpréter :**
- **Contribution individuelle** = part de l'inertie de l'axe due à cette commune
- Les grandes villes contribuent fortement (effet de levier)
- Seuil théorique = 100/n ≈ 100/28000 ≈ **0.0036%**
- CTR > 0.5% → commune très influente sur l'axe

**Communes les plus influentes (Axe 1) :**
| Code | Commune | CTR Dim1 | Interprétation |
|------|---------|----------|----------------|
| 75056 | Paris | 2.46% | Métropole ultra-urbaine |
| 13055 | Marseille | 1.23% | Grande métropole |
| 69123 | Lyon | 0.99% | Grande métropole |

---

### 📊 Graphiques produits et leur lecture

#### Graphique 1 : Matrice de corrélation (`corrplot`)

**Code R :**
```r
X11()
corrplot(mat.cor, method = "color", type = "lower", ...)
```

**Description :**
- Matrice triangulaire inférieure
- Couleurs : bleu = corrélation positive, rouge = négative
- Intensité = force de la corrélation

**Ce qu'il faut observer :**
- Blocs de variables corrélées (structures)
- Variables isolées (spécifiques)
- Corrélations fortes négatives (oppositions)

---

#### Graphique 2 : Éboulis des valeurs propres (`fviz_eig`)

**Code R :**
```r
X11()
fviz_eig(res.acp, addlabels = TRUE, ylim = c(0, 35))
```

**Description :**
- Barres : % d'inertie par axe
- Courbe : % cumulé (optionnel)
- Ligne rouge (Kaiser) : seuil λ = 1

**Ce qu'il faut observer :**
- Position du "coude" (cassure de la pente)
- Nombre de barres au-dessus de 100/p
- Combien d'axes pour ~80% d'inertie

---

#### Graphique 3 : Cercle des corrélations (`fviz_pca_var`)

**Code R :**
```r
X11()
fviz_pca_var(res.acp, col.var = "contrib", repel = TRUE)
```

**Description :**
- Cercle de rayon 1
- Flèches = variables
- Longueur = qualité de représentation
- Couleur = contribution (gradient)

**Règles de lecture :**
```
┌────────────────────────────────────────────────────────────────┐
│ LECTURE DU CERCLE DES CORRÉLATIONS                             │
├────────────────────────────────────────────────────────────────┤
│ • Variable PROCHE du cercle → bien représentée                 │
│ • Variables PROCHES entre elles → corrélées positivement       │
│ • Variables OPPOSÉES → corrélées négativement                  │
│ • Variables à 90° → non corrélées                              │
│ • Variable COURTE → mal représentée (regarder autre plan)      │
└────────────────────────────────────────────────────────────────┘
```

---

#### Graphique 4 : Contributions des variables (`fviz_contrib`)

**Code R :**
```r
X11()
fviz_contrib(res.acp, choice = "var", axes = 1)
```

**Description :**
- Barres horizontales
- Ligne rouge pointillée = seuil 100/p
- Barres au-dessus = contribuent significativement

**Ce qu'il faut observer :**
- Quelles variables dépassent le seuil
- Équilibre ou dominance de certaines variables

---

#### Graphique 5 : Nuage des individus (`fviz_pca_ind`)

**Code R :**
```r
X11()
fviz_pca_ind(res.acp, col.ind = "cos2", pointsize = 1)
```

**Description :**
- Chaque point = une commune
- Position = coordonnées factorielles
- Couleur = qualité de représentation (cos²)

**Ce qu'il faut observer :**
- Forme du nuage (allongé, rond, groupes)
- Points extrêmes (atypiques)
- Concentration vs dispersion

---

#### Graphique 6 : Biplot (`fviz_pca_biplot`)

**Code R :**
```r
X11()
fviz_pca_biplot(res.acp, repel = TRUE, col.var = "#2E9FDF")
```

**Description :**
- Superposition individus + variables
- Permet de voir quelles communes correspondent à quelles caractéristiques

**Ce qu'il faut observer :**
- Communes proches de certaines variables
- Interprétation conjointe individus/variables

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
