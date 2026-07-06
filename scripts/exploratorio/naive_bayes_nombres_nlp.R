###############################################################
# EXPLORATORIO: NAIVE BAYES SOBRE TEXTO DEL NOMBRE (NLP)
#
# Pregunta: ¿predice el texto del nombre de un partido su cluster del
# segundo nivel (partido no institucionalizado / de nicho /
# institucionalizado, script 11)?
#
# Resultado (ver README): NO de forma confiable. Con priors por
# defecto, accuracy (84.1%) queda por debajo del baseline (85.7%,
# clase mayoritaria) y el recall de "Partido institucionalizado" es
# marginal (8%). Con priors uniformes mejora el recall de clases
# minoritarias pero cae la exactitud global (Kappa se mantiene bajo,
# ~0.1-0.12 en ambos casos). Se documenta como hallazgo negativo
# honesto, NO se incluyo en el reporte principal.
#
# Requiere resultados/nivel2_partidos_clusterizados.csv (script 11).
###############################################################

suppressPackageStartupMessages({
  library(tidyverse)
  library(tidytext)
  library(e1071)
  library(caret)
  library(stringi)
})

set.seed(20260706)

###############################################################
# 1. CARGAR
###############################################################

base <- read_csv("resultados/nivel2_partidos_clusterizados.csv", show_col_types = FALSE)
base <- base |> select(nombre, cluster) |> distinct(nombre, .keep_all = TRUE)
cat("Partidos:", nrow(base), "\n")
print(table(base$cluster))

###############################################################
# 2. TOKENIZAR
###############################################################

stopwords_es <- c("de", "del", "la", "el", "los", "las", "y", "en", "para",
                   "por", "con", "a", "al", "un", "una", "o", "e", "que")

base$id <- seq_len(nrow(base))
base$texto <- toupper(base$nombre) |> stri_trans_general("Latin-ASCII") |> tolower()
base$texto <- gsub("[^a-z ]", " ", base$texto)

tokens <- base |>
  select(id, texto) |>
  unnest_tokens(palabra, texto) |>
  filter(!palabra %in% stopwords_es, nchar(palabra) > 1)

###############################################################
# 3. FILTRAR PALABRAS POCO FRECUENTES
###############################################################

frecuencias <- tokens |> count(palabra, sort = TRUE)
palabras_ok <- frecuencias |> filter(n >= 5) |> pull(palabra)
cat("\nVocabulario (palabras con >=5 apariciones):", length(palabras_ok), "\n")

tokens_ok <- tokens |> filter(palabra %in% palabras_ok)

###############################################################
# 4. MATRIZ DOCUMENTO-TERMINO (BINARIA)
###############################################################

dtm <- tokens_ok |>
  distinct(id, palabra) |>
  mutate(presente = 1) |>
  pivot_wider(names_from = palabra, values_from = presente, values_fill = 0)

datos_nb <- base |> select(id, cluster) |> inner_join(dtm, by = "id")
datos_nb$cluster <- factor(datos_nb$cluster)

###############################################################
# 5. TRAIN / TEST (ESTRATIFICADO)
###############################################################

idx <- createDataPartition(datos_nb$cluster, p = 0.75, list = FALSE)
train <- datos_nb[idx, ]
test <- datos_nb[-idx, ]

X_train <- train |> select(-id, -cluster) |> mutate(across(everything(), as.factor))
X_test <- test |> select(-id, -cluster) |> mutate(across(everything(), as.factor))
y_train <- train$cluster
y_test <- test$cluster

###############################################################
# 6. NAIVE BAYES (PRIORS POR DEFECTO)
###############################################################

modelo_nb <- naiveBayes(X_train, y_train, laplace = 1)
pred <- predict(modelo_nb, X_test)
cm <- confusionMatrix(pred, y_test)
print(cm)

cat("\nBaseline (clase mayoritaria):", round(100 * max(prop.table(table(y_test))), 1), "%\n")
cat("Accuracy:", round(100 * cm$overall["Accuracy"], 1), "%  | Kappa:", round(cm$overall["Kappa"], 3), "\n")
print(round(cm$byClass[, c("Precision", "Recall", "F1")], 3))

###############################################################
# 7. PALABRAS MAS DISCRIMINATIVAS PARA "PARTIDO INSTITUCIONALIZADO"
###############################################################

tabla_prob <- modelo_nb$tables
palabras <- names(X_train)
prob_elite <- sapply(palabras, function(p) tabla_prob[[p]]["Partido institucionalizado", "1"])
prob_marginal <- sapply(palabras, function(p) tabla_prob[[p]]["Partido no institucionalizado", "1"])

ratio <- data.frame(palabra = palabras, p_elite = prob_elite, p_marginal = prob_marginal) |>
  mutate(ratio = p_elite / (p_marginal + 0.001)) |>
  arrange(desc(ratio))

cat("\n--- Top 15 palabras mas asociadas a 'Partido institucionalizado' ---\n")
print(head(ratio, 15))

###############################################################
# FIN
###############################################################
