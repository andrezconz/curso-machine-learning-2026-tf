# Datos

## Incluidos en este repositorio

- **`partidos.xlsx`** — Clasificación de partidos y movimientos políticos colombianos.
  Fuente: Cabra-Ruíz, Torres, Wills-Otero & Castilla-Gutiérrez (2023), "Una
  caracterización histórica de los partidos políticos de Colombia: 1958–2022"
  (Documento CEDE-Datos, Universidad de los Andes). 5.143 filas, 27 variables
  (25 documentadas en el diccionario oficial + 2 adicionales de primera/segunda
  vuelta presidencial). Unidad de observación: partido/movimiento/coalición
  (incluye ~2.988 filas con coalicion=1, la mayoría alianzas de alcance
  municipal/departamental, ver sección 4.2 y 5.4 del reporte).
- **`Diccionario_Partidos_Politicos_Colombia.pdf`** — Diccionario oficial de
  variables de la base anterior (Cabra-Ruíz et al., 2023, v1.0, noviembre de
  2023): describe las 25 variables documentadas, sus categorías exactas y las
  fuentes usadas para construirlas.
- **`clasificacion_partidos_v1.txt`** — Misma base en formato texto delimitado por
  tabulaciones (usada solo como referencia; los scripts leen `partidos.xlsx`).
- **`base_nivel2_no_coalicion.csv`** — Los 2.155 partidos no-coalición del
  segundo nivel de análisis (sección 5.4 del reporte), ya con los votos
  electorales por nivel (1958–2023) unidos a las variables categóricas de
  `partidos.xlsx`. Es exactamente el `data.frame` que produce
  `scripts/09_Segundo_Nivel_Preparacion.R` (35 variables, sin la
  codificación dummy todavía), copiado aquí para que se pueda continuar
  el análisis del nivel 2 (selección de k, modelo K-Means) sin tener que
  descargar y procesar primero los ~130 archivos electorales crudos
  (ver sección siguiente). Se regenera exactamente igual corriendo
  `08_Cruce_Votos_Electorales.R` y `09_Segundo_Nivel_Preparacion.R` con
  los datos electorales completos.

## NO incluidos (por tamaño): resultados electorales 1958–2023

Los scripts `08_Cruce_Votos_Electorales.R` en adelante requieren los resultados
electorales históricos de Colombia (Torres, Barinas-Forero, Forero-Mesa,
Sánchez & Tibavisco, 2023), ~130 archivos `.tab`/`.dta`, ~2,5 GB en total.
No se incluyen en este repositorio por su tamaño, pero **tampoco hacen
falta** para reproducir el análisis: `base_nivel2_no_coalicion.csv`
(arriba) ya trae los votos unidos, así que los scripts `09` en adelante
y el notebook `Analisis_Reproducible.Rmd` corren sin ellos.

Si igual quieres descargarlos y reconstruir el cruce desde cero (por
ejemplo, para auditar el script `08`), ver la guía completa:
[`DESCARGAR_DATOS_ELECTORALES.md`](DESCARGAR_DATOS_ELECTORALES.md).

## Nota sobre rutas con tildes (macOS / iCloud Drive)

Si este repositorio se clona o se mantiene dentro de una ruta con caracteres
acentuados (p. ej. una carpeta de iCloud Drive como "AM Sector Público"), los
paquetes `readxl` (para `.xlsx`) y `haven` (para `.dta`) pueden fallar con un
error de tipo "cannot be opened" o "does not exist" por un problema de
normalización Unicode (NFD vs. NFC) específico de macOS. Si esto ocurre,
copie la carpeta `data/` a una ruta sin tildes/caracteres especiales (p. ej.
`/tmp/proyecto/data`) antes de correr los scripts, o clone el repositorio
fuera de iCloud Drive.
