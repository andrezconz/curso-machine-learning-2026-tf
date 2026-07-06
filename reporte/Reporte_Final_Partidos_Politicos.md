# Más allá de la ideología

### Tipologías empíricas de los partidos y movimientos políticos colombianos (1848–2023)

**Aprendizaje de Máquinas y Políticas Públicas**
Bogotá Summer School in Economics 2026 — Pontificia Universidad Javeriana
Reporte de política · 6 de julio de 2026
**Autor: Andrez Felipe Guerrero Torres**
**Data:** Cabra-Ruíz, Torres, Wills-Otero & Castilla-Gutiérrez (2023); Torres, Barinas-Forero, Forero-Mesa, Sánchez & Tibavisco (2023). Centro de Estudios sobre Desarrollo Económico (CEDE), Universidad de los Andes.
*Desarrollado con el apoyo de Claude (Claude Code, Anthropic) como asistente de análisis y redacción.*

> Nota: las tablas de apoyo se presentan en la sección **Anexos**, al final de este documento, para mantener el cuerpo del reporte dentro de las 12 páginas acordadas.

---

## Resumen de los datos y su preparación

Este reporte combina dos fuentes de datos (*data*) del CEDE, Universidad de los Andes. La primera —Cabra-Ruíz, Torres, Wills-Otero & Castilla-Gutiérrez (2023)— clasifica 5.143 partidos, movimientos y coaliciones políticas colombianas con variables de ideología, tradicionalidad, nacionalización, grupo representativo y participación electoral binaria en siete tipos de elección. Al revisarla se descubrió que el 58% de las filas (2.988) corresponden a coaliciones (variable `coalicion=1`), la mayoría de alcance local, aunque muchas son alianzas Liberal-Conservador para una sola alcaldía y no vehículos marginales.

La segunda fuente —Torres, Barinas-Forero, Forero-Mesa, Sánchez & Tibavisco (2023)— son los resultados electorales históricos de Colombia (1958–2023), a nivel de candidato-municipio-elección. Se cruzaron por nombre con la primera base (excluyendo coaliciones y normalizando texto) logrando emparejar el 80,6% de los votos históricos no-coalición.

La preparación incluyó: limpieza de nombres; imputación cuidadosa de valores faltantes sin fabricar señal falsa en variables con códigos centinela 98/99; codificación dummy consistente (corrigiendo un error de codificación asimétrica, ver sección 7); estandarización de todas las variables; y, para el análisis con votos, una transformación log(1+votos) dado su fuerte sesgo a la derecha. El detalle se documenta en las secciones 4 y 5, y las tablas descriptivas completas en los **Anexos**.

Con estos insumos se construyeron dos niveles de análisis: (1) K-Means sobre el universo completo de 5.143 organizaciones con participación binaria (secciones 4–6), y (2) un segundo modelo, restringido a los 2.155 partidos no-coalición y enriquecido con votos reales por nivel electoral (sección 5.4), que sirve como validación cruzada del primero con otra fuente de datos.

## 1. Pregunta de investigación

¿Qué tipologías empíricas de partidos políticos colombianos emergen del análisis conjunto de sus características organizativas, electorales e ideológicas, y qué revelan sobre la estructura del sistema de partidos?

Es una pregunta descriptiva/exploratoria: no busca predecir una etiqueta ya conocida, sino descubrir agrupamientos latentes a partir de los atributos disponibles. El protocolo del curso admite explícitamente preguntas de este tipo ("¿qué grupos o patrones existen?"), y la ausencia de una variable de resultado observada hace que el aprendizaje no supervisado sea la estrategia natural.

## 2. Motivación

La ideología no es el eje que organiza al sistema de partidos colombiano: los datos lo desmienten. La forma más habitual de describir a un partido es por su etiqueta ideológica, pero cerca del 40% de los partidos no tiene ideología clasificable, y —de forma casi paradójica (sección 5.4)— los partidos electoralmente más exitosos son también los que con mayor frecuencia carecen de ella. Un marco que se apoye en la ideología está, entonces, construido sobre datos faltantes en la mitad de los casos que más importan.

