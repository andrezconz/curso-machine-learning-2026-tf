###############################################################
# SCRIPT 4
# K-MEANS
###############################################################

library(tidyverse)
library(cluster)
library(factoextra)

###############################################################
# CARGAR MATRIZ
###############################################################

datos_ml <- readRDS("datos_ml.rds")

###############################################################
# SEMILLA
###############################################################

set.seed(20260706)

###############################################################
# 1. METODO DEL CODO
###############################################################

wss <- numeric(10)

for(i in 1:10){
  
  wss[i] <- kmeans(
    datos_ml,
    centers = i,
    nstart = 100
  )$tot.withinss
  
}

elbow <- data.frame(
  
  k = 1:10,
  WSS = wss
  
)

ggplot(elbow,
       aes(k,WSS))+
  
  geom_line(size=1)+
  
  geom_point(size=3)+
  
  scale_x_continuous(breaks=1:10)+
  
  theme_minimal(base_size = 14)+
  
  labs(
    
    title="Método del Codo",
    
    x="Número de clusters",
    
    y="Within Sum of Squares"
    
  )

###############################################################
# 2. SILHOUETTE
###############################################################

fviz_nbclust(
  
  datos_ml,
  
  kmeans,
  
  method="silhouette",
  
  k.max=10
  
)+
  
  theme_minimal()

###############################################################
#=========================================================
#
# CAMBIAR ESTE VALOR SEGUN LOS GRAFICOS
#
###############################################################

k <- 4

###############################################################
# 3. MODELO FINAL
###############################################################

modelo_kmeans <- kmeans(
  
  datos_ml,
  
  centers = k,
  
  nstart = 100,
  
  iter.max = 1000
  
)

###############################################################
# 4. RESUMEN
###############################################################

print(modelo_kmeans)

###############################################################
# 5. TAMAÑO CLUSTERS
###############################################################

table(modelo_kmeans$cluster)

###############################################################
# 6. PORCENTAJES
###############################################################

round(
  
  prop.table(
    
    table(modelo_kmeans$cluster)
    
  )*100,
  
  2
  
)

###############################################################
# 7. CENTROIDES
###############################################################

centroides <-
  
  round(
    
    modelo_kmeans$centers,
    
    3
    
  )

centroides

###############################################################
# 8. VARIANZA EXPLICADA
###############################################################

cat("\n")

cat("=========================\n")

cat("VARIANZA EXPLICADA\n")

cat("=========================\n")

100*
  
  modelo_kmeans$betweenss/
  
  modelo_kmeans$totss

###############################################################
# 9. SILHOUETTE PROMEDIO
###############################################################

sil <- silhouette(
  
  modelo_kmeans$cluster,
  
  dist(datos_ml)
  
)

mean(sil[,3])

###############################################################
# 10. GRAFICO SILHOUETTE
###############################################################

fviz_silhouette(sil)

###############################################################
# 11. PCA
###############################################################

pca <- prcomp(
  
  datos_ml,
  
  center=TRUE,
  
  scale.=TRUE
  
)

coord <-
  
  as.data.frame(
    
    pca$x
    
  )

coord$cluster <-
  
  factor(
    
    modelo_kmeans$cluster
    
  )

###############################################################
# 12. GRAFICO PCA
###############################################################

ggplot(
  
  coord,
  
  aes(
    
    PC1,
    
    PC2,
    
    color=cluster
    
  )
  
)+
  
  geom_point(
    
    size=2.8,
    
    alpha=.80
    
  )+
  
  theme_minimal(base_size = 14)+
  
  labs(
    
    title="Clusters sobre las dos primeras componentes principales"
    
  )

###############################################################
# 13. EXPORTAR
###############################################################

write.csv(
  
  centroides,
  
  "centroides.csv"
  
)

saveRDS(
  
  modelo_kmeans,
  
  "modelo_kmeans.rds"
  
)

coord$cluster <-
  
  factor(
    
    modelo_kmeans$cluster
    
  )

write.csv(
  
  coord,
  
  "coordenadas_pca.csv",
  
  row.names=FALSE
  
)

###############################################################
# 14. MATRIZ RESULTADOS
###############################################################

resultado <-
  
  datos_ml

resultado$cluster <-
  
  factor(
    
    modelo_kmeans$cluster
    
  )

write.csv(
  
  resultado,
  
  "datos_clusterizados.csv",
  
  row.names=FALSE
  
)

###############################################################
# FIN
###############################################################