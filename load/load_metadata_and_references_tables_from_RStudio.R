### Paths
wd <- '/home/stagiaire/Emotion3/'
temp <- '/tmp'
  
### Libraries
options(java.parameters = "-Xmx4024m")
library(XLConnect,quietly = TRUE)
library(RPostgreSQL)

### Connect to the database
drv <- dbDriver("PostgreSQL")
con_emotion3_local <-  dbConnect(drv,user="postgres",dbname="emotion3",host="localhost")

### Read the data
setwd(wd)
DDD <- loadWorkbook("./XLS/DDD_Database.xls", create = FALSE)

### ------------------------ MANAGE METADATA -------------------------------

### 1- Full data dictionary ----
### Extract spreadsheet DDD
ddd <- readWorksheet(DDD,"DDD")

### Save in temp to allow for insertion in the database
write.table(ddd,file='/tmp/ddd.csv',row.names = FALSE,sep="\t",na = '')

### CREATE metadata.ddd (to include in emotion3_schema_manu.sql)
### If not already present
create.metadata.ddd <- dbSendQuery(con_emotion3_local,paste0("
DROP TABLE IF EXISTS metadata.ddd;
CREATE TABLE metadata.ddd (
  entity character varying(255),
  variable character varying(255),
  data_type character varying(255),
  unit character varying(255),
  basic_checks character varying(255),
  description character varying(2500),
  variable_type integer,
  views_level integer
);
ALTER TABLE metadata.ddd OWNER TO \"dbaEmotion\";"
,sep=""))

