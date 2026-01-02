# ============================================================================
# ACP - BASE COMPARATEUR DE TERRITOIRES INSEE
# Indicateurs socio-économiques des communes françaises
# Auteur: Étudiant M1 Statistique - Cours E. Périnel (2024-2025)
# ============================================================================

# =============================================================================
# 🧠 MNÉMOTECHNIQUES ÉTUDIANT FRANÇAIS - RETENIR L'ACP EN 5 ÉTAPES
# =============================================================================
# 
# "PICCI" - Les 5 étapes de l'ACP:
#   P = Préparation (charger données, nettoyer, centrer-réduire)
#   I = Inertie (valeurs propres, % variance expliquée)
#   C = Cercle des corrélations (liens variables-axes)
#   C = Contributions (qui contribue à quoi?)
#   I = Individus (projection et interprétation)
#
# "COS²" = "Combien On Se fie" → qualité de représentation
#       cos² proche de 1 = bien représenté
#       cos² proche de 0 = mal représenté (attention!)
#
# "CTR" = "Combien Tu Représentes" → contribution
#       CTR > 1/n = l'individu/variable contribue fortement
#
# Règle du COUDE: là où la courbe "casse" = nb d'axes à garder
#
# Cercle de corrélation:
#       - Variables LONGUES = bien représentées
#       - Variables PROCHES = corrélées positivement
#       - Variables OPPOSÉES = corrélées négativement
#       - Variables PERPENDICULAIRES = non corrélées
# =============================================================================

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  0° INSTALLATION ET CHARGEMENT DES PACKAGES                              ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📦 MNÉMO: "FaCoCo GPS" 
#   Fa = FactoMineR (le moteur de l'ACP)
#   Co = factoextra (les beaux graphiques)
#   Co = corrplot (matrices de corrélation)
#   G = ggplot2 (graphiques avancés)
#   P = psych (statistiques descriptives)
#   S = skimr (résumé rapide des données)

packages <- c("FactoMineR", "factoextra", "corrplot", "ggplot2", "psych", "skimr", "PCDimension")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  1° CHARGEMENT ET PRÉPARATION DES DONNÉES                                ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📥 Importation du fichier INSEE - Base Comparateur de Territoires
# MNÉMO: "INSEE = Indicateurs Nationaux Socio-Économiques Essentiels"
insee <- read.csv(
  "/Users/cheriet/Documents/ACPCCM1/base_cc_comparateur.csv",
  sep = ";",
  stringsAsFactors = TRUE,
  na.strings = c("", "NA", "s")  # "s" = secret statistique
)

# 📋 Aperçu rapide des données
cat("\n=== STRUCTURE DES DONNÉES ===\n")
cat("Nombre de communes:", nrow(insee), "\n")
cat("Nombre de variables:", ncol(insee), "\n")

cat("\n=== NOMS DES COLONNES ===\n")
print(names(insee))

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  2° SÉLECTION DES VARIABLES QUANTITATIVES                                ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Sélection de 12 variables quantitatives pertinentes pour l'ACP
# MNÉMO: "DPEL LRMC ECAT" 
#   D = Démographie (pop, naissances, décès)
#   P = Pauvreté (taux pauvreté, revenu médian)
#   E = Emploi (emplois, chômage)
#   L = Logement (résidences, vacants)
#   
#   L = Log proportion résidences principales
#   R = Revenu médian
#   M = Ménages
#   C = Chômage
#
#   E = Établissements
#   C = Construction
#   A = Agriculture
#   T = Taille (superficie)

# Création de variables DÉRIVÉES (taux et ratios) plus pertinentes pour l'ACP
# → Car les valeurs brutes dépendent de la taille de la commune

