###Carga de librerias###

library(rlang)
library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)
#library(HH)
library(ggplot2)
library(dunn.test)
library(rworldmap)
library(scales)
#install.packages("devtools")
library(devtools)
#devtools::install_github("rensa/ggflags") # Instalar por primera vez
library(ggflags) # Para geom_flags
#install.packages("countrycode")
library(countrycode)  # Para obtener codigos de paises
library(ggrepel)
library(RColorBrewer)
library(GGally)
library(broom)
library(MASS)
library(ggpubr)



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
                'Melanesia' = 'seagreen1',
                'Micronesia' = 'black',
                'Polinesia' = 'navy',
                'Sudeste Asiatico' = 'moccasin'
                )
                


continentcolors<-c('Africa'='gray11', 
                'America' = 'red2',
                'Asia' = 'yellow3',
                'Oceania' ='forestgreen',
                'Europa' = "cornflowerblue")



############################### CARGA DATOS##############################################

indices2 <- read_delim("https://raw.githubusercontent.com/juansokil/Scripts-Tesis/master/resultados/total_indices.txt", "\t", escape_double = FALSE, trim_ws = TRUE)
indices2$especializacion_pct = indices2$especializacion*100

totales <- read_delim("https://raw.githubusercontent.com/juansokil/Scripts-Tesis/master/resultados/totales.csv", ";", escape_double = FALSE, trim_ws = TRUE)



#############################REGRESIONES#########################
lm.genero <- lm(`Estudios de G<e9>nero` ~ year, data=totales)
sm <- summary(lm.genero)
anova(lm.genero)
# Function for Root Mean Squared Error
RMSE <- function(error) { sqrt(mean(error^2)) }
RMSE(sm$residuals)
# Function for Mean Absolute Error
mae <- function(error) { mean(abs(error)) }
mae(sm$residuals)

### CODIGOS ISO####
countrycode <-  as.data.frame(countrycode::codelist) %>% 
  as_tibble() %>% 
  select(pais = country.name.en, code = ecb )  %>% 
  filter(!is.na(code)) %>% 
  print(n = Inf)


#########################MAPA GENERAL########################


mapped_data <- joinCountryData2Map(indices2, joinCode = "ISO3", nameJoinColumn = "ISO3")
#mymap <- fortify(mapped_data)

par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")
mapParams <-mapCountryData(mapped_data, nameColumnToPlot="continente", colourPalette=continentcolors, 
                           mapTitle = "",  catMethod = "categorical",
                           missingCountryCol="white", oceanCol="lightblue", addLegend=TRUE)
do.call( addMapLegend, c(mapParams, legendWidth=0.5, legendMar = 3))


mapped_data <- joinCountryData2Map(indices2, joinCode = "ISO3", nameJoinColumn = "ISO3")
mapped_data2 <- subset (mapped_data, !is.na(subcontinente))


#mymap <- fortify(mapped_data)
dev.off()
par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")
mapParams <-mapCountryData(mapped_data2, nameColumnToPlot="subcontinente", colourPalette=manualcolors, 
                           mapTitle = "",  catMethod = "categorical",
                           missingCountryCol="white", oceanCol="lightblue", addLegend=TRUE)
do.call( addMapLegend, c(mapParams, legendWidth=0.5, legendMar = 3))





#########################ANALISIS EXPLORATORIO DE ESPECIALIZACIÓN########################

######MAPAS#####
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
indice_gdi <- indices2 %>% select (country, ISO2, ISO3, continente, continente_en, subcontinente, subcontinente_en, especializacion, Global_Index)

###Transformo la base
indice_gathered_1 <- indice_gdi %>%
  gather(key = Global_index, value = measurement, -c(country, ISO2, ISO3, continente, continente_en, subcontinente, subcontinente_en, especializacion) )

indice_gathered_1_head <- indice_gathered_1 %>% arrange(desc(especializacion))
indice_gathered_1_head <- head(indice_gathered_1_head,92)


###ESPECIALIZACION ORDENADA POR PAIS###
indice_gathered_1_head %>% 
  arrange(desc(measurement)) %>%
  mutate(code = tolower(ISO2)) %>%
  #filter(!is.na(measurement)) %>%
  ggplot(aes(x = reorder(country, -especializacion), y=especializacion)) +
  geom_bar(stat='identity', aes(fill=continente)) +
  #geom_text(aes(label = country)) +
  geom_flag(aes(country = code),size = 10 ) +
  #scale_size(range = c(2, 12)) +
  coord_flip() 

###BOXPLOT ESPECIALIZACION###
indice_gathered_1_head %>%
  filter(continente_en %in%  c('Africa', 'Americas', 'Asia', 'Europe')) %>%
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




