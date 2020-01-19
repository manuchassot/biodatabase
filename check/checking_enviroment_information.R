### Path
wd <- '/home/stagiaire/Emotion3/CSV/fishing_environment/'
setwd(wd)

### Read the data
environment <- read.csv('./Data_Sampling_environment.csv',sep='\t',header = TRUE)

### Check all fish where the information on fishing environment is missing (geom_text) and refers to Seychelles EEZ without mention of Mahé Plateau
environment_to_check <- environment[environment$remarks_fishing %in% c("Fish caught by Ton John's boat; fishing location = SYC EEZ","Fishing_gear is specific to this species and corresponds to tangle nets; fishing location = SYC EEZ","fishing location = SYC EEZ"),]

write.table(environment_to_check,file = './environment_to_check_temp.csv',sep='\t',row.names = F)