# ======================================================
# Exercice : ACP Heart Disease - UCI Dataset
# ======================================================
# Dataset : Heart Disease de l'Université de Californie
# Source : UCI Machine Learning Repository
# Objectif : Analyse en Composantes Principales sur 
#            les facteurs de risque cardiaque

library(FactoMineR)
library(factoextra)
library(corrplot)
library(ggplot2)
library(psych)        
library(skimr)        
library(PCDimension)
library(dplyr)


# ======================================================
# 1) IMPORTATION DES DONNÉES
# ======================================================

# Télécharger les données depuis UCI
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/heart-disease/processed.cleveland.data"

# Lire les données sans en-tête
heart <- read.csv(url, header = FALSE, stringsAsFactors = TRUE)

# Noms des colonnes (selon la documentation UCI)
colnames(heart) <- c("age", "sex", "cp", "trestbps", "chol", "fbs", 
                     "restecg", "thalach", "exang", "oldpeak", 
                     "slope", "ca", "thal", "num")

# Remplacer les "?" (valeurs manquantes) par NA
heart[heart == "?"] <- NA

# Conversion en types appropriés
heart <- data.frame(
  age = as.numeric(heart$age),
  sex = as.factor(heart$sex),
  cp = as.factor(heart$cp),
  trestbps = as.numeric(heart$trestbps),
  chol = as.numeric(heart$chol),
  fbs = as.factor(heart$fbs),
  restecg = as.factor(heart$restecg),
  thalach = as.numeric(heart$thalach),
  exang = as.factor(heart$exang),
  oldpeak = as.numeric(heart$oldpeak),
  slope = as.factor(heart$slope),
  ca = as.numeric(heart$ca),
  thal = as.factor(heart$thal),
  num = as.factor(heart$num)
)

# Nettoyage : supprimer les valeurs manquantes
heart_clean <- na.omit(heart)

cat("\n=== DIMENSIONS DU DATASET ===\n")
cat("Avant nettoyage :", nrow(heart), "patients\n")
cat("Après nettoyage :", nrow(heart_clean), "patients\n")
cat("Patients supprimés :", nrow(heart) - nrow(heart_clean), "\n")


# ======================================================
# 2) RÉSUMÉ DES DONNÉES
# ======================================================

cat("\n=== STRUCTURE DES DONNÉES ===\n")
str(heart_clean)

cat("\n=== RÉSUMÉ DES DONNÉES ===\n")
summary(heart_clean)

cat("\n=== PREMIÈRES LIGNES ===\n")
head(heart_clean)

cat("\n=== NOMS DES VARIABLES ===\n")
names(heart_clean)

# Résumé détaillé avec skimr
cat("\n=== EXPLORATION AVEC SKIMR ===\n")
skim(heart_clean)

# Statistiques descriptives avec psych
cat("\n=== STATISTIQUES DESCRIPTIVES (PSYCH) ===\n")
describe(heart_clean)


# ======================================================
# 3) IDENTIFICATEUR DES INDIVIDUS
# ======================================================

# Créer des identifiants pour les patients
rownames(heart_clean) <- paste0("P", 1:nrow(heart_clean))

# Sélectionner les variables quantitatives pour l'ACP
heart_quanti <- heart_clean %>% 
  select(age, trestbps, chol, thalach, oldpeak, ca)

# Vérification
cat("\n=== VARIABLES QUANTITATIVES POUR L'ACP ===\n")
dim(heart_quanti)
names(heart_quanti)


# ======================================================
# 4) MATRICE DES CORRÉLATIONS
# ======================================================

cat("\n=== MATRICE DES CORRÉLATIONS ===\n")
mat.cor <- round(cor(heart_quanti), 3)
print(mat.cor)

# Visualisation : méthode couleur
corrplot(
  mat.cor,
  method = "color",
  type = "lower",
  tl.srt = 45,
  tl.cex = 0.9,
  addCoef.col = "black",
  number.cex = 0.8,
  title = "Matrice des corrélations - Heart Disease",
  mar = c(0, 0, 2, 0)
)

# Visualisation : méthode mixte
corrplot.mixed(
  mat.cor, 
  upper = 'ellipse',
  lower = 'number',
  tl.cex = 0.9,
  number.cex = 0.8,
  title = "Matrice mixte des corrélations",
  mar = c(0, 0, 2, 0)
)