La literatura sobre sistemas de partidos ofrece dimensiones más robustas y observables. Panebianco (1988) y Mainwaring y Scully (1995) definen la institucionalización partidista como la capacidad de sobrevivir y reproducirse en el tiempo más allá de sus fundadores, aproximable con la longevidad organizativa. Jones y Mainwaring (2003) proponen la nacionalización electoral —competencia sostenida en múltiples niveles— como complemento natural. Meguid (2005) caracteriza a los partidos de nicho como aquellos que compiten sobre una dimensión estrecha y no económica (étnica, religiosa, sectorial). Estas tres nociones —institucionalización, nacionalización y nicho— se usan aquí para nombrar e interpretar los perfiles encontrados. Esta elección no es solo una lectura externa: los propios autores de la base (Cabra-Ruíz et al., 2023) clasifican a los partidos colombianos en cinco dimensiones —ideología, grupos identitarios, tradicionalidad, nacionalización y longevidad—, es decir, la longevidad ya es, por diseño, una de las dimensiones centrales de esta base.

Esta relectura no es solo académica: el debate sobre la proliferación de partidos —"partidos de garaje" o "microempresas electorales"— ha sido central en las reformas al régimen de partidos (Acto Legislativo 01 de 2003, Ley 1475 de 2011, y las discusiones de 2023–2025). La preocupación de fondo es que muchas organizaciones obtienen o mantienen personería jurídica sin construir una organización duradera, lo que fragmenta la representación y encarece la administración electoral. Si la ideología no distingue bien a estos partidos, la institucionalización y la nacionalización sí podrían hacerlo, de forma más directamente accionable para el diseño de reglas.

Este reporte busca cuantificar sistemáticamente, sobre el universo completo de partidos alguna vez registrados, cuántos son organizaciones institucionalizadas y nacionalizadas y cuántos son vehículos efímeros. El hallazgo central —que menos del 2% está institucionalizado y nacionalizado— aporta evidencia directa al diseño de umbrales de personería jurídica, reglas de coalición y fórmulas de financiación estatal.

## 3. Estrategia empírica

Dado que la pregunta es descriptiva y no existe una variable de "tipo de partido" previamente etiquetada, se descartó cualquier método supervisado (regresión logística, árboles, kNN, SVM): la tipología es precisamente lo que se busca descubrir. Se optó por K-Means por tres razones:

- **Escala**: con 5.143 observaciones, el clustering jerárquico (matriz de distancias n×n, dendrograma inmanejable) es poco práctico frente a K-Means, cuyo costo crece linealmente con n.
- **Naturaleza de los datos**: tras codificar dummies y estandarizar, K-Means con distancia euclidiana es simple, interpretable y eficiente para una primera aproximación exploratoria.
- **Validez interna verificable**: a diferencia de DBSCAN (sensible a la densidad, poco adecuado para datos dummy dispersos) o mezclas gaussianas (asumen covarianza continua poco natural para binarias), K-Means admite criterios estándar (codo, silhouette, Calinski-Harabasz) para justificar objetivamente k.

El PCA se usó únicamente como herramienta de visualización e interpretación de cargas, no como reducción de dimensionalidad previa al clustering (K-Means corrió sobre las variables dummy estandarizadas). Los grupos se validaron con pruebas χ² de independencia frente a cada variable original, con la V de Cramér como tamaño de efecto y corrección de Benjamini-Hochberg para el múltiple testing (12 pruebas).

## 4. Datos

La base —Cabra-Ruíz, Torres, Wills-Otero & Castilla-Gutiérrez (2023), "Una caracterización histórica de los partidos políticos de Colombia: 1958–2022" (Documento CEDE-Datos)— clasifica todos los partidos, movimientos y coaliciones con registro electoral entre 1958 y 2022. La unidad de observación es el partido/movimiento/coalición; el campo `temporalidad` se remonta hasta 1848 para organizaciones antiguas (p. ej. el Liberal). El archivo contiene 5.143 observaciones y 27 variables (25 documentadas en el diccionario oficial, más 2 de participación en primera/segunda vuelta presidencial). El detalle de variables está en la **Tabla A1** (Anexos).

### 4.1 Calidad y tratamiento de los datos

Las variables de texto libre (justificaciones, fuentes) tienen alta proporción de valores faltantes genuinos (73%–100%), esperable porque solo se documentan con fuente primaria disponible; no se usaron en el modelo.