####TEST DE HIPOTESIS####
indice_gathered_1_head %>%
  group_by(continente) %>%
  summarize(mean(especializacion), n())

###EXCLUYO OCEANIA PORQUE TIENE MENOS DE 3 CASOS####
indice_gathered_1_head_gathered <- 
  indice_gathered_1_head %>%
  filter(continente %in%  c('Africa', 'Americas', 'Asia', 'Europe')) 

indice_gathered_1_head_gathered %>%
  summarise(statistic = shapiro.test(especializacion)$statistic,
            p.value = shapiro.test(especializacion)$p.value)

#################SUPUESTOS######################

#####Normalidad#####
indice_gathered_1_head_gathered %>%
  group_by(continente) %>%
  summarise(statistic = shapiro.test(especializacion)$statistic,
            p.value = shapiro.test(especializacion)$p.value)

ggplot(indice_gathered_1_head_gathered, aes(x=especializacion)) + 
  geom_histogram(aes(y=..density..), colour="black", fill="white")+
  facet_wrap(~continente) +
  geom_density(alpha=.2, fill="#FF6666") 


#####Homocedasticidad#####
bartlett.test(especializacion ~ continente, data = indice_gathered_1_head_gathered)
fligner.test(especializacion ~ continente, data = indice_gathered_1_head_gathered)

# Homogeneity of Variance Plot
hov(especializacion ~ continente, data = indice_gathered_1_head_gathered)
hovPlot(especializacion ~ continente, data = indice_gathered_1_head_gathered)

###Una vez realizadas las pruebas, se ve que test se puede aplicar###
indice_gathered_1_head_gathered <- indice_gathered_1_head_gathered %>%
filter(subcontinente_en %in% c('Channel Islands', 'Eastern Africa', 'Eastern Asia', 'Eastern Europe', 'Northern Africa', 'South-eastern Asia', 'South America', 'Southern Asia', 'Southern Europe',  'Western Asia', 'Western Europe')) 

###ANOVA en el caso que supere ambas pruebas
model1<- aov(indice_gathered_1_head_gathered$especializacion~indice_gathered_1_head_gathered$subcontinente)
summary(model1)
plot(model1)

###Post hoc que nos permite ver la diferencia entre que grupos# - SIRVE PARA ANOVA##

tuk<-TukeyHSD(model1, conf.level = 0.95)
psig=as.numeric(apply(tuk$`indice_gathered_1_head_gathered$subcontinente`[,2:3],1,prod)>=0)+1
op=par(mar=c(4.2,9,3.8,2))
plot(tuk,col=psig,yaxt="n")
for (j in 1:length(psig)){
  axis(2,at=j,labels=rownames(tuk$`indice_gathered_1_head_gathered$subcontinente`)[length(psig)-j+1],
       las=1,cex.axis=.55,col.axis=psig[length(psig)-j+1])
}
par(op)



###Sino supera la homocedasticidad y la normalidad se pueden aplicar cualquiera de estas dos pruebas###
oneway.test(indice_gathered_1_head_gathered$especializacion~indice_gathered_1_head_gathered$continente)
kruskal.test(indice_gathered_1_head_gathered$especializacion~indice_gathered_1_head_gathered$continente)

###Post hoc que nos permite ver la diferencia entre que grupos# - SIRVE PARA KRUSKAL TEST##
dt <- dunn.test(indice_gathered_1_head_gathered$especializacion, indice_gathered_1_head_gathered$continente)
dunnTest <- as.data.frame(dt)


#########################ANALISIS EXPLORATORIO DE GLOBAL GENDER GAP########################


mapped_data <- joinCountryData2Map(indices2, joinCode = "ISO2", nameJoinColumn = "ISO2")
mapped_data
par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")
mapParams <-mapCountryData(mapped_data, nameColumnToPlot="Global_Index", colourPalette="topo", 
                           mapTitle = "", 
                           missingCountryCol="white", oceanCol="lightblue", addLegend=FALSE
                           #, mapRegion='eurasia'
)
do.call( addMapLegend, c(mapParams, legendWidth=0.5, legendMar = 3))



global_gender_gap <- indices2 %>%
  select (country, ISO2, ISO3, continente, subcontinente, Global_Index, Economic_participation_and_opportunity, Educational_attainment, Health_and_survival, Political_Empowerment)


global_gender_gap %>% group_by(continente) %>% summarize (Global_Index=mean(Global_Index, na.rm=TRUE),
                                                          Economic_participation_and_opportunity=mean(Economic_participation_and_opportunity, na.rm=TRUE),
                                                          Educational_attainment=mean(Educational_attainment, na.rm=TRUE),
                                                          Health_and_survival=mean(Health_and_survival, na.rm=TRUE),
                                                          Political_Empowerment=mean(Political_Empowerment, na.rm=TRUE))