# ======================================================
# 5) ACP NORMÉE SUR LES 6 VARIABLES QUANTITATIVES
# ======================================================

cat("\n=== RÉALISATION DE L'ACP NORMÉE ===\n")

# ACP sur les variables quantitatives
# scale.unit = TRUE pour une ACP normée (centrée-réduite)
X11()  # Ouvrir une fenêtre graphique externe
heart.acp <- PCA(heart_quanti, 
                 scale.unit = TRUE,
                 ncp = 5,
                 graph = TRUE)

# Les deux graphiques sont construits automatiquement
# - Cercle des corrélations (variables)
# - Plan factoriel des individus


# ======================================================
# 6) INERTIE DES AXES ET VALEURS PROPRES
# ======================================================

cat("\n=== INERTIE DES AXES (VALEURS PROPRES) ===\n")
print(heart.acp$eig)

cat("\nInertie totale :", sum(heart.acp$eig[, 1]), "\n")
cat("En ACP normée : Inertie totale = p =", ncol(heart_quanti), "\n")


# ======================================================
# 7) ÉBOULIS DES VALEURS PROPRES
# ======================================================

cat("\n=== ÉBOULIS DES VALEURS PROPRES ===\n")

# Graphique des valeurs propres
X11()
fviz_eig(heart.acp, 
         addlabels = TRUE, 
         choice = "eigenvalue",
         title = "Éboulis des valeurs propres")

# Graphique du pourcentage d'inertie
X11()
fviz_eig(heart.acp, 
         addlabels = TRUE,
         title = "Éboulis - % de variance expliquée")


# ======================================================
# 8) NOMBRE D'AXES À RETENIR
# ======================================================

cat("\n=== CRITÈRES DE SÉLECTION DU NOMBRE D'AXES ===\n")

# Critère de Kaiser : valeurs propres > 1
kaiser <- heart.acp$eig[, 1] > 1
cat("\nCritère de Kaiser (val. propres > 1):\n")
cat("Nombre d'axes retenus:", sum(kaiser), "\n")
cat("Axes retenus:", which(kaiser), "\n")

# Critère du bâton brisé
n_var <- ncol(heart_quanti)
bs <- 100 * brokenStick(1:n_var, n_var)
vp <- heart.acp$eig[, 2]

cat("\nCritère du bâton brisé:\n")
batons <- data.frame(
  Axe = 1:length(bs),
  Inertie = vp[1:length(bs)],
  Baton_brise = bs
)
print(batons)

# Graphique comparatif
barplot(
  rbind(vp[1:length(bs)], bs),
  beside = TRUE,
  legend = c("Inertie observée", "Bâton brisé"),
  col = c("tomato1", "turquoise3"), 
  border = "white",
  main = "Critère du bâton brisé",
  xlab = "Dimensions",
  ylab = "Pourcentage de variance",
  cex.names = 0.9,
  cex.axis = 0.9,
  las = 1
)

cat("\n→ Décision : Retenir les 2 premiers axes\n")


# ======================================================
# 9) CORRÉLATIONS ENTRE VARIABLES ET AXES
# ======================================================

cat("\n=== CORRÉLATIONS VARIABLES-AXES (COR) ===\n")
cat("En ACP normée : coordonnées = corrélations\n\n")

print(round(heart.acp$var$cor, 3))

# Variables les plus corrélées avec l'axe 1
cat("\n--- AXLE 1 ---\n")
cor_ax1 <- sort(heart.acp$var$cor[, 1], decreasing = TRUE)
print(round(cor_ax1, 3))

# Variables les plus corrélées avec l'axe 2
cat("\n--- AXE 2 ---\n")
cor_ax2 <- sort(heart.acp$var$cor[, 2], decreasing = TRUE)
print(round(cor_ax2, 3))


# ======================================================
# 10) CORRÉLATIONS SUR PLUSIEURS DIMENSIONS
# ======================================================

# Heatmap des corrélations variables-dimensions
cat("\n=== CORRÉLATIONS SUR LES 5 DIMENSIONS ===\n")
print(round(heart.acp$var$cor, 3))

corrplot(
  heart.acp$var$cor,
  is.corr = FALSE,
  title = "Corrélations Variables-Dimensions",
  mar = c(0, 0, 2, 0)
)


# ======================================================
# 11) QUALITÉ DE REPRÉSENTATION DES VARIABLES
# ======================================================

