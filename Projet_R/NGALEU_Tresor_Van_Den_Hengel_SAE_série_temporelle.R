#Chargement et Visualisation

# =========================================================================
# PARTIE 1 : ANALYSE DESCRIPTIVE ET GRAPHIQUE
# =========================================================================

# Nettoyage de la mémoire
rm(list=ls())

# Chargement du fichier
# On suppose que le fichier est dans le dossier de travail
setwd("/drive/alumni/iut2502239/SD2/SEMESTRE3/description et prevision de donnees temporelles")
data <- read.csv("monthly_car_sales.csv")
y <- data$sales
#Vérifie si il n'a pas de valeur manquante 
sum(is.na(y))
# Vérifier la classe de la colonne date
class(data$date)
# Méthode avec R Base
data$date <- as.Date(data$date, format="%Y-%m-%d")
#%Y : Année avec 4 chiffres (1992)
#%m : Mois en chiffres (01)
#%d : Jour en chiffres (01)
#%y : Année avec 2 chiffres (92)

# Définition des paramètres temporels
n <- length(y)      # Nombre de points (192)observations (de 1992 à 2007).
t <- 1:n            # Les données sont mensuelles (fréquence = 12).
p <- 12             # La période est donc 12(c'est a dire de janvier jusqu'a decembre). On observe 16 cycles(répétition de l'année 1992 jusqu'a 2007) complets (192 / 12 = 16).

# --- Tracé de la série brute ---
# Pourquoi ? Pour identifier visuellement la tendance et la saisonnalité.
plot(t, y, type="l", col="blue", lwd=2,
     main="Évolution des ventes mensuelles de voitures (1992-2007)",
     xlab="Temps (Mois)", ylab="Ventes")

# Ajout d'une grille pour mieux voir les cycles
grid()

# Pourquoi étudier l'ACF ?
# L'ACF mesure la corrélation entre la série y(t) et sa version décalée y(t-k).
# Cela permet de confirmer scientifiquement la présence de saisonnalité.

acf(y, lag.max = 36, main="ACF de la série brute (Ventes de voitures)")
#Comme tes données sont mensuelles (p=12), utiliser 36 permet de voir 3 années complètes (12, 24 et 36 mois) c'est le mois de chaque fin de ces 3années c a d chaque année

# =========================================================================
# PARTIE 2 Estimation de la Tendance (f_t)
# =========================================================================

# Pourquoi utiliser la Moyenne Mobile ? 
# Elle permet d'éliminer la saisonnalité (p=12) pour isoler la tendance réelle.
# On utilise un filtre centré d'ordre 12 (norme de Caron).
#k=p=12 qui est la période, k=2m et ici c'est m=6
filtre <- c(0.5, rep(1, 11), 0.5) / 12
# POURQUOI UTILISER stats::filter ?
# Nous utilisons 'stats::filter' explicitement car si le package 'dplyr' est chargé,
# la fonction 'filter' par défaut cherchera à filtrer des lignes de tableau 
# au lieu d'appliquer un lissage numérique sur notre vecteur de ventes.
MM12 <- stats::filter(y, filtre)

# Pourquoi un modèle paramétrique ? 
# La moyenne mobile est tronquée (NA au début/fin). Pour prévoir, il nous faut 
# une équation mathématique f(t) = a*t + b.
# t = m+1,...,n−m, d'où t=7,...,186 qui représentre les indices
indices <- 7:(n-6) # On travaille sur la partie sans NA
a <- cov(t[indices], MM12[indices]) / var(t[indices])
b <- mean(MM12[indices]) - a * mean(t[indices])

# Construction de la tendance
ft <- a * t + b
plot(t, y, type="l", col="gray", main="Série et Tendance lissée")
# On ne trace MM12 que là où elle existe
lines(t, ft, col="red", lwd=3) # Superposition sur le graphe

