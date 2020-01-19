### Path
wd <- '/home/stagiaire/Emotion3/CSV/data_prep'
setwd(wd)

### Libraries
library(openxlsx)

### Read the data
#dataprepxls <- read.csv('./Data_Prep_from_xls.csv',sep=';',header = TRUE)
dataprep <- read.csv('./Data_Prep.csv',sep='\t',header = TRUE)

## Find samples missing from dataprep
#toto= merge(dataprepxls,dataprep,by='subsample_identifier',all.x=T)
#toto[is.na(toto$sample_identifier.y),]

### Duplicates of subsample identifiers
list_duplicate_subsamples_identifiers <- dataprep[duplicated(dataprep$subsample_identifier),c('fish_identifier','sample_identifier','subsample_identifier')]
list_duplicate_subsamples_identifiers
write.table(list_duplicate_subsamples_identifiers,file=paste('duplicates_subsamples_',Sys.Date(),".csv",sep=""),sep = '\t',row.names = FALSE)

### Remove duplicates
#dataprep <- dataprep[!duplicated(dataprep$subsample_identifier),]
#write.table(dataprep,file='Data_Prep.csv',row.names = FALSE,sep='\t',na = '')

### Check consistency between fish identifiers in FISH and DATA_PREP
fish <- read.csv('../fish/Data_Sampling_fish.csv',sep='\t',header = TRUE)

### Duplicates
nrow(fish)
length(unique(fish$fish_identifier))

toto = merge(dataprep,fish,by.x='fish_identifier',by.y='fish_identifier',all.x=T)
data.frame(fish_identifier=unique(toto[is.na(toto$species_code_fao),'fish_identifier']))
write.table(data.frame(fish_identifier=unique(toto[is.na(toto$species_code_fao),'fish_identifier'])),file=paste('fish_identifierInDataPrepButNotInFish',Sys.Date(),".csv",sep=""),sep = '\t',row.names = FALSE)

### trick to remove the fish from Dataprep to enable loading
#pipo = data.frame(fish_identifier=unique(toto[is.na(toto$species_code_fao),'fish_identifier']))
#dataprep <- dataprep[!(dataprep$fish_identifier %in% pipo$fish_identifier),]
#write.table(dataprep,file='Data_Prep.csv',row.names = FALSE,sep='\t',na='')