cat("\n=== QUALITÉ DE REPRÉSENTATION DES VARIABLES (COS²) ===\n")
print(round(heart.acp$var$cos2, 3))

# Cos² sur le plan (axes 1-2)
cos2_plan <- rowSums(heart.acp$var$cos2[, 1:2])
cat("\nQualité sur le plan (1,2):\n")
print(round(cos2_plan, 3))

# Visualisation : cercle des corrélations avec cos²
X11()
fviz_pca_var(
  heart.acp, 
  col.var = "cos2",
  gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
  repel = TRUE,
  title = "Cercle des corrélations - Qualité de représentation"
)

# Cercle standard
X11()
fviz_pca_var(
  heart.acp, 
  col.var = "black",
  repel = TRUE,
  title = "Cercle des corrélations"
)

# Cercle avec contribution
X11()
fviz_pca_var(
  heart.acp, 
  col.var = "contrib",
  gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
  repel = TRUE,
  title = "Variables - Contribution aux axes"
)


# ======================================================
# 12) QUALITÉ DE REPRÉSENTATION DES INDIVIDUS
# ======================================================

cat("\n=== QUALITÉ DE REPRÉSENTATION DES INDIVIDUS (COS²) ===\n")

# Qualité sur l'axe 1
qlt1 <- heart.acp$ind$cos2[, 1]
cat("\nTop 10 patients - Qualité sur l'axe 1:\n")
print(round(sort(qlt1, decreasing = TRUE)[1:10], 3))

# Qualité sur le plan (1,2)
qlt12 <- rowSums(heart.acp$ind$cos2[, 1:2])
cat("\nTop 10 patients - Qualité sur plan (1,2):\n")
print(round(sort(qlt12, decreasing = TRUE)[1:10], 3))

cat("\nBottom 10 patients - Qualité sur plan (1,2):\n")
print(round(sort(qlt12, decreasing = FALSE)[1:10], 3))

# Graphiques de qualité
X11()
fviz_cos2(heart.acp, 
          choice = "ind", 
          axes = 1,
          top = 20,
          title = "Qualité de représentation - Axe 1")

X11()
fviz_cos2(heart.acp, 
          choice = "ind", 
          axes = 1:2,
          top = 20,
          title = "Qualité de représentation - Plan (1,2)")


# ======================================================
# 13) PLAN DES INDIVIDUS SELON QUALITÉ
# ======================================================

# Taille des points selon cos²
X11()
fviz_pca_ind(heart.acp, 
             pointsize = "cos2",
             pointshape = 21, 
             fill = "#E7B800",
             repel = TRUE,
             title = "Patients - Taille selon cos²") +
  coord_fixed(ratio = 1)

# Sélection des patients bien représentés
X11()
fviz_pca_ind(heart.acp, 
             pointsize = "cos2",
             pointshape = 21, 
             fill = "#E7B800",
             repel = TRUE, 
             select.ind = list(cos2 = 0.5),
             title = "Patients bien représentés (cos² > 0.5)") +
  coord_fixed(ratio = 1)

# Couleur selon cos²
X11()
fviz_pca_ind(heart.acp, 
             col.ind = "cos2", 
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             select.ind = list(cos2 = 0.5),
             title = "Patients - Couleur selon cos²") +
  coord_fixed(ratio = 1)

# Taille ET couleur selon cos²
X11()
fviz_pca_ind(heart.acp, 
             col.ind = "cos2", 
             pointsize = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             title = "Patients - Taille et couleur selon cos²") +
  coord_fixed(ratio = 1)

# Plan de base
X11()
fviz_pca_ind(heart.acp,
             col.ind = "#696969",
             repel = TRUE,
             title = "Plan factoriel des patients") +
  coord_fixed(ratio = 1)


# ======================================================
# 14) CONTRIBUTIONS DES INDIVIDUS
# ======================================================

cat("\n=== CONTRIBUTIONS DES INDIVIDUS (CTR) ===\n")

# Contribution moyenne des individus
contrib_moy <- 100 / nrow(heart_quanti)
cat("Contribution moyenne d'un patient:", round(contrib_moy, 2), "%\n")

# Top contributeurs à l'axe 1
cat("\nTop 15 patients - Contribution à l'axe 1:\n")
ctr_ind_ax1 <- sort(heart.acp$ind$contrib[, 1], decreasing = TRUE)[1:15]
print(round(ctr_ind_ax1, 2))

