BEGIN;

SET SEARCH_PATH TO metadata, core, codelists, analysis, import_log, public;

TRUNCATE md_ddd CASCADE;
TRUNCATE md_analysis_tracer_detail CASCADE;
TRUNCATE md_organism_measure_detail CASCADE;

------------------
-- SCHEMA METADATA
------------------
-- md_ddd
INSERT INTO md_ddd SELECT * FROM import.md_ddd_database;

-- md_analysis_tracer_detail
ALTER SEQUENCE md_analysis_tracer_detail_id_seq RESTART;
INSERT INTO md_analysis_tracer_detail(analysis_type, tracer_name, standard_unit, tracer_description, views_level, ref_table, data_type)
SELECT entity, variable, unit, comment, views_level, CASE WHEN length(trim(basic_checks)) = 0 THEN NULL ELSE basic_checks END, data_type FROM md_ddd a
WHERE tracer = 1 AND NOT EXISTS (SELECT 1 FROM metadata.md_ddd b WHERE a.entity = b.entity AND
                   a.variable = b.variable GROUP BY entity, variable HAVING COUNT(*) > 1) ORDER BY entity, variable;

-- md_organism_measure_detail
INSERT INTO md_organism_measure_detail(measure_name, standard_unit, measure_description) SELECT variable,
unit, comment FROM md_ddd WHERE tracer = 2 ORDER BY variable;

-- Initial validation
DROP TABLE IF EXISTS import_log.log_invalid_data;
CREATE TABLE import_log.log_invalid_data
(
    entity varchar(50),
    schema_name varchar(50),
    table_name varchar(50),
    column_name varchar(50),
    required_excel_data_type varchar(50)
);

CREATE OR REPLACE FUNCTION import_log.log_invalid_data (entity_name text, schema_name text, tbl_name text) RETURNS VOID AS
$func$
BEGIN
    WITH data_types AS
    (
         SELECT a.variable, a.data_type as defined_data_type, b.data_type as current_data_type
         FROM metadata.md_ddd a
                  JOIN
              information_schema.columns b ON a.variable = b.column_name
         WHERE a.entity = entity_name
           AND b.table_schema = schema_name
           AND b.table_name = tbl_name
    )
    INSERT INTO import_log.log_invalid_data SELECT entity_name, schema_name, tbl_name, variable, defined_data_type FROM data_types WHERE
    (lower(defined_data_type) = 'string' AND current_data_type NOT IN ('text', 'character varying', 'double precision')) OR
    (lower(defined_data_type) = 'integer' AND current_data_type NOT IN ('integer', 'smallint', 'bigint')) OR
    (lower(defined_data_type) = 'hour' AND current_data_type != 'double precision') OR
    (lower(defined_data_type) = 'date' AND current_data_type != 'date') OR
    (lower(defined_data_type) = 'dec' AND current_data_type NOT IN ('numeric', 'double precision', 'real', 'decimal', 'integer', 'smallint', 'bigint'));
END
$func$ LANGUAGE plpgsql;

SELECT log_invalid_data('environment', 'import', 'co_data_sampling_environment');
SELECT log_invalid_data('organism', 'import', 'co_data_sampling_organism');
SELECT log_invalid_data('preparation', 'import', 'co_data_prep');
SELECT log_invalid_data('moisture', 'import', 'an_moisture');
SELECT log_invalid_data('contaminants_tm', 'import', 'an_contaminants_tm');
SELECT log_invalid_data('contaminants_pfc', 'import', 'an_contaminants_pfc');
SELECT log_invalid_data('contaminants_musk', 'import', 'an_contaminants_musk');
SELECT log_invalid_data('aminoacids', 'import', 'an_amino_acids');
SELECT log_invalid_data('otolith_morphometrics', 'import', 'an_otolith_morphometrics');
SELECT log_invalid_data('contaminants_hg', 'import', 'an_contaminants_hg');
SELECT log_invalid_data('lipidclasses', 'import', 'an_lipid_classes');
SELECT log_invalid_data('totallipids', 'import', 'an_total_lipids');
SELECT log_invalid_data('contaminants_pcb', 'import', 'an_contaminants_pcb');
SELECT log_invalid_data('otolith_increment_counts', 'import', 'an_otolith_increment_counts');
SELECT log_invalid_data('fattyacids', 'import', 'an_fatty_acids');
SELECT log_invalid_data('stomach_content_category', 'import', 'an_stomach_content_category');
SELECT log_invalid_data('stableisotopes', 'import', 'an_stable_isotopes');
SELECT log_invalid_data('contaminants_dioxin', 'import', 'an_contaminants_dioxin');
SELECT log_invalid_data('fatmeter', 'import', 'an_fatmeter');
SELECT log_invalid_data('fecundity', 'import', 'an_repro_fecundity');
SELECT log_invalid_data('proteins', 'import', 'an_proteins');
SELECT log_invalid_data('maturity', 'import', 'an_repro_maturity');

COMMIT;