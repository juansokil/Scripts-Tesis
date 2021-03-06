##################################
##################################
########CAPITULO 3 ###############
##################################
##################################

#install.packages("raster")
#install.packages("tidyverse")
library(tidyverse)
#install.packages("sp")
#install.packages("maptools")
#install.packages("rgeos")
library(rgeos)

library(sp)
library(maptools)
library(ggplot2)
library(maps)

### LIBRERIAS###
#install.packages("shiny")
#install.packages("viridis")
library(viridis)
library(shiny)
library(data.table)
library(ggplot2)
library(stringr)
library(dplyr)
library(maptools)
library(maps)
library(readr)
library(tidyr)
library(ggrepel)
library(scales)
library(devtools)
library(ggplot2)
library(ggflags) # Para geom_flags
library(countrycode)  # Para obtener codigos de paises
library(tidyverse)
library(readr)
library(gganimate)
library(readr)
library(caret)






##########################################
##########################################
##################### 3. 1 ###############
##########################################
##########################################

################REGRESION#################
#specify the cross-validation method
ctrl <- trainControl(method = "LOOCV")

regres <- read_delim("C:/Users/Juan/Desktop/regres.txt", 
                     "\t", escape_double = FALSE, locale = locale(decimal_mark = ",", 
                                                                  grouping_mark = "."), trim_ws = TRUE)


#fit a regression model and use LOOCV to evaluate performance
model <- train(total2 ~ year, data = regres, method = "lm", trControl = ctrl)
print(model)
model <- lm(genero2 ~ year, data = regres)
model
mean(model$residuals^2)
model <- lm(sociales ~ year, data = regres)
model

summary(model)
model <- lm(sociales2 ~ year, data = regres)
plot(model)

summary(model$fitted.values)
mse <- (1/15)

mean((training.data - predict(training.model))^2)

round(mean(model$fitted.values - model$model$genero)^2,4)
r <- model$fitted.values - model$model$genero
round(sum(r),4)
mse = sum(model$residuals^2)/model$df.residual
summary(model$coefficients)
plot(model$fitted.values, regres$genero)


####EJEMPLO MANUAL REGRESION########
x <- c(43,21,25,42,57,59)
y <- c(99,65,79,75,87,81)
n <- 6

parametros <- function (x,y,n) {
  intercepto = ((sum(y)*sum(x^2))-(sum(x)*sum(x*y)))/((n*(sum(x^2))- sum(x)^2))
  print(intercepto)
  pendiente = (n*(sum(x*y))-(sum(x)*sum(y)))  / ((n*sum(x^2)) - (sum(x)^2))
  print(pendiente)
}

parametros(x,y,n)


parametros(regres$year,regres$genero,15)
y_estimado= -579122 + (289.81*regres$year)







##########################################
##########################################
##################### 3. 2 ###############
##########################################
##########################################

library(readr)
totales <- read_delim("C:/Users/Juan/Dropbox/POSGRADOS/Uba/99-Tesis/scripts/scripts/graficos/totales.csv", 
                      ";", escape_double = FALSE, trim_ws = TRUE)


totales2 <- read_delim("C:/Users/Juan/Dropbox/POSGRADOS/Uba/99-Tesis/scripts/scripts/graficos/totales2.csv", 
                       ";", escape_double = FALSE, trim_ws = TRUE)


ggplot(totales2, aes(Ano, Especializacion)) +  geom_point() + geom_line() +
  coord_cartesian(ylim = c(0, 0.02))  +
  geom_smooth(method='loess') +
  scale_y_continuous(labels = percent)  +
  scale_x_continuous(breaks = seq(2004, 2018, by = 1))




################ANALISIS A NIVEL####################

#install.packages("rworldmap")
library("rworldmap")
library(scales)

countrycode <-  as.data.frame(countrycode::codelist) %>% 
  as.tibble() %>% 
  select(pais = country.name.en, code = ecb )  %>% 
  filter(!is.na(code)) %>% 
  print(n = Inf)



