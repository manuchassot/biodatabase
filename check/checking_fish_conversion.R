### Path
wd <- '/home/stagiaire/Emotion3/CSV/fish/'
setwd(wd)

### Libraries
library(openxlsx)

fish_temp <- read.csv('fish_temp.csv',sep=';',header=TRUE)
fish <- read.csv("Data_Sampling_fish.csv",sep='\t',header=TRUE)
toto=merge(fish,fish_temp,by.x='fish_identifier',by.y='fish_identifier',all.y=TRUE)
toto[is.na(toto$code_sampling_platform.x),]
