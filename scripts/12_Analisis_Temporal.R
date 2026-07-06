###############################################################
# SCRIPT 12
# EVIDENCIA TEMPORAL: COMPOSICION POR PERIODO DE FUNDACION
#
# Requiere resultados/nivel2_partidos_clusterizados.csv (script 11).
# Compara antes/despues de la Constitucion de 1991, el Acto
# Legislativo 01/2003 y la Ley 1475/2011.
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(janitor)
})

partidos <- read_excel("data/partidos.xlsx") |> clean_names()
partidos <- partidos |>
  mutate(
    ano_fundacion = as.numeric(str_extract(temporalidad, "^[0-9]{4}")),
    es_coalicion = str_starts(toupper(trimws(nombre)), "COALICION")
  )

periodo <- function(anio) {
  cut(anio,
      breaks = c(-Inf, 1991, 2003, 2011, Inf),
      labels = c("Antes de 1991", "1991-2003 (Const. 91)", "2003-2011 (AL 01/2003)", "2011-2023 (Ley 1475/2011)"),
      right = FALSE)
}
partidos$periodo <- periodo(partidos$ano_fundacion)

###############################################################
# TABLA 1: % coalicion ad hoc por periodo (universo completo, n=5143)
###############################################################

cat("=== TABLA 1: % de entidades que son coaliciones ad hoc, por periodo de fundacion (n=5.143) ===\n")
t1 <- partidos |>
  filter(!is.na(periodo)) |>
  count(periodo, es_coalicion) |>
  group_by(periodo) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()
print(t1)

resumen1 <- t1 |>
  filter(es_coalicion == TRUE) |>
  select(periodo, n_coalicion = n, pct_coalicion = pct)
totales <- partidos |> filter(!is.na(periodo)) |> count(periodo, name = "total")
resumen1 <- resumen1 |> left_join(totales, by = "periodo")
cat("\n--- Resumen: % coalicion ad hoc y total de entidades por periodo ---\n")
print(resumen1)

###############################################################
# TABLA 2: perfil (nivel 2) por periodo, solo no-coalicion
###############################################################

nivel2 <- read_csv("resultados/nivel2_partidos_clusterizados.csv", show_col_types = FALSE)
nivel2 <- nivel2 |> select(nombre, cluster) |> distinct(nombre, .keep_all = TRUE)

partidos_nc <- partidos |> filter(!es_coalicion) |> left_join(nivel2, by = "nombre")

cat("\n=== TABLA 2: composicion de clusters (nivel 2) entre partidos NO-coalicion, por periodo de fundacion ===\n")
t2 <- partidos_nc |>
  filter(!is.na(periodo), !is.na(cluster)) |>
  count(periodo, cluster) |>
  group_by(periodo) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  ungroup()
print(t2)

t2_wide <- t2 |>
  select(periodo, cluster, pct) |>
  pivot_wider(names_from = cluster, values_from = pct, values_fill = 0)
cat("\n--- Tabla ancha ---\n")
print(t2_wide)

n_por_periodo <- partidos_nc |> filter(!is.na(periodo), !is.na(cluster)) |> count(periodo, name = "n_partidos")
cat("\nn de partidos no-coalicion con cluster asignado, por periodo:\n")
print(n_por_periodo)

write.csv(resumen1, "resultados/temporal_coalicion_por_periodo.csv", row.names = FALSE)
write.csv(t2_wide, "resultados/temporal_clusters_por_periodo.csv", row.names = FALSE)

###############################################################
# FIN
###############################################################