setwd("C:/Users/Juan/Dropbox/POSGRADOS/Uba/99-Tesis/scripts/scripts/Indices")
getwd()
library(readr)
indices2 <- read_delim("total_indices.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
indices2 <- read_delim("indices2.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
indices2$especializacion_pct = indices2$especializacion*100

#world <- map_data("world") 
#indicesfull <- left_join(world, indices2, by = c("region" = "country"))

##OPCION##
mapped_data <- joinCountryData2Map(indices2, joinCode = "ISO2", nameJoinColumn = "ISO2")
mapped_data
par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")
mapParams <-mapCountryData(mapped_data, nameColumnToPlot="especializacion_pct", colourPalette="topo", 
                           mapTitle = "", 
                           missingCountryCol="white", oceanCol="lightblue", addLegend=FALSE
                           #, mapRegion='eurasia'
)
do.call( addMapLegend, c(mapParams, legendWidth=0.5, legendMar = 3))




####Selecciono las variables que me sirven####
indice_gdi <- indices2 %>% select (country, ISO2, ISO3, continente, subcontinente, especializacion, Global_Index)

indice_gathered_1 <- indice_gdi %>%
  gather(key = Global_index, value = measurement, -c(country, ISO2, ISO3, continente, subcontinente, especializacion) )

indice_gathered_1_head <- indice_gathered_1 %>% arrange(desc(especializacion))
indice_gathered_1_head <- head(indice_gathered_1_head,92)


###BOXPLOT ESPECIALIZACION###
indice_gathered_1_head %>%
  filter(continente %in%  c('Africa', 'Americas', 'Asia', 'Europe','Oceania')) %>%
  ggplot(aes(x=continente, y=especializacion,  label=ISO2, fill=subcontinente)) +
  geom_point(size=3) +
  geom_boxplot(fill = "#4271AE", colour = "#1F3552", alpha = 0.7, outlier.colour = "red", outlier.shape = 20) +
  coord_cartesian(ylim = c(0.00, 0.04))  +
  geom_label_repel(size=2) +
  # geom_jitter() +
  #geom_point() +
  #geom_jitter() +
  # facet_wrap(~continente, scales = "free", ncol=3) +
  theme(legend.title=element_blank(), axis.title.y = element_blank(), legend.position="bottom") 




#################TEST NO PARAMETRICOS#####################


#### tengo los paises con la especialización###
tabla <- indice_gathered_1_head %>% group_by(subcontinente) %>% summarise(count=n(), median=median(especializacion, na.rm=TRUE), IQR=IQR(especializacion, na.rm=TRUE))
View(tabla)

sudeste_asiatico <- indice_gathered_1_head %>% filter(subcontinente =='Sudeste Asiatico') %>% select(country, subcontinente, especializacion)

africa_oriental <- indice_gathered_1_head %>% filter(subcontinente =='Africa Oriental') %>% select(country, subcontinente, especializacion)
europa_occidental <- indice_gathered_1_head %>% filter(subcontinente =='Europa Occidental') %>% select(country, subcontinente, especializacion)
europa_oriental <- indice_gathered_1_head %>% filter(subcontinente =='Europa Oriental') %>% select(country, subcontinente, especializacion)
europa_norte <- indice_gathered_1_head %>% filter(subcontinente =='Europa del Norte') %>% select(country, subcontinente, especializacion)

comparacion <- rbind(europa_oriental, europa_norte)
View(comparacion)

res <- wilcox.test(europa_occidental$especializacion, sudeste_asiatico$especializacion,  alternative='two.sided', correct=TRUE, exact=TRUE)
res


indice_gathered_1_head_gathered <- 
  indice_gathered_1_head %>%
  filter(continente %in%  c('Africa', 'Americas', 'Asia', 'Europe')) %>%
  select(subcontinente, especializacion) 

indice_gathered_1_head_gathered %>%
  group_by(subcontinente) %>%
  summarize(mean(especializacion), n())


#https://rpubs.com/Joaquin_AR/219148
kruskal.test(indice_gathered_1_head_gathered$especializacion~indice_gathered_1_head_gathered$subcontinente)


###Post hoc que nos permite ver la diferencia entre que grupos###
TukeyHSD(model1, conf.level = 0.90)
plot(TukeyHSD(model1, conf.level = 0.90),las=1, col = "red")








##########################################
##########################################
##################### 3. 3 ###############
##########################################
##########################################


base_completa <- read_delim("C:/Users/Juan/Dropbox/POSGRADOS/Uba/99-Tesis/scripts/scripts/LDA/base_completa.csv",   "\t", escape_double = FALSE, col_types = cols(X1 = col_skip(), id_1 = col_skip()), trim_ws = TRUE)
paises_colaboracion <- read_delim("C:/Users/Juan/Dropbox/POSGRADOS/Uba/99-Tesis/scripts/scripts/LDA/paises_colaboracion.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
completo <-  base_completa %>% left_join(paises_colaboracion, c('id'='ut'))

#indices2 <- read_delim("https://raw.githubusercontent.com/juansokil/Scripts-Tesis/master/resultados/total_indices.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
indices2 <- read_delim("https://raw.githubusercontent.com/juansokil/Scripts-Tesis/master/resultados/indices2.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
indices2$especializacion_pct = indices2$especializacion*100



indice_especializacion_tesis <- indices2 %>%
  select(pais, ISO2, ISO3, continente, subcontinente, esp_2004_2006, esp_2007_2009, esp_2010_2012, esp_2013_2015, esp_2016_2018 ) %>%
  gather(key = "periodo", value = "participacion", -c(pais, ISO2, ISO3, continente, subcontinente)) 




indice_especializacion_tesis$periodo <- str_replace(indice_especializacion_tesis$periodo, "esp_", "")


variable_order <- c('2004_2006',  '2007_2009',  '2010_2012',  '2013_2015',  '2016_2018')

indice_especializacion_tesis <- indice_especializacion_tesis %>%
  mutate(periodo = factor(periodo, levels = variable_order))  %>%
  arrange(pais, periodo)




indice_especializacion_tesis %>%
  filter(ISO2 %in% c('US','AR','IS'))  %>%
  ggplot(aes(periodo, participacion, group=pais, color=pais)) + geom_line()




countries <- read_delim("https://raw.githubusercontent.com/juansokil/Covid-19/master/bases/countries.txt", "\t", escape_double = FALSE, col_types = cols(name = col_skip()), trim_ws = TRUE)
#countries$country <- str_to_lower(countries$country)

indice_especializacion_tesis <- indice_especializacion_tesis %>%
  left_join(countries, by=c('ISO2'='country'))









#############CALCULAR LA IMPORTANCIA DE LOS TOPICOS############## TOTAL #########



#############CALCULAR LA IMPORTANCIA DE LOS TOPICOS############## TOTAL #########
base_total <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO3, continente, subcontinente, starts_with("Topic"))  %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.01, NA))) %>%
gather(key = "topico", value = "participacion", -c(id, Año, ISO3, continente, subcontinente)) %>%
  #filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  #filter(!is.na(participacion)) %>%
  group_by(topico) %>%
  summarize(total=mean(participacion, na.rm=TRUE))