insee$densite_pop <- insee$P22_POP / insee$SUPERF  # Densité population
insee$taux_natalite <- (insee$NAIS1621 / 6) / insee$P22_POP * 1000  # Taux natalité pour 1000
insee$taux_mortalite <- (insee$DECE1621 / 6) / insee$P22_POP * 1000  # Taux mortalité pour 1000
insee$taux_res_secondaires <- insee$P22_RSECOCC / insee$P22_LOG * 100  # % rés. secondaires
insee$taux_logements_vacants <- insee$P22_LOGVAC / insee$P22_LOG * 100  # % logements vacants
insee$taux_proprietaires <- insee$P22_RP_PROP / insee$P22_RP * 100  # % propriétaires
insee$taux_chomage <- insee$P22_CHOM1564 / insee$P22_ACT1564 * 100  # Taux de chômage
insee$ratio_emploi_pop <- insee$P22_EMPLT / insee$P22_POP1564 * 100  # Ratio emploi/pop active
insee$pct_agriculture <- insee$ETAZ23 / insee$ETTOT23 * 100  # % établissements agricoles
insee$pct_industrie <- insee$ETBE23 / insee$ETTOT23 * 100  # % établissements industriels
insee$pct_construction <- insee$ETFZ23 / insee$ETTOT23 * 100  # % établissements construction
insee$pct_services <- insee$ETGU23 / insee$ETTOT23 * 100  # % services et commerce

# Conversion des variables caractères en numériques
insee$MED21 <- as.numeric(as.character(insee$MED21))
insee$TP6021 <- as.numeric(as.character(insee$TP6021))
insee$PIMP21 <- as.numeric(as.character(insee$PIMP21))

# Variables quantitatives pour l'ACP (12 variables)
var_quanti <- c(
  "densite_pop",           # 1. Densité de population
  "taux_natalite",         # 2. Taux de natalité
  "taux_mortalite",        # 3. Taux de mortalité
  "taux_res_secondaires",  # 4. % résidences secondaires
  "taux_logements_vacants",# 5. % logements vacants
  "taux_proprietaires",    # 6. % propriétaires
  "MED21",                 # 7. Revenu médian 2021
  "TP6021",                # 8. Taux de pauvreté 2021
  "taux_chomage",          # 9. Taux de chômage
  "pct_agriculture",       # 10. % établ. agricoles
  "pct_industrie",         # 11. % établ. industriels
  "pct_services"           # 12. % services/commerce
)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  3° NETTOYAGE DES DONNÉES                                                ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Création du dataframe pour l'ACP avec les variables sélectionnées
# Ajout du département comme variable illustrative

# Extraction du code département (2 premiers caractères du CODGEO)
insee$departement <- substr(insee$CODGEO, 1, 2)
insee$departement <- factor(insee$departement)

# Sélection et nettoyage
df_acp <- insee[, c("CODGEO", var_quanti, "departement")]
df_acp <- na.omit(df_acp)  # Suppression des NA

# Suppression des valeurs infinies ou aberrantes
df_acp <- df_acp[is.finite(df_acp$densite_pop), ]
df_acp <- df_acp[is.finite(df_acp$taux_natalite), ]
df_acp <- df_acp[is.finite(df_acp$taux_mortalite), ]
df_acp <- df_acp[df_acp$taux_chomage < 100, ]  # Taux raisonnable

# Renommer les lignes avec le code commune
rownames(df_acp) <- df_acp$CODGEO

cat("\n=== APRÈS NETTOYAGE ===\n")
cat("Nombre de communes conservées:", nrow(df_acp), "\n")
cat("Nombre de variables:", length(var_quanti), "\n")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  4° STATISTIQUES DESCRIPTIVES                                            ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Résumé statistique des 12 variables
cat("\n=== STATISTIQUES DESCRIPTIVES ===\n")
print(summary(df_acp[, var_quanti]))