global_gender_gap_totales <- global_gender_gap %>% summarize (Global_Index=mean(Global_Index, na.rm=TRUE),
                                                              Economic_participation_and_opportunity=mean(Economic_participation_and_opportunity, na.rm=TRUE),
                                                              Educational_attainment=mean(Educational_attainment, na.rm=TRUE),
                                                              Health_and_survival=mean(Health_and_survival, na.rm=TRUE),
                                                              Political_Empowerment=mean(Political_Empowerment, na.rm=TRUE))



global_gender_gap_gathered <- 
  global_gender_gap %>%
  gather(key = index, value = measurement, -c(country, ISO2, ISO3, continente, subcontinente))   %>% 
  mutate(code = tolower(ISO2))



global_gender_gap_gathered$index <- factor(global_gender_gap_gathered$index, 
                                           levels = c("Political_Empowerment",
                                                      "Health_and_survival",
                                                      "Educational_attainment", 
                                                      "Economic_participation_and_opportunity", 
                                                      "Global_Index"))

global_gender_gap_gathered %>%
  filter(continente %in%  c('Africa', 'Americas', 'Asia', 'Europe','Oceania')) %>%
  ggplot(aes(x=index, y=measurement,  label=ISO2, color=continente)) +
  geom_point(size=12, shape=108) +
  coord_flip() +
  theme(legend.position = "right")



reestructurada = global_gender_gap %>% arrange(continente) %>% group_by(continente, subcontinente) %>% filter (!is.na(subcontinente)) %>%summarize (Global_Index=mean(Global_Index, na.rm=TRUE),
                                                          Economic_participation_and_opportunity=mean(Economic_participation_and_opportunity, na.rm=TRUE),
                                                          Educational_attainment=mean(Educational_attainment, na.rm=TRUE),
                                                          Health_and_survival=mean(Health_and_survival, na.rm=TRUE),
                                                          Political_Empowerment=mean(Political_Empowerment, na.rm=TRUE)) 
  
reestructurada$subcontinente <- factor(reestructurada$subcontinente, 
                                           levels = c('Eastern Africa',
                                                      'Middle Africa',
                                                      'Northern Africa',
                                                      'Southern Africa',
                                                      'Western Africa',
                                                      'Caribbean',
                                                      'Central America',
                                                      'Northern America',
                                                      'South America',
                                                      'Central Asia',
                                                      'Eastern Asia',
                                                      'South-eastern Asia',
                                                      'Southern Asia',
                                                      'Western Asia',
                                                      'Channel Islands',
                                                      'Eastern Europe',
                                                      'Southern Europe',
                                                      'Western Europe',
                                                      'Australia and New Zealand',
                                                      'Melanesia'))





mapped_data <- joinCountryData2Map(indices2, joinCode = "ISO2", nameJoinColumn = "ISO2")
mapped_data
par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")
mapParams <-mapCountryData(mapped_data, nameColumnToPlot="Global_Index", colourPalette="topo", 
                           mapTitle = "", 
                           missingCountryCol="white", oceanCol="lightblue", addLegend=FALSE
                           #, mapRegion='eurasia'
)
do.call( addMapLegend, c(mapParams, legendWidth=0.5, legendMar = 3))



global_gender_gap <- indices2 %>%
  select (country, ISO2, ISO3, continente_en, continente, subcontinente_en, subcontinente, Global_Index, Economic_participation_and_opportunity, Educational_attainment, Health_and_survival, Political_Empowerment)


global_gender_gap %>% group_by(continente) %>% summarize (Global_Index=mean(Global_Index, na.rm=TRUE),
                                                          Economic_participation_and_opportunity=mean(Economic_participation_and_opportunity, na.rm=TRUE),
                                                          Educational_attainment=mean(Educational_attainment, na.rm=TRUE),
                                                          Health_and_survival=mean(Health_and_survival, na.rm=TRUE),
                                                          Political_Empowerment=mean(Political_Empowerment, na.rm=TRUE))


global_gender_gap_totales <- global_gender_gap %>% summarize (Global_Index=mean(Global_Index, na.rm=TRUE),
                                                              Economic_participation_and_opportunity=mean(Economic_participation_and_opportunity, na.rm=TRUE),
                                                              Educational_attainment=mean(Educational_attainment, na.rm=TRUE),
                                                              Health_and_survival=mean(Health_and_survival, na.rm=TRUE),
                                                              Political_Empowerment=mean(Political_Empowerment, na.rm=TRUE))



global_gender_gap_gathered <- 
  global_gender_gap %>%
  gather(key = index, value = measurement, -c(country, ISO2, ISO3, continente, continente_en, subcontinente, subcontinente_en))   %>% 
  mutate(code = tolower(ISO2))



