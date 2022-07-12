rm(list = ls())

library(tidyverse)
library(readxl)
library(janitor)





jukseark <- read_excel(
  "C:/Users/Gusia/Desktop/HACKATHON/ISSSV1337/OPXfinans2.xlsx")

jukseark_1 <- read_excel(
  "C:/Users/Gusia/Desktop/HACKATHON/ISSSV1337/OPXfinansAGA.xlsx",
                         col_names = c("entry", "value"))
  

juksedata <- jukseark %>% 
  pivot_wider(names_from = Name, values_from = Value) %>% 
  clean_names() %>% 
    mutate(
    KPI_ROI = administrative+fundraising/private_contributions/membership_fees)


juksedata_1 <- jukseark_1 %>% 
  pivot_wider(names_from = entry, values_from = value) %>% 
  na.omit() %>% 
  clean_names() %>% 
  mutate(
    KPI_ROI = administrative+fundraising/private_contributions/membership_fees)

  

  
 