# 📊 Statistiques détaillées avec psych
cat("\n=== STATISTIQUES DÉTAILLÉES (psych::describe) ===\n")
print(describe(df_acp[, var_quanti]))

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  5° MATRICE DE CORRÉLATION                                               ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📐 Calcul de la matrice de corrélation
# MNÉMO: "cor() = cœur des relations entre variables"
mat.cor <- round(cor(df_acp[, var_quanti], use = "complete.obs"), 3)

cat("\n=== MATRICE DE CORRÉLATION ===\n")
print(mat.cor)

# 📊 Visualisation de la matrice de corrélation
X11()
corrplot(mat.cor, 
         method = "color",
         type = "lower",
         tl.srt = 45,
         tl.col = "black",
         tl.cex = 0.7,
         addCoef.col = "black",
         number.cex = 0.6,
         title = "Corrélations entre les 12 variables INSEE",
         mar = c(0, 0, 2, 0))

# 📊 Version mixte
X11()
corrplot.mixed(mat.cor, 
               upper = "ellipse",
               lower = "number",
               tl.col = "black",
               tl.cex = 0.7,
               number.cex = 0.5,
               title = "Matrice de corrélation INSEE")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  6° RÉALISATION DE L'ACP                                                 ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 🎯 ACP avec FactoMineR::PCA()
# MNÉMO: scale.unit = TRUE car unités différentes (%, hab/km², euros...)

# Dataframe pour l'ACP avec variable quali illustrative
df_pca <- df_acp[, c(var_quanti, "departement")]

# ACP normée sur les 12 variables quantitatives
res.acp <- PCA(df_pca, 
               scale.unit = TRUE,
               ncp = 10,
               quali.sup = 13,  # departement est illustratif
               graph = FALSE)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  7° VALEURS PROPRES ET INERTIE                                           ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Valeurs propres
cat("\n=== VALEURS PROPRES ===\n")
print(res.acp$eig)

# Inertie totale (en ACP normée = nombre de variables = 12)
cat("\n=== INERTIE TOTALE ===\n")
cat("Somme des valeurs propres:", sum(res.acp$eig[, 1]), "\n")
cat("(doit être égal à p =", length(var_quanti), ")\n")

# Pourcentage d'inertie du premier plan (axes 1 et 2)
cat("\n=== INERTIE DU PLAN 1-2 ===\n")
cat("Dim1 + Dim2 =", round(res.acp$eig[1, 2] + res.acp$eig[2, 2], 2), "%\n")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  8° ÉBOULIS DES VALEURS PROPRES                                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📈 Scree plot en pourcentage
X11()
fviz_eig(res.acp, 
         addlabels = TRUE,
         ylim = c(0, 35),
         main = "Éboulis des valeurs propres - Communes INSEE",
         xlab = "Dimensions",
         ylab = "% de variance expliquée")

# 📏 Critère de Kaiser: garder les axes avec λ > 1
cat("\n=== CRITÈRE DE KAISER (λ > 1) ===\n")
cat("Axes à retenir:", sum(res.acp$eig[, 1] > 1), "\n")

# 📏 Critère du bâton brisé
if (require(PCDimension)) {
  p <- length(var_quanti)
  bs <- 100 * brokenStick(1:p, p)
  vp <- res.acp$eig[1:p, 2]
  
  X11()
  barplot(rbind(vp, bs),
          beside = TRUE,
          legend = c("Inertie (%)", "Bâton brisé"),
          col = c("tomato1", "turquoise3"),
          border = "white",
          main = "Critère du bâton brisé",
          xlab = "Dimensions",
          ylab = "Inertie (%)",
          names.arg = paste0("Dim", 1:p),
          cex.names = 0.7)
}

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  9° CORRÉLATIONS VARIABLES-AXES                                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Coordonnées des variables (= corrélations en ACP normée)
cat("\n=== COORDONNÉES DES VARIABLES ===\n")
print(round(res.acp$var$coord[, 1:5], 3))

# Variables les plus corrélées à l'axe 1
cat("\n=== CORRÉLATIONS AVEC L'AXE 1 (triées) ===\n")
print(sort(res.acp$var$cor[, 1], decreasing = TRUE))

