###############################################################
# SCRIPT 7
# INFERENCIA ESTADÍSTICA DE LOS CLUSTERS
#
# PROPOSITO METODOLOGICO
# El script 6 describe los clusters; este script pregunta si esas
# diferencias son estadísticamente reales o podrían deberse al
# azar. Para cada variable original se hace una prueba χ² de
# independencia contra la asignación de cluster (¿la variable y el
# cluster están asociados, o son independientes?), se mide el
# TAMAÑO de esa asociación con la V de Cramér (χ² crece solo con n,
# no dice si el efecto es grande o pequeño), y se ajustan los
# p-valores con Benjamini-Hochberg porque se corren 12 pruebas
# simultáneas (sin ajuste, el riesgo de falsos positivos se
# acumula). Este último punto fue clave para detectar que la V de
# Cramér perfecta (1,0) de "tradicional" en la versión original del
# pipeline era un artefacto de un bug de codificación, no una señal
# real (ver script 3 y sección 7 del reporte).
###############################################################

rm(list = ls())

###############################################################
# LIBRERÍAS
###############################################################

library(tidyverse)
library(readxl)
library(janitor)
library(DescTools)
library(broom)

###############################################################
# IMPORTAR BASE
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
# VARIABLES
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
# OBJETOS
###############################################################

tabla_resultados <- data.frame()

###############################################################
# CICLO PRINCIPAL
###############################################################

for(v in variables){
  
  cat("\n=====================================\n")
  cat(v,"\n")
  cat("=====================================\n")
  
  datos <- partidos |>
    filter(!is.na(.data[[v]]))
  
  tabla <- table(datos$cluster,
                 datos[[v]])
  
  ###########################################################
  # CHI CUADRADO
  ###########################################################
  
  chi <- suppressWarnings(
    chisq.test(tabla)
  )
  
  ###########################################################
  # CRAMER V
  ###########################################################
  
  cv <- CramerV(tabla)
  
  ###########################################################
  # RESIDUOS
  ###########################################################
  
  residuos <- round(chi$stdres,2)
  
  write.csv(
    residuos,
    paste0(
      "Resultados/Residuos_",
      v,
      ".csv"
    )
  )
  
  ###########################################################
  # TABLA RESUMEN
  ###########################################################
  
  tabla_resultados <-
    
    rbind(
      
      tabla_resultados,
      
      data.frame(
        
        Variable=v,
        
        Chi2=round(
          unname(chi$statistic),
          3
        ),
        
        gl=unname(chi$parameter),
        
        p=chi$p.value,
        
        CramerV=round(cv,3)
        
      )
      
    )
  
}

###############################################################
# AJUSTE POR MÚLTIPLES PRUEBAS
###############################################################

tabla_resultados$p_ajustado <-
  
  p.adjust(
    
    tabla_resultados$p,
    
    method="BH"
    
  )

###############################################################
# SIGNIFICANCIA
###############################################################

tabla_resultados$Significativo <-
  
  ifelse(
    
    tabla_resultados$p_ajustado<0.05,
    
    "Sí",
    
    "No"
    
  )

###############################################################
# ORDENAR
###############################################################

tabla_resultados <-
  
  tabla_resultados |>
  
  arrange(
    
    desc(CramerV)
    
  )

###############################################################
# MOSTRAR
###############################################################

print(tabla_resultados)

###############################################################
# EXPORTAR
###############################################################

write.csv(
  
  tabla_resultados,
  
  "Resultados/InferenciaClusters.csv",
  
  row.names=FALSE
  
)

###############################################################
# VARIABLES MÁS IMPORTANTES
###############################################################

ggplot(
  
  tabla_resultados,
  
  aes(
    
    reorder(Variable,CramerV),
    
    CramerV
    
  )
  
)+
  
  geom_col(fill="steelblue")+
  
  coord_flip()+
  
  theme_minimal(base_size=13)+
  
  labs(
    
    title="Importancia de las variables",
    
    x="",
    
    y="V de Cramér"
    
  )

###############################################################
# HEATMAP DE RESIDUOS
###############################################################

