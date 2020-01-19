### Path
wd <- '/home/stagiaire/Emotion3/'
setwd(wd)

### Libraries
library(gdata)

### All subsamples in analyses should be in the sample bank
### The converse does not hold as the sample bank can include subsamples being stored, in processing, etc.

### Read the data
### SAMPLE BANK
dataprep_from_xls <- read.xls("./XLS/Data_Prep.xls",sheet = 'Data_Prep', header=TRUE,fileEncoding="latin1",dec='.')
dataprep_from_csv <- read.csv('./CSV/data_prep/Data_Prep.csv',sep='\t',header = TRUE)

### Checking absence of subsample identifiers from Hg analyses in Dataprep
#hg <- read.xls("./XLS/Data_Contaminants.xls",sheet = 'hg', header=TRUE,fileEncoding="latin1",dec='.')
hg <- read.csv('./CSV/analysis/Data_Contaminants_HG.csv',sep='\t',header=T)
hg_merged_with_dataprep <- merge(hg,dataprep_from_csv,by.x='subsample_identifier',by.y='subsample_identifier',all.x=T,suffixes = c('_analysis','_dataprep'))
missing_hg_subsamples_from_dataprep <- unique(hg_merged_with_dataprep[is.na(hg_merged_with_dataprep$fish_identifier_dataprep),c('fish_identifier_analysis','sample_identifier_analysis','subsample_identifier')])
missing_hg_subsamples_from_dataprep

### Save the HG result
write.xlsx(missing_hg_subsamples_from_dataprep,file=paste('./CSV/analysis/subsamplesInHgButNotDataPrep',Sys.Date(),".xlsx",sep=""),row.names = FALSE)

### Checking absence of subsample identifiers from TM analyses in Dataprep
tm <- read.csv('./CSV/analysis/Data_Contaminants_TM.csv',sep='\t',header=T)
tm_merged_with_dataprep <- merge(tm,dataprep_from_csv,by.x='subsample_identifier',by.y='subsample_identifier',all.x=T,suffixes = c('_analysis','_dataprep'))
missing_tm_subsamples_from_dataprep = unique(tm_merged_with_dataprep[is.na(tm_merged_with_dataprep$fish_identifier_dataprep),c('fish_identifier_analysis','sample_identifier_analysis','subsample_identifier')])
missing_tm_subsamples_from_dataprep

### Save the TM result
write.xlsx(missing_tm_subsamples_from_dataprep,file=paste('./CSV/analysis/subsamplesInTMButNotDataPrep',Sys.Date(),".xlsx",sep=""),row.names = FALSE)

### Checking absence of subsample identifiers from LC analyses in Dataprep
lc <- read.csv('./CSV/analysis/Data_LipidClasses.csv',sep='\t',header=T)
lc_merged_with_dataprep = merge(lc,dataprep_from_csv,by.x='subsample_identifier',by.y='subsample_identifier',all.x=T,suffixes = c('_analysis','_dataprep'))
missing_lc_subsamples_from_dataprep <- unique(lc_merged_with_dataprep[is.na(lc_merged_with_dataprep$fish_identifier_dataprep),c('fish_identifier_analysis','sample_identifier_analysis','subsample_identifier')])
missing_lc_subsamples_from_dataprep

### Save the LC result
write.xlsx(missing_lc_subsamples_from_dataprep,file=paste('./CSV/analysis/subsamplesInLCButNotDataPrep',Sys.Date(),".xlsx",sep=""),row.names = FALSE)

### Checking absence of subsample identifiers from SI analyses in Dataprep
si <- read.csv('./CSV/analysis/Data_StableIsotopes.csv',sep='\t',header=T)
si_merged_with_dataprep <- merge(si,dataprep_from_csv,by.x='subsample_identifier',by.y='subsample_identifier',all.x=T,suffixes = c('_analysis','_dataprep'))
missing_si_subsamples_from_dataprep <- unique(si_merged_with_dataprep[is.na(si_merged_with_dataprep$fish_identifier_dataprep),c('fish_identifier_analysis','sample_identifier_analysis','subsample_identifier')])
missing_si_subsamples_from_dataprep

### Save the SI result
write.xlsx(missing_si_subsamples_from_dataprep,file=paste('./CSV/analysis/subsamplesInSiButNotDataPrep',Sys.Date(),".xlsx",sep=""),row.names = FALSE)

### Checking absence of subsample identifiers from FA analyses in Dataprep
fa <- read.csv('./CSV/analysis/Data_FattyAcids.csv',sep='\t',header=T)
fa_merged_with_dataprep <- merge(fa,dataprep_from_csv,by.x='subsample_identifier',by.y='subsample_identifier',all.x=T,suffixes = c('_analysis','_dataprep'))
missing_fa_subsamples_from_dataprep <- unique(fa_merged_with_dataprep[is.na(fa_merged_with_dataprep$fish_identifier_dataprep),c('fish_identifier_analysis','sample_identifier_analysis','subsample_identifier')])
missing_fa_subsamples_from_dataprep

### Save the FA result
write.xlsx(pipo,file=paste('subsamplesInFAButNotDataPrep',Sys.Date(),".xlsx",sep=""),row.names = FALSE)