# Variables les plus corrélées à l'axe 2
cat("\n=== CORRÉLATIONS AVEC L'AXE 2 (triées) ===\n")
print(sort(res.acp$var$cor[, 2], decreasing = TRUE))

# 📊 Visualisation des corrélations
X11()
corrplot(res.acp$var$cor[, 1:5], 
         is.corr = FALSE,
         method = "color",
         addCoef.col = "black",
         number.cex = 0.7,
         tl.cex = 0.7,
         title = "Corrélations variables-axes",
         mar = c(0, 0, 2, 0))

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  10° CERCLE DES CORRÉLATIONS                                             ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📐 Cercle de corrélation = projection des variables

# Plan Dim1-Dim2
X11()
fviz_pca_var(res.acp, 
             col.var = "black",
             repel = TRUE,
             title = "Cercle des corrélations (Dim1-Dim2)") +
  coord_fixed(ratio = 1)

# Avec couleur selon contribution
X11()
fviz_pca_var(res.acp, 
             col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             title = "Cercle des corrélations - couleur = contribution") +
  coord_fixed(ratio = 1)

# Plan Dim1-Dim3
X11()
fviz_pca_var(res.acp, 
             axes = c(1, 3),
             col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             title = "Cercle des corrélations (Dim1-Dim3)") +
  coord_fixed(ratio = 1)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  11° CONTRIBUTIONS DES VARIABLES (CTR)                                   ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Contributions des variables (en %)
cat("\n=== CONTRIBUTIONS DES VARIABLES (%) ===\n")
print(round(res.acp$var$contrib[, 1:5], 2))

# Seuil d'importance: 100/p = 100/12 = 8.33%
cat("\nSeuil de contribution significative: 100/12 =", round(100/length(var_quanti), 2), "%\n")

# 📊 Barplot contributions à l'axe 1
X11()
fviz_contrib(res.acp, 
             choice = "var", 
             axes = 1,
             fill = "steelblue",
             title = "Contributions des variables à Dim1")

# 📊 Barplot contributions à l'axe 2
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
             title = "Contributions des variables au plan 1-2")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  12° QUALITÉ DE REPRÉSENTATION DES VARIABLES (COS²)                      ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Qualité de représentation (cos²)
cat("\n=== COS² DES VARIABLES ===\n")
print(round(res.acp$var$cos2[, 1:5], 3))

# 📊 Barplot cos² sur plan 1-2
X11()
fviz_cos2(res.acp, 
          choice = "var", 
          axes = 1:2,
          fill = "darkgreen",
          title = "Qualité de représentation (cos²) - Plan 1-2")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  13° GRAPHIQUES DES INDIVIDUS (COMMUNES)                                 ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Nuage des individus coloré par cos²
X11()
fviz_pca_ind(res.acp, 
             col.ind = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             pointsize = 1,
             title = "Communes colorées par qualité (cos²)") +
  coord_fixed(ratio = 1)

# 📊 Sélection des communes bien représentées
X11()
fviz_pca_ind(res.acp, 
             col.ind = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             select.ind = list(cos2 = 0.7),
             pointsize = 2,
             title = "Communes avec cos² > 0.7") +
  coord_fixed(ratio = 1)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  14° CONTRIBUTIONS DES INDIVIDUS                                         ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Top contributeurs à l'axe 1
cat("\n=== TOP 20 COMMUNES CONTRIBUTRICES À L'AXE 1 ===\n")
top_contrib_1 <- head(sort(res.acp$ind$contrib[, 1], decreasing = TRUE), 20)
print(round(top_contrib_1, 3))

# 📊 Barplot top contributeurs
X11()
fviz_contrib(res.acp, 
             choice = "ind", 
             axes = 1,
             top = 30,
             fill = "steelblue",
             title = "Top 30 communes contributrices à Dim1")

