# Perfiles de los partidos políticos colombianos (1848–2022)

Trabajo final del curso **Aprendizaje de Máquinas y Políticas Públicas**
(Bogotá Summer School in Economics 2026, Pontificia Universidad Javeriana).

## Pregunta de investigación

¿Qué perfiles o tipos de partidos y movimientos políticos han existido en
Colombia entre 1848 y 2022, en términos de su alcance electoral y su
carácter ideológico, y qué proporción corresponde a vehículos electorales
marginales frente a maquinarias partidistas consolidadas y multinivel?

Ver el reporte completo en [`reporte/Reporte_Final_Partidos_Politicos.docx`](reporte/Reporte_Final_Partidos_Politicos.docx)
(también disponible en [`reporte/Reporte_Final_Partidos_Politicos.md`](reporte/Reporte_Final_Partidos_Politicos.md)).

## Resumen de hallazgos

- **Nivel 1** (K-Means, k=4, sobre las 5.143 organizaciones registradas,
  participación electoral binaria): solo el **1,8%** (93 partidos) funciona
  como maquinaria electoral multinivel; el resto opera en un solo nivel o
  de forma marginal.
- **Nivel 2** (K-Means, k=3, sobre 2.155 partidos no-coalición, con votos
  reales 1958–2023): el **4,8%** (103 partidos, entre ellos el Liberal, el
  Conservador, Cambio Radical, Polo y Alianza Verde) concentra el grueso
  del respaldo electoral real, corroborando el hallazgo del nivel 1 con
  otra fuente de datos.
- **Descubrimiento de datos**: el 58% de las 5.143 filas de `partidos.xlsx`
  no son partidos, sino coaliciones ad hoc de alcance local.
- **Evidencia temporal**: tras las reformas de 2003 y 2011 (pensadas para
  frenar la proliferación de partidos), el número de organizaciones nuevas
  se disparó y la probabilidad de que un partido nuevo llegue a ser "élite
  nacional" cayó de 14,4% a 1,2%.

## Estructura del repositorio

```
├── data/                    partidos.xlsx + DATA.md (fuentes y datos no incluidos)
├── scripts/                 pipeline de R, en orden de ejecucion (01 a 12)
│   └── exploratorio/        chequeos que NO entraron al reporte final
├── resultados/              CSVs/RDS generados por los scripts
├── figuras/                 graficos (PNG) usados en el reporte
└── reporte/                 reporte final (.docx y .md)
```

## Cómo correr el pipeline

Requiere R (>= 4.x) con los paquetes: `tidyverse`, `readxl`, `janitor`,
`skimr`, `caret`, `cluster`, `factoextra`, `corrplot`, `fpc`, `DescTools`,
`broom`, `scales`, `reshape2`, `ggalluvial`, `data.table`, `haven`,
`stringi`, `kernlab`, `mclust`, `tidytext`, `e1071`.

Ejecutar desde la raíz del repositorio, en orden:

| Script | Qué hace |
|---|---|
| `01_configuracion.R` | Carga paquetes e importa `data/partidos.xlsx` |
| `02_EDA.R` | Análisis exploratorio (missing, distribuciones) |
| `03_Procesamiento.R` | Limpieza, codificación dummy, estandarización |
| `04_1_Seleccion_K.R` | Selección de k (codo, silhouette, Calinski-Harabasz) |
| `04_KMeans.R` | Modelo K-Means final (nivel 1, k=4) |
| `05_PCA.R` | Componentes principales (visualización) |
| `06_Resultados.R` | Caracterización de los 4 clusters |
| `07_Inferencia_Clusters.R` | χ², V de Cramér por variable |
| `08_Cruce_Votos_Electorales.R` | Cruce con votos reales 1958–2023 (requiere datos no incluidos, ver `data/DATA.md`) |
| `09_Segundo_Nivel_Preparacion.R` | Prepara datos del segundo nivel (partidos no-coalición + votos) |
| `10_Segundo_Nivel_Seleccion_K.R` | Selección de k para el segundo nivel |
| `11_Segundo_Nivel_Modelo.R` | Modelo final del segundo nivel (k=3) |
| `12_Analisis_Temporal.R` | Composición de clusters por periodo de reforma |

`scripts/exploratorio/` contiene dos chequeos adicionales que **no** están en
el reporte final: Kernel PCA / Spectral Clustering (robustez del nivel 1) y
un Naive Bayes que intenta predecir el nivel electoral a partir del texto
del nombre del partido (resultado negativo: el nombre no predice el éxito
electoral de forma confiable).

Los scripts `01`–`07` guardan sus resultados en la raíz del proyecto (tal
como en el análisis original); los scripts `08` en adelante guardan en
`resultados/`. Los archivos ya generados están incluidos en `resultados/`
para quien no quiera correr el pipeline completo.

### Nota sobre rutas con tildes

Ver `data/DATA.md` — si el repositorio queda dentro de una ruta con
caracteres acentuados (p. ej. iCloud Drive), `readxl`/`haven` pueden fallar
al leer `.xlsx`/`.dta`. Solución: copiar `data/` a una ruta sin tildes o
clonar el repositorio fuera de esa carpeta.

## Correcciones metodológicas documentadas

Durante la elaboración de este trabajo se detectaron y corrigieron dos
errores en el pipeline original (ver sección 7 del reporte):

1. Codificación dummy asimétrica (`model.matrix(~.-1, ...)` duplicaba el
   peso de la primera variable categórica).
2. Imputación por moda de códigos centinela 98/99 en variables con hasta
   99% de "no aplica/sin clasificar", que fabricaba una variable casi
   constante y distorsionaba el clustering.

## Autor

Curso de Aprendizaje de Máquinas y Políticas Públicas, Bogotá Summer School
in Economics 2026, Pontificia Universidad Javeriana.