# =========================================================================
# PARTIE 3 : ESTIMATION DE LA SAISONNALITÉ (MULTIPLICATIVE) 
# =========================================================================

# Pourquoi la division ? 
# On cherche le rapport entre la série brute et la tendance : y = ft * st => st = y / ft# Écart à la tendance
#Calcule la série de donnée sans tendance
ratio_detrend <- y / ft

# Calcul des coefficients saisonniers (moyenne par mois(Janvier à Décembre))
# On transforme en matrice pour grouper par mois (12 colonnes)
mat_sj <- matrix(ratio_detrend, ncol=12, byrow=TRUE)
sj <- colMeans(mat_sj, na.rm = TRUE)

# Pourquoi normaliser autour de 1 ?
# Dans un modèle additif, la somme des coefficients doit être 0.
# Dans un modèle MULTIPLICATIF, la MOYENNE des coefficients doit être 1.
# (Si la moyenne est 1.1, cela signifierait que la saisonnalité crée une hausse artificielle de 10% par an).
sj <- sj / mean(sj)
# On crée la série saisonnière complète sur toute la durée
st <- rep(sj, length.out=n)
cat("Coefficients saisonniers (autour de 1) :", sj, "\n")

# =========================================================================
# PARTIE 5  SÉRIE CVS (Corrigée des Variations Saisonnières)  
# =========================================================================

# Formule : CVS = Y_brut / Saisonnalité
CVS <- y / st

# Visualisation : La série CVS doit maintenant suivre de très près la droite de tendance rouge.
plot(t, CVS, type="l", main="Série CVS (Modèle Multiplicatif)", 
     ylab="Ventes désaisonnalisées", col="darkgreen")
abline(b, a, col="red", lwd=2) # On trace la tendance ft calculée au début

# =========================================================================
#PARTIE 5 MODÈLE DÉTERMINISTE ET QUALITÉ (MSE)
# =========================================================================

#Pourquoi ? Le modèle déterministe est la combinaison "parfaite" de notre droite et de nos coefficients c'est a dire tendance*saisonnalité.
#PRÉVISION DÉTERMINISTE ET ERREUR ---
# On reconstruit la série : y_det = Tendance * Saisonnalité
y_det <- ft * st

# Calcul de l'erreur (MSE) : toujours la différence au carré entre réel et modèle
mse_det <- mean((y - y_det)^2)
cat("La MSE du modèle déterministe multiplicatif est :", mse_det, "\n")
#Une MSE de 126 613 indique que le modèle capte correctement la tendance et la saisonnalité,
#mais qu’il subsiste des écarts dus à des chocs non expliqués.
#calcule de RMSE (Root Mean Square Error) pour ramener l'erreur à la même unité que tes données (les ventes de voitures
rmse <- sqrt(mse_det)
rmse
#En moyenne, le modèle se trompe d’environ 350 voitures par rapport aux vraies ventes.

#6. ANALYSE DES RÉSIDUS ET MODÈLE ARMA

# =========================================================================
# PARTIE 6 : ANALYSE DES RÉSIDUS 
# =========================================================================

#Pourquoi ? Même dans un modèle multiplicatif, l'erreur finale (le résidu) est souvent traitée de façon additive pour l'ARMA, ou alors on étudie le rapport. Ici, nous étudions l'écart restant.
# Les résidus représentent l'écart que le modèle (ft * st) n'a pas pu expliquer.
residus <- y - y_det

# Diagnostic graphique pour choisir les paramètres p et q
par(mfrow=c(1,2))
acf(residus, main="ACF des résidus (Multiplicatif)")
pacf(residus, main="PACF des résidus (Multiplicatif)")

# Pourquoi ARMA(1,1) ? 
# On suppose que l'erreur d'aujourd'hui dépend de celle d'hier (p=1) et d'un choc passé (q=1).
model_arma <- arima(residus, order=c(1,0,1))
# Résidus expliqués par ARMA
res_arma <- residuals(model_arma)
res_ajust <- residus - res_arma