for(v in variables){
  
  tabla <- table(
    partidos$cluster,
    partidos[[v]]
  )
  
  chi <- suppressWarnings(
    chisq.test(tabla)
  )
  
  heat <- as.data.frame(
    chi$stdres
  )
  
  names(heat) <-
    c(
      "Cluster",
      "Categoria",
      "Residuo"
    )
  
  g <-
    
    ggplot(
      
      heat,
      
      aes(
        
        Categoria,
        
        Cluster,
        
        fill=Residuo
        
      )
      
    )+
    
    geom_tile(color="white")+
    
    geom_text(
      
      aes(
        
        label=round(
          Residuo,
          2
        )
        
      ),
      
      size=3
      
    )+
    
    scale_fill_gradient2(
      
      low="blue",
      
      mid="white",
      
      high="red"
      
    )+
    
    theme_minimal()+
    
    labs(
      
      title=v,
      
      x="",
      
      y=""
      
    )
  
  print(g)
  
}

###############################################################
# RESUMEN AUTOMÁTICO
###############################################################

cat("\n")
cat("=========================================\n")
cat("VARIABLES MÁS ASOCIADAS A LOS CLUSTERS\n")
cat("=========================================\n")

print(
  
  tabla_resultados |>
    
    arrange(
      
      desc(CramerV)
      
    )
  
)

###############################################################
# FIN
###############################################################

ideologia_cluster <- partidos |>
  count(cluster, ideologia) |>
  group_by(cluster) |>
  mutate(
    porcentaje = 100 * n / sum(n)
  )

ideologia_cluster

ggplot(
  ideologia_cluster,
  aes(
    x = factor(ideologia),
    y = porcentaje,
    fill = cluster
  )
) +
  geom_col(position = "dodge") +
  theme_minimal() +
  labs(
    x = "Ideología",
    y = "Porcentaje",
    fill = "Cluster"
  )

prop.table(table(datos$ideologia))

chisq.test(
  partidos$cluster,
  partidos$ideologia
)

DescTools::CramerV(
  table(partidos$cluster,
        partidos$ideologia)
)

identitarios <- partidos |>
  filter(
    !grupo_representativo_1 %in% c(99)
  )

grupo_cluster <- identitarios |>
  count(
    cluster,
    grupo_representativo_1
  ) |>
  group_by(cluster) |>
  mutate(
    porcentaje = 100 * n / sum(n)
  )

partidos |>
  count(
    cluster,
    ideologia,
    grupo_representativo_1
  )


library(ggalluvial)

datos <- partidos |>
  count(cluster,
        ideologia,
        grupo_representativo_1)

ggplot(
  datos,
  aes(
    axis1 = ideologia,
    axis2 = grupo_representativo_1,
    y = n
  )
) +
  geom_alluvium(aes(fill = factor(cluster))) +
  geom_stratum(width = 0.2) +
  geom_text(
    stat = "stratum",
    aes(label = after_stat(stratum))
  ) +
  scale_x_discrete(
    limits = c("Ideología", "Grupo")
  ) +
  theme_minimal()


tabla <- partidos |>
  count(
    cluster,
    ideologia,
    grupo_representativo_1
  ) |>
  group_by(cluster, ideologia) |>
  mutate(
    porcentaje = round(100 * n / sum(n), 2)
  )

write.csv(
  tabla,
  "Resultados/Ideologia_Grupo_Cluster.csv",
  row.names = FALSE
)

tabla <- partidos |>
  filter(!grupo_representativo_1 %in% c(98, 99)) |>
  count(
    cluster,
    ideologia,
    grupo_representativo_1
  ) |>
  group_by(cluster, ideologia) |>
  mutate(
    porcentaje = round(100 * n / sum(n), 2)
  )

tabla

tabla <- partidos |>
  filter(!as.character(grupo_representativo_1) %in% c("98", "99")) |>
  count(
    cluster,
    ideologia,
    grupo_representativo_1
  ) |>
  group_by(cluster, ideologia) |>
  mutate(
    porcentaje = round(100 * n / sum(n), 2)
  )

tabla
