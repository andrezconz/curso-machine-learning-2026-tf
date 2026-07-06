###############################################################
# SCRIPT 5.1
# PROYECCION t-SNE DE LOS CLUSTERS (NIVEL 1)
#
# Complementa la PCA lineal del script 5 con una proyeccion no
# lineal que preserva mejor la vecindad local (cubierta en la
# sesion de aprendizaje no supervisado del curso). Se probo
# tambien UMAP, pero fallo al inicializar por la enorme cantidad
# de perfiles categoricos identicos o casi identicos entre
# partidos (grafo de vecinos con componentes desconectados);
# t-SNE si produjo una proyeccion estable.
#
# Requiere resultados/datos_ml.rds y resultados/modelo_kmeans.rds
# (scripts 3 y 4). Instalar Rtsne si hace falta:
# install.packages("Rtsne")
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(Rtsne)
})

datos_ml <- readRDS("resultados/datos_ml.rds")
modelo_kmeans <- readRDS("resultados/modelo_kmeans.rds")

X <- as.matrix(datos_ml)

set.seed(2025)
tsne <- Rtsne(X, dims = 2, perplexity = 30, check_duplicates = FALSE,
              pca = FALSE, theta = 0.5, max_iter = 1000, verbose = FALSE)

coord <- as.data.frame(tsne$Y)
names(coord) <- c("TSNE1", "TSNE2")
coord$cluster <- factor(modelo_kmeans$cluster)

p <- ggplot(coord, aes(TSNE1, TSNE2, color = cluster)) +
  geom_point(alpha = 0.5, size = 1.4) +
  theme_minimal(base_size = 13) +
  labs(title = "Proyeccion t-SNE de los 4 clusters (nivel 1)",
       subtitle = "La cercania local es informativa; NO interpretar tamanos ni distancias entre grupos",
       x = "t-SNE 1", y = "t-SNE 2", color = "Cluster")

ggsave("figuras/fig5_tsne_nivel1.png", p, width = 7.2, height = 5, dpi = 150)

###############################################################
# FIN
###############################################################
