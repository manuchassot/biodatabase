### Introduction

Using the scripts in this folder data can be extracted from MS Excel files and loaded into PostgreSQL. All scripts are either R scripts or SQL scripts. The R scripts are primarily used to convert data from MS Excel format to CSV format (with little or no transformation applied), and to load some of the data directly into temporary tables (database schema *import*). The SQL scripts are used to populate the codelist tables and to perform the actual transformation of data in the ETL process.

### Usage

The scripts should be run from a terminal (Linux/MacOS) or command prompt (Windows) in the order as numbered. The database connection parameters are currently hardcoded in the R scripts but will be replaced with environment variables at a later stage. It is assumed that the password for user *geodb_admin* is specified in *.pgpass*. Note that script *5_transform_data.sql* has not been completed yet.

```bash
$ Rscript 1_analysis_and_main_tables2csv_and_pg.R path_to_excel_files
```

```bash
$ Rscript 2_codelist_tables2csv.R path_to_excel_files
```

```bash
$ psql -U geodb_admin -d emotion -f 3_empty_codelist_tables.sql
$ cd path_to_excel_files/csv/codelists
$ psql -U geodb_admin -d emotion -f path_with_r_and_sql_scripts/4_load_codelist_tables.sql
```

```bash
$ psql -U geodb_admin -d emotion -f path_with_r_and_sql_scripts/5_transform_data.sql
```