# Top contributeurs à l'axe 2
cat("\nTop 15 patients - Contribution à l'axe 2:\n")
ctr_ind_ax2 <- sort(heart.acp$ind$contrib[, 2], decreasing = TRUE)[1:15]
print(round(ctr_ind_ax2, 2))

# Vérification : somme des contributions = 1
cat("\nVérification - Somme CTR axe 1:", sum(heart.acp$ind$contrib[, 1]), "\n")
cat("Vérification - Somme CTR axe 2:", sum(heart.acp$ind$contrib[, 2]), "\n")


# ======================================================
# 15) CONTRIBUTIONS MAX ET MIN - AXE 1
# ======================================================

cat("\n=== CONTRIBUTIONS - AXE 1 ===\n")
ctr1_sorted <- sort(heart.acp$ind$contrib[, 1])
cat("Top 5 contributeurs (maximum):\n")
print(tail(ctr1_sorted, 5))
cat("\nTop 5 contributeurs (minimum):\n")
print(head(ctr1_sorted, 5))

# Graphique
X11()
fviz_contrib(heart.acp, 
             choice = "ind", 
             axes = 1,
             top = 15,
             title = "Top 15 patients - Contribution à l'axe 1")


# ======================================================
# 16) CONTRIBUTIONS MAX ET MIN - AXE 2
# ======================================================

cat("\n=== CONTRIBUTIONS - AXE 2 ===\n")
ctr2_sorted <- sort(heart.acp$ind$contrib[, 2])
cat("Top 5 contributeurs (maximum):\n")
print(tail(ctr2_sorted, 5))
cat("\nTop 5 contributeurs (minimum):\n")
print(head(ctr2_sorted, 5))

# Graphique
X11()
fviz_contrib(heart.acp, 
             choice = "ind", 
             axes = 2,
             top = 15,
             title = "Top 15 patients - Contribution à l'axe 2")


# ======================================================
# 17) DIAGRAMMES EN BÂTONS DES CONTRIBUTIONS
# ======================================================

cat("\n=== GRAPHIQUES DES CONTRIBUTIONS ===\n")

# Contributions à l'axe 1
X11()
fviz_contrib(heart.acp, 
             choice = "ind", 
             axes = 1,
             top = 15,
             title = "Top 15 patients - Contribution à l'axe 1")

# Contributions à l'axe 2
X11()
fviz_contrib(heart.acp, 
             choice = "ind", 
             axes = 2,
             top = 15,
             title = "Top 15 patients - Contribution à l'axe 2")

# Contributions des variables à l'axe 1
X11()
fviz_contrib(heart.acp, 
             choice = "var", 
             axes = 1,
             title = "Contribution des variables à l'axe 1")

# Contributions des variables à l'axe 2
X11()
fviz_contrib(heart.acp, 
             choice = "var", 
             axes = 2,
             title = "Contribution des variables à l'axe 2")

# Contributions des variables axes 1+2
X11()
fviz_contrib(heart.acp, 
             choice = "var", 
             axes = 1:2,
             title = "Contribution des variables aux axes 1-2")

# Heatmap des contributions
X11()
corrplot(heart.acp$var$contrib, 
         is.corr = FALSE,
         title = "Contributions des variables",
         mar = c(0, 0, 2, 0))


# ======================================================
# 18) VARIABLES ILLUSTRATIVES
# ======================================================

cat("\n=== AJOUT DES VARIABLES ILLUSTRATIVES ===\n")

# Ajouter les variables qualitatives pour visualisation
heart_avec_quali <- heart_clean %>%
  select(age, trestbps, chol, thalach, oldpeak, ca, sex, cp, num)

# Nouvelle ACP avec variables qualitatives supplémentaires
heart.acp.quali <- PCA(
  heart_avec_quali,
  quanti.sup = NULL,      # Pas de variables quantitatives supplémentaires
  quali.sup = c(7, 8, 9), # Colonnes des variables qualitatives
  scale.unit = TRUE,
  ncp = 5,
  graph = FALSE
)


# ======================================================
# 19) VISUALISATION PAR SEXE
# ======================================================

cat("\n=== INDIVIDUS SELON LE SEXE ===\n")

