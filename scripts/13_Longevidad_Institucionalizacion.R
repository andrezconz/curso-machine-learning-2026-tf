###############################################################
# SCRIPT 13
# LONGEVIDAD ORGANIZATIVA (INSTITUCIONALIZACION, SECCION 5.5)
#
# Panebianco (1988) y Mainwaring & Scully (1995) definen la
# institucionalizacion partidista como la capacidad de una
# organizacion de sobrevivir en el tiempo mas alla de su
# fundacion. Este script calcula la longevidad de cada partido
# (anos entre fundacion y ultimo registro, campo temporalidad) y
# la cruza con los clusters del segundo nivel (script 11) como
# prueba independiente de que institucionalizacion, no ideologia,
# es el eje que mejor distingue a los partidos colombianos.
#
# Requiere resultados/nivel2_partidos_clusterizados.csv (script 11),
# que ya incluye temporalidad y cluster en el mismo archivo (no
# hace falta un join adicional con partidos.xlsx).
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
})

base <- read_csv("resultados/nivel2_partidos_clusterizados.csv", show_col_types = FALSE)

base <- base |>
  mutate(
    ano_ini = as.numeric(str_extract(temporalidad, "^[0-9]{4}")),
    ano_fin = as.numeric(str_extract(temporalidad, "[0-9]{4}$")),
    longevidad = ano_fin - ano_ini
  )

tabla_longevidad <- base |>
  group_by(cluster) |>
  summarise(
    n = n(),
    longevidad_promedio = round(mean(longevidad), 1),
    longevidad_mediana = median(longevidad),
    longevidad_maxima = max(longevidad)
  )

cat("Longevidad por cluster (nivel 2):\n")
print(tabla_longevidad)

write.csv(tabla_longevidad, "resultados/longevidad_por_cluster.csv", row.names = FALSE)

###############################################################
# FIN
###############################################################
