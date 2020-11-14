### Introduction

Using the scripts in this folder data can be extracted from MS Excel files and loaded into PostgreSQL. All scripts are either R scripts or SQL scripts. The R scripts are primarily used to convert data from MS Excel format to CSV format (with little or no transformation applied), and to load some of the data directly into temporary tables (database schema *import*). The SQL scripts are used to populate the codelist tables and to perform the actual transformation of data in the ETL process. Errors and data inconsistencies are logged in schema *import\_log*.

### Usage

The scripts should be run from a terminal (Linux/MacOS) or command prompt (Windows) in the order as numbered.

```bash
$ Rscript path_to_r_and_sql_scripts_dir/1_analysis_and_main_tables2csv_and_pg.R --datadir=path_to_excel_files --db=emotion --host=localhost --port=5432 --user=user --pw=password
$ Rscript path_to_r_and_sql_scripts_dir/2_codelist_tables2csv.R --datadir=path_to_excel_files
$ psql -U geodb_admin -d emotion -h localhost -f path_to_r_and_sql_scripts_dir/3_empty_codelist_tables.sql
$ cd path_to_excel_files/csv/codelists
$ psql -U geodb_admin -d emotion -h localhost -f path_to_r_and_sql_scripts_dir/4_load_codelist_tables.sql
$ psql -U geodb_admin -d emotion -h localhost -f path_to_r_and_sql_scripts_dir/5_md_and_initial_validation.sql
$ psql -U geodb_admin -d emotion -h localhost -f path_to_r_and_sql_scripts_dir/6_validate_and_log.sql
$ psql -U geodb_admin -d emotion -h localhost -f path_to_r_and_sql_scripts_dir/7_transform_data.sql
```

Running script *5_md_and_initial_validation.sql* will create a table *log_invalid_data* in schema *import_log*. Entries in this table can indicate that the original Excel files contain invalid data in the columns listed (i.e. data that do not conform to the data types specified in DDD). The original Excel data should then be revised and script *5_md_and_initial_validation.sql* be re-run. This should be repeated until there are no entries in table *log_invalid_data* anymore. Only then the remaining two scripts should be run to complete the ETL workflow.

