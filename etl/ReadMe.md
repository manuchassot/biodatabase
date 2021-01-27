### Introduction

Using the scripts in this folder data can be extracted from MS Excel files and loaded into PostgreSQL. All scripts are either R scripts or SQL scripts. The R scripts are primarily used to convert data from MS Excel format to CSV format (with little or no transformation applied), and to load some of the data directly into staging tables (database schema *import*). The SQL scripts are used to populate the codelist tables and to perform the actual transformation of data in the ETL process. Errors and data inconsistencies are logged in schema *import\_log*.

### Usage

The scripts should be run from a terminal (Linux/MacOS) or command prompt (Windows) in the order as numbered.

```bash
$ Rscript path_to_r_and_sql_script_dir/r/1_analysis_core_and_metadata2csv_and_pg.R --datadir=path_to_excel_dir --db=emotion --host=localhost --port=5432 --user=geodb_admin --pw=xxxxxxxx
$ Rscript path_to_r_and_sql_script_dir/r/2_codelist_data2csv.R --datadir=path_to_excel_dir
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_script_dir/sql/1_empty_tables.sql
$ cd path_to_excel_dir/csv/codelists
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_script_dir/sql/2_load_codelist_data.sql
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_script_dir/sql/3_load_metadata.sql
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_script_dir/sql/4_validation_step1.sql
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_script_dir/sql/5_validation_step2.sql
$ psql -U geodb_admin -d emotion -f path_to_r_and_sql_script_dir/sql/6_load_core_and_analysis_data.sql
```

Running script *4\_validation\_step1.sql* will create several log tables in schema *import_log*, most importantly table *log\_invalid\_data*. Entries in this table can indicate that the original Excel files contain invalid data in the columns listed (i.e. data that do not comply with the data types specified in worksheet *DDD* of file *DDD_Database.xslx*). The original Excel data should then be revised and all scripts up to and including script *4\_validation\_step1.sql* be re-run. This should be repeated until there are no entries in table *log\_invalid\_data* anymore. Script *5\_validation\_step2.sql* performs important additional checks and creates three more log tables. Also these tables should be reviewed and data be fixed accordingly in the original Excel data. Again, all scripts up to and including script *5\_validation\_step2.sql* should be re-run. Only then the sixth and last script should be run to complete the ETL workflow.

