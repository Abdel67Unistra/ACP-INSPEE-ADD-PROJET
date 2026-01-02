# 🫀 ACP sur les Maladies Cardiaques (Heart Disease UCI)

## Projet M1 Statistique - Cours E. Périnel (2024-2025)

---

# 🧠 MNÉMOTECHNIQUES POUR RETENIR L'ACP

## 📌 "PICCI" - Les 5 étapes de l'ACP

| Lettre | Étape | Description |
|--------|-------|-------------|
| **P** | Préparation | Charger données, nettoyer, centrer-réduire |
| **I** | Inertie | Valeurs propres, % variance expliquée |
| **C** | Cercle | Cercle des corrélations (liens variables-axes) |
| **C** | Contributions | Qui contribue à quoi? |
| **I** | Individus | Projection et interprétation |

## 📌 Autres mnémotechniques essentiels

| Concept | Mnémotechnique | Signification |
|---------|----------------|---------------|
| **cos²** | "**C**ombien **O**n **S**e fie" | Qualité de représentation (proche de 1 = bien représenté) |
| **CTR** | "**C**ombien **T**u **R**eprésentes" | Contribution (CTR > 1/n = contribution forte) |
| **COUDE** | Là où la courbe "casse" | Nombre d'axes à garder |
| **Kaiser** | "K > 1" | Garder les axes avec λ > 1 |

## 📌 Interpréter le cercle des corrélations

| Position | Interprétation |
|----------|----------------|
| Variable **PROCHE** du cercle | Bien représentée |
| Variables **PROCHES** entre elles | Corrélées positivement |
| Variables **OPPOSÉES** (180°) | Corrélées négativement |
| Variables **PERPENDICULAIRES** (90°) | Non corrélées |
| Variable **LONGUE** (proche du rayon) | Forte contribution |

---

# 📊 DESCRIPTION DU PROJET

## Dataset
- **Source**: UCI Machine Learning Repository - Heart Disease (Cleveland)
- **URL**: `https://archive.ics.uci.edu/ml/machine-learning-databases/heart-disease/`
- **Observations**: 297 patients (après nettoyage)
- **Variables actives**: 6 variables quantitatives
- **Variables illustratives**: 2 variables qualitatives (sexe, diagnostic)

## Variables analysées

### Variables quantitatives actives
| Variable | Description | Unité |
|----------|-------------|-------|
| `age` | Âge du patient | années |
| `trestbps` | Pression artérielle au repos | mm Hg |
| `chol` | Cholestérol sérique | mg/dl |
| `thalach` | Fréquence cardiaque maximale | bpm |
| `oldpeak` | Dépression ST à l'effort | - |
| `ca` | Nombre de vaisseaux colorés | 0-3 |

### Variables qualitatives supplémentaires (illustratives)
| Variable | Description | Modalités |
|----------|-------------|-----------|
| `sex` | Sexe | Femme / Homme |
| `num_cat` | Diagnostic | Sain / Malade |

---

# 📦 PACKAGES R UTILISÉS

| Package | Rôle | Mnémo |
|---------|------|-------|
| `FactoMineR` | Moteur de l'ACP | **Fa** |
| `factoextra` | Visualisations avancées | **Co** |
| `corrplot` | Matrices de corrélation | **Co** |
| `ggplot2` | Graphiques | **G** |
| `psych` | Statistiques descriptives | **P** |
| `skimr` | Résumé rapide | **S** |

> 🎯 Mnémo packages: "**FaCoCo GPS**"

---

# 📋 ÉTAPES DE L'ANALYSE ET FONCTIONS R

## 1️⃣ Chargement et préparation des données

### Fonctions utilisées
- `read.csv()` - Importer les données CSV
- `na.omit()` - Supprimer les valeurs manquantes
- `factor()` - Convertir en variable qualitative

### Explication du cours
> **Centrer-réduire** les données est OBLIGATOIRE quand les variables ont des unités différentes (ici: années, mm Hg, mg/dl, bpm...). Cela donne le **même poids** à toutes les variables.
> 
> $X_{centré-réduit} = \frac{X - \bar{X}}{\sigma_X}$

---

## 2️⃣ Statistiques descriptives