X11()
fviz_contrib(res.acp, 
             choice = "ind", 
             axes = 2,
             top = 30,
             fill = "darkorange",
             title = "Top 30 communes contributrices à Dim2")

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  15° BIPLOT (INDIVIDUS + VARIABLES)                                      ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Biplot = superposition individus et variables
X11()
fviz_pca_biplot(res.acp, 
                repel = TRUE,
                col.var = "#2E9FDF",
                col.ind = "#696969",
                select.ind = list(cos2 = 0.8),
                pointsize = 1,
                title = "Biplot INSEE (communes cos² > 0.8)") +
  coord_fixed(ratio = 1)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  16° DESCRIPTION DES AXES                                                ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Description automatique des axes
desc <- dimdesc(res.acp, axes = 1:3)

cat("\n=== DESCRIPTION DE L'AXE 1 ===\n")
print(desc$Dim.1)

cat("\n=== DESCRIPTION DE L'AXE 2 ===\n")
print(desc$Dim.2)

cat("\n=== DESCRIPTION DE L'AXE 3 ===\n")
print(desc$Dim.3)

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  17° ANALYSE PAR DÉPARTEMENT (VARIABLE ILLUSTRATIVE)                     ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# 📊 Coordonnées moyennes des départements
cat("\n=== COORDONNÉES DES DÉPARTEMENTS (variable illustrative) ===\n")
print(head(res.acp$quali.sup$coord, 20))

# Visualisation des barycentres des départements
# Note: trop de départements pour une visualisation claire
# On peut sélectionner quelques départements représentatifs

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  18° SYNTHÈSE ET INTERPRÉTATION                                          ║
# ╚══════════════════════════════════════════════════════════════════════════╝

cat("\n")
cat("╔══════════════════════════════════════════════════════════════════════════╗\n")
cat("║                    SYNTHÈSE DE L'ANALYSE ACP - INSEE                     ║\n")
cat("╚══════════════════════════════════════════════════════════════════════════╝\n")

cat("\n📊 DONNÉES ANALYSÉES:\n")
cat("   - ", nrow(df_acp), " communes françaises (individus)\n")
cat("   - ", length(var_quanti), " variables quantitatives actives\n")
cat("   - 1 variable qualitative illustrative (département)\n")

cat("\n📈 INERTIE EXPLIQUÉE:\n")
for (i in 1:min(5, nrow(res.acp$eig))) {
  cat("   - Dim", i, ": ", round(res.acp$eig[i, 2], 1), "% de variance\n", sep = "")
}
cat("   - Dim1+Dim2: ", round(sum(res.acp$eig[1:2, 2]), 1), "% cumulés\n")
cat("   - Dim1+Dim2+Dim3: ", round(sum(res.acp$eig[1:3, 2]), 1), "% cumulés\n")

cat("\n🎯 INTERPRÉTATION DES AXES (à adapter selon résultats):\n")
cat("   AXE 1: Oppose typiquement:\n")
cat("     • Communes urbaines/denses vs rurales\n")
cat("     • Services/commerce vs agriculture\n")
cat("   AXE 2: Nuance secondaire (ex: richesse/pauvreté)\n")
cat("   AXE 3: Autre dimension (ex: tourisme/résidences secondaires)\n")

cat("\n📋 VARIABLES ANALYSÉES:\n")
for (v in var_quanti) {
  cat("   - ", v, "\n")
}

cat("\n💡 MNÉMOTECHNIQUES À RETENIR:\n")
cat("   - PICCI: Préparation, Inertie, Cercle, Contributions, Individus\n")
cat("   - cos² = qualité, CTR = contribution\n")
cat("   - Cercle: proche=corrélé, opposé=anticorrélé, 90°=indépendant\n")
cat("   - Seuil CTR: 100/12 = 8.3%\n")

cat("\n✅ ANALYSE TERMINÉE\n")
