###############################################################
# PROYECTO FINAL
# Aprendizaje de Máquinas para Políticas Públicas
#
# Tema:
# Identificación de perfiles de partidos políticos colombianos
# mediante K-Means
#
# Base:
# CEDE - Universidad de los Andes
#
# Autor:
#
###############################################################

rm(list = ls())

graphics.off()

cat("\014")

###############################################################
# 1. PAQUETES
###############################################################

paquetes <- c(
  
  "tidyverse",
  "readxl",
  "janitor",
  "skimr",
  "ggplot2",
  "caret",
  "cluster",
  "factoextra",
  "corrplot"
  
)

instalar <- paquetes[!(paquetes %in%
                         installed.packages()[,"Package"])]

if(length(instalar)>0){
  
  install.packages(instalar)
  
}

lapply(paquetes,
       library,
       character.only=TRUE)

###############################################################
# 2. IMPORTAR BASE
###############################################################

partidos <- read_excel("data/partidos.xlsx")

###############################################################
# 3. LIMPIAR NOMBRES
###############################################################

partidos <- clean_names(partidos)

###############################################################
# 4. VERIFICAR
###############################################################

dim(partidos)

names(partidos)

glimpse(partidos)

###############################################################
# 5. RESUMEN
###############################################################

skim(partidos)

###############################################################
# 6. COPIA DE SEGURIDAD
###############################################################

datos_originales <- partidos

###############################################################
# FIN SCRIPT 1
###############################################################