View(base_total)


base_total_01 <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO3, continente, subcontinente, starts_with("Topic"))  %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.01, NA))) %>%
gather(key = "topico", value = "participacion", -c(id, Año, ISO3, continente, subcontinente)) %>%
  filter(Año == 2004 | Año == 2005 | Año == 2006) %>%
  #filter(Año == 2007 | Año == 2008 | Año == 2009) %>%
  #filter(Año == 2010 | Año == 2011 | Año == 2012) %>%
  #filter(Año == 2013 | Año == 2014 | Año == 2015) %>%
  #filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  #filter(!is.na(participacion)) %>%
  group_by(topico) %>%
  summarize(esp_2004_2006=mean(participacion, na.rm=TRUE))


base_total_02 <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO3, continente, subcontinente, starts_with("Topic"))  %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.01, NA))) %>%
gather(key = "topico", value = "participacion", -c(id, Año, ISO3, continente, subcontinente)) %>%
  #filter(Año == 2004 | Año == 2005 | Año == 2006) %>%
  filter(Año == 2007 | Año == 2008 | Año == 2009) %>%
  #filter(Año == 2010 | Año == 2011 | Año == 2012) %>%
  #filter(Año == 2013 | Año == 2014 | Año == 2015) %>%
  #filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  #filter(!is.na(participacion)) %>%
  group_by(topico) %>%
  summarize(esp_2007_2009=mean(participacion, na.rm=TRUE))