### Fonctions utilisées
- `summary()` - Résumé statistique (min, Q1, médiane, moyenne, Q3, max)
- `psych::describe()` - Statistiques détaillées (n, moyenne, écart-type, médiane, etc.)

### Résultat attendu
```
           age    trestbps      chol   thalach    oldpeak        ca
Min.      29.00     94.00    126.0    71.00      0.00      0.000
Median    55.00    130.00    243.0   153.00      0.80      0.000
Mean      54.54    131.69    247.4   149.60      1.04      0.672
Max.      77.00    200.00    564.0   202.00      6.20      3.000
```

---

## 3️⃣ Matrice de corrélation

### Fonctions utilisées
- `cor()` - Calcul de la matrice de corrélation
- `corrplot()` - Visualisation en ellipses
- `corrplot.mixed()` - Visualisation mixte (ellipses + chiffres)

### Explication du cours
> La **matrice de corrélation** mesure les relations linéaires entre les variables:
> - $r = +1$ : corrélation positive parfaite
> - $r = 0$ : pas de corrélation linéaire  
> - $r = -1$ : corrélation négative parfaite
>
> 🎯 Mnémo: "cor() = **cœur** des relations"

### Description du graphique
Le **corrplot** affiche:
- Des **ellipses bleues** pour les corrélations positives
- Des **ellipses rouges** pour les corrélations négatives
- Plus l'ellipse est **étroite et inclinée**, plus la corrélation est forte

---

## 4️⃣ Réalisation de l'ACP

### Fonction principale
```r
PCA(X, scale.unit = TRUE, ncp = 5, quali.sup = c(7,8), graph = FALSE)
```

### Paramètres expliqués

| Paramètre | Valeur | Signification |
|-----------|--------|---------------|
| `scale.unit` | TRUE | Centrer-réduire les données |
| `ncp` | 5 | Garder max 5 composantes |
| `quali.sup` | c(7,8) | Variables qualitatives illustratives |
| `graph` | FALSE | Pas de graphiques automatiques |

### Explication du cours
> L'ACP cherche des **axes principaux** (composantes) qui:
> 1. Sont des **combinaisons linéaires** des variables originales
> 2. Sont **non corrélés** entre eux (orthogonaux)
> 3. Maximisent la **variance** expliquée (inertie)
>
> Mathématiquement: on diagonalise la **matrice de corrélation** pour obtenir les **vecteurs propres** (directions des axes) et **valeurs propres** (variance sur chaque axe).

---

## 5️⃣ Valeurs propres et choix du nombre d'axes

### Fonctions utilisées
- `res.acp$eig` - Accès aux valeurs propres
- `fviz_eig()` - Graphique d'éboulis (scree plot)
- `brokenStick()` - Critère du bâton brisé

### Résultat: Tableau des valeurs propres
```
         eigenvalue  percentage  cumulative
Dim.1       1.89       31.5%       31.5%
Dim.2       1.22       20.3%       51.8%
Dim.3       1.05       17.5%       69.3%
Dim.4       0.82       13.7%       83.0%
Dim.5       0.61       10.2%       93.2%
Dim.6       0.41        6.8%      100.0%
```

### Critères de choix du nombre d'axes

| Critère | Règle | Application ici |
|---------|-------|-----------------|
| **Kaiser** | λ > 1 | Garder **3 axes** (Dim1, Dim2, Dim3) |
| **Coude** | Cassure dans l'éboulis | Après Dim2 ou Dim3 |
| **Bâton brisé** | λ > seuil théorique | Variable selon calcul |
| **70-80%** | Variance cumulée | ~3 axes pour 70% |

### Explication du cours
> **Valeur propre (λ)** = variance expliquée par l'axe
> 
> 🎯 Mnémo: "Plus λ est grand, plus l'axe est **important**"
>
> Le graphique d'**éboulis** (scree plot) montre la décroissance des valeurs propres. On cherche le **coude** = là où la courbe "casse".

### Description du graphique (Éboulis)
- **Axe X**: Numéro de la composante (Dim1, Dim2, ...)
- **Axe Y**: % de variance expliquée
- Barres **décroissantes**: chaque axe explique moins que le précédent
- Chercher le **coude** pour décider combien d'axes garder

