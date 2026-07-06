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

## NO incluidos (por tamaño): resultados electorales 1958–2023

Los scripts `08_Cruce_Votos_Electorales.R` en adelante requieren los resultados
electorales históricos de Colombia (Registraduría Nacional / CEDE) para:

- Alcaldía, Asamblea Departamental, Concejo Municipal, Gobernación (elecciones territoriales)
- Cámara de Representantes, Senado (elecciones legislativas)
- Presidencia (primera y segunda vuelta)

para el periodo 1958–2023 (~130 archivos `.tab`/`.dta`, candidato-municipio-elección,
~2,5 GB en total). No se incluyen en este repositorio por su tamaño.

**Para reproducir el análisis de las secciones 5.4, 6.3 y los scripts 08–12:**

1. Descargue los archivos electorales por año y tipo de elección de la fuente
   CEDE/Registraduría Nacional (mismo origen que `partidos.xlsx`).
2. Colóquelos en esta carpeta (`data/`) con el patrón de nombre
   `AAAA_tipo_de_eleccion.tab` (o `.dta` para alcaldías), por ejemplo:
   `2022_senado.tab`, `2019_alcaldia.dta`, `2018_camara.tab`.
3. Cada archivo debe tener, como mínimo, las columnas `ano`, `tipo_eleccion`,
   `codigo_partido` (nombre del partido, no un código numérico) y `votos`.

## Nota sobre rutas con tildes (macOS / iCloud Drive)

Si este repositorio se clona o se mantiene dentro de una ruta con caracteres
acentuados (p. ej. una carpeta de iCloud Drive como "AM Sector Público"), los
paquetes `readxl` (para `.xlsx`) y `haven` (para `.dta`) pueden fallar con un
error de tipo "cannot be opened" o "does not exist" por un problema de
normalización Unicode (NFD vs. NFC) específico de macOS. Si esto ocurre,
copie la carpeta `data/` a una ruta sin tildes/caracteres especiales (p. ej.
`/tmp/proyecto/data`) antes de correr los scripts, o clone el repositorio
fuera de iCloud Drive.
