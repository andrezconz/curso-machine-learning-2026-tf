###############################################################
# SCRIPT 6
# CARACTERIZACIÓN DE LOS CLUSTERS
#
# PROPOSITO METODOLOGICO
# K-Means asigna un número a cada partido, pero un número no dice
# nada por sí solo: hay que "traducir" cada cluster de vuelta a las
# variables originales (ideología, tradicionalidad, participación
# electoral por nivel) para poder nombrarlo e interpretarlo de
# forma sustantiva (secciones 5.2 y 6.1 del reporte). Este paso es
# el puente entre el resultado puramente algorítmico del script 4 y
# la narrativa de política pública: sin esta caracterización,
# "cluster 1" seguiría siendo una etiqueta vacía en vez de
# "maquinarias electorales multinivel".
###############################################################

rm(list = ls())

###############################################################
# LIBRERÍAS
###############################################################

library(tidyverse)
library(readxl)
library(janitor)
library(scales)

###############################################################
# CARGAR BASE ORIGINAL
###############################################################

partidos <- read_excel("data/partidos.xlsx") |>
  clean_names()

###############################################################
# CARGAR MODELO
###############################################################

modelo_kmeans <- readRDS("modelo_kmeans.rds")

###############################################################
# AGREGAR CLUSTER
###############################################################

partidos$cluster <- factor(modelo_kmeans$cluster)

###############################################################
# TAMAÑO DE LOS CLUSTERS
###############################################################

tamano_cluster <- partidos |>
  count(cluster) |>
  mutate(
    porcentaje = round(100 * n / sum(n),2)
  )

print(tamano_cluster)

###############################################################
# EXPORTAR
###############################################################

write.csv(
  tamano_cluster,
  "tamano_clusters.csv",
  row.names = FALSE
)

###############################################################
# VARIABLES A ANALIZAR
###############################################################

variables <- c(
  
  "tradicional",
  "gradonac",
  "ideologia",
  "grupo_representativo_1",
  "grupo_representativo_2",
  "part_alcaldia",
  "part_asamblea",
  "part_camara",
  "part_concejo",
  "part_gobernacion",
  "part_presidencia",
  "part_senado"
  
)

###############################################################
# TABLAS DE CONTINGENCIA
###############################################################

for(v in variables){
  
  cat("\n=======================================\n")
  cat("VARIABLE:",v,"\n")
  cat("=======================================\n")
  
  print(
    table(
      partidos[[v]],
      partidos$cluster
    )
  )
  
}

###############################################################
# PORCENTAJES POR CLUSTER
###############################################################

for(v in variables){
  
  cat("\n=======================================\n")
  cat("PORCENTAJES:",v,"\n")
  cat("=======================================\n")
  
  tabla <- partidos |>
    count(cluster,.data[[v]]) |>
    group_by(cluster) |>
    mutate(
      porcentaje = round(100*n/sum(n),2)
    )
  
  print(tabla)
  
}

###############################################################
# VARIABLES BINARIAS
###############################################################

binarias <- c(
  
  "part_alcaldia",
  "part_asamblea",
  "part_camara",
  "part_concejo",
  "part_gobernacion",
  "part_presidencia",
  "part_senado"
  
)

###############################################################
# PERFIL ELECTORAL
###############################################################

perfil <- partidos |>
  group_by(cluster) |>
  summarise(
    
    across(
      
      all_of(binarias),
      
      mean,
      
      na.rm=TRUE
      
    )
    
  )

print(perfil)

###############################################################
# EXPORTAR
###############################################################

write.csv(
  
  perfil,
  
  "perfil_electoral.csv",
  
  row.names=FALSE
  
)

###############################################################
# GRAFICO PERFIL ELECTORAL
###############################################################

perfil_long <- perfil |>
  pivot_longer(
    cols = c(
      part_alcaldia,
      part_asamblea,
      part_camara,
      part_concejo,
      part_gobernacion,
      part_presidencia,
      part_senado
    ),
    names_to = "Variable",
    values_to = "Valor"
  )

