# ACP - Base Comparateur de Territoires INSEE
## Analyse en Composantes Principales des communes françaises
### Master 1 Statistique - Cours E. Périnel (2024-2025)

---

## 📖 Table des matières
1. [Mise en situation](#mise-en-situation)
2. [Les données INSEE](#les-données-insee)
3. [Variables de l'analyse](#variables-de-lanalyse)
4. [L'ACP en 5 étapes (PICCI)](#lacp-en-5-étapes-picci)
5. [Fonctions R utilisées](#fonctions-r-utilisées)
6. [Interprétation des résultats](#interprétation-des-résultats)
7. [Mnémotechniques étudiant](#mnémotechniques-étudiant)

---

## 📍 Mise en situation

### Contexte
La **Base du comparateur de territoires** est une base de données produite par l'**INSEE** (Institut National de la Statistique et des Études Économiques) qui rassemble une trentaine d'indicateurs clés décrivant les **35 000+ communes françaises**.

### Pourquoi cette ACP ?
En tant que statisticien, on vous demande d'analyser la **diversité des territoires français**. Chaque commune est caractérisée par de nombreuses variables : démographie, logement, revenus, emploi, activité économique...

**Questions posées :**
- Quelles sont les grandes dimensions qui structurent les différences entre communes ?
- Peut-on identifier des profils de territoires ? (urbain/rural, riche/pauvre, touristique...)
- Quelles variables sont les plus discriminantes ?

### Intérêt de l'ACP
L'ACP permet de :
1. **Réduire la dimensionnalité** : passer de 12 variables à 2-3 axes synthétiques
2. **Visualiser** les relations entre communes
3. **Identifier** les variables qui expliquent le plus les différences
4. **Détecter** des groupes de communes similaires

### Source des données
- **Producteur** : INSEE
- **URL** : https://www.insee.fr/fr/statistiques/2521169
- **Fichier** : `base_cc_comparateur.csv`
- **Année de référence** : 2021-2023 (selon les variables)
- **Unité statistique** : Commune (code CODGEO)

---

## 📊 Les données INSEE

### Description générale
| Caractéristique | Valeur |
|-----------------|--------|
| Nombre d'observations | ~35 000 communes |
| Nombre de variables brutes | 32 |
| Séparateur CSV | Point-virgule (;) |
| Valeurs manquantes | "s" (secret statistique), vides |

### Variables brutes disponibles
| Code | Description |
|------|-------------|
| CODGEO | Code commune |
| P22_POP | Population 2022 |
| SUPERF | Superficie (km²) |
| NAIS1621 | Naissances 2016-2021 |
| DECE1621 | Décès 2016-2021 |
| P22_MEN | Ménages 2022 |
| P22_LOG | Logements 2022 |
| P22_RP | Résidences principales |
| P22_RSECOCC | Résidences secondaires |
| P22_LOGVAC | Logements vacants |
| P22_RP_PROP | Résidences principales propriétaires |
| MED21 | Médiane niveau de vie 2021 (€) |
| TP6021 | Taux de pauvreté 2021 (%) |
| P22_EMPLT | Emplois 2022 |
| P22_CHOM1564 | Chômeurs 15-64 ans |
| P22_ACT1564 | Actifs 15-64 ans |
| ETTOT23 | Total établissements 2023 |
| ETAZ23 | Établissements agriculture |
| ETBE23 | Établissements industrie |
| ETFZ23 | Établissements construction |
| ETGU23 | Établissements commerce/services |
| ETOQ23 | Établissements admin publique |

---

## 🔢 Variables de l'analyse

### Transformation des variables
Pour l'ACP, on utilise des **ratios et taux** plutôt que des valeurs brutes car :
- Les valeurs brutes dépendent de la **taille de la commune**
- Paris a plus de logements que Plouescat juste par sa taille
- Les ratios permettent de **comparer** des communes de tailles différentes

### 12 Variables quantitatives actives

| N° | Variable | Formule | Interprétation |
|----|----------|---------|----------------|
| 1 | `densite_pop` | Population / Superficie | Concentration humaine |
| 2 | `taux_natalite` | (Naissances/6) / Pop × 1000 | Dynamisme démographique |
| 3 | `taux_mortalite` | (Décès/6) / Pop × 1000 | Vieillissement |
| 4 | `taux_res_secondaires` | Rés. secondaires / Logements × 100 | Attractivité touristique |
| 5 | `taux_logements_vacants` | Log. vacants / Logements × 100 | Désertification |
| 6 | `taux_proprietaires` | Propriétaires / Rés. principales × 100 | Stabilité résidentielle |
| 7 | `MED21` | Variable brute (€) | Niveau de vie médian |
| 8 | `TP6021` | Variable brute (%) | Précarité économique |
| 9 | `taux_chomage` | Chômeurs / Actifs × 100 | Dynamisme économique |
| 10 | `pct_agriculture` | Établ. agri / Total × 100 | Ruralité |
| 11 | `pct_industrie` | Établ. indus / Total × 100 | Tissu industriel |
| 12 | `pct_services` | Établ. services / Total × 100 | Tertiarisation |

### Variable qualitative illustrative
- **Département** : extrait du code commune (2 premiers caractères)
- Ne participe pas au calcul mais aide à l'interprétation

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
Étudiant M1 Statistique - Université de Strasbourg

Date : Janvier 2025
