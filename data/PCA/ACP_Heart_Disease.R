# ============================================================================
# ACP - ANALYSE EN COMPOSANTES PRINCIPALES
# Dataset: Heart Disease UCI (Cleveland)
# Auteur: Étudiant M1 Statistique - Cours E. Périnel
# ============================================================================

# =============================================================================
# MNÉMOTECHNIQUE ÉTUDIANT FRANÇAIS - RETENIR L'ACP EN 5 ÉTAPES
# =============================================================================
# 
# 🧠 "PICCI" - Les 5 étapes de l'ACP:
#   P = Préparation (charger données, nettoyer, centrer-réduire)
#   I = Inertie (valeurs propres, % variance expliquée)
#   C = Cercle des corrélations (liens variables-axes)
#   C = Contributions (qui contribue à quoi?)
#   I = Individus (projection et interprétation)
#
# 🎯 "COS²" = "Combien On Se fie" → qualité de représentation
#       cos² proche de 1 = bien représenté
#       cos² proche de 0 = mal représenté (attention!)
#
# 📊 "CTR" = "Combien Tu Représentes" → contribution
#       CTR > 1/n = l'individu/variable contribue fortement
#
# 🔄 Règle du COUDE: là où la courbe "casse" = nb d'axes à garder
#
# 📐 Cercle de corrélation:
#       - Variables LONGUES = bien représentées
#       - Variables PROCHES = corrélées positivement
#       - Variables OPPOSÉES = corrélées négativement
#       - Variables PERPENDICULAIRES = non corrélées
# =============================================================================

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  0° INSTALLATION ET CHARGEMENT DES PACKAGES                              ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Liste des packages nécessaires
# 📦 MNÉMO: "FaCoCo GPS" 
#   Fa = FactoMineR (le moteur de l'ACP)
#   Co = factoextra (les beaux graphiques)
#   Co = corrplot (matrices de corrélation)
#   G = ggplot2 (graphiques avancés)
#   P = psych (statistiques descriptives)
#   S = skimr (résumé rapide des données)

packages <- c("FactoMineR", "factoextra", "corrplot", "ggplot2", "psych", "skimr")

# Installation automatique si nécessaire
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  1° CHARGEMENT ET PRÉPARATION DES DONNÉES                                ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📥 Importation depuis UCI Repository
# 🎯 MNÉMO: "Cleveland = Cœur malade"
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/heart-disease/processed.cleveland.data"
heart <- read.csv(url, header = FALSE, na.strings = "?")

# Attribution des noms de colonnes
# 📋 MNÉMO: Les 14 variables du cœur - "ASTRE CholE FEB ThaS CaNum"
#   A = age, S = sex, T = cp(type douleur), R = trestbps(tension repos)
#   E = chol(cholestérol), E = fbs(glycémie), B = restecg(ECG)
#   Tha = thalach(FC max), S = exang(angine effort), Ca = oldpeak + slope + ca + thal
#   Num = num(diagnostic)

colnames(heart) <- c("age", "sex", "cp", "trestbps", "chol", "fbs", 
                     "restecg", "thalach", "exang", "oldpeak", 
                     "slope", "ca", "thal", "num")

# Suppression des valeurs manquantes
# 💡 MNÉMO: "NA = Non Admis" → on les retire
heart <- na.omit(heart)
cat("Nombre d'observations après nettoyage:", nrow(heart), "\n")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  2° SÉLECTION DES VARIABLES ET EXPLORATION                               ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Variables QUANTITATIVES ACTIVES pour l'ACP
# 🎯 MNÉMO: "ACTCO" = Age, Chol, Trestbps, Ca, Oldpeak + thalach
#   - age: âge en années
#   - trestbps: pression artérielle au repos (mm Hg)
#   - chol: cholestérol sérique (mg/dl)  
#   - thalach: fréquence cardiaque maximale atteinte
#   - oldpeak: dépression ST à l'effort
#   - ca: nombre de vaisseaux colorés par fluoroscopie (0-3)

var_quanti <- c("age", "trestbps", "chol", "thalach", "oldpeak", "ca")

# 📊 Variables QUALITATIVES SUPPLÉMENTAIRES (illustratives)
# 🎯 MNÉMO: "IlluSTRAtives = ne participent pas au calcul mais s'affichent"
#   - sex: sexe (0=F, 1=H)
#   - num: diagnostic (0=sain, 1-4=maladie)

# Conversion en facteurs avec labels explicites
heart$sex <- factor(heart$sex, levels = c(0, 1), labels = c("Femme", "Homme"))
heart$num_cat <- factor(ifelse(heart$num == 0, "Sain", "Malade"))

