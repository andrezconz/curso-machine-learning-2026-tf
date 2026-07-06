###############################################################
# SCRIPT 4.1
# SELECCION DEL NUMERO OPTIMO DE CLUSTERS
###############################################################

library(tidyverse)
library(cluster)
library(fpc)

###############################################################
# CARGAR DATOS
###############################################################

datos_ml <- readRDS("datos_ml.rds")

###############################################################
# SEMILLA
###############################################################

set.seed(20260706)

###############################################################
# RANGO DE K
###############################################################

k_max <- 10

###############################################################
# OBJETOS
###############################################################

wss <- numeric(k_max)

silhouette_media <- numeric(k_max)

calinski <- numeric(k_max)

###############################################################
# CALCULAR DISTANCIAS UNA SOLA VEZ
###############################################################

distancias <- dist(datos_ml)

###############################################################
# ITERAR SOBRE LOS VALORES DE K
###############################################################

for(k in 2:k_max){
  
  modelo <- kmeans(
    datos_ml,
    centers = k,
    nstart = 100,
    iter.max = 1000
  )
  
  ###########################################################
  # WSS
  ###########################################################
  
  wss[k] <- modelo$tot.withinss
  
  ###########################################################
  # SILHOUETTE
  ###########################################################
  
  sil <- silhouette(
    modelo$cluster,
    distancias
  )
  
  silhouette_media[k] <- mean(sil[,3])
  
  ###########################################################
  # CALINSKI-HARABASZ
  ###########################################################
  
  stats <- cluster.stats(
    d = distancias,
    clustering = modelo$cluster
  )
  
  calinski[k] <- stats$ch
  
}

###############################################################
# TABLA RESUMEN
###############################################################

tabla_k <- tibble(
  
  k = 2:k_max,
  
  WSS = wss[2:k_max],
  
  Silhouette = silhouette_media[2:k_max],
  
  Calinski_Harabasz = calinski[2:k_max]
  
)

print(tabla_k)

###############################################################
# EXPORTAR
###############################################################

write.csv(
  tabla_k,
  "seleccion_k.csv",
  row.names = FALSE
)

###############################################################
# GRAFICO WSS
###############################################################

ggplot(tabla_k,
       aes(k,WSS))+
  
  geom_line(linewidth=1)+
  
  geom_point(size=3)+
  
  scale_x_continuous(breaks=2:k_max)+
  
  theme_minimal(base_size=14)+
  
  labs(
    title="Método del Codo",
    x="Número de clusters",
    y="Within Sum of Squares"
  )

###############################################################
# GRAFICO SILHOUETTE
###############################################################

ggplot(tabla_k,
       aes(k,Silhouette))+
  
  geom_line(linewidth=1)+
  
  geom_point(size=3,color="steelblue")+
  
  scale_x_continuous(breaks=2:k_max)+
  
  theme_minimal(base_size=14)+
  
  labs(
    title="Índice de Silhouette",
    x="Número de clusters",
    y="Silhouette promedio"
  )

###############################################################
# GRAFICO CALINSKI-HARABASZ
###############################################################

ggplot(tabla_k,
       aes(k,Calinski_Harabasz))+
  
  geom_line(linewidth=1)+
  
  geom_point(size=3,color="darkred")+
  
  scale_x_continuous(breaks=2:k_max)+
  
  theme_minimal(base_size=14)+
  
  labs(
    title="Índice Calinski-Harabasz",
    x="Número de clusters",
    y="Índice CH"
  )

###############################################################
# MEJOR K SEGUN SILHOUETTE
###############################################################

mejor_sil <- tabla_k |>
  filter(Silhouette == max(Silhouette))

cat("\n")
cat("========================================\n")
cat("MEJOR K SEGUN SILHOUETTE\n")
cat("========================================\n")

print(mejor_sil)

###############################################################
# MEJOR K SEGUN CALINSKI
###############################################################

mejor_ch <- tabla_k |>
  filter(Calinski_Harabasz == max(Calinski_Harabasz))

cat("\n")
cat("========================================\n")
cat("MEJOR K SEGUN CALINSKI-HARABASZ\n")
cat("========================================\n")

print(mejor_ch)

###############################################################
# RECOMENDACION
###############################################################

cat("\n")
cat("========================================\n")
cat("RECOMENDACION\n")
cat("========================================\n")

cat("Compare los tres criterios:\n")
cat("- Método del codo\n")
cat("- Silhouette\n")
cat("- Calinski-Harabasz\n\n")

cat("Seleccione el valor de k que presente\n")
cat("el mejor equilibrio entre simplicidad\n")
cat("e interpretación sustantiva.\n")

###############################################################
# FIN
###############################################################