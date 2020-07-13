library(openxlsx)
library(stringr)

xlsx2df <- function(dataDir, xlsFileName, sheetName = NULL) {
  
  if (is.null(sheetName)) {
    df <- read.xlsx(paste(dataDir, xlsFileName, sep="/"), skipEmptyCols = FALSE)
  } else {
    df <- read.xlsx(paste(dataDir, xlsFileName, sep="/"), sheet = sheetName, skipEmptyCols = FALSE) 
  }
  return (df)
}

df2csv <- function(dataDir, csvFileName, df) {
  
  subDir <- '/csv/codelists/'
  if (!dir.exists(file.path(dataDir, subDir))) {
    dir.create(file.path(dataDir, subDir))
  }
  write.table(df, file=paste0(dataDir, subDir, csvFileName), sep="\t", row.names = FALSE, fileEncoding='utf8', na="", quote=FALSE)
  return (invisible(NULL))
}

processData <- function(dataDir, csvFileName, xlsFileName, sheetName = NULL) {
  
  df = xlsx2df(dataDir, xlsFileName, sheetName)
  # Replace line breaks within cells:
  df <- data.frame(lapply(df, function(x) {
                      gsub("\n", " | ", x)
                    }))
  df2csv(dataDir, csvFileName, df)
}

# Read data directory (containing Excel files) from commandline argument
# Usage: Rscript codelist_tables2csv.R path_to_excel_files
args <- commandArgs(trailingOnly = TRUE)
dataDir=args[1]
#dataDir<- '~/Downloads/SFA_Excel'

processData(dataDir, "cl_aggregation.csv", "DDD_Database.xlsx", "AGGREGATION")
processData(dataDir, "cl_amino_acid.csv", "DDD_Database.xlsx", "AMINO_ACIDS")
processData(dataDir, "cl_analysis.csv", "DDD_Database.xlsx", "ANALYSIS")
processData(dataDir, "cl_analysis_lab.csv", "DDD_Database.xlsx", "ANALYSIS_LAB")
processData(dataDir, "cl_analysis_mode.csv", "DDD_Database.xlsx", "ANALYSIS_MODE")
processData(dataDir, "cl_analysis_replicate.csv", "DDD_Database.xlsx", "ANALYSIS_REPLICATE")
processData(dataDir, "cl_analysis_sample_description.csv", "DDD_Database.xlsx", "ANALYSIS_SAMP_DESCRIPTION")
processData(dataDir, "cl_atresia.csv", "DDD_Database.xlsx", "ATRESIA")
processData(dataDir, "cl_derivatization_mode.csv", "DDD_Database.xlsx", "DERIVATIZATION_MODE")
processData(dataDir, "cl_drying_mode.csv", "DDD_Database.xlsx", "DRYING_MODE")
processData(dataDir, "cl_extraction_mode.csv", "DDD_Database.xlsx", "EXTRACTION_MODE")
processData(dataDir, "cl_fatm_mode.csv", "DDD_Database.xlsx", "FATMETER_MODE")
processData(dataDir, "cl_fatty_acid.csv", "DDD_Database.xlsx", "FATTY_ACIDS")
processData(dataDir, "cl_fish_face.csv", "DDD_Database.xlsx", "FISH_FACE")
processData(dataDir, "cl_fraction_type.csv", "DDD_Database.xlsx", "FRACTION_TYPE")
processData(dataDir, "cl_fractionation_mode.csv", "DDD_Database.xlsx", "FRACTIONATION_MODE")
processData(dataDir, "cl_gear.csv", "DDD_Database.xlsx", "GEAR")
processData(dataDir, "cl_grinding_mode.csv", "DDD_Database.xlsx", "GRINDING_MODE")
processData(dataDir, "cl_increment_type.csv", "DDD_Database.xlsx", "INCREMENT_TYPE")
processData(dataDir, "cl_landing.csv", "DDD_Database.xlsx", "LANDING")
processData(dataDir, "cl_macro_maturity.csv", "DDD_Database.xlsx", "MACRO_MATURITY")
processData(dataDir, "cl_measure_unit.csv", "DDD_Database.xlsx", "MEASURE_UNIT")
processData(dataDir, "cl_micro_maturity.csv", "DDD_Database.xlsx", "MICRO_MATURITY")
processData(dataDir, "cl_mineral.csv", "DDD_Database.xlsx", "MINERALS")
processData(dataDir, "cl_ocean.csv", "DDD_Database.xlsx", "OCEAN")
processData(dataDir, "cl_operator.csv", "DDD_Database.xlsx", "OPERATOR")
processData(dataDir, "cl_organic_contaminant.csv", "DDD_Database.xlsx", "ORGANIC_CONTAMINANTS")
processData(dataDir, "cl_organism_sampling_status.csv", "DDD_Database.xlsx", "ORGANISM_SAMPLING_STATUS")
processData(dataDir, "cl_otolith_breaking.csv", "DDD_Database.xlsx", "OTOLITH_BREAKING")
processData(dataDir, "cl_otolith_measurement.csv", "DDD_Database.xlsx", "OTOLITH_MEASUREMENT")
processData(dataDir, "cl_otolith_number.csv", "DDD_Database.xlsx", "OTOLITH_NUMBER")
processData(dataDir, "cl_otolith_part.csv", "DDD_Database.xlsx", "OTOLITH_PART")
processData(dataDir, "cl_otolith_section_type.csv", "DDD_Database.xlsx", "OTOLITH_SECTION_TYPE")
processData(dataDir, "cl_packaging.csv", "DDD_Database.xlsx", "PACKAGING")
processData(dataDir, "cl_pof.csv", "DDD_Database.xlsx", "POF")
processData(dataDir, "cl_prey_group.csv", "DDD_Database.xlsx", "PREY_GROUPS")
processData(dataDir, "cl_processing_replicate.csv", "DDD_Database.xlsx", "PROCESSING_REPLICATE")
processData(dataDir, "cl_project.csv", "DDD_Database.xlsx", "PROJECT")
processData(dataDir, "cl_reading_method.csv", "DDD_Database.xlsx", "READING_METHOD")
processData(dataDir, "cl_reference_material.csv", "DDD_Database.xlsx", "REFERENCE_MATERIAL")
processData(dataDir, "cl_sample_position.csv", "DDD_Database.xlsx", "SAMPLE_POSITION")
processData(dataDir, "cl_sampling_platform.csv", "DDD_Database.xlsx", "SAMPLING_PLATFORM")
processData(dataDir, "cl_sex.csv", "DDD_Database.xlsx", "SEX")
processData(dataDir, "cl_species.csv", "DDD_Database.xlsx", "SPECIES")
processData(dataDir, "cl_storage_mode.csv", "DDD_Database.xlsx", "STORAGE_MODE")
processData(dataDir, "cl_tissue.csv", "DDD_Database.xlsx", "TISSUE")
processData(dataDir, "cl_vessel.csv", "DDD_Database.xlsx", "VESSEL")
processData(dataDir, "cl_vessel_storage.csv", "DDD_Database.xlsx", "VESSEL_STORAGE")
processData(dataDir, "cl_well_position.csv", "DDD_Database.xlsx", "VESSEL_WELL")
