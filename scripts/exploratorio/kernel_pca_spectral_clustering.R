###############################################################
# EXPLORATORIO: KERNEL PCA Y SPECTRAL CLUSTERING (ROBUSTEZ)
#
# Chequeo de robustez del modelo del nivel 1 (script 4). NO forma
# parte del pipeline principal; el resultado (ARI = 0.71, el
# cluster minoritario "maquinarias electorales" no se recupera
# con un kernel RBF) se resume como limitacion en la seccion 7
# del reporte, sin reemplazar el modelo K-Means reportado.
#
# Requiere resultados/datos_ml.rds y resultados/modelo_kmeans.rds
# (scripts 3 y 4).
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(kernlab)
  library(mclust)
})

datos_ml <- readRDS("resultados/datos_ml.rds")
modelo_kmeans <- readRDS("resultados/modelo_kmeans.rds")
X <- as.matrix(datos_ml)

set.seed(20260706)

cat("========================================\n")
cat("1. KERNEL PCA (RBF)\n")
cat("========================================\n")

sigma_est <- sigest(X, scaled = FALSE)["50%"]
cat("Sigma estimado (heuristica de sigest, mediana):", round(sigma_est, 4), "\n")

kpc <- kpca(X, kernel = "rbfdot", kpar = list(sigma = as.numeric(sigma_est)), features = 5)

kpc_coord <- as.data.frame(rotated(kpc))
names(kpc_coord) <- paste0("KPC", 1:ncol(kpc_coord))
kpc_coord$cluster_kmeans <- factor(modelo_kmeans$cluster)

eig <- eig(kpc)
cat("\n% relativo de los primeros 5 valores propios (de los calculados):\n")
print(round(100 * eig[1:5] / sum(eig), 2))

p_kpca <- ggplot(kpc_coord, aes(KPC1, KPC2, color = cluster_kmeans)) +
  geom_point(alpha = 0.5, size = 1.8) +
  theme_minimal(base_size = 13) +
  labs(title = "Kernel PCA (RBF) coloreado por cluster de K-Means",
       x = "KPC1", y = "KPC2", color = "Cluster K-Means")
ggsave("../figuras/exploratorio_kernelpca.png", p_kpca, width = 7, height = 5, dpi = 150)

cat("\n========================================\n")
cat("2. SPECTRAL CLUSTERING (k=4)\n")
cat("========================================\n")

n <- nrow(X)
if (n > 2000) {
  idx <- sample(1:n, 2000)
  Xs <- X[idx, ]
  cat("n =", n, "-> se usa una muestra aleatoria de 2000 para factibilidad computacional\n")
} else {
  idx <- 1:n
  Xs <- X
}

sc <- specc(Xs, centers = 4, kernel = "rbfdot")

cluster_kmeans_muestra <- factor(modelo_kmeans$cluster)[idx]
cluster_spectral <- factor(sc)

cat("\nTabla cruzada K-Means (muestra) vs Spectral:\n")
print(table(KMeans = cluster_kmeans_muestra, Spectral = cluster_spectral))

ari <- adjustedRandIndex(cluster_kmeans_muestra, cluster_spectral)
cat("\nIndice de Rand ajustado (K-Means vs Spectral, mismos puntos):", round(ari, 4), "\n")

cat("\n========================================\n")
cat("3. PERFIL SUSTANTIVO DE LOS CLUSTERS ESPECTRALES\n")
cat("========================================\n")

partidos <- readxl::read_excel("data/partidos.xlsx") |> janitor::clean_names()
tmp <- partidos[idx, ]
tmp$cluster_spectral <- cluster_spectral

cat("\nIdeologia (%) por cluster espectral:\n")
print(round(100 * prop.table(table(tmp$cluster_spectral, tmp$ideologia), margin = 1), 1))
cat("\nPart_presidencia (%) por cluster espectral:\n")
print(round(100 * prop.table(table(tmp$cluster_spectral, tmp$part_presidencia), margin = 1), 1))

###############################################################
# FIN
###############################################################