Más relevante: `gradonac` usa 99 para "no se puede clasificar", y `grupo_representativo_1/2` usan dos códigos con significados distintos: 98 ("no representa un grupo identitario" —respuesta válida, no faltante—) y 99 ("no se tiene información" —faltante genuino—), cubriendo 11,3%, 88,6% y 98,6% de los partidos respectivamente. En una primera versión del pipeline estos códigos se recodificaban a NA sin distinguirlos y se imputaban con la moda, fabricando una variable casi constante que dominaba artificialmente la distancia euclídea de K-Means. Se corrigió tratando 98 y 99 como categorías propias y diferenciadas.

Todas las variables categóricas se codificaron como dummy mediante una matriz de diseño con intercepto que luego se descarta (evitando que la primera variable reciba codificación de rango completo mientras las demás reciben referencia —error corregido en este trabajo, ver sección 7). Las columnas de varianza cero se eliminaron y el conjunto final se estandarizó (media 0, desviación 1). La distribución completa de cada variable y la participación electoral por nivel se muestran en las **Tablas A2 y A3** (Anexos).

La participación cae drásticamente con el nivel de gobierno —de 55,3% en alcaldías a 1,2% en presidencia—, primer indicio, ya visible antes del clustering, de que la mayoría de los partidos colombianos opera solo a nivel local.

## 5. Implementación de la metodología

### 5.1 Selección del número de clusters

Se calcularon tres criterios para k entre 2 y 10 (100 inicializaciones por valor de k; ver **Tabla A4** en Anexos). El Calinski-Harabasz favorece fuertemente k=2 (914), mientras el silhouette crece de forma casi monótona hacia valores mayores de k (máximo en k=10, con 0,364). Ante este desacuerdo entre criterios —habitual en datos dummy de alta dimensionalidad— se optó por k=4: silhouette comparable al de k=2–3 (0,282 vs. 0,280–0,289) y, sobre todo, una partición sustantivamente interpretable, frente a soluciones de k más alto que maximizan la cohesión estadística pero son más difíciles de comunicar con claridad.

![Figura 1. Índice de silhouette por número de clusters.](../figuras/fig1_silhouette.png)

*Figura 1. Índice de silhouette por número de clusters (línea punteada: k=4, valor elegido).*

### 5.2 Modelo final y validación

El modelo final (k=4, nstart=100, iter.max=1000, semilla=20260706) explica el 25,2% de la varianza total (between_SS/total_SS) y alcanza un silhouette promedio de 0,26. La cohesión varía entre grupos (**Tabla A5**, Anexos): los clusters 2 y 3 (los más grandes) muestran silhouette de 0,21 y 0,42 —buena separación—, mientras los clusters 4 y 1 muestran 0,12 y –0,04; el cluster 1, el más pequeño y sustantivamente más interesante, tiene menor cohesión y debe interpretarse con cautela (ver limitaciones).

![Figura 2. Clusters proyectados sobre PCA.](../figuras/fig2_pca_clusters.png)

*Figura 2. Clusters proyectados sobre las dos primeras componentes principales del PCA (uso ilustrativo; el clustering se estimó sobre las variables originales).*

Como complemento, se proyectaron los mismos datos con t-SNE, técnica no lineal que preserva mejor la vecindad local (cubierta en la sesión de no supervisado del curso). UMAP falló al inicializar por la enorme cantidad de perfiles categóricos idénticos entre partidos; t-SNE sí produjo una proyección estable (Figura 3), revelando decenas de manchas compactas —cada una, un perfil categórico exacto— que los 4 clusters de K-Means no siempre respetan (el cluster 3 agrupa varias bajo una etiqueta), mientras el cluster 1 ("maquinarias electorales multinivel") aparece como su propio grupo compacto, respaldando que es un perfil sustantivo y no un artefacto del algoritmo.

![Figura 3. Proyección t-SNE de los 4 clusters.](../figuras/fig5_tsne_nivel1.png)

*Figura 3. Proyección t-SNE de los 4 clusters (nivel 1). La cercanía local es informativa; tamaño y distancia entre manchas no debe interpretarse literalmente.*

### 5.3 Validación estadística de los perfiles

Para cada una de las 12 variables originales se realizó una prueba χ² frente a la asignación de cluster, con V de Cramér y ajuste Benjamini-Hochberg (**Tabla A6**, Anexos). Las 12 variables resultaron significativas (p < 0,001), confirmando que la partición captura patrones reales, no ruido; encabezan `part_presidencia` (V=0,821), `ideologia` (0,615) y `grupo_representativo_2` (0,573). Tras corregir el error de codificación dummy (sección 7), `tradicional` —que con el error mostraba V=1,0, sugiriendo que definía un cluster por sí sola— pasó a 0,305, su peso real entre las 12 variables; la señal original estaba inflada por el artefacto de codificación.