# Création du dataframe pour l'ACP
df_acp <- heart[, var_quanti]
rownames(df_acp) <- paste0("Patient_", 1:nrow(df_acp))

# 📋 Aperçu des données
cat("\n=== APERÇU DES DONNÉES ===\n")
print(head(df_acp))

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  3° STATISTIQUES DESCRIPTIVES                                            ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Résumé statistique complet
cat("\n=== STATISTIQUES DESCRIPTIVES ===\n")
print(summary(df_acp))

# 📊 Statistiques avec psych::describe
cat("\n=== STATISTIQUES DÉTAILLÉES (psych) ===\n")
print(describe(df_acp))

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  4° MATRICE DE CORRÉLATION                                               ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📐 Calcul de la matrice de corrélation
# 🎯 MNÉMO: "cor() = cœur des relations entre variables"
mat.cor <- cor(df_acp)
cat("\n=== MATRICE DE CORRÉLATION ===\n")
print(round(mat.cor, 3))

# 📊 Visualisation de la matrice de corrélation
X11()
corrplot(mat.cor, 
         method = "ellipse",      # Forme des ellipses
         type = "upper",          # Triangle supérieur
         tl.col = "black",        # Couleur des labels
         tl.srt = 45,             # Rotation des labels
         title = "Matrice de corrélation - Heart Disease",
         mar = c(0, 0, 2, 0))

# 📊 Version mixte (chiffres + ellipses)
X11()
corrplot.mixed(mat.cor, 
               upper = "ellipse", 
               lower = "number",
               tl.col = "black",
               title = "Corrélations - Heart Disease")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  5° RÉALISATION DE L'ACP                                                 ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 🎯 ACP avec FactoMineR::PCA()
# MNÉMO: "PCA() = Principal Component Analysis"
#   - scale.unit = TRUE → données centrées-réduites (OBLIGATOIRE si unités différentes!)
#   - ncp = 5 → garder 5 composantes max
#   - quali.sup → variables qualitatives illustratives (ne participent pas au calcul)
#   - graph = FALSE → pas de graphiques automatiques (on les fait nous-mêmes)

# 💡 MNÉMO "Centrer-Réduire": 
#   Centrer = soustraire la moyenne (ramène à 0)
#   Réduire = diviser par l'écart-type (ramène à 1)
#   → Toutes les variables ont le même poids!

res.acp <- PCA(heart[, c(var_quanti, "sex", "num_cat")], 
               scale.unit = TRUE,
               ncp = 5,
               quali.sup = c(7, 8),  # sex et num_cat sont illustratives
               graph = FALSE)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  6° VALEURS PROPRES ET CHOIX DU NOMBRE D'AXES                            ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Valeurs propres = variance expliquée par chaque axe
# 🎯 MNÉMO: "λ (lambda) = la force de l'axe"
#   Plus λ est grand, plus l'axe capture de l'information

cat("\n=== VALEURS PROPRES ===\n")
print(res.acp$eig)

# 📈 Graphique des valeurs propres (Scree plot / Éboulis)
# 🎯 MNÉMO: "Éboulis = les rochers qui tombent" → chercher le COUDE
X11()
fviz_eig(res.acp, 
         addlabels = TRUE,         # Afficher les pourcentages
         ylim = c(0, 40),
         main = "Éboulis des valeurs propres",
         xlab = "Composantes principales",
         ylab = "% de variance expliquée")

# 📏 Critère de Kaiser: garder les axes avec λ > 1
# 🎯 MNÉMO: "Kaiser = K > 1" → l'axe explique plus qu'une variable seule
cat("\n=== CRITÈRE DE KAISER (λ > 1) ===\n")
cat("Axes à retenir:", sum(res.acp$eig[, 1] > 1), "\n")

# 📏 Critère du bâton brisé (Broken Stick)
# 🎯 MNÉMO: "Bâton cassé" = si tu casses un bâton au hasard, quelle longueur attends-tu?
# On garde les axes dont λ > valeur théorique du bâton brisé
if (require(PCDimension)) {
  p <- ncol(df_acp)
  bs <- brokenStick(1:p, p)
  cat("\n=== CRITÈRE DU BÂTON BRISÉ ===\n")
  print(data.frame(
    Dimension = 1:p,
    Valeur_propre = res.acp$eig[1:p, 1],
    Seuil_baton_brise = bs,
    Retenir = ifelse(res.acp$eig[1:p, 1] > bs, "OUI", "NON")
  ))
}

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  7° RÉSULTATS SUR LES VARIABLES                                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Coordonnées des variables (= corrélations variables-axes)
# 🎯 MNÉMO: "coord = où se place la variable sur les axes"
cat("\n=== COORDONNÉES DES VARIABLES ===\n")
print(round(res.acp$var$coord, 3))

