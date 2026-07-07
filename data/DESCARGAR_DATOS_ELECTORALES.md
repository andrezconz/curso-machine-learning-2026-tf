# Cómo descargar y ubicar los datos electorales crudos (opcional)

Esta guía es solo para quien quiera **reconstruir desde cero** el cruce
de partidos.xlsx con los resultados electorales reales (script `08` y
en adelante). **No es necesaria** para reproducir el resto del análisis:
el repositorio ya incluye `data/base_nivel2_no_coalicion.csv` (los 2.155
partidos no-coalición con los votos ya unidos) y los resultados
intermedios en `resultados/`, así que los scripts `09` a `13` y el
notebook `Analisis_Reproducible.Rmd` corren igual sin descargar nada más.

Sáltate esta guía a menos que quieras auditar o repetir el paso del
cruce de nombres en sí mismo (script `08_Cruce_Votos_Electorales.R`).

## Qué son estos datos

Resultados electorales históricos de Colombia (Torres, Barinas-Forero,
Forero-Mesa, Sánchez & Tibavisco, 2023, "Resultados electorales de
Colombia", Documento CEDE-Datos), a nivel de candidato-municipio-elección,
para:

- Alcaldía, Asamblea Departamental, Concejo Municipal, Gobernación (elecciones territoriales)
- Cámara de Representantes, Senado (elecciones legislativas)
- Presidencia (primera y segunda vuelta)

para el periodo 1958–2023: ~130 archivos `.tab`/`.dta`, ~2,5 GB en
total. No se incluyen en este repositorio por su tamaño.

## Dónde descargarlos

**Descarga oficial:** [DataHub Uniandes — Resultados electorales de Colombia](https://datahub.uniandes.edu.co/dataset.xhtml?persistentId=doi%3A10.71590%2FR2KLKI)
(DOI: 10.71590/R2KLKI).

## Cómo ubicarlos para que los scripts los encuentren

1. Descargue los archivos electorales por año y tipo de elección del
   DataHub enlazado arriba.
2. Colóquelos en `data/` (la misma carpeta de este documento) con el
   patrón de nombre `AAAA_tipo_de_eleccion.tab` (o `.dta` para
   alcaldías), por ejemplo: `2022_senado.tab`, `2019_alcaldia.dta`,
   `2018_camara.tab`.
3. Cada archivo debe tener, como mínimo, las columnas `ano`,
   `tipo_eleccion`, `codigo_partido` (nombre del partido, no un código
   numérico) y `votos`.
4. Corra `Rscript scripts/08_Cruce_Votos_Electorales.R` desde la raíz
   del repositorio. Esto regenera `resultados/votos_totales_partido_nivel.csv`
   y, si sigue con `09_Segundo_Nivel_Preparacion.R`, un
   `data/base_nivel2_no_coalicion.csv` idéntico al que ya está en el
   repositorio (mismo cruce, misma semilla, mismos datos fuente).

## Nota sobre rutas con tildes (macOS / iCloud Drive)

Si este repositorio se clona o se mantiene dentro de una ruta con
caracteres acentuados (p. ej. una carpeta de iCloud Drive como "AM
Sector Público"), los paquetes `readxl` (para `.xlsx`) y `haven` (para
`.dta`) pueden fallar con un error de tipo "cannot be opened" o "does
not exist" por un problema de normalización Unicode (NFD vs. NFC)
específico de macOS. Si esto ocurre, copie la carpeta `data/` a una
ruta sin tildes/caracteres especiales (p. ej. `/tmp/proyecto/data`)
antes de correr los scripts, o clone el repositorio fuera de iCloud
Drive.
