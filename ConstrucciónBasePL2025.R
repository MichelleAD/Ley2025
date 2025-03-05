# Librerías ---------------------------------------------------------------

library(ggplot2); library(dplyr) 
library(reshape); library(tools); library(readxl)

# Datos -------------------------------------------------------------------

PROYECCIONES <- read_excel("estimaciones-y-proyecciones-2002-2035-comunas (1).xlsx", sheet = 1,skip = 3)
PROYECCIONES <- head(PROYECCIONES, -1)

CUT2018 <- read_excel("cut_2018_v04.xlsx")

POB_MULTI <- read_excel("Estimaciones_Indice_Pobreza_Multidimensional_Comunas_2022.xlsx", skip = 2)
POB_MULTI <- head(POB_MULTI,-5)

proyecto_ley_2025 <- read_excel("proyecto_ley_2025.xls", skip = 4)

# Cambiar el nombre de algunas variables para hacer el left join.

proyecto_ley_2025 <- proyecto_ley_2025 %>%
  mutate(NombreComuna = toTitleCase(tolower(Comunas)))

#Aquí cambio el nombre de la variable por la cual haré el leftjoin

colnames(CUT2018)[colnames(CUT2018) == "Nombre Comuna"] <- "NombreComuna"
colnames(POB_MULTI)[colnames(POB_MULTI) == "Nombre comuna"] <- "NombreComuna"
colnames(PROYECCIONES)[colnames(PROYECCIONES) == "Nombre Comuna"] <- "NombreComuna"


colnames(CUT2018)[colnames(CUT2018) == "Código Comuna 2018"] <- "CódigoComuna"
CUT2018$CódigoComuna[1:207] <- substr(CUT2018$CódigoComuna[1:207], 2, nchar(CUT2018$CódigoComuna[1:207]))
CUT2018$CódigoComuna <- as.numeric(CUT2018$CódigoComuna)
colnames(PROYECCIONES)[colnames(PROYECCIONES) == "Comuna"] <- "CódigoComuna"

unique(CUT2018$CódigoComuna)
unique(PROYECCIONES$CódigoComuna) 

POB_MULTI <- left_join(POB_MULTI, CUT2018, by = "NombreComuna")
unique(POB_MULTI$NombreComuna)


#Elimino las variables que están repetidas en las bases (a excepción de NombreComuna)
#y mantengo 

POB_MULTI <- POB_MULTI %>% select(-Región, -Código)
PROYECCIONES <- PROYECCIONES %>% select(-Region)


BASE <- proyecto_ley_2025 %>%
  left_join(PROYECCIONES, by = "NombreComuna") %>%
  left_join(CUT2018, by = "NombreComuna") %>%
  left_join(POB_MULTI, by = "NombreComuna")


BASE <- BASE %>% mutate(RegionAB = case_when(Región == "Tarapacá" ~ "TPCA",
                                             Región == "Atacama" ~ "ATCMA",
                                             Región == "Antofagasta" ~ "ANTOF",
                                             Región == "Coquimbo" ~ "COQ",
                                             Región == "Valparaíso" ~ "VALPO",
                                             Región == "Libertador General Bernardo O'Higgins" ~ "LGBO",
                                             Región == "Maule" ~ "MAULE",
                                             Región == "Ñuble" ~ "NUBLE",
                                             Región == "Biobío" ~ "BBIO",
                                             Región == "La Araucanía" ~ "ARAUC",
                                             Región == "los Lagos"  ~ "LAGOS",
                                             Región == "Aysén del General Carlos Ibáñez del Campo" ~ "AYSEN",
                                             Región == "Magallanes y de la Antártica Chilena"  ~ "MAG",
                                             Región == "Metropolitana de Santiago" ~  "RM" ,
                                             Región == "Los Ríos" ~ "RIOS",
                                             Región == "Arica y Parinacota"  ~ "AyP",
                                             TRUE ~ "INTERREGIONAL"
                                             ))

unique(BASE$Región)
writexl::write_xlsx(BASE, "BASE.xlsx")