### 5.4 Segundo nivel: validación con votos electorales reales (1958–2023)

Los indicadores `part_*` son binarios, sin capturar la magnitud del respaldo electoral. Se incorporaron los resultados electorales históricos (Torres et al., 2023) para los mismos siete niveles, a nivel de candidato-municipio-elección. Al cruzarlos con la base de partidos se confirmó que el 58% de las 5.143 organizaciones (2.988 filas) son coaliciones, en su mayoría de alcance local —aunque el 71% está clasificado como `gradonac=1` ("nacional"), y muchas son alianzas puntuales Liberal-Conservador, no vehículos marginales—.

Dado que no es posible atribuir de forma no arbitraria los votos de una coalición a un partido individual, esas filas se excluyeron, dejando un universo de 2.155 partidos no-coalición. El emparejamiento de nombres usó normalización ligera (mayúsculas, sin tildes/puntuación, sin palabras genéricas como "PARTIDO" o "MOVIMIENTO"), logrando emparejar el 80,6% de los votos históricos no-coalición (1.636 de 2.119 partidos). El 19,4% restante corresponde a variantes con eslóganes propios que la normalización ligera no resuelve sin riesgo de falsos positivos. La estadística descriptiva de los votos por nivel está en la **Tabla A7** (Anexos): la enorme brecha entre promedio y mediana en todos los niveles confirma el fuerte sesgo a la derecha que motivó la transformación log(1+votos).

Para cada uno de los 2.155 partidos no-coalición se sumaron los votos por nivel (log-transformados) y se combinaron, con la misma codificación dummy, con las variables categóricas originales. La selección de k favoreció valores bajos (silhouette = 0,542 en k=2 y 0,528 en k=3); se eligió k=3 en vez de k=2 porque separa un tercer grupo —una élite partidista minoritaria— que k=2 fusiona con el grupo intermedio, la distinción más relevante para el reporte de política. Las siete variables de votos (no solo senado) entraron todas al K-Means junto con las categóricas; el tamaño, composición y perfil de votos por cluster están en las **Tablas A8 y A9** (Anexos).

El patrón se sostiene en los siete niveles: "Partido institucionalizado" supera a "Partido vehículo" por un factor de 60 a 1.300 veces, sin depender de una sola elección. "Partido de nicho" se distingue por presencia relativamente alta en gobernación/presidencia frente a votación mínima en senado, coherente con partidos de representación de intereses específicos que rara vez compiten a nivel nacional.

![Figura 4. Segundo nivel: clusters con votos reales.](../figuras/fig4_nivel2_pca.png)

*Figura 4. Segundo nivel: clusters de partidos no-coalición con votos electorales reales, proyectados sobre PCA.*

"Partido institucionalizado" (4,8% de los no-coalición) incluye, de forma reconocible, al Liberal (43,6 millones de votos históricos al Senado), Conservador (30,5 millones), Cambio Radical, Polo Democrático, Alianza Verde, Nuevo Liberalismo y Opción Ciudadana. Este resultado, con magnitud real de respaldo electoral y restringido a partidos genuinos, corrobora con otra fuente de datos el hallazgo central de la sección 6.

### 5.5 Longevidad organizativa: la institucionalización puesta a prueba

Si la institucionalización es la capacidad de sobrevivir en el tiempo más allá de la fundación (Panebianco, 1988; Mainwaring & Scully, 1995), la longevidad de cada partido (años entre fundación y último registro, campo `temporalidad`) ofrece una prueba directa —independiente del clustering— de si los nombres del segundo nivel son adecuados (**Tabla A10**, Anexos). El contraste es contundente: la mitad de los partidos vehículo y de nicho desaparecen en el mismo año en que se registran (mediana = 0), mientras los institucionalizados sobreviven en promedio 13,3 años —Liberal y Conservador, fundados en 1848 y 1849 y vigentes en 2022, marcan el máximo de 174 años—. Esta brecha, obtenida con una variable que no participó en el clustering, confirma que institucionalización, más que ideología, es el eje que mejor distingue a los partidos colombianos.

## 6. Reporte de política

### 6.1 Qué se encontró