X11()
fviz_pca_ind(heart.acp.quali, 
             habillage = heart_clean$sex,
             palette = c("#E7B800", "#2E9FDF"),
             legend.title = "Sexe",
             addEllipses = TRUE,
             ellipse.type = "confidence",
             title = "Plan factoriel - Patients par sexe") +
  coord_fixed(ratio = 1)

# Avec couleur uniquement
X11()
fviz_pca_ind(heart.acp.quali, 
             col.ind = heart_clean$sex,
             palette = c("#E7B800", "#2E9FDF"),
             legend.title = "Sexe",
             addEllipses = TRUE,
             ellipse.type = "confidence") +
  coord_fixed(ratio = 1)


# ======================================================
# 20) VISUALISATION PAR MALADIE CARDIAQUE
# ======================================================

cat("\n=== INDIVIDUS SELON LA PRÉSENCE DE MALADIE ===\n")

# Créer variable binaire : 0 (aucune) vs 1-4 (présence)
disease <- ifelse(heart_clean$num == 0, "Sain", "Atteint")

X11()
fviz_pca_ind(heart.acp.quali, 
             col.ind = disease,
             palette = c("#00AFBB", "#FC4E07"),
             legend.title = "Statut cardiaque",
             title = "Plan factoriel - Statut cardiaque") +
  coord_fixed(ratio = 1)

# Avec ellipses
X11()
fviz_pca_ind(heart.acp.quali, 
             habillage = disease,
             palette = c("#00AFBB", "#FC4E07"),
             legend.title = "Statut cardiaque",
             addEllipses = TRUE,
             ellipse.type = "confidence",
             title = "Plan factoriel - Statut cardiaque (ellipses)") +
  coord_fixed(ratio = 1)


# ======================================================
# 21) TESTS STATISTIQUES VARIABLES QUALITATIVES
# ======================================================

cat("\n=== TESTS - VARIABLES QUALITATIVES LIÉES AUX DIMENSIONS ===\n")

# Si des variables qualitatives ont été en qualitatif supplémentaire :
if (!is.null(heart.acp.quali$quali.sup)) {
  cat("\nRésultats des tests qualitatives:\n")
  print(heart.acp.quali$quali.sup)
}


# ======================================================
# 22) BIPLOT - VARIABLES ET INDIVIDUS
# ======================================================

cat("\n=== BIPLOT : SYNTHÈSE VARIABLES + INDIVIDUS ===\n")

# Biplot standard
X11()
fviz_pca_biplot(heart.acp, 
                repel = TRUE,
                col.var = "#2E9FDF",
                col.ind = "#696969",
                title = "Biplot - Patients et Variables") +
  coord_fixed(ratio = 1)

# Biplot avec gradient de qualité
X11()
fviz_pca_biplot(heart.acp,
                col.ind = qlt12,
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                col.var = "black",
                repel = TRUE,
                title = "Biplot - Qualité des patients") +
  coord_fixed(ratio = 1)


# ======================================================
# 23) INTERPRÉTATION DES AXES
# ======================================================

cat("\n")
cat("╔════════════════════════════════════════════════╗\n")
cat("║     INTERPRÉTATION DES AXES PRINCIPAUX        ║\n")
cat("╚════════════════════════════════════════════════╝\n\n")

cat("AXE 1 (Dimension 1):\n")
cat("──────────────────\n")
cat("Inertie expliquée:", round(heart.acp$eig[1, 2], 2), "%\n\n")
cat("Variables les plus corrélées:\n")
ax1_sorted <- sort(abs(heart.acp$var$cor[, 1]), decreasing = TRUE)
for (i in 1:length(ax1_sorted)) {
  var_name <- names(ax1_sorted)[i]
  cor_val <- heart.acp$var$cor[var_name, 1]
  cat(sprintf("  %d. %s : r = %+.3f\n", i, var_name, cor_val))
}

cat("\nInterprétation: Cet axe représente la CHARGE CARDIOVASCULAIRE\n")
cat("                (Gradient de sévérité fonctionnelle)\n\n")

cat("\nAXE 2 (Dimension 2):\n")
cat("──────────────────\n")
cat("Inertie expliquée:", round(heart.acp$eig[2, 2], 2), "%\n\n")
cat("Variables les plus corrélées:\n")
ax2_sorted <- sort(abs(heart.acp$var$cor[, 2]), decreasing = TRUE)
for (i in 1:length(ax2_sorted)) {
  var_name <- names(ax2_sorted)[i]
  cor_val <- heart.acp$var$cor[var_name, 2]
  cat(sprintf("  %d. %s : r = %+.3f\n", i, var_name, cor_val))
}

