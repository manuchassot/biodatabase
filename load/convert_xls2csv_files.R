### Paths
wd <- '/home/stagiaire/Emotion3/'
setwd(wd)

### Libraries
library(gdata,quietly = TRUE)    #read.xls
library(openxlsx)
#options(java.parameters = "-Xmx4024m")
#library(XLConnect,quietly = TRUE)   #loadWorkbook and readWorksheet
#library(readxl)  #test

### 1- Amino-acids -----
amino_acids <- read.xls("./XLS/Data_AminoAcids.xls",sheet = 'aminoacids', header=TRUE,fileEncoding="latin1",dec='.')

### Remove columns with only NAs
#indic.only.na <- (apply(amino_acids,2,function(x) sum(is.na(x))) == nrow(amino_acids))
#names(amino_acids)[indic.only.na]
#amino_acids <- amino_acids[,!indic.only.na]
### Write the CSV file
write.table(amino_acids,file='./CSV/analysis/Data_AminoAcids.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 2- Mercury ----
hg <- read.xls("./XLS/Data_Contaminants.xls",sheet = 'hg', header=TRUE,fileEncoding="latin1",dec='.')
#hg <- read.xlsx("./XLS/Data_Contaminants.xlsx",sheet = 'hg')

### Remove columns with only NAs
indic.only.na <- (apply(hg,2,function(x) sum(is.na(x))) == nrow(hg))
names(hg)[indic.only.na]
hg <- hg[,!indic.only.na]

### Write the CSV file
write.table(hg,file='./CSV/analysis/Data_Contaminants_HG.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 3- Metallic tracers ---- 
### other than mercury
tm <- read.xls("./XLS/Data_Contaminants.xls",sheet = 'tm', header=TRUE,fileEncoding="latin1",dec='.')
#tm <- read.xlsx("./XLS/Data_Contaminants.xlsx",sheet = 'tm')

### Remove columns with only NAs
indic.only.na <- (apply(tm,2,function(x) sum(is.na(x))) == nrow(tm))
names(tm)[indic.only.na]
tm <- tm[,!indic.only.na]

### Write the CSV file
write.table(tm,file='./CSV/analysis/Data_Contaminants_TM.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 4- PCBs ----
#pcbs <- read.xls("./XLS/Data_Contaminants.xls",sheet = 'pcb', header=TRUE,fileEncoding="latin1",dec='.')
pcbs <- read.xlsx("./XLS/Data_Contaminants.xlsx",sheet = 'pcb')

### Remove columns with only NAs
#indic.only.na <- (apply(pcbs,2,function(x) sum(is.na(x))) == nrow(pcbs))
#names(pcbs)[indic.only.na]
#pcbs <- pcbs[,!indic.only.na]

### Write the CSV file
write.table(pcbs,file='./CSV/analysis/Data_Contaminants_PCBDEOC.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 5- Dioxin ----
#dioxin <- read.xls("./XLS/Data_Contaminants.xls",sheet = 'dioxin', header=TRUE,fileEncoding="latin1",dec='.')
dioxin <- read.xlsx("./XLS/Data_Contaminants.xlsx",sheet = 'dioxin')

# Remove empty columns linked to the reading of the xls file
#indic.empty.columns <- grep("X",names(dioxin))
#names(dioxin)[indic.empty.columns]
#dioxin <- dioxin[,1:(min(indic.empty.columns)-1)]

write.table(dioxin,file='./CSV/analysis/Data_Contaminants_Dioxin.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 6- Musk ----
#musk <- read.xls("./XLS/Data_Contaminants.xls",sheet = 'musk', header=TRUE,fileEncoding="latin1",dec='.')
musk <- read.xlsx("./XLS/Data_Contaminants.xlsx",sheet = 'musk')

# Remove empty columns linked to the reading of the xls file
#indic.empty.columns <- grep("X",names(musk))
#names(musk)[indic.empty.columns]
#musk <- musk[,1:(min(indic.empty.columns)-1)]

write.table(musk,file='./CSV/analysis/Data_Contaminants_Musk.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 7- Fatmeter ----
fatmeter <- read.xls("./XLS/Data_Fatmeter.xls",sheet = 'fatmeter', header=TRUE,fileEncoding="latin1")
write.table(fatmeter,file='./CSV/analysis/Data_Fatmeter.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 8- Fatty acids ----
#fatty_acids <- read.xls("./XLS/Data_FattyAcids.xls",sheet = 'fattyacids', header=TRUE,fileEncoding="latin1",dec='.')
fatty_acids <- read.xlsx("./XLS/Data_FattyAcids.xlsx",sheet = 'fattyacids')

# Remove empty columns linked to the reading of the xls file
#indic.empty.columns <- grep("X",names(fatty_acids))
#names(fatty_acids)[indic.empty.columns]
#fatty_acids <- fatty_acids[,1:(min(indic.empty.columns)-1)]

### Remove columns with only NAs
#indic.only.na <- (apply(fatty_acids,2,function(x) sum(is.na(x))) == nrow(fatty_acids))
#names(fatty_acids)[indic.only.na]
#fatty_acids <- fatty_acids[,!indic.only.na]

### Write CSV file
write.table(fatty_acids,file='./CSV/analysis/Data_FattyAcids.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 9- Lipid classes ----
#lipid_classes <- read.xls("./XLS/Data_LipidClasses.xls",sheet = 'lipidclasses', header=TRUE,fileEncoding="latin1",dec='.')
lipid_classes <- read.xlsx("./XLS/Data_LipidClasses.xlsx",sheet = 'lipidclasses')

### Remove columns with only NAs
#indic.only.na <- (apply(lipid_classes,2,function(x) sum(is.na(x))) == nrow(lipid_classes))
#names(lipid_classes)[indic.only.na]
#lipid_classes <- lipid_classes[,!indic.only.na]

### Remove 3 columns: volume_unit, lipidclasses_concentration_unit, analysis_mass_unit
#columns.to.remove <- c('volume_unit','lipidclasses_concentration_unit','analysis_mass_unit')
#indic.columns.to.remove <- names(lipid_classes) %in% columns.to.remove
#lipid_classes <- lipid_classes[,!indic.columns.to.remove]

### Write CSV file
write.table(lipid_classes,file='./CSV/analysis/Data_LipidClasses.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 10- Otoliths measurements ----
otoliths_morpho <- read.xls("./XLS/Data_Otoliths.xls",sheet = 'otolith_morphometrics', header=TRUE,fileEncoding="latin1",dec='.')
### Remove columns with only NAs
indic.only.na <- (apply(otoliths_morpho,2,function(x) sum(is.na(x))) == nrow(otoliths_morpho))
names(otoliths_morpho)[indic.only.na]
#otoliths_morpho <- otoliths_morpho[,!indic.only.na]
### Write CSV file
write.table(otoliths_morpho,file='./CSV/analysis/Data_Otoliths_morpho.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 11- Otoliths increments ----
otoliths_inc <- read.xls("./XLS/Data_Otoliths.xls",sheet = 'otolith_increment_counts', header=TRUE,fileEncoding="latin1",dec='.')
### Remove columns with only NAs
indic.only.na <- (apply(otoliths_inc,2,function(x) sum(is.na(x))) == nrow(otoliths_inc))
names(otoliths_inc)[indic.only.na]
#otoliths_inc <- otoliths_inc[,!indic.only.na]
### Write CSV file
write.table(otoliths_inc,file='./CSV/analysis/Data_Otoliths_counts.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 12- Proteins ----
proteins <- read.xls("./XLS/Data_Proteins.xls",sheet = 'proteins', header=TRUE,fileEncoding="latin1",dec='.')
### Remove columns with only NAs
indic.only.na <- (apply(proteins,2,function(x) sum(is.na(x))) == nrow(proteins))
names(proteins)[indic.only.na]
#proteins <- proteins[,!indic.only.na]
### Write CSV file
write.table(proteins,file='./CSV/analysis/Data_Proteins.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 13- Reproduction: maturity stage ----
repro_mat <- read.xls("./XLS/Data_Reproduction.xls",sheet = 'reproduction', header=TRUE,fileEncoding="latin1",dec='.')
### Remove columns with only NAs
indic.only.na <- (apply(repro_mat,2,function(x) sum(is.na(x))) == nrow(repro_mat))
names(repro_mat)[indic.only.na]
#repro_mat <- repro_mat[,!indic.only.na]
### Write CSV file
write.table(repro_mat,file='./CSV/analysis/Data_Reproduction_repro.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 14- Reproduction: Fecundity ----
repro_fec <- read.xls("./XLS/Data_Reproduction.xls",sheet = 'fecundity', header=TRUE,fileEncoding="latin1",dec='.')
### Remove columns with only NAs
#indic.only.na <- (apply(repro_fec,2,function(x) sum(is.na(x))) == nrow(repro_fec))
#names(repro_fec)[indic.only.na]
#repro_fec <- repro_fec[,!indic.only.na]
### Write CSV file
write.table(repro_fec,file='./CSV/analysis/Data_Reproduction_fecundity.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 15- Stable isotopes ----
#stable_isotopes <- read.xls("./XLS/Data_StableIsotopes.xls",sheet = 'stableisotopes', header=TRUE,fileEncoding="latin1",dec='.')
stable_isotopes <- read.xlsx("./XLS/Data_StableIsotopes.xlsx")

### Remove columns with only NAs
# indic.only.na <- (apply(stable_isotopes,2,function(x) sum(is.na(x))) == nrow(stable_isotopes))
# names(stable_isotopes)[indic.only.na]
# stable_isotopes <- stable_isotopes[,!indic.only.na]

### Write CSV file
write.table(stable_isotopes,file='./CSV/analysis/Data_StableIsotopes.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)

### 15- Stomach contents ----
stomach_contents <- read.xls("./XLS/Data_StomachContents.xls",sheet = 'stomach_content_category', header=TRUE,fileEncoding="latin1",dec='.')
### Remove columns with only NAs
indic.only.na <- (apply(stomach_contents,2,function(x) sum(is.na(x))) == nrow(stomach_contents))
names(stomach_contents)[indic.only.na]
#stomach_contents <- stomach_contents[,!indic.only.na]
### Write CSV file
write.table(stomach_contents,file='./CSV/analysis/Data_StomachContents.csv',sep="\t",row.names = FALSE,fileEncoding='utf8',na="",quote=FALSE)