# 📊 Contributions des variables (en %)
# 🎯 MNÉMO: "CTR = Combien Tu Représentes pour construire l'axe"
#   CTR > 100/p = variable importante pour l'axe (ici p=6, donc seuil = 16.7%)
cat("\n=== CONTRIBUTIONS DES VARIABLES (%) ===\n")
print(round(res.acp$var$contrib, 2))

# 📊 Qualité de représentation (cos²)
# 🎯 MNÉMO: "cos² = Combien On Se fie à la projection"
#   cos² proche de 1 = variable bien représentée sur l'axe
cat("\n=== COS² DES VARIABLES ===\n")
print(round(res.acp$var$cos2, 3))

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  8° CERCLE DES CORRÉLATIONS                                              ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📐 Cercle de corrélation = projection des variables sur le plan factoriel
# 🎯 MNÉMO pour interpréter le cercle:
#   - Variable PROCHE du cercle = bien représentée
#   - Variables PROCHES entre elles = corrélées positivement
#   - Variables OPPOSÉES = corrélées négativement  
#   - Variables à 90° = non corrélées

# Plan Dim1-Dim2
X11()
fviz_pca_var(res.acp, 
             col.var = "contrib",           # Couleur selon contribution
             gradient.cols = c("blue", "yellow", "red"),
             repel = TRUE,                  # Éviter chevauchement des labels
             title = "Cercle des corrélations (Dim1-Dim2)")

# Plan Dim1-Dim3
X11()
fviz_pca_var(res.acp, 
             axes = c(1, 3),
             col.var = "cos2",              # Couleur selon qualité
             gradient.cols = c("blue", "yellow", "red"),
             repel = TRUE,
             title = "Cercle des corrélations (Dim1-Dim3)")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  9° CONTRIBUTIONS DES VARIABLES - VISUALISATION                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Barplot des contributions à l'axe 1
# 🎯 MNÉMO: "Qui construit l'axe 1?"
X11()
fviz_contrib(res.acp, 
             choice = "var", 
             axes = 1,
             fill = "steelblue",
             title = "Contributions des variables à Dim1")

# 📊 Barplot des contributions à l'axe 2
X11()
fviz_contrib(res.acp, 
             choice = "var", 
             axes = 2,
             fill = "darkorange",
             title = "Contributions des variables à Dim2")

# 📊 Contributions aux deux premiers axes
X11()
fviz_contrib(res.acp, 
             choice = "var", 
             axes = 1:2,
             fill = "darkgreen",
             title = "Contributions des variables à Dim1-2")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  10° QUALITÉ DE REPRÉSENTATION (COS²) - VISUALISATION                    ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Barplot des cos² sur l'axe 1
X11()
fviz_cos2(res.acp, 
          choice = "var", 
          axes = 1,
          fill = "steelblue",
          title = "Qualité de représentation (cos²) - Dim1")

# 📊 Barplot des cos² sur les axes 1 et 2
X11()
fviz_cos2(res.acp, 
          choice = "var", 
          axes = 1:2,
          fill = "darkorange",
          title = "Qualité de représentation (cos²) - Dim1-2")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  11° RÉSULTATS SUR LES INDIVIDUS                                         ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Coordonnées des individus
# 🎯 MNÉMO: "Où se place chaque patient sur les nouveaux axes?"
cat("\n=== COORDONNÉES DES INDIVIDUS (10 premiers) ===\n")
print(round(head(res.acp$ind$coord, 10), 3))

# 📊 Contributions des individus
# 🎯 MNÉMO: "Quels patients tirent l'axe dans leur direction?"
cat("\n=== CONTRIBUTIONS DES INDIVIDUS (top 10 Dim1) ===\n")
contrib_ind <- res.acp$ind$contrib
print(round(head(contrib_ind[order(contrib_ind[,1], decreasing = TRUE), ], 10), 2))

# 📊 Cos² des individus
cat("\n=== COS² DES INDIVIDUS (10 premiers) ===\n")
print(round(head(res.acp$ind$cos2, 10), 3))

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  12° GRAPHIQUES DES INDIVIDUS                                            ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Nuage des individus simple
X11()
fviz_pca_ind(res.acp, 
             col.ind = "cos2",              # Couleur selon qualité
             gradient.cols = c("blue", "yellow", "red"),
             pointsize = 2,
             repel = TRUE,
             title = "Projection des individus (Dim1-Dim2)")

# 📊 Nuage des individus coloré par SEXE
# 🎯 MNÉMO: "habillage = costume des points"
X11()
fviz_pca_ind(res.acp, 
             habillage = "sex",             # Variable qualitative
             addEllipses = TRUE,            # Ellipses de concentration
             ellipse.level = 0.95,          # Niveau de confiance
             palette = c("pink", "lightblue"),
             repel = TRUE,
             title = "Individus par Sexe")

