###############################################################
# SCRIPT 11
# SEGUNDO NIVEL: MODELO FINAL (k=3) Y FIGURA PCA
#
# Requiere resultados/datos_ml2.rds y
# resultados/base_nivel2_partidos_no_coalicion.csv (script 9).
# k=3 elegido por silhouette/Calinski-Harabasz e interpretabilidad
# (ver script 10 y seccion 5.4 del reporte).
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
})

datos_ml2 <- readRDS("resultados/datos_ml2.rds")
base <- fread("resultados/base_nivel2_partidos_no_coalicion.csv")

set.seed(20260706)
m <- kmeans(datos_ml2, centers = 3, nstart = 100, iter.max = 1000)

# Las etiquetas se asignan por tamano del cluster (no por el ID arbitrario
# que les da kmeans, que puede cambiar con la semilla): el grupo mas grande
# es "Vehiculo marginal", el intermedio "Nicho/identitario", el mas
# pequeno "Elite nacional" -- consistente con el patron sustantivo 86%/9%/5%
# ya documentado en el reporte.
tam <- table(m$cluster)
orden <- order(-tam)
mapa_etiquetas <- setNames(
  c("Vehiculo marginal", "Nicho/identitario", "Elite nacional"),
  names(tam)[orden]
)
base$cluster <- factor(mapa_etiquetas[as.character(m$cluster)],
                        levels = c("Vehiculo marginal", "Nicho/identitario", "Elite nacional"))

fwrite(base, "resultados/nivel2_partidos_clusterizados.csv")

sil <- cluster::silhouette(m$cluster, dist(datos_ml2))
cat("Silhouette promedio general:", round(mean(sil[, 3]), 3), "\n")
cat("Silhouette por cluster (etiquetado por tamano):\n")
sil_por_id <- tapply(sil[, 3], sil[, 1], mean)
names(sil_por_id) <- mapa_etiquetas[names(sil_por_id)]
print(round(sil_por_id, 3))
cat("Varianza explicada (between/total):", round(100 * m$betweenss / m$totss, 1), "%\n")

pca <- prcomp(datos_ml2, center = TRUE, scale. = TRUE)
coord <- as.data.frame(pca$x)
coord$cluster <- base$cluster
var1 <- round(100 * summary(pca)$importance[2, 1], 1)
var2 <- round(100 * summary(pca)$importance[2, 2], 1)

p <- ggplot(coord, aes(PC1, PC2, color = cluster)) +
  geom_point(alpha = 0.6, size = 1.8) +
  theme_minimal(base_size = 13) +
  labs(title = "Segundo nivel: clusters de partidos no-coalicion con votos reales (1958-2023)",
       x = paste0("PC1 (", var1, "%)"), y = paste0("PC2 (", var2, "%)"), color = "Cluster")
ggsave("figuras/fig4_nivel2_pca.png", p, width = 7.5, height = 5, dpi = 150)

###############################################################
# FIN
###############################################################