global_gender_gap_gathered$index <- factor(global_gender_gap_gathered$index, 
                                           levels = c("Political_Empowerment",
                                                      "Health_and_survival",
                                                      "Educational_attainment", 
                                                      "Economic_participation_and_opportunity", 
                                                      "Global_Index"))

global_gender_gap_gathered <- global_gender_gap_gathered %>% mutate(indices = case_when (index =="Political_Empowerment" ~ 'Empoderamiento Político',
                            index =="Health_and_survival" ~ 'Salud y Supervivencia',
                            index =="Educational_attainment" ~ 'Logros Educativos',
                            index =="Economic_participation_and_opportunity" ~ 'Participación Economica y Oportunidades',
                            index =="Global_Index" ~ 'Global Gender Gap'))



global_gender_gap_gathered$indices <- factor(global_gender_gap_gathered$indices, 
                                           levels = c("Empoderamiento Político",
                                                      "Salud y Supervivencia",
                                                      "Logros Educativos", 
                                                      "Participación Economica y Oportunidades", 
                                                      "Global Gender Gap"))


global_gender_gap_gathered %>%
  filter(continente_en %in%  c('Africa', 'Americas', 'Asia', 'Europe','Oceania')) %>%
  ggplot(aes(x=indices, y=measurement,  label=ISO2, color=continente)) +
  geom_point(size=8, shape=108) +
  coord_flip() +
  theme(legend.position = "right")


reestructurada = global_gender_gap %>% arrange(continente) %>% group_by(continente, continente_en, subcontinente, subcontinente_en) %>% filter (!is.na(subcontinente)) %>%
                                               summarize (Global_Index=mean(Global_Index, na.rm=TRUE),
                                                          Economic_participation_and_opportunity=mean(Economic_participation_and_opportunity, na.rm=TRUE),
                                                          Educational_attainment=mean(Educational_attainment, na.rm=TRUE),
                                                          Health_and_survival=mean(Health_and_survival, na.rm=TRUE),
                                                          Political_Empowerment=mean(Political_Empowerment, na.rm=TRUE)) 
  
reestructurada$subcontinente_en <- factor(reestructurada$subcontinente_en, 
                                           levels = c('Eastern Africa',
                                                      'Middle Africa',
                                                      'Northern Africa',
                                                      'Southern Africa',
                                                      'Western Africa',
                                                      'Caribbean',
                                                      'Central America',
                                                      'Northern America',
                                                      'South America',
                                                      'Central Asia',
                                                      'Eastern Asia',
                                                      'South-eastern Asia',
                                                      'Southern Asia',
                                                      'Western Asia',
                                                      'Channel Islands',
                                                      'Eastern Europe',
                                                      'Southern Europe',
                                                      'Western Europe',
                                                      'Australia and New Zealand',
                                                      'Melanesia'))




reestructurada_gathered <- 
  reestructurada %>%
  gather(key = index, value = measurement, -c(continente, continente_en, subcontinente, subcontinente_en))  


reestructurada_gathered <- reestructurada_gathered %>% mutate(indices = case_when (index =="Political_Empowerment" ~ 'Empoderamiento Político',
                                                                                         index =="Health_and_survival" ~ 'Salud y Supervivencia',
                                                                                         index =="Educational_attainment" ~ 'Logros Educativos',
                                                                                         index =="Economic_participation_and_opportunity" ~ 'Participación Economica y Oportunidades',
                                                                                         index =="Global_Index" ~ 'Global Gender Gap'))



reestructurada_gathered$indices <- factor(reestructurada_gathered$indices, 
                                             levels = c("Empoderamiento Político",
                                                        "Salud y Supervivencia",
                                                        "Logros Educativos", 
                                                        "Participación Economica y Oportunidades", 
                                                        "Global Gender Gap"))



reestructurada_gathered %>%
  filter(continente_en %in%  c('Africa', 'Americas', 'Asia', 'Europe','Oceania')) %>%
  filter(subcontinente_en %in% c('Caribbean', 'Central America', 'Central Asia', 'Channel Islands', 'Eastern Africa', 'Eastern Asia', 'Eastern Europe', 'Northern Africa', 'Northern America', 'South-eastern Asia', 'South America', 'Southern Africa', 'Southern Asia', 'Southern Europe', 'Western Africa', 'Western Asia', 'Western Europe')) %>%
  #filter(!index %in%  c('Global_Index')) %>%
  ggplot(aes(x=indices, y=measurement, color=subcontinente)) +
  #geom_point(size=4, shape =22)  +
  geom_jitter(size=6)  +
  geom_boxplot(fill = "#4271AE", colour = "#1F3552", alpha = 0.7) +
  coord_flip()