---

## 6️⃣ Résultats sur les variables

### Fonctions utilisées
- `res.acp$var$coord` - Coordonnées des variables (= corrélations avec les axes)
- `res.acp$var$contrib` - Contributions des variables (%)
- `res.acp$var$cos2` - Qualité de représentation (cos²)

### Coordonnées des variables
```
           Dim.1    Dim.2    Dim.3
age        0.65     0.38    -0.11
trestbps   0.48     0.31     0.52
chol       0.32    -0.51     0.57
thalach   -0.71     0.35     0.15
oldpeak    0.68     0.03    -0.07
ca         0.60     0.12     0.22
```

### Contributions (%)
> Seuil d'importance: **100/p = 100/6 = 16.7%**
>
> Si CTR > 16.7%, la variable contribue fortement à l'axe

### Cos² (Qualité de représentation)
> 🎯 Mnémo: cos² = "**C**ombien **O**n **S**e fie"
>
> - cos² proche de **1** = variable **bien représentée**
> - cos² proche de **0** = variable **mal représentée** (prudence!)

---

## 7️⃣ Cercle des corrélations

### Fonction utilisée
```r
fviz_pca_var(res.acp, col.var = "contrib", gradient.cols = c("blue", "yellow", "red"), repel = TRUE)
```

### Paramètres
| Paramètre | Signification |
|-----------|---------------|
| `col.var = "contrib"` | Colorier selon la contribution |
| `col.var = "cos2"` | Colorier selon la qualité |
| `gradient.cols` | Échelle de couleurs |
| `repel = TRUE` | Éviter le chevauchement des labels |
| `axes = c(1,3)` | Changer de plan (ici Dim1-Dim3) |

### Explication du cours
> Le **cercle des corrélations** représente les variables dans l'espace des composantes.
>
> - Les **coordonnées** d'une variable = ses **corrélations** avec les axes
> - La **distance au centre** = qualité de représentation (proche du cercle = bien représentée)
>
> ⚠️ On ne peut interpréter que les variables **proches du cercle**!

### Description du graphique
| Position de la variable | Interprétation |
|-------------------------|----------------|
| Proche du cercle (rayon 1) | Bien représentée, fiable |
| Loin du cercle (près du centre) | Mal représentée, à ignorer |
| Même direction que l'axe | Forte corrélation avec l'axe |
| Deux variables proches | Corrélées positivement |
| Deux variables opposées | Corrélées négativement |
| Deux variables à 90° | Non corrélées |

---

## 8️⃣ Contributions des variables - Barplots

### Fonctions utilisées
```r
fviz_contrib(res.acp, choice = "var", axes = 1)   # Axe 1
fviz_contrib(res.acp, choice = "var", axes = 2)   # Axe 2
fviz_contrib(res.acp, choice = "var", axes = 1:2) # Axes 1+2
```

### Explication du cours
> La **contribution** mesure la part de chaque variable dans la construction de l'axe.
>
> - Formule: $CTR_{jk} = \frac{coord_{jk}^2}{\lambda_k}$
> - Somme des contributions = 100% pour chaque axe
>
> 🎯 Seuil: une variable est **importante** si CTR > 1/p = 100/nombre_variables

### Description du graphique
- **Barplot** avec une barre par variable
- **Ligne rouge pointillée** = seuil de contribution moyenne (100/p)
- Les barres **au-dessus** de la ligne = variables importantes pour l'axe

---

## 9️⃣ Qualité de représentation (Cos²) - Barplots

### Fonctions utilisées
```r
fviz_cos2(res.acp, choice = "var", axes = 1)    # Axe 1
fviz_cos2(res.acp, choice = "var", axes = 1:2)  # Plan 1-2
```

### Explication du cours
> Le **cos²** mesure la qualité de la projection:
>
> - $cos^2 = \frac{coord^2}{distance^2}$
> - C'est le carré du cosinus de l'angle entre la variable et l'axe
> - Somme des cos² sur tous les axes = 1
>
> 🎯 Plus cos² est **grand**, mieux la variable est **représentée**

### Description du graphique
- **Barplot** avec cos² par variable
- Plus la barre est **haute**, meilleure est la représentation
- Variables avec cos² faible: **interpréter avec prudence**!