### INSERT metadata.ddd
send.metadata.ddd <- dbSendQuery(con_emotion3_local,paste0("COPY metadata.ddd FROM '/tmp/ddd.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 2- Details of analysis tracers ----
### Create table metadata.analysis_tracers_details from metadata.ddd
create.metadata.analysis.tracers.details <- dbSendQuery(con_emotion3_local,paste0("
DROP TABLE IF EXISTS metadata.analysis_tracers_details CASCADE;
CREATE TABLE metadata.analysis_tracers_details AS
SELECT entity AS analysis_type,
variable AS tracer_name,
unit AS standard_unit,
description AS tracer_description,
views_level
FROM metadata.ddd
WHERE variable_type = 1
ORDER BY analysis_type,tracer_name;",sep=""))

### Save the metadata csv file
### Command terminal
## \copy (SELECT * FROM metadata.analysis_tracers_details) TO '/home/stagiaire/Emotion3/CSV/metadata/analysis_tracers_details.csv' WITH DELIMITER E'\t' CSV HEADER

### 3- Details of fish measurements ----
### Create table fish_measure_details
create.metadata.fish.measures.details <- dbSendQuery(con_emotion3_local,paste0("
DROP TABLE IF EXISTS metadata.fish_measures_details;
CREATE TABLE metadata.fish_measures_details AS
SELECT variable AS measure_name,
unit AS standard_unit,
description AS measure_description
FROM metadata.ddd
WHERE variable_type = 2
ORDER BY measure_name;",sep=""))

### Save the metadata csv file
### Command terminal
## \copy (SELECT * FROM metadata.fish_measures_details) TO '/home/stagiaire/Emotion3/CSV/metadata/fish_measures_details.csv' WITH DELIMITER E'\t' CSV HEADER

# ------------------------ MANAGE REFERENCES TABLES -----------------------------

### 1- List of Anchored Fish Aggregating Devices ----
### Extract spreadsheet afad
afad <- readWorksheet(DDD,"AFAD")

### Save in temp to allow for insertion in the database
write.table(afad,file='/tmp/afad.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.afad
send.references.tables.afad <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.afad FROM '/tmp/afad.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 2- List of amino-acids ----
### Extract spreadsheet amino_acids
amino_acids <- readWorksheet(DDD,"AMINO_ACIDS")

### Save in temp to allow for insertion in the database
write.table(amino_acids,file='/tmp/amino_acids.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.amino_acids
send.references.tables.amino_acids <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.amino_acids FROM '/tmp/amino_acids.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 3- List of groups of analyses ----
### Extract spreadsheet ANALYSIS
analysis <- readWorksheet(DDD,"ANALYSIS")

### Save in temp to allow for insertion in the database
analyis_groups <- unique(analysis[,c("analysis_group","desc_analysis_group")])
analyis_groups <- analyis_groups[order(analyis_groups$analysis_group),]
write.table(analyis_groups,file='/tmp/analysis_groups.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.analysis_groups
send.references.tables.analyis_groups <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.analysis_groups FROM '/tmp/analysis_groups.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 4- Laboratories of analysis ----
### Extract spreadsheet ANALYSIS_LAB
analysis_lab <- readWorksheet(DDD,"ANALYSIS_LAB")

### Save in temp to allow for insertion in the database
write.table(analysis_lab,file='/tmp/analysis_lab.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.analysis_lab
send.references.tables.analyis_lab <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.analysis_lab FROM '/tmp/analysis_lab.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 5- Matching between groups of analysis and analysis types ----
analysis_matching_groups <- unique(analysis[,c('analysis_group','analysis')])
names(analysis_matching_groups)[2] <- "analysis_type"

### Save in temp to allow for insertion in the database
write.table(analysis_matching_groups,file='/tmp/analysis_matching_groups.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.analysis_matching_groups
send.references.tables.analyis_matching_groups <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.analysis_matching_groups FROM '/tmp/analysis_matching_groups.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 6- Modes of analysis ----
### Extract spreadsheet ANALYSIS_MODE
analysis_modes <- readWorksheet(DDD,"ANALYSIS_MODE")

### Save in temp to allow for insertion in the database
write.table(analysis_modes,file='/tmp/analysis_modes.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.analysis_modes
send.references.tables.analyis_modes <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.analysis_modes FROM '/tmp/analysis_modes.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 7- Labelling of analysis replicates ----
### Extract spreadsheet ANALYSIS_REPLICATE
analysis_replicate <- readWorksheet(DDD,"ANALYSIS_REPLICATE")

### Save in temp to allow for insertion in the database
write.table(analysis_replicate,file='/tmp/analysis_replicate.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.analysis_replicate
send.references.tables.analyis_replicate <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.analysis_replicate FROM '/tmp/analysis_replicate.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 8- Description of samples ----
### Extract spreadsheet ANALYSIS_SAMP_DESCRIPTION
analysis_sample_description <- readWorksheet(DDD,"ANALYSIS_SAMP_DESCRIPTION")

### Save in temp to allow for insertion in the database
write.table(analysis_sample_description,file='/tmp/analysis_sample_description.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.analysis_sample_description
send.references.tables.analyis_sample_description <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.analysis_sample_description FROM '/tmp/analysis_sample_description.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 9- Types of analysis ----
analysis_types <- unique(analysis[,c('analysis','desc_analysis')])
### Extract each component of analysis$desc_analysis from cut at '\n' and get first element
analysis_types$desc_analysis <- unlist(lapply(strsplit(analysis_types$desc_analysis,split = "\n"), function(l) l[[1]]))

### Save in temp to allow for insertion in the database
write.table(analysis_types,file='/tmp/analysis_types.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.analysis_types
send.references.tables.analyis_types <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.analysis_types FROM '/tmp/analysis_types.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 10- Stages of atresia -----
### Extract spreadsheet ATRESIA
atresia <- readWorksheet(DDD,"ATRESIA")

### Save in temp to allow for insertion in the database
write.table(atresia,file='/tmp/atresia.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.atresia
send.references.tables.atresia <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.atresia FROM '/tmp/atresia.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 11- List of certified materials ----
### Extract spreadhsheet CRM
crm <- readWorksheet(DDD,"CRM")

### Save in temp to allow for insertion in the database
write.table(crm,file='/tmp/crm.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.crm
send.references.tables.crm <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.crm FROM '/tmp/crm.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 12- List of drying modes ----
### Extract spreadsheet DRYING_MODE
drying_mode <- readWorksheet(DDD,"DRYING_MODE")

### Save in temp to allow for insertion in the database
write.table(drying_mode,file='/tmp/drying_mode.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.atresia
send.references.tables.drying_mode <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.drying_mode FROM '/tmp/drying_mode.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 13- Modes of extraction ----
### Extract spreadsheet EXTRACTION_MODE
extraction_mode <- readWorksheet(DDD,"EXTRACTION_MODE")

### Save in temp to allow for insertion in the database
write.table(extraction_mode,file='/tmp/extraction_mode.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.extraction_mode
send.references.tables.extraction_mode <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.extraction_mode FROM '/tmp/extraction_mode.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 14- List of fatty acids ----
### Extract spreadsheet FATTY_ACIDS
fatty_acids <- readWorksheet(DDD,"FATTY_ACIDS")

### Save in temp to allow for insertion in the database
write.table(fatty_acids,file='/tmp/fatty_acids.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.fatty_acids
send.references.tables.fatty_acids <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.fatty_acids FROM '/tmp/fatty_acids.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 15- List of fishing modes ----
### Extract spreadsheet FISHING_MODE
fishing_mode <- readWorksheet(DDD,"FISHING_MODE")

### Save in temp to allow for insertion in the database
write.table(fishing_mode,file='/tmp/fishing_mode.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.fishing_mode
send.references.tables.fishing_mode <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.fishing_mode FROM '/tmp/fishing_mode.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 16- List of fishing gears ----
### Extract spreadsheet GEAR
gear <- readWorksheet(DDD,"GEAR")

### Save in temp to allow for insertion in the database
write.table(gear,file='/tmp/gear.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.gear
send.references.tables.gear <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.gear FROM '/tmp/gear.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 17- List of grinding modes ----
### Extract spreadsheet GRINDING_MODE
grinding_mode <- readWorksheet(DDD,"GRINDING_MODE")

### Save in temp to allow for insertion in the database
write.table(grinding_mode,file='/tmp/grinding_mode.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.grinding_mode
send.references.tables.grinding_mode <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.grinding_mode FROM '/tmp/grinding_mode.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 18- List of landing sites ----
### Extract spreadsheet LANDING
landing <- readWorksheet(DDD,"LANDING")

### Save in temp to allow for insertion in the database
write.table(landing,file='/tmp/landing.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.landing
send.references.tables.landing <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.landing FROM '/tmp/landing.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 19- Stages of macroscopic maturity (visual exam) ----
### Extract spreadsheet 
macro_maturity <- readWorksheet(DDD,"MACRO_MATURITY")

### Save in temp to allow for insertion in the database
write.table(macro_maturity,file='/tmp/macro_maturity.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.macro_maturity
send.references.tables.macro_maturity <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.macro_maturity FROM '/tmp/macro_maturity.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 20- Stages of microscopic maturity (histology) ----
### Extract spreadsheet 
micro_maturity_stage <- readWorksheet(DDD,"MICRO_MATURITY")

### Save in temp to allow for insertion in the database
write.table(micro_maturity_stage,file='/tmp/micro_maturity_stage.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.micro_maturity
send.references.tables.micro_maturity_stage <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.micro_maturity_stage FROM '/tmp/micro_maturity_stage.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 21- List of oceans ----
### Extract spreadsheet 
ocean <- readWorksheet(DDD,"OCEAN")

### Save in temp to allow for insertion in the database
write.table(ocean,file='/tmp/ocean.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.ocean
send.references.tables.ocean <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.ocean FROM '/tmp/ocean.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 22- List of operators ----
### Extract spreadsheet 
operator <- readWorksheet(DDD,"OPERATOR")

### Save in temp to allow for insertion in the database
write.table(operator,file='/tmp/operator.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.operator
send.references.tables.operator <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.operator FROM '/tmp/operator.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 23- Types of measurement of otolith ----
### Extract spreadsheet
otolith_measurement_type <- readWorksheet(DDD,"OTOLITHS")

### Save in temp to allow for insertion in the database
write.table(otolith_measurement_type,file='/tmp/otolith_measurement_type.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.otolith_measurement_type
send.references.tables.otolith_measurement_type <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.otolith_measurement_type FROM '/tmp/otolith_measurement_type.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 24- Type of packaging -----
### Extract spreadsheet
packaging <- readWorksheet(DDD,"PACKAGING")

### Save in temp to allow for insertion in the database
write.table(packaging,file='/tmp/packaging.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.packaging
send.references.tables.packaging <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.packaging FROM '/tmp/packaging.csv' WITH DELIMITER E'\\t' CSV HEADER"))

### 25- Classification of post-ovulatory follicles ----
### Extract spreadsheet
pof <- readWorksheet(DDD,"POF")

### Save in temp to allow for insertion in the database
write.table(pof,file='/tmp/pof.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.pof
send.references.tables.pof <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.pof FROM '/tmp/pof.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 26- List of prey groups -----
### Extract spreadsheet
prey_groups <- readWorksheet(DDD,"PREY_GROUPS")

### Save in temp to allow for insertion in the database
write.table(prey_groups,file='/tmp/prey_groups.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.prey_groups
send.references.tables.prey_groups <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.prey_groups FROM '/tmp/prey_groups.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 27- Labelling of processing replicates ----
### Extract spreadsheet
processing_replicates <- readWorksheet(DDD,"PROCESSING_REPLICATE")

### Save in temp to allow for insertion in the database
write.table(processing_replicates,file='/tmp/processing_replicates.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.processing_replicate
send.references.tables.processing_replicates <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.processing_replicates FROM '/tmp/processing_replicates.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 28- List of projects ----
### Extract spreadsheet
project <- readWorksheet(DDD,"PROJECT")

### Save in temp to allow for insertion in the database
write.table(project,file='/tmp/project.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.project
send.references.tables.project <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.project FROM '/tmp/project.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 29- List of sample positions ----
### Extract spreadsheet
sample_position <- readWorksheet(DDD,"SAMPLE_POSITION")

### Save in temp to allow for insertion in the database
write.table(sample_position,file='/tmp/sample_position.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.sample_position
send.references.tables.sample_position <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.sample_position FROM '/tmp/sample_position.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 30- List of sampling platforms ----
### Extract spreadsheet
sampling_platform <- readWorksheet(DDD,"SAMPLING_PLATFORM")

### Save in temp to allow for insertion in the database
write.table(sampling_platform,file='/tmp/sampling_platform.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.sampling_platform
send.references.tables.sampling_platform <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.sampling_platform FROM '/tmp/sampling_platform.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 31- Classification of sex ----
### Extract spreadsheet
sex <- readWorksheet(DDD,"SEX")

### Save in temp to allow for insertion in the database
write.table(sex,file='/tmp/sex.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.sex
send.references.tables.sex <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.sex FROM '/tmp/sex.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 32- List of species ----
### Extract spreadsheet
### Caution: Do not include columns 'SFA.ID.ppt' & 'SFA_life_history_table'
species <- readWorksheet(DDD,"SPECIES")[,1:17]

### Save in temp to allow for insertion in the database
write.table(species,file='/tmp/species.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.species
send.references.tables.species <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.species FROM '/tmp/species.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 33- Classification of stomach fullness ----
### Extract spreadsheet
stomach_fullness <- readWorksheet(DDD,"STOMACH_FULLNESS")

### Save in temp to allow for insertion in the database
write.table(stomach_fullness,file='/tmp/stomach_fullness.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.stomach_fullness
send.references.tables.stomach_fullness <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.stomach_fullness FROM '/tmp/stomach_fullness.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 34- List of storage modes ----
### Extract spreadsheet
storage_mode <- readWorksheet(DDD,"STORAGE_MODE")

### Save in temp to allow for insertion in the database
write.table(storage_mode,file='/tmp/storage_mode.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.storage_mode
send.references.tables.storage_mode <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.storage_mode FROM '/tmp/storage_mode.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 35- List of tissues ----
### Extract spreadsheet
tissue <- readWorksheet(DDD,"TISSUE")

### Save in temp to allow for insertion in the database
write.table(tissue,file='/tmp/tissue.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.tissue
send.references.tables.tissue <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.tissue FROM '/tmp/tissue.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 36- List of vessels ----
### Extract spreadsheet
vessel <- readWorksheet(DDD,"VESSEL")

### Save in temp to allow for insertion in the database
write.table(vessel,file='/tmp/vessel.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.vessel
send.references.tables.vessel <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.vessel FROM '/tmp/vessel.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 37- Classification of vessel storage ----
### Extract spreadsheet
vessel_storage <- readWorksheet(DDD,"VESSEL_STORAGE")

### Save in temp to allow for insertion in the database
write.table(vessel_storage,file='/tmp/vessel_storage.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.vessel_storage
send.references.tables.vessel_storage <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.vessel_storage FROM '/tmp/vessel_storage.csv' WITH DELIMITER E'\\t' CSV HEADER"))

# 38- Derivatization mode ----
### Extract spreadsheet
derivatization_mode <- readWorksheet(DDD,"DERIVATIZATION_MODE")

### Save in temp to allow for insertion in the database
write.table(derivatization_mode,file='/tmp/derivatization_mode.csv',row.names = FALSE,sep="\t",na = '')

### INSERT references_tables.vessel_storage
send.references.tables.derivatization_mode <- dbSendQuery(con_emotion3_local,paste0("COPY references_tables.derivatization_mode FROM '/tmp/derivatization_mode.csv' WITH DELIMITER E'\\t' CSV HEADER"))


