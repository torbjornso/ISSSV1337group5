rm(list = ls())

library(tidyverse)
library(readxl)
library(janitor)


# Leser inn excel-fil og angir kolonnenavn
jukseark <- read_excel("./OPXfinans.xlsx", col_names = c("entry", "value"))
 

juksedata <- jukseark %>%
  na.omit() %>% # Dropper NA (det som var overskrifter i excel)
  pivot_wider(names_from = entry, values_from = value) %>% # Gjør om rader til kolonner (variabler)
  clean_names() %>% # Lager mer r-vennlige kolonnenavn
  mutate(
    KPI = sum_total_revenue+total_assets/total_liabilities) # Legger til en kolonne med KPI,
# regnet ut som summen av inntekter delt på liabilities. Detter er bare et eksempel.
# Jeg vet fortsatt ingenting om å lage KPI.