Los datos son contundentes: el sistema de partidos colombiano no es un espectro continuo de ideologías, sino una pirámide radicalmente desigual de alcance electoral, y la ideología explica poco de esa desigualdad. El modelo identifica cuatro perfiles, con implicaciones distintas para la regulación del sistema de partidos:

- **Cluster 1 — "Maquinarias electorales multinivel"** (1.8%, n=93): el más pequeño y determinante. Participa en todos los niveles muy por encima del promedio (67.7% presidencia, 50.5% senado, 55.9% cámara), pero el 66.7% no tiene ideología clasificable — el éxito multinivel se asocia con menor perfil programático, consistente con un sistema más personalista/clientelar que doctrinario.
- **Cluster 2 — "Vehículos sin identidad programática"** (39.4%, n=2.024): el más grande. 99.6% sin ideología clasificable, casi nada tradicional (0.4%), participación dispersa sin patrón de consolidación.
- **Cluster 3 — "Partidos locales con identidad ideológica"** (37.6%, n=1.931): ~100% con ideología clasificada (77.6% "ni derecha ni izquierda"), concentrado en alcaldías (73.6%), presencia nula en presidencia.
- **Cluster 4 — "Partidos ideológicos de espectro amplio"** (21.3%, n=1.095): totalmente clasificados (30.0% izquierda, 65.8% "ni derecha ni izquierda"), alcance local moderado.

El hallazgo central es cuantitativo: solo 93 partidos (1.8%) funcionan como maquinarias multinivel; el 98.2% restante opera en un solo nivel o de forma marginal. El segundo nivel (votos reales, sin coaliciones) corrobora el patrón: solo el 4,8% de los partidos genuinos —"Partido institucionalizado", que incluye al Liberal, Conservador, Cambio Radical, Polo y Verde— concentra el grueso del respaldo electoral, mientras el 86% son vehículos con votación marginal.

### 6.2 Qué significa para la política pública

Si el problema es la proliferación de vehículos sin sustancia, la solución no puede seguir midiéndose con una sola elección: los datos muestran que casi cualquier partido supera un umbral de votación puntual, pero solo una élite de 93 organizaciones sostiene ese desempeño en varios niveles a la vez. De ahí se derivan cuatro implicaciones concretas:

- Los umbrales de personería jurídica (hoy basados en votación mínima en una sola elección) podrían exigir desempeño en más de un nivel, dado que el 98.2% de los partidos históricos no alcanzaría ese estándar, mientras el grupo de élite (cluster 1) ya lo cumple.
- La financiación estatal podría ponderarse por amplitud de participación (número de niveles), no solo votos totales, para desincentivar vehículos de un solo uso (cluster 2).
- La asociación entre éxito multinivel y baja clasificación ideológica (cluster 1) sugiere que fortalecer partidos programáticos requiere incentivos específicos, no solo asumir que el éxito electoral produce partidos más doctrinarios.
- La tipología puede usarse como insumo de monitoreo periódico: reclasificar la oferta partidista vigente permitiría a la Registraduría y al CNE medir si la proliferación de vehículos marginales aumenta o disminuye tras cada reforma.

Se recomienda usar esta tipología como insumo descriptivo para el diseño de reglas, no como mecanismo automático de cancelación de personería jurídica (ver limitaciones éticas, sección 7).

### 6.3 Evidencia temporal: ¿funcionaron las reformas?

Usando el año de fundación, se comparó la composición de los clusters del segundo nivel entre partidos no-coalición fundados en cuatro periodos delimitados por hitos de reforma: antes de 1991, 1991–2003, 2003–2011 (Acto Legislativo 01/2003, umbral electoral) y 2011–2023 (Ley 1475/2011, requisitos de personería) (**Tabla A11**, Anexos). El patrón es contrario al objetivo declarado: el número de partidos nuevos se disparó tras cada reforma (de 395 en 2003–2011 a 1.097 en 2011–2023, un periodo más corto), mientras la probabilidad de que un partido nuevo llegue a "institucionalizado" cayó de 14,4% a 1,2%. Ni el umbral de 2003 ni la Ley 1475 frenaron la creación de vehículos electorales; si acaso, coincidieron con una aceleración de su proliferación, mientras alcanzar peso real se volvió más difícil frente a la ventaja consolidada de organizaciones históricas (Liberal, Conservador). Esto refuerza la recomendación de exigir desempeño multinivel sostenido, no un umbral de votación puntual.

## 7. Limitaciones

