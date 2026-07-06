###############################################################
# SCRIPT 8.1
# ESTADISTICAS DESCRIPTIVAS DE LAS BASES (SECCION 4.3 Y 5.4)
#
# Genera las tablas descriptivas de partidos.xlsx (distribucion
# de variables categoricas, participacion electoral por nivel) y
# de los votos historicos emparejados (script 8).
#
# Requiere resultados/votos_totales_partido_nivel.csv (script 8).
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(janitor)
  library(data.table)
  library(stringi)
})

partidos <- read_excel("data/partidos.xlsx") |> clean_names()

###############################################################
# 1. RESUMEN GENERAL
###############################################################

cat("N total:", nrow(partidos), "\n")
cat("N coaliciones (coalicion=1):", sum(partidos$coalicion == 1),
    sprintf("(%.1f%%)\n", 100 * mean(partidos$coalicion == 1)))

###############################################################
# 2. DISTRIBUCION DE VARIABLES CATEGORICAS
###############################################################

dist_tabla <- function(var, nombre) {
  t <- table(var, useNA = "no")
  data.frame(variable = nombre, categoria = names(t), n = as.integer(t),
             pct = round(100 * as.integer(t) / length(var), 1))
}

tabla_categoricas <- bind_rows(
  dist_tabla(partidos$tradicional, "tradicional"),
  dist_tabla(partidos$gradonac, "gradonac"),
  dist_tabla(partidos$ideologia, "ideologia"),
  dist_tabla(partidos$grupo_representativo_1, "grupo_representativo_1"),
  dist_tabla(partidos$grupo_representativo_2, "grupo_representativo_2")
)
print(as.data.frame(tabla_categoricas))
write.csv(tabla_categoricas, "resultados/descriptiva_categoricas.csv", row.names = FALSE)

###############################################################
# 3. PARTICIPACION ELECTORAL POR NIVEL (UNIVERSO COMPLETO)
###############################################################

part_vars <- c("part_alcaldia", "part_asamblea", "part_camara", "part_concejo",
               "part_gobernacion", "part_presidencia", "part_senado")

tabla_participacion <- map_dfr(part_vars, function(v) {
  x <- partidos[[v]]
  tibble(nivel = v, n_participa = sum(x == 1), pct_participa = round(100 * mean(x == 1), 1))
})
print(tabla_participacion)
write.csv(tabla_participacion, "resultados/descriptiva_participacion.csv", row.names = FALSE)

###############################################################
# 4. DESCRIPTIVA DE VOTOS HISTORICOS (1958-2023)
###############################################################

votos <- fread("resultados/votos_totales_partido_nivel.csv")

canon <- function(x) {
  x <- toupper(stri_trans_general(x, "Latin-ASCII"))
  x <- gsub("[^A-Z]", "", x)
  case_when(
    grepl("CONCEJO", x) ~ "Concejo", grepl("ASAMBLEA", x) ~ "Asamblea",
    grepl("SENADO", x) ~ "Senado", grepl("ALCALD", x) ~ "Alcaldia",
    grepl("CAMARA|CMARA|C.MARA", x) ~ "Camara", grepl("GOBERNAC", x) ~ "Gobernacion",
    grepl("PRESIDENCIA", x) ~ "Presidencia", TRUE ~ "Otro")
}
votos[, nivel := canon(tipo_eleccion)]
votos_agg <- votos[, .(votos_totales = sum(votos_totales)), by = .(nombre, nivel)]

tabla_votos <- votos_agg[, .(
  n_partidos_con_votos = .N,
  votos_total = sum(votos_totales),
  votos_promedio = round(mean(votos_totales)),
  votos_mediana = as.numeric(median(votos_totales)),
  votos_maximo = max(votos_totales)
), by = nivel]
setorder(tabla_votos, -votos_total)
print(tabla_votos)
write.csv(tabla_votos, "resultados/descriptiva_votos.csv", row.names = FALSE)

###############################################################
# FIN
###############################################################