base_total_03 <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO3, continente, subcontinente, starts_with("Topic"))  %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.01, NA))) %>%
gather(key = "topico", value = "participacion", -c(id, Año, ISO3, continente, subcontinente)) %>%
  #filter(Año == 2004 | Año == 2005 | Año == 2006) %>%
  #filter(Año == 2007 | Año == 2008 | Año == 2009) %>%
  filter(Año == 2010 | Año == 2011 | Año == 2012) %>%
  #filter(Año == 2013 | Año == 2014 | Año == 2015) %>%
  #filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  #filter(!is.na(participacion)) %>%
  group_by(topico) %>%
  summarize(esp_2010_2012=mean(participacion, na.rm=TRUE))


base_total_04 <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO3, continente, subcontinente, starts_with("Topic"))  %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.01, NA))) %>%
gather(key = "topico", value = "participacion", -c(id, Año, ISO3, continente, subcontinente)) %>%
  #filter(Año == 2004 | Año == 2005 | Año == 2006) %>%
  #filter(Año == 2007 | Año == 2008 | Año == 2009) %>%
  #filter(Año == 2010 | Año == 2011 | Año == 2012) %>%
  filter(Año == 2013 | Año == 2014 | Año == 2015) %>%
  #filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  #filter(!is.na(participacion)) %>%
  group_by(topico) %>%
  summarize(esp_2013_2015=mean(participacion, na.rm=TRUE))


base_total_05 <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO3, continente, subcontinente, starts_with("Topic"))  %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.01, NA))) %>%
gather(key = "topico", value = "participacion", -c(id, Año, ISO3, continente, subcontinente)) %>%
  #filter(Año == 2004 | Año == 2005 | Año == 2006) %>%
  #filter(Año == 2007 | Año == 2008 | Año == 2009) %>%
  #filter(Año == 2010 | Año == 2011 | Año == 2012) %>%
  #filter(Año == 2013 | Año == 2014 | Año == 2015) %>%
  filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  #filter(!is.na(participacion)) %>%
  group_by(topico) %>%
  summarize(esp_2016_2018=mean(participacion, na.rm=TRUE))

resumen <- base_total_01 %>% left_join(base_total_02) %>% left_join(base_total_03) %>% left_join(base_total_04) %>% left_join(base_total_05)




##############GRAFICO PENDIENTE DE TOPICOS ###


vv = resumen %>%
  select(topico, esp_2004_2006, esp_2007_2009, esp_2010_2012, esp_2013_2015, esp_2016_2018) %>%
  gather(key=periodo, value=especializacion, -c(topico))

vv$periodo <- str_replace(vv$periodo,"esp_2004_2006","2004")
vv$periodo <- str_replace(vv$periodo,"esp_2007_2009","2007")
vv$periodo <- str_replace(vv$periodo,"esp_2010_2012","2010")
vv$periodo <- str_replace(vv$periodo,"esp_2013_2015","2013")
vv$periodo <- str_replace(vv$periodo,"esp_2016_2018","2016") 

vv$periodo <- as.integer(vv$periodo)



total_topicos$ISO3 <- 'TOTAL'


total_topicos <- total_topicos %>% select(ISO3, topico, periodo, especializacion)

glimpse(total_topicos)
glimpse(vv)


total <- rbind(total_topicos, vv)


View(total)



vv <- vv %>%
  mutate(
    color = case_when(
      especializacion < 0 ~ 1,
      especializacion > 0 ~ 2))



View(vv)

#write.csv(vv, 'participacion_topicos.csv')


