###############################################################
# SCRIPT 2
# ANALISIS EXPLORATORIO DE DATOS (EDA)
#
# PROPOSITO METODOLOGICO
# Antes de tocar una sola variable hay que entender su forma:
# dimension del problema, tipos de dato, y sobre todo el patron de
# valores faltantes. Este ultimo punto es el mas critico para el
# resto del pipeline: aqui se detecta que las variables de texto
# libre (justificaciones, fuentes) tienen 73%-100% de faltantes
# genuinos, mientras que gradonac y grupo_representativo_1/2 NO
# tienen NA de tipo faltante-real sino codigos centinela (98/99)
# que se manejan de forma especial en el script 3. Sin este
# diagnostico previo, seria facil tratar por error un codigo
# centinela como si fuera un dato perdido cualquiera.
###############################################################

###############################################################
# 1. DIMENSIONES
###############################################################

cat("\n")
cat("==============================\n")
cat("DIMENSIONES DE LA BASE\n")
cat("==============================\n")

dim(partidos)

###############################################################
# 2. ESTRUCTURA
###############################################################

cat("\n")
cat("==============================\n")
cat("ESTRUCTURA\n")
cat("==============================\n")

str(partidos)

###############################################################
# 3. VARIABLES
###############################################################

cat("\n")
cat("==============================\n")
cat("NOMBRES VARIABLES\n")
cat("==============================\n")

names(partidos)

###############################################################
# 4. PRIMERAS OBSERVACIONES
###############################################################

head(partidos)

###############################################################
# 5. ULTIMAS OBSERVACIONES
###############################################################

tail(partidos)

###############################################################
# 6. RESUMEN GENERAL
###############################################################

summary(partidos)

###############################################################
# 7. INFORME COMPLETO
###############################################################

skim(partidos)

###############################################################
# 8. VALORES FALTANTES
###############################################################

na_tabla <- partidos |>
  summarise(
    across(
      everything(),
      ~sum(is.na(.))
    )
  ) |>
  pivot_longer(
    everything(),
    names_to = "Variable",
    values_to = "n_missing"
  ) |>
  arrange(desc(n_missing))

###############################################################
# 9. GRAFICO DE VALORES FALTANTES
###############################################################

ggplot(
  na_tabla,
  aes(
    x = reorder(Variable, n_missing),
    y = n_missing
  )
) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Valores faltantes por variable",
    x = "",
    y = "Número de valores faltantes"
  ) +
  theme_minimal()

###############################################################
# 10. DUPLICADOS
###############################################################

cat("\n")
cat("==============================\n")
cat("DUPLICADOS\n")
cat("==============================\n")

sum(duplicated(partidos))

###############################################################
# 11. VARIABLES NUMERICAS
###############################################################

numericas <-
  
  partidos |>
  
  select(where(is.numeric))

names(numericas)

###############################################################
# 12. VARIABLES CATEGORICAS
###############################################################

categoricas <-
  
  partidos |>
  
  select(
    
    where(is.character),
    
    where(is.factor)
    
  )

names(categoricas)

###############################################################
# 13. HISTOGRAMAS
###############################################################

if(ncol(numericas)>0){
  
  for(i in names(numericas)){
    
    print(
      
      ggplot(
        
        partidos,
        
        aes(
          
          x=.data[[i]]
          
        )
        
      )+
        
        geom_histogram(
          
          bins=30,
          
          fill="darkcyan",
          
          color="white"
          
        )+
        
        theme_minimal(base_size=12)+
        
        labs(
          
          title=i,
          
          x="",
          
          y="Frecuencia"
          
        )
      
    )
    
  }
  
}

###############################################################
# 14. VARIABLES MAS IMPORTANTES
###############################################################

variables <- c(
  
  "tradicional",
  "gradonac",
  "ideologia",
  "grupo_representativo_1",
  "grupo_representativo_2"
  
)

###############################################################
# 15. GRAFICOS DE BARRAS
###############################################################

for(i in variables){
  
  print(
    
    ggplot(
      
      partidos,
      
      aes(
        
        factor(.data[[i]])
        
      )
      
    )+
      
      geom_bar(fill="tomato")+
      
      theme_minimal(base_size=13)+
      
      labs(
        
        title=i,
        
        x="",
        
        y="Frecuencia"
        
      )
    
  )
  
}

###############################################################
# 16. VARIABLES ELECTORALES
###############################################################

electorales <- c(
  
  "part_alcaldia",
  "part_asamblea",
  "part_camara",
  "part_concejo",
  "part_gobernacion",
  "part_presidencia",
  "part_presidencia_1v",
  "part_presidencia_2v",
  "part_senado"
  
)

###############################################################
# 17. PARTICIPACION ELECTORAL
###############################################################

for(i in electorales){
  
  print(
    
    ggplot(
      
      partidos,
      
      aes(
        
        factor(.data[[i]])
        
      )
      
    )+
      
      geom_bar(fill="steelblue")+
      
      theme_minimal(base_size=12)+
      
      labs(
        
        title=i,
        
        x="",
        
        y="Número de partidos"
        
      )
    
  )
  
}

###############################################################
# 18. TABLA DESCRIPTIVA
###############################################################

tabla_descriptiva <-
  
  partidos |>
  
  select(
    
    tradicional,
    
    gradonac,
    
    ideologia,
    
    all_of(electorales)
    
  )

summary(tabla_descriptiva)

###############################################################
# 19. EXPORTAR TABLAS
###############################################################

write.csv(
  
  na_tabla,
  
  "tabla_missing.csv",
  
  row.names=FALSE
  
)

###############################################################
# 20. GUARDAR FIGURAS
###############################################################

ggsave(
  
  "missing_values.png",
  
  width=8,
  
  height=6
  
)

###############################################################
# FIN DEL SCRIPT
###############################################################