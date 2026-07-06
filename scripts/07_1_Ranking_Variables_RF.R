###############################################################
# SCRIPT 7.1
# RANKING DE VARIABLES: INDEPENDENCIA UNIVARIADA VS. IMPORTANCIA
# MULTIVARIADA (ARBOL DE DECISION Y RANDOM FOREST)
#
# PROPOSITO METODOLOGICO
# El script 7 evalua cada variable por separado frente al cluster
# (chi2 / V de Cramer): una prueba univariada, una variable a la
# vez. Ese enfoque no escala bien si el numero de variables
# candidatas crece, y no controla por la correlacion entre ellas
# (dos variables redundantes pueden aparecer ambas como "fuertes"
# aunque aporten la misma senal). Este script complementa esa
# prueba con dos modelos multivariados que usan las 12 variables
# a la vez para predecir el cluster: un arbol de decision unico
# (referencia interpretable) y un Random Forest (referencia mas
# estable, promedia cientos de arboles). La importancia de
# variables de estos modelos (MeanDecreaseGini) responde una
# pregunta distinta a la V de Cramer: no "que tan asociada esta
# esta variable sola", sino "cuanto aporta esta variable una vez
# que las demas ya estan en el modelo". Que ambos enfoques
# coincidan en las variables principales (parte 3 del script)
# es una validacion cruzada adicional de que los clusters son
# sustantivamente reales, no un artefacto de una sola prueba
# estadistica. Ver seccion 5.3 del reporte.
#
# Requiere data/partidos.xlsx, modelo_kmeans.rds (script 4, raiz del
# proyecto) y Resultados/InferenciaClusters.csv (script 7, tambien
# en la raiz). Guarda sus propios resultados en resultados/, ya
# curado (ver README).
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(janitor)
  library(caret)
  library(rpart)
  library(randomForest)
})

###############################################################
# 1. CARGAR DATOS Y MODELO
###############################################################

partidos <- read_excel("data/partidos.xlsx") |> clean_names()
modelo_kmeans <- readRDS("modelo_kmeans.rds")
partidos$cluster <- factor(modelo_kmeans$cluster)

variables <- c(
  "tradicional", "gradonac", "ideologia", "grupo_representativo_1",
  "grupo_representativo_2", "part_alcaldia", "part_asamblea",
  "part_camara", "part_concejo", "part_gobernacion",
  "part_presidencia", "part_senado"
)

datos_rf <- partidos[, c(variables, "cluster")]
for (v in variables) datos_rf[[v]] <- as.factor(datos_rf[[v]])

cat("Distribucion de clusters (n=5,143):\n")
print(table(datos_rf$cluster))

###############################################################
# 2. PARTICION TRAIN/TEST (ESTRATIFICADA)
###############################################################

set.seed(20260706)
idx <- createDataPartition(datos_rf$cluster, p = 0.75, list = FALSE)
train <- datos_rf[idx, ]
test <- datos_rf[-idx, ]

###############################################################
# 3. ARBOL DE DECISION UNICO (REFERENCIA INTERPRETABLE)
###############################################################

set.seed(20260706)
arbol <- rpart(cluster ~ ., data = train, method = "class")
pred_arbol <- predict(arbol, test, type = "class")
cm_arbol <- confusionMatrix(pred_arbol, test$cluster)

cat("\n========================================\n")
cat("ARBOL DE DECISION (rpart)\n")
cat("Accuracy:", round(100 * cm_arbol$overall["Accuracy"], 1), "%\n")
cat("========================================\n")
print(round(cm_arbol$byClass[, c("Precision", "Recall", "F1")], 3))

imp_arbol <- arbol$variable.importance
imp_arbol_df <- data.frame(
  variable = names(imp_arbol),
  importancia_arbol = round(100 * imp_arbol / sum(imp_arbol), 1)
)

###############################################################
# 4. RANDOM FOREST (500 ARBOLES)
###############################################################

set.seed(20260706)
rf <- randomForest(cluster ~ ., data = train, ntree = 500, importance = TRUE)
pred_rf <- predict(rf, test)
cm_rf <- confusionMatrix(pred_rf, test$cluster)

cat("\n========================================\n")
cat("RANDOM FOREST (500 arboles)\n")
cat("Accuracy:", round(100 * cm_rf$overall["Accuracy"], 1),
    "%  | OOB error:", round(rf$err.rate[500, 1] * 100, 1), "%\n")
cat("========================================\n")
print(round(cm_rf$byClass[, c("Precision", "Recall", "F1")], 3))

imp_rf <- importance(rf)
imp_rf_df <- data.frame(
  variable = rownames(imp_rf),
  MeanDecreaseAccuracy = round(imp_rf[, "MeanDecreaseAccuracy"], 1),
  importancia_rf = round(100 * imp_rf[, "MeanDecreaseGini"] / sum(imp_rf[, "MeanDecreaseGini"]), 1)
)

###############################################################
# 5. TABLA COMPARATIVA: V DE CRAMER VS ARBOL VS RANDOM FOREST
###############################################################

# El script 7 guarda en "Resultados/" (raiz) al correrlo desde cero;
# el repositorio conserva ademas una copia curada en "resultados/"
# (ver README). Se usa la que exista, priorizando el output fresco.
ruta_cramer <- if (file.exists("Resultados/InferenciaClusters.csv")) {
  "Resultados/InferenciaClusters.csv"
} else {
  "resultados/inferencia_clusters/InferenciaClusters.csv"
}
cramer_v <- read.csv(ruta_cramer) |>
  select(variable = Variable, cramer_v = CramerV)

comparativo <- cramer_v |>
  left_join(imp_arbol_df, by = "variable") |>
  left_join(imp_rf_df, by = "variable") |>
  mutate(
    rank_cramer = rank(-cramer_v),
    rank_arbol = rank(-replace_na(importancia_arbol, 0)),
    rank_rf = rank(-importancia_rf)
  ) |>
  arrange(rank_rf)

cat("\n========================================\n")
cat("COMPARATIVO DE RANKINGS: UNIVARIADO VS MULTIVARIADO\n")
cat("========================================\n")
print(comparativo)

cat("\nCorrelacion de rangos (Spearman):\n")
cat("  Cramer vs Arbol:", round(cor(comparativo$rank_cramer, comparativo$rank_arbol, method = "spearman"), 3), "\n")
cat("  Cramer vs RF:   ", round(cor(comparativo$rank_cramer, comparativo$rank_rf, method = "spearman"), 3), "\n")
cat("  Arbol vs RF:    ", round(cor(comparativo$rank_arbol, comparativo$rank_rf, method = "spearman"), 3), "\n")

write.csv(comparativo, "resultados/ranking_variables_comparativo.csv", row.names = FALSE)
write.csv(as.data.frame(cm_rf$byClass), "resultados/rf_metricas_por_cluster.csv")

###############################################################
# FIN
###############################################################