regresion_topico1 = vv %>%
  ungroup() %>% 
  group_by(topico, color) %>% 
  do(tidy(lm(especializacion ~ periodo, data = .)))  %>%
  filter(term == 'periodo') %>%
  select(topico, color, estimate)  %>%
  rename('pendienteT'='estimate') %>%
  mutate(pendienteT=pendienteT*100) %>%
  filter (topico %in% c('Topic03',  'Topic06',  'Topic08',  'Topic09',   'Topic11',  'Topic12',  'Topic16',  
                        'Topic17',  'Topic21',  'Topic30',  'Topic32',   'Topic33',  'Topic36',  'Topic38',  
                        'Topic41',  'Topic43',  'Topic48',  'Topic52',   'Topic55',  'Topic59',  'Topic62',  
                        'Topic72',  'Topic73',  'Topic84',  'Topic90',  'Topic92',  'Topic94',  'Topic96',  'Topic97',  'Topic99')) 





regresion_topico1 %>%
  ggplot(aes(x=reorder(topico, pendienteT), y=pendienteT, color=color, fill=color)) +
  geom_bar(stat='identity') +
  #scale_fill_gradientn(colours=c("red", "green"), breaks=c(1,2)) +
  theme(legend.title=element_blank(), legend.position="bottom", axis.text.x=element_text(angle=90, hjust=1)) 





#############################














#############CALCULAR LA IMPORTANCIA DE UN TOPICO POR REGION - VERSION 2020##############
############EN ESTE CASO LA ESPECIALIZACION POR TOPICO SE AJUSTA A LA ESPECIALIZACION POR PAIS####
indicesmatch <- indices2 %>%
  select(ISO2, especializacion_pct) %>%
  mutate(especializacion_pct = especializacion_pct /100)

#####LE SUMO GLOBAL GENDER GAP####
completo <- completo %>% left_join(indicesmatch, by=c('ISO2'='ISO2'))
completo$agrup <- 1


#View(completo$especializacion_pct.x)


topicos_relevantes <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO2, continente, subcontinente, starts_with("Topic"), especializacion_pct= especializacion_pct.x)  %>%
  filter(continente %in%  c('Europa','Asia', 'America', 'Africa', 'Oceania')) %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.001, NA))) %>%
filter(especializacion_pct > 0 ) %>%
  filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  gather(key = "topico", value = "participacion", -c(id, Año, ISO2, continente, subcontinente,especializacion_pct)) %>%
  mutate(importancia_topico=(participacion * especializacion_pct)) %>%
  #filter(participacion > 0) %>%
  #filter(!is.na(participacion)) %>%
  #group_by(ISO3, topico) %>%
  group_by(ISO2, topico,continente,subcontinente) %>%
  summarize(importancia_topico=mean(importancia_topico, na.rm=TRUE)*100, participacion=mean(participacion, na.rm=TRUE)*100, especializacion_pct=mean(especializacion_pct, na.rm=TRUE)*100, cantidad=n_distinct(id))  %>%
  group_by(continente, subcontinente, ISO2, topico) %>%
  #group_by(continente) %>%
  summarize(importancia_topico=mean(importancia_topico, na.rm=TRUE), participacion=mean(participacion, na.rm=TRUE)/100, especializacion_pct=mean(especializacion_pct, na.rm=TRUE)/100, cantidad=cantidad) %>%
  mutate(importancia_topico_pond = (importancia_topico / especializacion_pct)/100) %>%
  filter (topico %in% c('Topic03',  'Topic06',  'Topic08',  'Topic09',   'Topic11',  'Topic12',  'Topic16',  
                        'Topic17',  'Topic21',  'Topic30',  'Topic32',   'Topic33',  'Topic36',  'Topic38',  
                        'Topic41',  'Topic43',  'Topic48',  'Topic52',   'Topic55',  'Topic59',  'Topic62',  
                        'Topic72',  'Topic73',  'Topic84',  'Topic90',  'Topic92',  'Topic94',  'Topic96',  'Topic97',  'Topic99'))



paises <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO2, continente, subcontinente, starts_with("Topic"))  %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.01, NA))) %>%
gather(key = "topico", value = "participacion", -c(id, Año, ISO2, continente, subcontinente)) %>%
  filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  #filter(!is.na(participacion)) %>%
  group_by(ISO2) %>%
  summarize(cantidad=n_distinct(id)) %>%
  filter(cantidad > 4)