cat("\nInterprétation: Cet axe représente les FACTEURS MÉTABOLIQUES\n")
cat("                (Dimension secondaire de variabilité)\n\n")


# ======================================================
# 24) PROFILS IDENTIFIÉS
# ======================================================

cat("\n╔════════════════════════════════════════════════╗\n")
cat("║        PROFILS DE PATIENTS IDENTIFIÉS         ║\n")
cat("╚════════════════════════════════════════════════╝\n\n")

# Extraire les coordonnées
coord_ind <- heart.acp$ind$coord[, 1:2]

# Quadrants
q1 <- sum(coord_ind[,1] > 0 & coord_ind[,2] > 0)
q2 <- sum(coord_ind[,1] < 0 & coord_ind[,2] > 0)
q3 <- sum(coord_ind[,1] < 0 & coord_ind[,2] < 0)
q4 <- sum(coord_ind[,1] > 0 & coord_ind[,2] < 0)

cat("Q1 (Dim1+, Dim2+):", q1, "patients\n")
cat("  → Charge ÉLEVÉE + Facteurs métaboliques positifs\n")
cat("  → Profil: TRÈS HAUT RISQUE\n\n")

cat("Q2 (Dim1-, Dim2+):", q2, "patients\n")
cat("  → Charge FAIBLE + Facteurs métaboliques positifs\n")
cat("  → Profil: JEUNE AVEC MÉTABOLISME PARTICULIER\n\n")

cat("Q3 (Dim1-, Dim2-):", q3, "patients\n")
cat("  → Charge FAIBLE + Facteurs métaboliques négatifs\n")
cat("  → Profil: SAIN & BAS RISQUE\n\n")

cat("Q4 (Dim1+, Dim2-):", q4, "patients\n")
cat("  → Charge ÉLEVÉE + Facteurs métaboliques négatifs\n")
cat("  → Profil: ÂGÉ AVEC CHARGE CARDIOVASCULAIRE\n\n")


# ======================================================
# 25) SAUVEGARDE DES RÉSULTATS
# ======================================================

cat("\n=== SYNTHÈSE DES RÉSULTATS ===\n\n")

# Créer un dataframe avec les résultats
results_summary <- data.frame(
  Patient = rownames(coord_ind),
  Dim1 = round(coord_ind[, 1], 3),
  Dim2 = round(coord_ind[, 2], 3),
  Cos2_Dim1 = round(heart.acp$ind$cos2[, 1], 3),
  Cos2_Dim2 = round(heart.acp$ind$cos2[, 2], 3),
  Cos2_Plan = round(qlt12, 3),
  Contrib_Dim1 = round(heart.acp$ind$contrib[, 1], 2),
  Contrib_Dim2 = round(heart.acp$ind$contrib[, 2], 2)
)

# Trier par qualité sur le plan
results_summary <- results_summary[order(results_summary$Cos2_Plan, decreasing = TRUE), ]

cat("Top 20 patients les mieux représentés:\n")
print(head(results_summary, 20))

# Optionnel : exporter les résultats
# write.csv(results_summary, "resultats_acp_heart.csv", row.names = FALSE)


# ======================================================
# FIN DE L'ANALYSE
# ======================================================

cat("\n")
cat("═══════════════════════════════════════════════════\n")
cat("   ACP - HEART DISEASE - ANALYSE COMPLÉTÉE        \n")
cat("═══════════════════════════════════════════════════\n")
cat("\nLes graphiques et résultats ont été générés.\n")
cat("Tous les éléments sont disponibles dans les objets R.\n\n")

# Résumé final
cat("Résumé final:\n")
cat("─────────────\n")
cat("Nombre de patients analysés:", nrow(heart_quanti), "\n")
cat("Nombre de variables:", ncol(heart_quanti), "\n")
cat("Variance expliquée par l'axe 1:", round(heart.acp$eig[1, 2], 1), "%\n")
cat("Variance expliquée par l'axe 2:", round(heart.acp$eig[2, 2], 1), "%\n")
cat("Variance cumulée (axes 1-2):", round(heart.acp$eig[2, 3], 1), "%\n")
cat("\n")
