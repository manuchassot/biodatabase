### Introduction

With the scripts provided, data can be extracted from MS Excel files and loaded into PostgreSQL. All scripts are either R scripts or SQL scripts. The R scripts are primarily used to convert data from MS Excel format to CSV format (with little or no transformation applied), and to load *analysis*, core and *metadata* directly into staging tables (database schema *import*). The SQL scripts are used to populate the codelist tables (schema *codelists*), and to transform data and load them into the final tables in schemas *core*, *analysis* and *metadata*. Errors and data inconsistencies are logged to eight tables in schema *import\_log*. To avoid encoding issues on Windows set the environment variable *PGCLIENTENCODING* to *UTF8* before running the scripts.

### Usage

The scripts should be run from a terminal (Linux/MacOS) or command prompt (Windows) in the order as follows:

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

Running script *4\_validation\_step1.sql* will log data quality issues to three log tables in schema *import_log*:

| Table                     | Purpose                                                      | Required action                                              |
| ------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| log\_invalid\_ metadata   | Logs issues in the metadata table (*metadata.md\_ddd*) such as missing entities and variables, and missing or unsupported data types | Review and fix metadata in worksheet *DDD* of file *DDD\_Database.xlsx* |
| log\_duplicate\_ metadata | Logs duplicate entries the metadata table (*metadata.md\_ddd*) | Review and fix metadata in worksheet *DDD* of file *DDD\_Database.xlsx* |
| log\_invalid\_ data       | Indicates missing type compliance in the original MS Excel data | Review and fix data in the relevant MS Excel files           |

Entries in the first two tables indicate issues in the metadata (worksheet *DDD* of table *DDD\_Database.xlsx*). Entries in the last table can indicate that the original Excel files contain invalid data in the columns listed (i.e. data that do not comply with the data types specified in worksheet *DDD* of file *DDD_Database.xslx*). The original Excel data should then be revised and all scripts up to and including script *4\_validation\_step1.sql* be re-run. This should be repeated until the three log tables have no entries anymore. Script *5\_validation\_step2.sql* performs important additional checks and logs potential data issues to five additional log tables:

| Table                                           | Purpose                                                      | Required action                                              |
| ----------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| log\_duplicate\_ analyis\_ids                   | Logs duplicate analysis identifiers                          | Review and fix identifiers in the relating MS Excel file(s)  |
| log\_missing\_micro\_ maturity\_ combinations   | Logs reproduction maturity data entries without relating entry in codelist table *cl\_micro\_maturity* | Review and add the required entry to worksheet *MICRO\_MATURITY* of file *DDD\_Database.xlsx* |
| log\_non\_distinct\_ sample\_entries            | The combination of organism identifier, sample identifier, tissue and sample position should be unique. Entries violating that rule are logged in this table | Review and fix data in worksheet *preparation* of file *Data\_Prep.xslx* |
| log\_values\_without\_ codelist\_entry          | Logs data values that have no matching entry in the relating codelist table (and thus, violate referential integrity) | Review and fix data in the codelist worksheets of file *DDD\_Database.xslx* and the relating MS Excel files |
| log\_analysis\_values\_without\_codelist\_entry | The combination of *analysis* and *analysis\_group* in various analysis tables should have a matching entry in codelist table *cl\_analysis*. Entries violating that rule are logged in this table | Review and fix data in worksheet *ANALYSIS* of file *DDD\_Database.xslx* and the relating MS Excel files |

Also these tables should be reviewed and data be fixed accordingly in the original MS Excel data. Again, all scripts up to and including script *5\_validation\_step2.sql* should be re-run. Only then the sixth and last script should be run to complete the ETL workflow.