### 7.1 Errores metodológicos identificados y corregidos

- **Codificación dummy asimétrica**: `model.matrix(~.-1, ...)` asignaba, por un comportamiento conocido de R, codificación de rango completo a la primera variable (`tradicional`) y codificación de referencia a las demás, duplicando su peso en la distancia euclídea. Se corrigió generando la matriz con intercepto y eliminándolo después.
- **Imputación por moda de códigos centinela**: los códigos 98/99 (hasta 98.6% de casos en algunas variables) se recodificaban a NA sin distinguirlos y se imputaban con la moda, fabricando variables casi constantes. Se corrigió tratándolos como categorías legítimas y diferenciadas.

Ambas correcciones cambiaron los resultados de forma material (la V de Cramér de `tradicional` pasó de 1,0 a 0,305), lo que subraya la importancia de auditar el preprocesamiento en clustering sobre variables dummy.

### 7.2 Limitaciones remanentes

- **Predicción vs. causalidad**: ejercicio puramente descriptivo. La asociación entre éxito multinivel y baja clasificación ideológica (cluster 1) es correlacional.
- **Estabilidad del cluster pequeño**: el cluster 1 (n=93) mostró sensibilidad no trivial a la secuencia aleatoria incluso con 100 inicializaciones: corridas exploratorias produjeron tamaños entre 46 y 211 partidos para el mismo grupo sustantivo. Interpretar como patrón real, no frontera exacta.
- **Agregación temporal**: se agrupan partidos desde 1848 sin distinguir el marco institucional de cada periodo (Constitución de 1991, reforma de 2003); parte de la señal puede reflejar época de fundación, no un tipo invariante.
- **Calidad de la clasificación ideológica**: se construye por revisión de estatutos (juicio interpretativo del CEDE); ~40% de los partidos no tiene ideología clasificable.
- **Generalización**: los resultados describen el universo histórico registrado, no necesariamente los partidos activos hoy.
- **Cobertura del cruce con votos**: el emparejamiento capturó 80,6% de los votos no-coalición; el resto (variantes con eslóganes) queda sin registrar, y las coaliciones (58% de la base) quedaron fuera por no ser atribuibles a un partido individual sin regla de reparto arbitraria.
- **Cobertura temporal de coaliciones**: el registro muestra 0% de coaliciones antes de 1991 y en 2003–2011, frente a 70%/66% en los otros periodos — probablemente refleja que el catálogo solo se documentó sistemáticamente para ciertos ciclos electorales, no ausencia real; por eso el análisis temporal (6.3) se restringe a no-coalición.
- **Sensibilidad al método de agrupamiento**: Kernel PCA y Spectral Clustering sobre una muestra de 2.000 partidos mostraron acuerdo moderado con K-Means (índice de Rand ajustado = 0,57): Spectral recupera bien el bloque local con ideología clasificada, pero no aísla el 1,8% de "maquinarias multinivel" — sensible al método, patrón robusto pero no una frontera exacta.
- **Consideraciones éticas**: clasificar partidos como "vehículos marginales" podría malinterpretarse como juicio de legitimidad política. Usar como insumo descriptivo para reglas generales, no como criterio automático de cancelación de personería jurídica.

## Referencias

- Cabra-Ruíz, N., Torres, S., Wills-Otero, L., & Castilla-Gutiérrez, V. (2023). Una caracterización histórica de los partidos políticos de Colombia: 1958–2022 (Documento CEDE-Datos). Centro de Estudios sobre Desarrollo Económico, Universidad de los Andes.
- Jones, M. P., & Mainwaring, S. (2003). The nationalization of parties and party systems: An empirical measure and an application to the Americas. *Party Politics*, 9(2), 139–166.
- Mainwaring, S., & Scully, T. R. (Eds.). (1995). *Building Democratic Institutions: Party Systems in Latin America*. Stanford University Press.
- Meguid, B. M. (2005). Competition between unequals: The role of mainstream party strategy in niche party success. *American Political Science Review*, 99(3), 347–359.
- Panebianco, A. (1988). *Political Parties: Organization and Power*. Cambridge University Press.
- Pizarro Leongómez, E. (2006). Giants with feet of clay: political parties in Colombia. In *Party Politics in the Andes*. Rowman & Littlefield.
- Torres, S., Barinas-Forero, A., Forero-Mesa, W., Sánchez, J. E., & Tibavisco, M. (2023). Resultados electorales de Colombia (Documento CEDE-Datos). Centro de Estudios sobre Desarrollo Económico, Universidad de los Andes. DataHub Uniandes, DOI: 10.71590/R2KLKI.