# Modèle Total Final (Déterministe + Aléatoire)
y_total <- y_det + res_ajust
mse_total <- mean((y - y_total)^2)
cat("La MSE totale (avec ARMA) est :", mse_total, "\n")
#Après l’ajout du modèle ARMA :
#MSE totale = 72 565
#soit une réduction de l’erreur d’environ 40 %
#Cela montre que le modèle total décrit beaucoup mieux la série observée.
rmse2 <- sqrt(mse_total)
rmse2
#En moyenne, le modèle se trompe d’environ 269 voitures par rapport aux vraies ventes.

# =========================================================================
# PARTIE 7 PRÉVISION TOTALE : DÉTERMINISTE + ALÉATOIRE (ARMA)
# =========================================================================

# 1. Partie Déterministe (Tendance * Saison)
# On veut prédire les 12 prochains mois (une année complète)
h <- 12
t_futur <- (n + 1):(n + h)

tendance_future <- a * t_futur + b

# Pour la saisonnalité, on reprend les coefficients sj des mois correspondants
# Si la série s'arrête en Décembre, on reprend de Janvier à Décembre
saison_future <- sj 

y_det_futur <- tendance_future * saison_future

# 2. Partie Aléatoire (Prédiction des résidus via ARMA)
# Pourquoi ? On utilise le modèle ARMA pour "deviner" la direction du bruit
pred_arma <- predict(model_arma, n.ahead = h)
res_futur <- pred_arma$pred # On récupère uniquement la valeur prédite

# 3. MODÈLE TOTAL FINAL (La somme des deux)
# Pourquoi y_total ? Parce que c'est la combinaison de toute notre analyse
y_total_futur <- y_det_futur + res_futur

# =========================================================================
# INTERVALLE DE CONFIANCE À 95 %
# =========================================================================

# Ecart-type des résidus du modèle total
sigma <- sd(y - y_total)

# Coefficient pour un IC à 95 %
alpha <- 1.96

# Bornes de l'intervalle de confiance
ic_inf <- y_total_futur - alpha * sigma
ic_sup <- y_total_futur + alpha * sigma


# On arrondit les valeurs pour un affichage propre
y_labels <- round(y_total_futur, 0)

# ================================
# GRAPHIQUE  
# ================================

graphics.off()
par(mfrow=c(1,1))
par(mar=c(5,5,4,2))

plot(t, y,
     type="l",
     lwd=2,
     col="steelblue",
     xlim=c(1, n + h),
     ylim=c(min(c(y, ic_inf)) * 0.9,
            max(c(y, ic_sup)) * 1.1),
     main="Analyse et Prévision des Ventes de Voitures pour l'année à venir",
     xlab="Temps (Mois)",
     ylab="Volume des Ventes",
     frame.plot=FALSE,
     axes=FALSE)

# Axes + grille 
axis(1, at=seq(0, n + h, by=12)) 
axis(2)
grid(col="lightgray", lty="dotted")

# IC 95 % (discrets)
polygon(
  c(t_futur, rev(t_futur)),
  c(ic_inf, rev(ic_sup)),
  col = rgb(0.7, 0.7, 0.7, 0.35),
  border = NA
)

# Prévision
lines(t_futur, y_total_futur,
      col="firebrick3",
      lwd=2,
      type="o",
      pch=19)

# Séparation passé / futur
abline(v=n, col="black", lty=2, lwd=1.5)
text(n, max(y)*1.05, "Début prévision", pos=2, cex=0.8)

# Légende 
legend("topleft",
       legend=c("Ventes observées",
                "Prévisions",
                "IC à 95 %"),
       col=c("steelblue", "firebrick3", "gray"),
       lwd=c(2,2,10),
       pch=c(NA,19,15),
       pt.cex=1,
       bty="n",
       cex=0.9)
