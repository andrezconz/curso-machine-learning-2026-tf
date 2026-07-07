###############################################################
# SCRIPT 9
# SEGUNDO NIVEL: PREPARACION DE DATOS CON VOTOS REALES
#
# Requiere haber corrido 08_Cruce_Votos_Electorales.R antes
# (usa resultados/votos_totales_partido_nivel.csv) -- SALVO que
# exista data/base_nivel2_no_coalicion.csv, en cuyo caso se usa
# directamente esa base ya construida (los mismos 2.155 partidos
# no-coalicion con los votos ya unidos) y se saltan los pasos 1-2,
# evitando tener que descargar los ~130 archivos electorales crudos
# solo para continuar desde aqui (ver data/DATA.md).
#
# Ejecutar con el working directory en la raiz del repositorio.
###############################################################

suppressPackageStartupMessages({
  library(data.table)
  library(tidyverse)
  library(readxl)
  library(janitor)
  library(stringi)
})

RUTA_BASE_PRECALCULADA <- "data/base_nivel2_no_coalicion.csv"

if (file.exists(RUTA_BASE_PRECALCULADA)) {

  cat("Usando", RUTA_BASE_PRECALCULADA, "(se saltan los pasos 1-2: no hace falta",
      "resultados/votos_totales_partido_nivel.csv ni los archivos electorales crudos)\n")

  base <- fread(RUTA_BASE_PRECALCULADA)
  niveles_votos <- grep("^votos_", names(base), value = TRUE)
  cat("Partidos no-coalicion:", nrow(base), "\n")
  cat("Partidos con al menos un voto registrado:", sum(rowSums(base[, ..niveles_votos]) > 0), "de", nrow(base), "\n")

} else {

  ###############################################################
  # 1. CONSOLIDAR NIVELES ELECTORALES (arregla variantes de codificacion)
  ###############################################################

  votos <- fread("resultados/votos_totales_partido_nivel.csv")

  canon <- function(x) {
    x <- toupper(stri_trans_general(x, "Latin-ASCII"))
    x <- gsub("[^A-Z]", "", x)
    case_when(
      grepl("CONCEJO", x) ~ "concejo",
      grepl("ASAMBLEA", x) ~ "asamblea",
      grepl("SENADO", x) ~ "senado",
      grepl("ALCALD", x) ~ "alcaldia",
      grepl("CAMARA|CMARA|C.MARA", x) ~ "camara",
      grepl("GOBERNAC", x) ~ "gobernacion",
      grepl("PRESIDENCIA", x) ~ "presidencia",
      TRUE ~ "otro"
    )
  }
  votos[, nivel := canon(tipo_eleccion)]
  votos_agg <- votos[, .(votos_totales = sum(votos_totales)), by = .(nombre, nivel)]

  votos_wide <- dcast(votos_agg, nombre ~ nivel, value.var = "votos_totales", fill = 0)
  setnames(votos_wide, setdiff(names(votos_wide), "nombre"), paste0("votos_", setdiff(names(votos_wide), "nombre")))
  cat("Dimensiones votos_wide:", dim(votos_wide), "\n")
  print(names(votos_wide))

  ###############################################################
  # 2. BASE DE PARTIDOS NO-COALICION
  ###############################################################

  partidos <- read_excel("data/partidos.xlsx") |> clean_names()
  partidos$nombre_upper <- toupper(trimws(partidos$nombre))
  no_coalicion <- !grepl("^COALICION", partidos$nombre_upper)
  base <- partidos[no_coalicion, ]
  cat("\nPartidos no-coalicion:", nrow(base), "\n")

  base <- merge(as.data.table(base), votos_wide, by = "nombre", all.x = TRUE)
  niveles_votos <- grep("^votos_", names(base), value = TRUE)
  for (v in niveles_votos) base[[v]][is.na(base[[v]])] <- 0

  cat("Partidos con al menos un voto registrado:", sum(rowSums(base[, ..niveles_votos]) > 0), "de", nrow(base), "\n")

}

###############################################################
# 3. VARIABLES PARA EL MODELO
###############################################################

cat_vars <- c("tradicional", "gradonac", "ideologia", "grupo_representativo_1", "grupo_representativo_2")
modelo_df <- base[, c("codigo_partido", "nombre", cat_vars, niveles_votos), with = FALSE]

# log1p de votos (fuertemente sesgados a la derecha)
for (v in niveles_votos) modelo_df[[paste0("log_", v)]] <- log1p(modelo_df[[v]])

# factores para las categoricas (98/99 quedan como categoria propia, igual que en el nivel 1)
for (v in cat_vars) modelo_df[[v]] <- as.factor(modelo_df[[v]])

# dummies consistentes: matriz de diseno CON intercepto, se elimina despues
# (evita el error de codificacion asimetrica corregido en el script 3)
form_vars <- cat_vars
X_cat <- model.matrix(as.formula(paste("~", paste(form_vars, collapse = "+"))), data = modelo_df)
X_cat <- X_cat[, colnames(X_cat) != "(Intercept)"]

X_num <- as.matrix(modelo_df[, paste0("log_", niveles_votos), with = FALSE])

X <- cbind(X_cat, X_num)
constantes <- apply(X, 2, function(x) length(unique(x)) == 1)
X <- X[, !constantes]

datos_ml2 <- scale(X)
cat("\nDimensiones datos_ml2 (nivel 2):", dim(datos_ml2), "\n")
print(colnames(datos_ml2))

###############################################################
# 4. GUARDAR
###############################################################

saveRDS(datos_ml2, "resultados/datos_ml2.rds")
saveRDS(modelo_df, "resultados/modelo_df2.rds")
fwrite(base, "resultados/base_nivel2_partidos_no_coalicion.csv")

###############################################################
# FIN
###############################################################