---

## Anexos

Tablas de apoyo referenciadas en el cuerpo del reporte.

### Tabla A1. Variables utilizadas en el modelo

| Variable | Descripción | Tipo |
|---|---|---|
| tradicional | Indicador de partido tradicional (Liberal/Conservador y afines) | Binaria |
| gradonac | 0 = No nacional; 1 = Nacional; 99 = No se puede clasificar | Categórica |
| ideologia | 1 = Izquierda; 2 = Derecha; 3 = Ni derecha ni izquierda; 4 = Información insuficiente | Categórica |
| grupo_representativo_1/2 | Grupo identitario representado (afro, indígena, cristiano, ex-militante, campesino, mujer, víctima); 98 = no representa; 99 = sin información | Categórica |
| part_alcaldia ... part_senado | Participación (0/1) en 7 tipos de elección + 1ª/2ª vuelta presidencial | Binarias (9) |

*Fuente: Cabra-Ruíz, Torres, Wills-Otero & Castilla-Gutiérrez (2023).*

### Tabla A2. Distribución de variables categóricas (n=5.143)

| Variable | Categoría | n | % |
|---|---|---|---|
| tradicional | 0 — No tradicional | 4,838 | 94.1% |
| tradicional | 1 — Tradicional | 305 | 5.9% |
| gradonac | 0 — No nacional | 2,428 | 47.2% |
| gradonac | 1 — Nacional | 2,134 | 41.5% |
| gradonac | 99 — No se puede clasificar | 581 | 11.3% |
| ideologia | 1 — Izquierda | 414 | 8.0% |
| ideologia | 2 — Derecha | 414 | 8.0% |
| ideologia | 3 — Ni derecha ni izquierda | 2,237 | 43.5% |
| ideologia | 4 — Información insuficiente | 2,078 | 40.4% |
| grupo_representativo_1 | 1–7 (afro, indígena, cristiano, ex-militante, campesino, mujer, víctima) | 587 | 11.4% |
| grupo_representativo_1 | 98 — No representa grupo identitario | 979 | 19.0% |
| grupo_representativo_1 | 99 — No se tiene información | 3,577 | 69.6% |
| grupo_representativo_2 | 1–6 (mismas categorías, sin víctimas) | 72 | 1.4% |
| grupo_representativo_2 | 98 — No representa grupo identitario | 3,056 | 59.4% |
| grupo_representativo_2 | 99 — No se tiene información | 2,015 | 39.2% |

*Fuente: elaboración propia con datos de Cabra-Ruíz et al. (2023).*

### Tabla A3. Participación electoral por nivel (n=5.143)

| Nivel | n participa | % participa |
|---|---|---|
| Alcaldía | 2,844 | 55.3% |
| Concejo | 1,364 | 26.5% |
| Cámara | 773 | 15.0% |
| Asamblea | 444 | 8.6% |
| Gobernación | 274 | 5.3% |
| Senado | 227 | 4.4% |
| Presidencia | 63 | 1.2% |

*Fuente: elaboración propia con datos de Cabra-Ruíz et al. (2023).*

### Tabla A4. Selección de k — codo, silhouette y Calinski-Harabasz (nivel 1)

| k | WSS | Silhouette | Calinski-Harabasz |
|---|---|---|---|
| 2 | 130,984 | 0.280 | 914 |
| 3 | 123,017 | 0.289 | 653 |
| 4 | 114,504 | 0.282 | 595 |
| 5 | 108,305 | 0.286 | 545 |
| 6 | 103,370 | 0.318 | 506 |
| 7 | 98,155 | 0.308 | 489 |
| 8 | 93,424 | 0.316 | 478 |
| 9 | 87,734 | 0.358 | 487 |
| 10 | 83,409 | 0.364 | 484 |

*Fuente: elaboración propia.*

### Tabla A5. Tamaño y silhouette por cluster (nivel 1)

| Cluster | n | % del total | Silhouette promedio |
|---|---|---|---|
| 1 | 93 | 1.8% | −0.04 |
| 2 | 2,024 | 39.4% | 0.21 |
| 3 | 1,931 | 37.6% | 0.42 |
| 4 | 1,095 | 21.3% | 0.12 |