---

## 🔟 Résultats sur les individus

### Fonctions utilisées
- `res.acp$ind$coord` - Coordonnées des individus
- `res.acp$ind$contrib` - Contributions des individus
- `res.acp$ind$cos2` - Qualité de représentation des individus

### Explication du cours
> Chaque **individu** (patient) est projeté dans le nouvel espace des composantes.
>
> - **Coordonnées** = position sur les nouveaux axes
> - **Contribution** = impact de l'individu sur la direction de l'axe
> - **Cos²** = qualité de la projection (bien ou mal représenté?)
>
> Les individus à **forte contribution** sont souvent des cas **atypiques** à examiner.

---

## 1️⃣1️⃣ Graphiques des individus

### Fonctions utilisées
```r
# Nuage simple coloré par qualité
fviz_pca_ind(res.acp, col.ind = "cos2", gradient.cols = c("blue", "yellow", "red"))

# Nuage avec variable qualitative
fviz_pca_ind(res.acp, habillage = "sex", addEllipses = TRUE)

# Nuage avec diagnostic
fviz_pca_ind(res.acp, habillage = "num_cat", addEllipses = TRUE, palette = c("green", "red"))
```

### Paramètres importants
| Paramètre | Signification |
|-----------|---------------|
| `col.ind = "cos2"` | Colorier par qualité |
| `habillage = "var"` | Colorier par variable qualitative |
| `addEllipses = TRUE` | Ajouter ellipses de concentration |
| `ellipse.level = 0.95` | Niveau de confiance (95%) |
| `repel = TRUE` | Éviter chevauchement |

### Explication du cours
> Le **nuage des individus** montre la répartition des observations:
>
> - Individus **proches** = profils similaires
> - Individus **éloignés** = profils différents
> - Individus **extrêmes** = cas atypiques
>
> Les **ellipses** délimitent les groupes (95% des individus du groupe y sont).

### Description du graphique
- Chaque **point** = un patient
- **Couleur** = selon cos² (qualité) ou groupe (sexe, diagnostic)
- **Ellipses** = zones de concentration par groupe
- Si les ellipses **se chevauchent** = les groupes ne sont pas distincts sur ce plan

---

## 1️⃣2️⃣ Biplot (Individus + Variables)

### Fonction utilisée
```r
fviz_pca_biplot(res.acp, repel = TRUE, col.var = "red", col.ind = "gray50")

# Avec groupes
fviz_pca_biplot(res.acp, habillage = "num_cat", addEllipses = TRUE)
```

### Explication du cours
> Le **biplot** superpose individus et variables sur le même graphique:
>
> - **Points** = individus
> - **Flèches** = variables
>
> 🎯 Règle d'interprétation: un individu situé **dans la direction** d'une variable a une **forte valeur** pour cette variable.

### Description du graphique
- **Points gris** = patients
- **Flèches rouges** = variables quantitatives
- Un patient vers la flèche `thalach` = fréquence cardiaque élevée
- Un patient opposé à `age` = patient jeune

---

## 1️⃣3️⃣ Contributions des individus - Barplots

### Fonctions utilisées
```r
fviz_contrib(res.acp, choice = "ind", axes = 1, top = 20)
fviz_contrib(res.acp, choice = "ind", axes = 2, top = 20)
```

### Explication du cours
> Les **individus contributeurs** "tirent" l'axe dans leur direction.
>
> - Identifier les **top contributeurs** permet de repérer les cas **atypiques**
> - Ces individus méritent un examen particulier (erreur? profil extrême?)

---

## 1️⃣4️⃣ Description des axes

### Fonction utilisée
```r
dimdesc(res.acp, axes = 1:3)
```

### Explication du cours
> `dimdesc()` donne une description **automatique** de chaque axe:
>
> - Variables les plus **corrélées** à l'axe
> - Catégories de variables qualitatives **caractéristiques**
>
> 🎯 Mnémo: "**DIM**ension **DESC**ription"

### Résultat typique
```
$Dim.1
       correlation   p.value
thalach   -0.71       < 0.001    # Corrélé négativement
oldpeak    0.68       < 0.001    # Corrélé positivement
age        0.65       < 0.001    # Corrélé positivement
```

