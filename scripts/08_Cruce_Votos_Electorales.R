###############################################################
# SCRIPT 8
# CRUCE CON RESULTADOS ELECTORALES REALES (1958-2023)
#
# Requiere los archivos electorales historicos (.tab/.dta) en
# data/, descargados por separado (ver data/DATA.md, no se
# incluyen en el repositorio por su tamano).
#
# Ejecutar con el working directory en la raiz del repositorio.
###############################################################

suppressPackageStartupMessages({
  library(data.table)
  library(readxl)
  library(janitor)
  library(haven)
  library(stringi)
})

###############################################################
# 1. NORMALIZACION DE NOMBRES
###############################################################

FILLER <- c("PARTIDO", "MOVIMIENTO", "COLOMBIANO", "COLOMBIANA", "POLITICO", "POLITICA", "NACIONAL")

normalizar <- function(x) {
  x <- toupper(trimws(x))
  x <- stri_trans_general(x, "Latin-ASCII")       # quita tildes/enies raras
  x <- gsub("[^A-Z0-9 ]", " ", x)                  # quita puntuacion
  palabras <- strsplit(x, "\\s+")
  palabras <- lapply(palabras, function(w) w[!(w %in% FILLER) & w != ""])
  vapply(palabras, function(w) paste(w, collapse = " "), character(1))
}

###############################################################
# 2. DICCIONARIO DE PARTIDOS NO-COALICION (partidos.xlsx)
###############################################################

partidos <- read_excel("data/partidos.xlsx") |> clean_names()
partidos$nombre_norm <- normalizar(partidos$nombre)
no_coalicion <- !grepl("^COALICION", toupper(trimws(partidos$nombre)))
dic <- unique(partidos[no_coalicion & partidos$nombre_norm != "", c("nombre", "nombre_norm")])
dic <- dic[!duplicated(dic$nombre_norm), ]  # colisiones -> se queda el primero
cat("Diccionario de partidos no-coalicion:", nrow(dic), "entradas unicas normalizadas\n")

###############################################################
# 3. LISTAR ARCHIVOS ELECTORALES (.tab / .dta)
###############################################################

archivos_tab <- list.files("data", pattern = "\\.tab$", full.names = TRUE)
archivos_dta <- list.files("data", pattern = "^[0-9]{4}_.*\\.dta$", full.names = TRUE)
cat("Archivos .tab:", length(archivos_tab), " | Archivos .dta:", length(archivos_dta), "\n")

###############################################################
# 4. FUNCION DE LECTURA Y AGREGACION POR ARCHIVO
###############################################################

leer_agg <- function(path) {
  ext <- tools::file_ext(path)
  if (ext == "tab") {
    dt <- tryCatch(
      fread(path, select = c("ano", "tipo_eleccion", "codigo_partido", "votos"), quote = "\"", encoding = "UTF-8",
            colClasses = list(character = c("ano", "tipo_eleccion", "codigo_partido"), numeric = "votos")),
      error = function(e) NULL
    )
  } else {
    d <- read_dta(path)
    d <- clean_names(d)
    cols <- intersect(c("ano", "tipo_eleccion", "codigo_partido", "votos"), names(d))
    d <- d[cols]
    for (cn in c("tipo_eleccion", "codigo_partido")) {
      if (cn %in% names(d)) d[[cn]] <- as.character(haven::as_factor(d[[cn]]))
    }
    if ("ano" %in% names(d)) d[["ano"]] <- as.character(d[["ano"]])
    if ("votos" %in% names(d)) d[["votos"]] <- as.numeric(d[["votos"]])
    dt <- as.data.table(d)
  }
  if (is.null(dt) || nrow(dt) == 0) return(NULL)
  dt <- dt[!is.na(codigo_partido) & trimws(codigo_partido) != ""]
  dt <- dt[!grepl("COALICION", codigo_partido, ignore.case = TRUE)]
  if (nrow(dt) == 0) return(NULL)
  dt[, votos := as.numeric(votos)]
  dt[is.na(votos), votos := 0]
  dt[, archivo := basename(path)]
  dt
}

###############################################################
# 5. PROCESAR TODOS LOS ARCHIVOS
###############################################################

todos <- c(archivos_tab, archivos_dta)
resultados <- vector("list", length(todos))
errores <- character(0)

for (i in seq_along(todos)) {
  f <- todos[i]
  res <- tryCatch(leer_agg(f), error = function(e) { errores <<- c(errores, paste(basename(f), ":", conditionMessage(e))); NULL })
  resultados[[i]] <- res
  if (i %% 20 == 0) cat("Procesados", i, "/", length(todos), "\n")
}

cat("\nArchivos con error:", length(errores), "\n")
if (length(errores) > 0) print(errores)

datos <- rbindlist(resultados, use.names = TRUE, fill = TRUE)
cat("\nTotal filas apiladas (sin coaliciones, sin blancos/nulos):", nrow(datos), "\n")

datos[, codigo_partido_norm := normalizar(codigo_partido)]

###############################################################
# 6. MATCH CONTRA EL DICCIONARIO
###############################################################

setDT(dic)
datos <- merge(datos, dic, by.x = "codigo_partido_norm", by.y = "nombre_norm", all.x = TRUE)

cobertura_votos <- datos[, .(votos_total = sum(votos)), by = .(matched = !is.na(nombre))]
cat("\n--- Cobertura de votos totales (todas las elecciones, 1958-2023) ---\n")
print(cobertura_votos)
cat(sprintf("%% de votos con match: %.1f%%\n",
            100 * cobertura_votos[matched == TRUE, votos_total] / sum(cobertura_votos$votos_total)))

###############################################################
# 7. TOP SIN MATCH (TRANSPARENCIA)
###############################################################

top_no_match <- datos[is.na(nombre), .(votos = sum(votos)), by = codigo_partido][order(-votos)][1:20]
cat("\n--- Top 20 SIN match por votos totales ---\n")
print(top_no_match)

###############################################################
# 8. AGREGACION FINAL: PARTIDO x NIVEL
###############################################################

final <- datos[!is.na(nombre), .(votos_totales = sum(votos), n_registros = .N), by = .(nombre, tipo_eleccion)]
setorder(final, nombre, -votos_totales)

fwrite(final, "resultados/votos_totales_partido_nivel.csv")
cat("\nGuardado resultados/votos_totales_partido_nivel.csv con", nrow(final), "filas (partido x tipo_eleccion)\n")
cat("Partidos distintos con al menos un match:", uniqueN(final$nombre), "de", nrow(dic), "en el diccionario no-coalicion\n")

###############################################################
# FIN
###############################################################
