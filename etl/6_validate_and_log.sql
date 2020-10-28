BEGIN;

SET SEARCH_PATH TO import_log, metadata, core, codelists, analysis, public;

DROP TABLE IF EXISTS log_duplicate_tracers;
CREATE TABLE log_duplicate_tracers AS SELECT entity, variable, count(*) FROM md_ddd
GROUP BY entity, variable HAVING COUNT(*) > 1;

CREATE TEMP TABLE projects AS
SELECT trim(unnest(string_to_array(project, '/'))) AS project_id, organism_identifier FROM import.co_data_sampling_organism;
DROP TABLE IF EXISTS log_missing_projects;
CREATE TABLE log_missing_projects AS SELECT project_id, organism_identifier FROM projects WHERE project_id NOT IN (SELECT project FROM cl_project);

DROP TABLE IF EXISTS log_invalid_organism_measure_values;
CREATE TABLE log_invalid_organism_measure_values
(
  organism_identifier VARCHAR(50),
  measure_name VARCHAR(50),
  measure_value text
);

DROP TABLE IF EXISTS log_non_distinct_sample_entries;
CREATE TABLE log_non_distinct_sample_entries AS SELECT * FROM import.co_data_prep WHERE sample_identifier IN
(SELECT sample_identifier FROM
(SELECT sample_identifier FROM import.co_data_prep GROUP BY sample_identifier, tissue, sample_position, organism_identifier) xxx GROUP BY sample_identifier HAVING count(*) > 1) ORDER BY sample_identifier;

DROP TABLE IF EXISTS log_subsample_invalid_date_entries;
CREATE TABLE log_subsample_invalid_date_entries AS SELECT sample_identifier, storage_date, drying_date
               FROM import.co_data_prep WHERE storage_date::text ~ '[a-zA-Z]' OR drying_date::text ~ '[a-zA-Z]';

DROP TABLE IF EXISTS log_duplicate_analysis_ids;
CREATE TABLE IF NOT EXISTS log_duplicate_analysis_ids (analysis_id varchar(20));
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_amino_acids GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_contaminants_dioxin GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_contaminants_hg GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_contaminants_musk GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_contaminants_pcb GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_contaminants_pfc GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_fatmeter GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_fatty_acids GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_lipid_classes GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_moisture GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_otolith_increment_counts GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_otolith_morphometrics GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_proteins GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_repro_fecundity GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_repro_maturity GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_stable_isotopes GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_stomach_content_category GROUP BY talend_an_id HAVING count(*) > 1;
INSERT INTO log_duplicate_analysis_ids SELECT talend_an_id FROM import.an_total_lipids GROUP BY talend_an_id HAVING count(*) > 1;

DROP TABLE IF EXISTS log_missing_micro_maturity_combinations;
CREATE TABLE log_missing_micro_maturity_combinations AS SELECT talend_an_id, micro_sex, micro_maturity, repro_phase, repro_subphase, mago_stage, mago_substage FROM import.an_repro_maturity WHERE talend_an_id NOT IN (SELECT a.talend_an_id FROM import.an_repro_maturity a, codelists.cl_micro_maturity b WHERE a.micro_sex = b.micro_sex AND a.micro_maturity = b.micro_maturity AND a.mago_substage = b.mago_substage AND a.mago_stage = b.mago_stage AND a.repro_phase = b.repro_phase AND a.repro_subphase = b.repro_subphase);

DROP TABLE IF EXISTS log_missing_reference_material;
CREATE TABLE log_missing_reference_material (talend_an_id VARCHAR(20), reference_material text);

DROP TABLE IF EXISTS log_invalid_analysis_measure_values;
CREATE TABLE log_invalid_analysis_measure_values
(
  analysis VARCHAR(20),
  tracer_name VARCHAR(100),
  measure_value text
);

COMMIT;