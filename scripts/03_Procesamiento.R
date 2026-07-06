###############################################################
# SCRIPT 3
# PREPROCESAMIENTO
###############################################################

library(tidyverse)

###############################################################
# 1. COPIA DE LA BASE
###############################################################

datos_cluster <- partidos

###############################################################
# 2. SELECCIONAR VARIABLES
###############################################################

datos_cluster <- datos_cluster %>%
  select(
    tradicional,
    gradonac,
    ideologia,
    grupo_representativo_1,
    grupo_representativo_2,
    part_alcaldia,
    part_asamblea,
    part_camara,
    part_concejo,
    part_gobernacion,
    part_presidencia,
    part_presidencia_1v,
    part_presidencia_2v,
    part_senado
  )

###############################################################
# 3. VERIFICAR TIPOS
###############################################################

str(datos_cluster)

###############################################################
# 4. CONVERTIR FACTORES A CARACTER
###############################################################

datos_cluster <- datos_cluster %>%
  mutate(
    across(where(is.factor), as.character)
  )

###############################################################
# 5. CODIGOS ESPECIALES (98/99)
###############################################################
# Los codigos 98 ("no aplica") y 99 ("sin clasificar") se
# mantienen como categorias propias en gradonac,
# grupo_representativo_1 y grupo_representativo_2 en vez de
# recodificarse a NA e imputarse con la moda: en estas
# variables 98/99 cubre entre el 11% y el 99% de los partidos,
# y forzar esa mayoria a la categoria mas frecuente fabricaba
# una variable casi constante que dominaba la distancia
# euclidiana de K-Means.

###############################################################
# 6. FUNCION MODA
###############################################################

moda <- function(x){
  
  ux <- na.omit(unique(x))
  
  ux[which.max(tabulate(match(x,ux)))]
  
}

###############################################################
# 7. IMPUTAR NA CON LA MODA
###############################################################

datos_cluster <- datos_cluster %>%
  mutate(
    across(
      everything(),
      ~replace(., is.na(.), moda(.))
    )
  )

###############################################################
# 8. VERIFICAR
###############################################################

colSums(is.na(datos_cluster))

###############################################################
# 9. CONVERTIR A FACTOR
###############################################################

datos_cluster <- datos_cluster %>%
  mutate(
    across(
      everything(),
      as.factor
    )
  )

###############################################################
# 10. CREAR VARIABLES DUMMY
###############################################################

X <- model.matrix(

  ~ .,

  data = datos_cluster

)

X <- X[, colnames(X) != "(Intercept)"]

###############################################################
# 11. PASAR A DATA FRAME
###############################################################

X <- as.data.frame(X)

###############################################################
# 12. ELIMINAR COLUMNAS CONSTANTES
###############################################################

constantes <-
  
  sapply(
    
    X,
    
    function(x)
      
      length(unique(x))==1
    
  )

X <-
  
  X[,!constantes]

###############################################################
# 13. VERIFICAR
###############################################################

dim(X)

###############################################################
# 14. NORMALIZAR
###############################################################

datos_ml <-
  
  scale(X)

###############################################################
# 15. PASAR A DATA FRAME
###############################################################

datos_ml <-
  
  as.data.frame(datos_ml)

###############################################################
# 16. COMPROBAR
###############################################################

summary(datos_ml)

###############################################################
# 17. MEDIA
###############################################################

round(
  
  colMeans(datos_ml),
  
  5
  
)

###############################################################
# 18. DESVIACION
###############################################################

round(
  
  apply(
    
    datos_ml,
    
    2,
    
    sd
    
  ),
  
  5
  
)

###############################################################
# 19. MATRIZ FINAL
###############################################################

str(datos_ml)

###############################################################
# 20. GUARDAR
###############################################################

saveRDS(
  
  datos_ml,
  
  "datos_ml.rds"
  
)

###############################################################
# FIN
###############################################################