# 📊 Nuage des individus coloré par DIAGNOSTIC
X11()
fviz_pca_ind(res.acp, 
             habillage = "num_cat",
             addEllipses = TRUE,
             ellipse.level = 0.95,
             palette = c("green", "red"),
             repel = TRUE,
             title = "Individus par Diagnostic (Sain/Malade)")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  13° BIPLOT (INDIVIDUS + VARIABLES)                                      ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Biplot = superposition individus et variables
# 🎯 MNÉMO: "Bi = deux" → on voit les deux en même temps
#   - Les flèches = les variables
#   - Les points = les individus
#   - Un individu dans la direction d'une variable = forte valeur pour cette variable

X11()
fviz_pca_biplot(res.acp, 
                repel = TRUE,
                col.var = "red",
                col.ind = "gray50",
                title = "Biplot ACP - Heart Disease")

# Biplot avec groupes
X11()
fviz_pca_biplot(res.acp, 
                habillage = "num_cat",
                addEllipses = TRUE,
                col.var = "black",
                repel = TRUE,
                title = "Biplot avec diagnostic Sain/Malade")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  14° CONTRIBUTIONS DES INDIVIDUS - VISUALISATION                         ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Top contributeurs à l'axe 1
X11()
fviz_contrib(res.acp, 
             choice = "ind", 
             axes = 1,
             top = 20,
             fill = "steelblue",
             title = "Top 20 contributeurs à Dim1")

# 📊 Top contributeurs à l'axe 2
X11()
fviz_contrib(res.acp, 
             choice = "ind", 
             axes = 2,
             top = 20,
             fill = "darkorange",
             title = "Top 20 contributeurs à Dim2")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  15° DESCRIPTION DES AXES PAR LES VARIABLES                              ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Description automatique des axes
# 🎯 MNÉMO: dimdesc() = "DIMension DESCription"
desc <- dimdesc(res.acp, axes = 1:3)

cat("\n=== DESCRIPTION DE L'AXE 1 ===\n")
print(desc$Dim.1)

cat("\n=== DESCRIPTION DE L'AXE 2 ===\n")
print(desc$Dim.2)

cat("\n=== DESCRIPTION DE L'AXE 3 ===\n")
print(desc$Dim.3)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  16° VARIABLES ILLUSTRATIVES (SUPPLÉMENTAIRES)                           ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Coordonnées des modalités des variables qualitatives
# 🎯 MNÉMO: "quali.sup = variables invitées, elles regardent mais ne votent pas"
cat("\n=== COORDONNÉES DES VARIABLES QUALITATIVES SUPPLÉMENTAIRES ===\n")
print(res.acp$quali.sup$coord)

# 📊 Visualisation avec les catégories
X11()
fviz_pca_ind(res.acp, 
             habillage = "num_cat",
             addEllipses = TRUE,
             palette = c("green", "red"),
             repel = TRUE,
             title = "ACP avec variable illustrative: Diagnostic")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  17° SYNTHÈSE ET INTERPRÉTATION                                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════════════╗\n")
cat("║                    SYNTHÈSE DE L'ANALYSE ACP                             ║\n")
cat("╚══════════════════════════════════════════════════════════════════════════╝\n")

cat("\n📊 DONNÉES ANALYSÉES:\n")
cat("   - ", nrow(df_acp), " patients (individus)\n")
cat("   - ", ncol(df_acp), " variables quantitatives actives\n")
cat("   - 2 variables qualitatives illustratives (sex, diagnostic)\n")

cat("\n📈 INERTIE EXPLIQUÉE:\n")
cat("   - Dim1: ", round(res.acp$eig[1, 2], 1), "% de variance\n")
cat("   - Dim2: ", round(res.acp$eig[2, 2], 1), "% de variance\n")
cat("   - Dim1+Dim2: ", round(sum(res.acp$eig[1:2, 2]), 1), "% cumulés\n")

cat("\n🎯 INTERPRÉTATION DES AXES:\n")
cat("   - Axe 1: Oppose typiquement les profils cardiaques (voir desc$Dim.1)\n")
cat("   - Axe 2: Nuance secondaire du profil cardiaque\n")

cat("\n💡 MNÉMOTECHNIQUES À RETENIR:\n")
cat("   - PICCI: Préparation, Inertie, Cercle, Contributions, Individus\n")
cat("   - cos² = qualité, CTR = contribution\n")
cat("   - Cercle: proche=corrélé, opposé=anticorrélé, 90°=indépendant\n")

cat("\n✅ ANALYSE TERMINÉE\n")