####CONTROL######
topicos_relevantes %>%
  group_by (ISO2) %>%
  filter (ISO2 =='US') %>%
  summarize(sum(importancia_topico_pond), sum(participacion), sum(importancia_topico) , mean(especializacion_pct))

topicos_relevantes$subcontinente <- as.factor(topicos_relevantes$subcontinente)
topicos_relevantes$continente <- as.factor(topicos_relevantes$continente) 
topicos_relevantes$ISO2 <- as.factor(topicos_relevantes$ISO2) 
topicos_relevantes$pais <-  topicos_relevantes$ISO2


topicos_relevantes <- topicos_relevantes %>%
  mutate(especializacion_tematica= (especializacion_pct*participacion)*100)










#########################################################################################################
#########################################################################################################
###########################################################RANKINGS Y ESTANDARIZADOS NIVEL PAIS
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################



topicos_relevantes <- completo %>%
  select(-Titulo) %>%
  select(id, Año, ISO2, continente, subcontinente, starts_with("Topic"), especializacion_pct=especializacion_pct.x)  %>%
  filter(continente %in%  c('Europa','Asia', 'America', 'Africa', 'Oceania')) %>%
  #### REEMPLAZO LOS VALORES MENORES a 0.001 por MISSING####  
#mutate_all(funs(replace(., . <= 0.001, NA))) %>%
filter(especializacion_pct > 0 ) %>%
  filter(Año == 2016 | Año == 2017 | Año == 2018 | Año == 2019) %>%
  gather(key = "topico", value = "participacion", -c(id, Año, ISO2, continente, subcontinente,especializacion_pct)) %>%
  mutate(importancia_topico=(participacion * especializacion_pct)) %>%
  #filter(participacion > 0) %>%
  #filter(!is.na(participacion)) %>%
  #group_by(ISO3, topico) %>%
  group_by(ISO2, topico,continente,subcontinente) %>%
  summarize(importancia_topico=mean(importancia_topico, na.rm=TRUE)*100, participacion=mean(participacion, na.rm=TRUE)*100, especializacion_pct=mean(especializacion_pct, na.rm=TRUE)*100, cantidad=n_distinct(id))  %>%
  group_by(continente, subcontinente, ISO2, topico) %>%
  #group_by(continente) %>%
  summarize(importancia_topico=mean(importancia_topico, na.rm=TRUE), participacion=mean(participacion, na.rm=TRUE)/100, especializacion_pct=mean(especializacion_pct, na.rm=TRUE)/100, cantidad=cantidad) %>%
  mutate(importancia_topico_pond = (importancia_topico / especializacion_pct)/100) %>%
  filter (topico %in% c('Topic03',  'Topic06',  'Topic08',  'Topic09',   'Topic11',  'Topic12',  'Topic16',  
                        'Topic17',  'Topic21',  'Topic30',  'Topic32',   'Topic33',  'Topic36',  'Topic38',  
                        'Topic41',  'Topic43',  'Topic48',  'Topic52',   'Topic55',  'Topic59',  'Topic62',  
                        'Topic72',  'Topic73',  'Topic84',  'Topic90',  'Topic92',  'Topic94',  'Topic96',  'Topic97',  'Topic99'))




variable_order <- c('Topic96',  'Topic21',  'Topic43',  'Topic52',  'Topic03',  
                    'Topic08',  'Topic12',  'Topic84',  'Topic06',  'Topic41',  
                    'Topic73',  'Topic92',  'Topic32',  'Topic62',  'Topic17',
                    'Topic55',  'Topic72',  'Topic90',  'Topic09',  'Topic11',  
                    'Topic30',  'Topic33',  'Topic16',  'Topic48',  'Topic59',  
                    'Topic94',  'Topic97',  'Topic99',  'Topic36',  'Topic38')