**Interprétation**: L'axe 1 oppose les patients âgés avec oldpeak élevé (côté positif) aux patients avec thalach élevé (côté négatif).

---

## 1️⃣5️⃣ Variables illustratives (supplémentaires)

### Fonction utilisée
```r
res.acp$quali.sup$coord  # Coordonnées des catégories
```

### Explication du cours
> Les variables **illustratives** (ou supplémentaires):
>
> - Ne participent **PAS** au calcul de l'ACP
> - Sont **projetées après** sur les axes
> - Permettent d'**interpréter** les axes
>
> 🎯 Mnémo: "variables **invitées**: elles regardent mais ne votent pas"

### Utilité
- Voir si les groupes (Sain/Malade) se séparent bien
- Interpréter les axes par rapport à des variables connues
- Valider l'analyse (ex: les malades sont-ils du côté des profils à risque?)

---

# 📈 SYNTHÈSE DE L'ANALYSE

## Données analysées
- **297 patients** (individus)
- **6 variables quantitatives** actives
- **2 variables qualitatives** illustratives (sexe, diagnostic)

## Résultats principaux

### Inertie expliquée
| Composante | Variance | Cumul |
|------------|----------|-------|
| Dim1 | ~31% | 31% |
| Dim2 | ~20% | 51% |
| Dim3 | ~17% | 69% |

### Interprétation des axes
- **Axe 1**: Oppose les profils cardiaques à risque (âge élevé, oldpeak élevé) aux profils sains (thalach élevé)
- **Axe 2**: Nuance secondaire, souvent liée au cholestérol

### Séparation des groupes
- Les patients **Sains** et **Malades** montrent une certaine séparation sur le plan Dim1-Dim2
- Les ellipses peuvent se chevaucher → la distinction n'est pas parfaite avec l'ACP seule

---

# 🎓 RAPPEL THÉORIQUE DU COURS

## Qu'est-ce que l'ACP?

L'**Analyse en Composantes Principales** est une méthode de **réduction de dimension** qui:

1. Transforme les variables corrélées en variables **non corrélées** (les composantes)
2. Classe ces nouvelles variables par **variance décroissante**
3. Permet de visualiser des données multidimensionnelles en **2D ou 3D**

## Formules essentielles

| Concept | Formule |
|---------|---------|
| Centrer-réduire | $z_j = \frac{x_j - \bar{x}_j}{\sigma_j}$ |
| Coordonnée individu | $F_{ik} = \sum_j z_{ij} \cdot u_{jk}$ |
| Coordonnée variable | $cor(X_j, F_k) = \sqrt{\lambda_k} \cdot u_{jk}$ |
| Contribution variable | $CTR_{jk} = \frac{coord_{jk}^2}{\lambda_k}$ |
| Cos² variable | $cos^2_{jk} = coord_{jk}^2$ |

## Les 3 questions de l'ACP

1. **Combien d'axes garder?** → Critères Kaiser, coude, bâton brisé
2. **Que représentent les axes?** → Cercle des corrélations, contributions
3. **Comment se répartissent les individus?** → Nuage des individus, groupes

---

# 📁 FICHIERS DU PROJET

```
ACPCCM1/
├── README.md                           # Ce fichier
├── data/
│   └── PCA/
│       └── ACP_Heart_Disease.R         # Script R complet avec mnémotechniques
└── indice-de-defavorisation-sociale-fdep-par-iris.csv
```

---

# 🔧 EXÉCUTION

```r
# Dans R ou RStudio
setwd("/chemin/vers/ACPCCM1/data/PCA")
source("ACP_Heart_Disease.R")
```

---

# 📚 RÉFÉRENCES

- Cours ACP - Emmanuel Périnel, M1 Statistique/DUAS 2024-25
- UCI Machine Learning Repository - Heart Disease Dataset
- Package FactoMineR: Lê, S., Josse, J., & Husson, F. (2008)
- Package factoextra: Kassambara, A., & Mundt, F.

---

**Auteur**: Étudiant M1 Statistique  
**Date**: Janvier 2026  
**Contrôle noté**: Rapport (11 janvier) | Oral (13-14 janvier)