ggplot(
  
  perfil_long,
  
  aes(
    
    Variable,
    
    Valor,
    
    fill=cluster
    
  )
  
)+
  
  geom_col(
    
    position="dodge"
    
  )+
  
  scale_y_continuous(
    
    labels=percent
    
  )+
  
  theme_minimal(base_size = 13)+
  
  labs(
    
    title="Participación electoral promedio por cluster",
    
    x="",
    
    y="Proporción"
    
  )

###############################################################
# IDEOLOGÍA
###############################################################

ideologia_cluster <- partidos |>
  
  count(
    
    cluster,
    
    ideologia
    
  ) |>
  
  group_by(cluster) |>
  
  mutate(
    
    porcentaje=100*n/sum(n)
    
  )

ggplot(
  
  ideologia_cluster,
  
  aes(
    
    factor(ideologia),
    
    porcentaje,
    
    fill=cluster
    
  )
  
)+
  
  geom_col(
    
    position="dodge"
    
  )+
  
  theme_minimal(base_size = 13)+
  
  labs(
    
    title="Distribución ideológica por cluster",
    
    x="Ideología",
    
    y="%"
    
  )

###############################################################
# TRADICIONALES
###############################################################

tradicional_cluster <- partidos |>
  
  count(
    
    cluster,
    
    tradicional
    
  ) |>
  
  group_by(cluster) |>
  
  mutate(
    
    porcentaje=100*n/sum(n)
    
  )

ggplot(
  
  tradicional_cluster,
  
  aes(
    
    factor(tradicional),
    
    porcentaje,
    
    fill=cluster
    
  )
  
)+
  
  geom_col(
    
    position="dodge"
    
  )+
  
  theme_minimal(base_size = 13)+
  
  labs(
    
    title="Partidos tradicionales por cluster",
    
    x="Tradicional",
    
    y="%"
    
  )

###############################################################
# NACIONALIZACIÓN
###############################################################

gradonac_cluster <- partidos |>
  
  count(
    
    cluster,
    
    gradonac
    
  ) |>
  
  group_by(cluster) |>
  
  mutate(
    
    porcentaje=100*n/sum(n)
    
  )

ggplot(
  
  gradonac_cluster,
  
  aes(
    
    factor(gradonac),
    
    porcentaje,
    
    fill=cluster
    
  )
  
)+
  
  geom_col(
    
    position="dodge"
    
  )+
  
  theme_minimal(base_size = 13)+
  
  labs(
    
    title="Grado de nacionalización",
    
    x="Gradonac",
    
    y="%"
    
  )

###############################################################
# IDENTIFICAR LOS PARTIDOS
###############################################################

resultado_final <- partidos |>
  
  select(
    
    codigo_partido,
    nombre,
    cluster,
    tradicional,
    gradonac,
    ideologia
    
  )

write.csv(
  
  resultado_final,
  
  "partidos_cluster.csv",
  
  row.names=FALSE
  
)

###############################################################
# RESUMEN AUTOMÁTICO
###############################################################

cat("\n=========================================\n")
cat("RESUMEN\n")
cat("=========================================\n")

for(i in levels(partidos$cluster)){
  
  cat("\n")
  
  cat("CLUSTER",i,"\n")
  
  cat("-----------------------------\n")
  
  tmp <- partidos |>
    
    filter(cluster==i)
  
  cat("Número de partidos:",nrow(tmp),"\n")
  
  cat("Tradicionales:",round(mean(tmp$tradicional==1)*100,1),"%\n")
  
  cat("Participan en Senado:",
      round(mean(tmp$part_senado==1)*100,1),"%\n")
  
  cat("Participan en Presidencia:",
      round(mean(tmp$part_presidencia==1)*100,1),"%\n")
  
  cat("Participan en Alcaldías:",
      round(mean(tmp$part_alcaldia==1)*100,1),"%\n")
  
}

###############################################################
# FIN
###############################################################