Modélisation et Prévision de Séries Temporelles avec ARIMA
Ce projet implémente un modèle ARIMA (AutoRegressive Integrated Moving Average) pour analyser et prévoir l'évolution du nombre de passagers aériens internationaux. Il suit la méthodologie classique de Box-Jenkins.

🚀 Présentation du Modèle ARIMA
Le modèle ARIMA est une méthode statistique robuste pour les séries temporelles qui combine trois composantes :

AR (Autorégression) : Utilise la relation de dépendance entre une observation actuelle et un certain nombre d'observations passées.

I (Intégration/Différenciation) : Rend la série stationnaire en soustrayant l'observation actuelle de la précédente pour éliminer les tendances.

MA (Moyenne Mobile) : Utilise la dépendance entre une observation et l'erreur résiduelle provenant d'un modèle de moyenne mobile appliqué aux observations passées.

Les ordres du modèle sont notés (p, d, q).

📊 Jeu de Données
Le projet utilise le dataset classique AirPassengers.csv, qui contient :
Month : La date (mensuelle) de janvier 1949 à décembre 1960.
Passengers : Le nombre total de passagers aériens internationaux (en milliers)

🛠️ Méthodologie (Approche Box-Jenkins)
Le projet suit les trois étapes itératives de la méthodologie Box-Jenkins :

Identification du modèle :

Analyse visuelle de la série (tendance, saisonnalité).

Tests de stationnarité (Test de Dickey-Fuller Augmenté).
Analyse des fonctions d'autocorrélations (ACF) et d'autocorrélations partielles (PACF) pour déterminer les ordres p et q.
Estimation : Calcul des paramètres du modèle ARIMA à l'aide de méthodes d'optimisation (moindres carrés).
Vérification (Diagnostic) :
Analyse des résidus pour vérifier s'ils se comportent comme un bruit blanc (non autocorrélés, variance constante).
Calcul des métriques d'erreur comme la RMSE (Root Mean Square Error) ou le critère AIC (Akaike Information Criterion).

💻 Installation et Utilisation
Prérequis
Le projet nécessite Python et les bibliothèques suivantes :

pandas
numpy
matplotlib
seaborn
statsmodels

Exécution
Ouvrez le fichier 01_Modele_Arima.ipynb dans un environnement Jupyter Notebook ou Google Colab et exécutez les cellules séquentiellement pour voir les visualisations et les résultats du modèle.

📈 Résultats attendus
Le notebook permet de transformer une série temporelle brute en une série stationnaire, d'ajuster le meilleur modèle ARIMA et de générer des prévisions futures tout en comparant les données réelles avec les prédictions du modèle.

Ce projet a été réalisé à des fins pédagogiques pour illustrer l'application des séries temporelles en Python.