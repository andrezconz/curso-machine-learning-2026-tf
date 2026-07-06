###############################################################
# SCRIPT 10
# SEGUNDO NIVEL: SELECCION DEL NUMERO DE CLUSTERS
#
# Requiere resultados/datos_ml2.rds (script 9).
# Ejecutar con el working directory en la raiz del repositorio.
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(cluster)
  library(fpc)
})

datos_ml2 <- readRDS("resultados/datos_ml2.rds")
set.seed(20260706)

k_max <- 10
wss <- numeric(k_max); sil <- numeric(k_max); ch <- numeric(k_max)
d <- dist(datos_ml2)

for (k in 2:k_max) {
  m <- kmeans(datos_ml2, centers = k, nstart = 100, iter.max = 1000)
  wss[k] <- m$tot.withinss
  s <- silhouette(m$cluster, d)
  sil[k] <- mean(s[, 3])
  st <- cluster.stats(d = d, clustering = m$cluster)
  ch[k] <- st$ch
}

tabla_k2 <- tibble(k = 2:k_max, WSS = wss[2:k_max], Silhouette = sil[2:k_max], Calinski_Harabasz = ch[2:k_max])
print(tabla_k2)

write.csv(tabla_k2, "resultados/seleccion_k_nivel2.csv", row.names = FALSE)

cat("\nmejor silhouette:\n"); print(tabla_k2[which.max(tabla_k2$Silhouette), ])
cat("\nmejor CH:\n"); print(tabla_k2[which.max(tabla_k2$Calinski_Harabasz), ])

###############################################################
# FIN
###############################################################
