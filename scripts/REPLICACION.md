# Cómo replicar este análisis, paso a paso

Esta guía asume que acabas de clonar el repositorio y no has corrido nada
todavía. Sigue los pasos en orden. Cada paso dice exactamente qué comando
correr, qué script se ejecuta y qué archivo deberías ver al final.

## 0. Prerrequisitos

1. R >= 4.x instalado.
2. Instalar los paquetes (una sola vez):

   ```r
   install.packages(c(
     "tidyverse", "readxl", "janitor", "skimr", "caret", "cluster",
     "factoextra", "corrplot", "fpc", "DescTools", "broom", "scales",
     "reshape2", "ggalluvial", "data.table", "haven", "stringi",
     "kernlab", "mclust", "tidytext", "e1071", "Rtsne", "rpart",
     "randomForest"
   ))
   ```

3. Tu directorio de trabajo en R debe ser la **raíz del repositorio**
   (la carpeta que contiene `scripts/`, `data/`, `resultados/`, `figuras/`),
   no `scripts/`. Verifícalo con `getwd()`.

4. **Si tu ruta contiene tildes o tu clonaste dentro de iCloud Drive**
   (p. ej. macOS con una carpeta como "Sector Público"), `readxl` y `haven`
   pueden fallar al leer `.xlsx`/`.dta`. Solución: clona o copia el
   repositorio a una ruta sin caracteres acentuados. Ver `data/DATA.md`.

## 1. Nivel 1 — universo completo (scripts 01 a 07_1)

### 1.1 Preparación (01-03): correr en una sola sesión de R

`01_configuracion.R`, `02_EDA.R` y `03_Procesamiento.R` comparten el
objeto `partidos` en memoria — son un único script largo dividido en tres
archivos por legibilidad, tal como en el análisis original. **No los
corras como tres llamadas separadas de `Rscript`**; corren con `source()`
en la misma sesión:

```r
source("scripts/01_configuracion.R")
source("scripts/02_EDA.R")
source("scripts/03_Procesamiento.R")
```

Al terminar deberías tener `datos_ml.rds` en la raíz del repositorio
(la matriz dummy estandarizada, lista para K-Means).

### 1.2 Modelo y validación (04 en adelante): cada script es independiente

Desde aquí cada script recarga sus propios insumos desde disco, así que
puedes correrlos con `Rscript` uno por uno:

```bash
Rscript scripts/04_1_Seleccion_K.R      # selección de k (codo/silhouette/CH) -> seleccion_k.csv
Rscript scripts/04_KMeans.R             # modelo final k=4 -> modelo_kmeans.rds, centroides.csv
Rscript scripts/05_PCA.R                # componentes principales -> fig2_pca_clusters.png
Rscript scripts/05_1_TSNE.R             # proyección t-SNE -> fig5_tsne_nivel1.png (requiere Rtsne)
Rscript scripts/06_Resultados.R         # caracterización de los 4 clusters -> partidos_cluster.csv
Rscript scripts/07_Inferencia_Clusters.R  # chi2 / V de Cramér -> Resultados/InferenciaClusters.csv
Rscript scripts/07_1_Ranking_Variables_RF.R  # árbol + Random Forest -> resultados/ranking_variables_comparativo.csv
```

Verificación rápida: `modelo_kmeans.rds` debería dar tamaños de cluster
93 / 2.024 / 1.931 / 1.095 (`table(readRDS("modelo_kmeans.rds")$cluster)`).
Si tu semilla y `nstart=100` están intactos, esto debe coincidir siempre
(ver comentario sobre reproducibilidad más abajo).

## 2. Nivel 2 — solo partidos no-coalición, con votos reales (scripts 08 a 13)

### 2.1 Descargar los datos electorales (no incluidos en el repositorio)

Los resultados electorales históricos de Colombia (1958–2023) pesan
~2.5GB y no se versionan. Descárgalos de:
[DataHub Uniandes — Resultados electorales de Colombia](https://datahub.uniandes.edu.co/dataset.xhtml?persistentId=doi%3A10.71590%2FR2KLKI)
y colócalos según las instrucciones de `data/DATA.md`.

Si no quieres descargar esos datos, puedes saltarte el script `08` y
seguir desde el `09` en adelante: el repositorio ya incluye los
resultados intermedios curados en `resultados/` (`votos_totales_partido_nivel.csv`,
`base_nivel2_partidos_no_coalicion.csv`, `datos_ml2.rds`), así que `09`
en adelante corren igual sin necesidad de los ~130 archivos crudos.

### 2.2 Correr el pipeline del nivel 2

```bash
Rscript scripts/08_Cruce_Votos_Electorales.R      # requiere los datos del paso 2.1
Rscript scripts/08_1_Estadisticas_Descriptivas.R  # tablas descriptivas (secciones 4 y 5.4)
Rscript scripts/09_Segundo_Nivel_Preparacion.R    # -> resultados/datos_ml2.rds
Rscript scripts/10_Segundo_Nivel_Seleccion_K.R    # selección de k -> resultados/seleccion_k_nivel2.csv
Rscript scripts/11_Segundo_Nivel_Modelo.R         # modelo final k=3 -> resultados/nivel2_partidos_clusterizados.csv
Rscript scripts/12_Analisis_Temporal.R            # composición de clusters por periodo de reforma
Rscript scripts/13_Longevidad_Institucionalizacion.R  # longevidad organizativa por cluster
```

Verificación rápida: `resultados/nivel2_partidos_clusterizados.csv`
debería tener 3 clusters con tamaños 1.854 ("Partido no institucionalizado"),
198 ("Partido de nicho") y 103 ("Partido institucionalizado").

## 3. Chequeos de robustez (opcional, no entran al reporte final)

```bash
Rscript scripts/exploratorio/kernel_pca_spectral_clustering.R  # requiere resultados/datos_ml.rds y modelo_kmeans.rds
Rscript scripts/exploratorio/naive_bayes_nombres_nlp.R         # requiere resultados/nivel2_partidos_clusterizados.csv
```

Ambos son autocontenidos (recargan sus insumos desde disco) y no afectan
ningún resultado del reporte principal si no se corren.

## 4. Sobre la reproducibilidad exacta

Todos los `set.seed()` usan **20260706**. Con K-Means y `nstart=100`, la
partición converge a la misma solución sustantiva sin importar pequeños
cambios de versión de R o de paquetes — lo único que puede cambiar es
qué número de cluster (1, 2, 3...) le toca a cada grupo, no su
composición. Por eso los scripts de nivel 2 (`11_Segundo_Nivel_Modelo.R`)
asignan las etiquetas por **tamaño del cluster**, no por su ID arbitrario:
si tu corrida da IDs distintos a los que aparecen en este documento, es
esperable y no indica un error.

## 5. Dónde quedan los resultados

- Scripts `01`–`07` guardan en la **raíz del repositorio** (tal como en
  el análisis original): `datos_ml.rds`, `modelo_kmeans.rds`,
  `centroides.csv`, `Resultados/` (con mayúscula), etc.
- Scripts `07_1` y `08` en adelante guardan directamente en `resultados/`
  (minúscula), ya organizado.
- Las figuras (`.png`) se guardan en `figuras/`.

Si algo no coincide con lo descrito aquí, compara primero con
`README.md` (sección "Cómo correr el pipeline") y con `data/DATA.md`
(para el problema de rutas con tildes).