manualcolors<-c('Africa Austral'='forestgreen', 
                'Africa Central'= 'red2', 
                'Africa del Norte' ='orange',
                'Africa Occidental'= 'cornflowerblue', 
                'Africa Oriental' = 'gainsboro',
                'America Central' = 'darkolivegreen4',
                'America del Norte' = 'indianred1',
                'America del Sur' = 'tan4', 
                'Asia Central' = 'darkblue',
                'Asia del Sur' = 'mediumorchid1',
                'Asia Occidental' = 'seagreen',
                'Asia Oriental' = 'yellowgreen', 
                'Australia y Nueva Zelanda' = 'lightsalmon',
                'Caribe' = 'tan3',
                'Europa del Norte' = "tan1",
                'Europa del Sur' = 'darkgray', 
                'Europa Occidental' = 'wheat4',
                'Europa Oriental' = 'chartreuse',  
                'Sudeste Asiatico' = 'moccasin')





###################################################################
####ESTANDARIZADO##A NIVEL PAIS #####################################################################
###################################################################
###################################################################



tabla <- topicos_relevantes %>%
  select(ISO2, continente, topico, especializacion_tematica=participacion) %>%
  group_by(topico)  %>%
  mutate(score=especializacion_tematica/mean(especializacion_tematica)) 

tabla <- tabla %>% left_join(paises) %>%
  filter (cantidad >= 5)

tabla$topico <- str_replace(tabla$topico, 'Topic','T')
tabla$ISO2<- as.factor(tabla$ISO2)

niveles <- tabla %>%
  select(continente, ISO2) %>%
  unique()  %>%
  ungroup() %>%
  arrange(desc(continente, ISO2))  %>%
  select(ISO2)  %>%
  unique()   %>%
  unlist()




continentcolors<-c('Africa'='gray11', 
                   'America' = 'red2',
                   'Asia' = 'yellow3',
                   'Oceania' ='forestgreen',
                   'Europa' = "cornflowerblue")


variable_order <- c('T96',  'T21',  'T43',  'T52',  'T03',  
                    'T08',  'T12',  'T84',  'T06',  'T41',  
                    'T73',  'T92',  'T32',  'T62',  'T17',
                    'T55',  'T72',  'T90',  'T09',  'T11',  
                    'T30',  'T33',  'T16',  'T48',  'T59',  
                    'T94',  'T97',  'T99',  'T36',  'T38')


continentcolors<-c('Africa'='gray11', 
                   'America' = 'red2',
                   'Asia' = 'yellow3',
                   'Oceania' ='forestgreen',
                   'Europa' = "cornflowerblue")



tabla2 <- tabla %>% left_join (valor_promedio_topicos_ultimo_periodo) %>%
  mutate(score2 = especializacion_tematica / promedio, 
         z = (score2 - mean(score2)) / sd(score2))


tabla2 <- tabla2 %>%
  mutate(
    type = case_when(
      z >= 1.64 ~ 1.64,
      z < 1.64 & z > -1.64 ~ 0,
      z <= -1.64 ~ -1.64))

tabla_paises <- read.table("C:/Users/Juan/Desktop/Materiales TESIS PARA APLICACION/parahacerlosgraficosfeosporpais.csv", header = TRUE, sep = "\t", row.names = 1)


#glimpse(PUNTAJES_Z_ANEXO)

#write.table(tabla_completa, file = "C:/Users/Juan/Desktop/Materiales TESIS PARA APLICACION/PUNTAJES_Z_ANEXO3.txt",quote=F, fileEncoding="iso-8859-1")


View(tabla_paises)



matriz <- tabla_paises %>%  
  arrange(continente, ISO2)  %>%
  mutate(ISO2=factor(ISO2, levels=niveles)) %>%
  mutate(topico = fct_rev(factor(topico, levels = variable_order))) %>%
  select(ISO2, continente, topico, z=z)

tabla_completa <- matriz %>% pivot_wider(names_from = topico, values_from = z)%>% column_to_rownames('ISO2') %>% 
  #  filter(continente %in% c('America')) %>% 
  select(T96,T21,T43,T52,T03,T08,T12,T84,T06,T41,T73,T92,T32,T62,T17,T55,T72,T90,T09,T11,T30,T33,T16,T48,T59,T94,T97,T99,T36,T38)

View(tabla_completa)

write.table(tabla_completa, file = "C:/Users/Juan/Desktop/Materiales TESIS PARA APLICACION/PUNTAJES_Z_ANEXO_2.csv", sep = "\t", qmethod = "double")

