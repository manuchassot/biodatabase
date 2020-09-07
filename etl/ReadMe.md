### Introduction

Using the scripts in this folder data can be extracted from MS Excel files and loaded into PostgreSQL. All scripts are either R scripts or SQL scripts. The R scripts are primarily used to convert data from MS Excel format to CSV format (with little or no transformation applied), and to load some of the data directly into temporary tables (database schema *import*). The SQL scripts are used to populate the codelist tables and to perform the actual transformation of data in the ETL process. Errors and data inconsistencies are logged in schema *import\_log*.

### Usage

The scripts should be run from a terminal (Linux/MacOS) or command prompt (Windows) in the order as numbered. The database connection parameters are currently hardcoded in the R script (only script *1\_analysis...R*) but will be replaced with environment variables at a later stage. ADJUST the connection parameters as required for your particular setup. It is assumed that the password for user *geodb_admin* is specified in *.pgpass*.

```bash
$ Rscript path_to_r_and_sql_scripts_dir/1_analysis_and_main_tables2csv_and_pg.R path_to_excel_files
$ Rscript path_to_r_and_sql_scripts_dir/2_codelist_tables2csv.R path_to_excel_files
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_scripts_dir/3_empty_codelist_tables.sql
$ cd path_to_excel_files/csv/codelists
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_scripts_dir/4_load_codelist_tables.sql
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_scripts_dir/5_validate_and_log.sql
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_scripts_dir/6_transform_data.sql
```