*Fuente: elaboración propia.*

### Tabla A6. Validación estadística de los perfiles (χ² y V de Cramér)

| Variable | V de Cramér | χ² | p ajustado (BH) |
|---|---|---|---|
| part_presidencia | 0.821 | 3,463.4 | < 0.001 |
| ideologia | 0.615 | 5,835.6 | < 0.001 |
| grupo_representativo_2 | 0.573 | 5,058.6 | < 0.001 |
| grupo_representativo_1 | 0.571 | 5,038.6 | < 0.001 |
| gradonac | 0.542 | 3,017.0 | < 0.001 |
| part_senado | 0.326 | 547.4 | < 0.001 |
| tradicional | 0.305 | 479.6 | < 0.001 |

*Fuente: elaboración propia.*

### Tabla A7. Estadística descriptiva de los votos históricos por nivel (1958–2023)

| Nivel | Partidos con votos | Votos totales | Promedio | Mediana | Máximo |
|---|---|---|---|---|---|
| Concejo | 618 | 141,520,199 | 228,997 | 2,678 | 50,204,571 |
| Asamblea | 141 | 139,802,861 | 991,510 | 59,738 | 61,833,083 |
| Cámara | 460 | 109,568,676 | 238,193 | 4,620 | 47,622,263 |
| Senado | 171 | 102,928,017 | 601,918 | 37,287 | 43,675,547 |
| Alcaldía | 808 | 99,644,219 | 123,322 | 3,249 | 27,318,479 |
| Presidencia | 64 | 93,826,350 | 1,466,037 | 29,177 | 41,705,550 |
| Gobernación | 145 | 59,680,036 | 411,586 | 90,477 | 22,171,005 |

*Fuente: elaboración propia con datos de Torres, Barinas-Forero, Forero-Mesa, Sánchez & Tibavisco (2023).*

### Tabla A8. Clusters del segundo nivel: tamaño y composición ideológica

| Cluster | n | % | Ideología no clasif. | Ejemplos |
|---|---|---|---|---|
| Partido vehículo | 1,854 | 86.0% | 99.8% | microempresas electorales sin trayectoria |
| Partido de nicho | 198 | 9.2% | 0.0% | ONIC, movimientos cristianos, integración popular |
| Partido institucionalizado | 103 | 4.8% | 48.5% | Liberal, Conservador, Cambio Radical, Polo, Verde |

*Fuente: elaboración propia.*

### Tabla A9. Votos históricos promedio por partido y nivel electoral, por cluster

| Cluster | Alcaldía | Asamblea | Cámara | Concejo | Gobernación | Presidencia | Senado |
|---|---|---|---|---|---|---|---|
| Partido vehículo | 6,686 | 1,024 | 2,026 | 2,782 | 3,529 | 1,650 | 1,431 |
| Partido de nicho | 16,399 | 1,905 | 2,370 | 4,126 | 17,845 | 67,019 | 782 |
| Partido institucionalizado | 805,796 | 1,329,062 | 1,020,909 | 1,290,609 | 471,643 | 752,177 | 971,416 |

*Fuente: elaboración propia.*

### Tabla A10. Longevidad organizativa por cluster (segundo nivel)

| Cluster | n | Longevidad promedio (años) | Longevidad mediana (años) | Longevidad máxima (años) |
|---|---|---|---|---|
| Partido vehículo | 1,854 | 0.5 | 0 | 43 |
| Partido de nicho | 198 | 0.8 | 0 | 25 |
| Partido institucionalizado | 103 | 13.3 | 8 | 174 |

*Fuente: elaboración propia con datos de temporalidad (Cabra-Ruíz et al., 2023).*

### Tabla A11. Composición de clusters (segundo nivel) por periodo de fundación

| Período | n partidos nuevos | % Institucionalizado | % Nicho | % Vehículo |
|---|---|---|---|---|
| Antes de 1991 | 279 | 10.0% | 2.2% | 87.8% |
| 1991–2003 (Const. 91) | 354 | 14.4% | 5.1% | 80.5% |
| 2003–2011 (Acto Legislativo 01/2003) | 395 | 2.8% | 7.1% | 90.1% |
| 2011–2023 (Ley 1475/2011) | 1,097 | 1.2% | 13.1% | 85.7% |

*Fuente: elaboración propia con datos de Cabra-Ruíz et al. (2023).*
