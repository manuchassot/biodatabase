library(openxlsx)
library(RPostgres)
library(argparse)
library(readr)

# DB connection
createDbConn <- function(database, host, port, user, password) {

  con <- dbConnect(RPostgres::Postgres(), dbname=database, host=host, port=port, user=user, password=password, sslmode='prefer')
  dbGetQuery(con, "SET SEARCH_PATH TO import, public")  
  return (con)
}

xlsx2df <- function(dataDir, xlsFileName, sheetName = NULL) {
  
  if (is.null(sheetName)) {
    df <- read.xlsx(paste(dataDir, xlsFileName, sep="/"), skipEmptyCols = FALSE, detectDates = TRUE)
  } else {
    df <- read.xlsx(paste(dataDir, xlsFileName, sep="/"), sheet = sheetName, skipEmptyCols = FALSE, detectDates = TRUE) 
  }
  return (df)
}

df2csv <- function(dataDir, subDir, csvFileName, df) {
  
  #write_delim(df, file=paste0(dataDir, subDir, csvFileName), delim="\t", na="")
  write_delim(df, path=paste0(dataDir, subDir, csvFileName), delim="\t", na="")
  return (invisible(NULL))
}

df2pg <- function(dbConn, tableName, df) {
  
  if (dbExistsTable(dbConn, tableName)) {
    dbRemoveTable(dbConn, tableName)
  }
  # Convert column names to lowercase
  colnames(df) <- tolower(colnames(df))
  # Replace "-" with "_" in column names
  colnames(df) <- gsub("-", "_", colnames(df))
  dbWriteTable(dbConn, tableName, df, row.names = FALSE)
  return (invisible(NULL))
}

processData <- function(dbConn, dataDir, tableName, csvFileName, xlsFileName, sheetName = NULL) {
  
  df <- xlsx2df(dataDir, xlsFileName, sheetName)
  if (startsWith(tableName, "an_")) {
    subDir <- "/csv/analysis/"
  } else if (startsWith(tableName, "co_")) {
    subDir <- "/csv/core/"
  } else if (startsWith(tableName, "md_")) {
    subDir <- "/csv/metadata/"
  }
  if (!dir.exists(file.path(dataDir, subDir))) {
    dir.create(file.path(dataDir, subDir), recursive = TRUE)
  }
  df2csv(dataDir, subDir, csvFileName, df)
  df2pg(dbConn, tableName, df)
}

parser <- ArgumentParser(description='Convert Excel data to CSV and PostgreSQL')
parser$add_argument('--datadir', action='store', type='character', required=TRUE, help='Directory containing Excel files')
parser$add_argument('--db', action='store', type='character', default='emotion', help='Database (default: emotion)')
parser$add_argument('--host', action='store', type='character', default='localhost', help='Host (default: localhost)')
parser$add_argument('--port', action='store', type='integer', default=5432, help='Port (default: 5432)')
parser$add_argument('--user', action='store', type='character', default='geodb_admin', help='Username (default: geodb_admin)')
parser$add_argument('--pw', action='store', type='character', required=TRUE, help='Password')
args <- parser$parse_args()
dataDir <- args$datadir

con <- createDbConn(args$db, args$host, args$port, args$user, args$pw)

# 1: Amino acids
processData(con, dataDir, "an_amino_acids", "Data_AminoAcids.csv", "Data_AminoAcids.xlsx")

# 2: Mercury
processData(con, dataDir, "an_contaminants_hg", "Data_Contaminants_HG.csv", "Data_Contaminants.xlsx", "hg")

# 3: Metallic tracers (other than mercury)
processData(con, dataDir, "an_contaminants_tm", "Data_Contaminants_TM.csv", "Data_Contaminants.xlsx", "tm")

# 4: PCBs
processData(con, dataDir, "an_contaminants_pcb", "Data_Contaminants_PCB.csv", "Data_Contaminants.xlsx", "pcb")

# 5: Dioxin
processData(con, dataDir, "an_contaminants_dioxin", "Data_Contaminants_Dioxin.csv", "Data_Contaminants.xlsx", "dioxin")

# 6: Musk
processData(con, dataDir, "an_contaminants_musk", "Data_Contaminants_Musk.csv", "Data_Contaminants.xlsx", "musk")

# 7: Fatmeter
processData(con, dataDir, "an_fatmeter", "Data_Fatmeter.csv", "Data_Fatmeter.xlsx", "fatmeter")

# 8: Fatty qcids
processData(con, dataDir, "an_fatty_acids", "Data_FattyAcids.csv", "Data_FattyAcids.xlsx", "fattyacids")

# 9: Lipid classes
processData(con, dataDir, "an_lipid_classes", "Data_LipidClasses.csv", "Data_LipidClasses.xlsx", "lipidclasses")

# 10: Otoliths measurements
processData(con, dataDir, "an_otolith_morphometrics", "Data_Otoliths_morpho.csv", "Data_Otoliths.xlsx", "otolith_morphometrics")

# 11: Otoliths increments
processData(con, dataDir, "an_otolith_increment_counts", "Data_Otoliths_counts.csv", "Data_Otoliths.xlsx", "otolith_increment_counts")

# 12: Proteins
processData(con, dataDir, "an_proteins", "Data_Proteins.csv", "Data_Proteins.xlsx", "proteins")

# 13: Reproduction: maturity stage
processData(con, dataDir, "an_repro_maturity", "Data_Reproduction_maturity.csv", "Data_Reproduction.xlsx", "maturity")

# 14: Reproduction: fecundity
processData(con, dataDir, "an_repro_fecundity", "Data_Reproduction_fecundity.csv", "Data_Reproduction.xlsx", "fecundity")

# 15: Stable isotopes
processData(con, dataDir, "an_stable_isotopes", "Data_StableIsotopes.csv", "Data_StableIsotopes.xlsx")

# 16: Stomach contents
processData(con, dataDir, "an_stomach_content_category", "Data_StomachContents.csv", "Data_StomachContents.xlsx", "stomach_content_category")

# 17: Total lipids
processData(con, dataDir, "an_total_lipids", "Data_TotalLipids.csv", "Data_TotalLipids.xlsx", "totallipids")

# 18: Moisture
processData(con, dataDir, "an_moisture", "Data_Moisture.csv", "Data_Moisture.xlsx", "moisture")

# 19: PFCs
processData(con, dataDir, "an_contaminants_pfc", "Data_Contaminants_PFC.csv", "Data_Contaminants.xlsx", "pfc")

# 20: Main XLSX files
processData(con, dataDir, "co_data_prep", "Data_Prep.csv", "Data_Prep.xlsx")
processData(con, dataDir, "co_data_sampling_environment", "Data_Sampling_Environment.csv", "Data_Sampling.xlsx", "environment")
processData(con, dataDir, "co_data_sampling_organism", "Data_Sampling_Organism.csv", "Data_Sampling.xlsx", "organism")
processData(con, dataDir, "md_ddd_database", "DDD_Database.csv", "DDD_Database.xlsx", "DDD")

dbDisconnect(con) 
