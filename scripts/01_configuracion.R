###############################################################
# PROYECTO FINAL
# Aprendizaje de Máquinas para Políticas Públicas
#
# Tema:
# Identificación de perfiles de partidos políticos colombianos
# mediante K-Means (aprendizaje no supervisado)
#
# Base:
# CEDE - Universidad de los Andes (Cabra-Ruíz, Torres, Wills-Otero
# & Castilla-Gutiérrez, 2023)
#
# Autor:
# Andrez Felipe Guerrero Torres
#
# SCRIPT 1 - PROPOSITO METODOLOGICO
# Este script es el punto de entrada del pipeline: carga las
# librerías necesarias e importa la base cruda tal como llega de
# la fuente, sin ninguna transformación. La razón de aislar este
# paso es la reproducibilidad: cualquier persona que corra el
# proyecto desde cero debe partir exactamente del mismo estado
# (mismos paquetes, mismos datos crudos) antes de que empiecen las
# decisiones de preprocesamiento (script 3), que son las que
# realmente pueden introducir sesgos si no se auditan con cuidado.
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