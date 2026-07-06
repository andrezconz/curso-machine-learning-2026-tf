###############################################################
# SCRIPT 5
# ANALISIS DE COMPONENTES PRINCIPALES
###############################################################

rm(list = ls())

###############################################################
# LIBRERIAS
###############################################################

library(tidyverse)
library(ggplot2)

###############################################################
# CARGAR OBJETOS
###############################################################

datos_ml <- readRDS("datos_ml.rds")

modelo_kmeans <- readRDS("modelo_kmeans.rds")

###############################################################
# PCA
###############################################################

pca <- prcomp(
  datos_ml,
  center = TRUE,
  scale. = TRUE
)

###############################################################
# RESUMEN
###############################################################

summary(pca)

###############################################################
# VALORES PROPIOS
###############################################################

eigenvalues <- pca$sdev^2

prop_var <- eigenvalues / sum(eigenvalues)

cum_prop <- cumsum(prop_var)

tabla_pca <- data.frame(
  Componente = paste0("PC",1:length(eigenvalues)),
  Eigenvalue = eigenvalues,
  Varianza = prop_var,
  Acumulada = cum_prop
)

print(tabla_pca)

###############################################################
# EXPORTAR
###############################################################

write.csv(
  tabla_pca,
  "tabla_pca.csv",
  row.names = FALSE
)

###############################################################
# SCREE PLOT
###############################################################

ggplot(
  tabla_pca,
  aes(
    x = Componente,
    y = Varianza
  )
)+
  
  geom_col(fill="steelblue")+
  
  geom_line(
    aes(group=1),
    color="red"
  )+
  
  geom_point(
    color="red",
    size=2
  )+
  
  theme_minimal(base_size = 13)+
  
  labs(
    title="Scree Plot",
    y="Proporción de varianza explicada",
    x=""
  )

###############################################################
# COORDENADAS
###############################################################

coord <- as.data.frame(pca$x)

coord$cluster <- factor(modelo_kmeans$cluster)

###############################################################
# GRAFICO PC1-PC2
###############################################################

ggplot(
  coord,
  aes(
    PC1,
    PC2,
    colour=cluster
  )
)+
  
  geom_point(
    alpha=.8,
    size=2.5
  )+
  
  stat_ellipse(
    aes(fill=cluster),
    geom="polygon",
    alpha=.15,
    colour=NA
  )+
  
  theme_minimal(base_size=14)+
  
  labs(
    title="Clusters proyectados sobre las dos primeras componentes",
    x="Primera componente principal",
    y="Segunda componente principal"
  )

###############################################################
# CARGAS
###############################################################

loadings <- as.data.frame(pca$rotation)

###############################################################
# VARIABLES IMPORTANTES PC1
###############################################################

pc1 <- loadings |>
  mutate(
    abs_loading = abs(PC1)
  ) |>
  arrange(desc(abs_loading))

print(head(pc1,15))

###############################################################
# VARIABLES IMPORTANTES PC2
###############################################################

pc2 <- loadings |>
  mutate(
    abs_loading = abs(PC2)
  ) |>
  arrange(desc(abs_loading))

print(head(pc2,15))

###############################################################
# HEATMAP DE CARGAS
###############################################################

library(reshape2)

heat <- loadings |>
  rownames_to_column("Variable") |>
  select(
    Variable,
    PC1,
    PC2
  )

heat_long <- melt(
  heat,
  id.vars="Variable"
)

ggplot(
  heat_long,
  aes(
    variable,
    Variable,
    fill=value
  )
)+
  
  geom_tile()+
  
  scale_fill_gradient2(
    low="blue",
    mid="white",
    high="red"
  )+
  
  theme_minimal(base_size=11)+
  
  labs(
    title="Contribución de las variables a las dos primeras componentes",
    x="",
    y=""
  )

###############################################################
# CORRELACIONES COMPONENTES
###############################################################

round(
  cor(coord[,1:5]),
  3
)

###############################################################
# EXPORTAR LOADINGS
###############################################################

write.csv(
  loadings,
  "loadings.csv"
)

###############################################################
# EXPORTAR COORDENADAS
###############################################################

write.csv(
  coord,
  "coordenadas_pca.csv",
  row.names = FALSE
)

###############################################################
# FIN SCRIPT
###############################################################