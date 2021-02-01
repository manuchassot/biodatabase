BEGIN;

SET SEARCH_PATH TO import_log, codelists, public;

DROP TABLE IF EXISTS log_non_distinct_sample_entries;
CREATE TABLE log_non_distinct_sample_entries AS SELECT * FROM import.co_data_prep WHERE sample_identifier IN
(SELECT sample_identifier FROM
(SELECT sample_identifier FROM import.co_data_prep GROUP BY sample_identifier, tissue, sample_position, organism_identifier) xxx GROUP BY sample_identifier HAVING count(*) > 1) ORDER BY sample_identifier;

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

DROP TABLE IF EXISTS projects;
CREATE TEMP TABLE projects AS
SELECT trim(unnest(string_to_array(project, '/'))) AS project_id, organism_identifier FROM import.co_data_sampling_organism;
INSERT INTO log_values_without_codelist_entry SELECT DISTINCT 'co_data_sampling_organism', 'project_id', 'cl_project', 'project', project_id FROM projects WHERE project_id NOT IN (SELECT project FROM cl_project);

-- Missing_reference_material
SELECT log_ref_material_values_without_codelist_entry('an_amino_acids');
SELECT log_ref_material_values_without_codelist_entry('an_contaminants_dioxin');
SELECT log_ref_material_values_without_codelist_entry('an_contaminants_hg');
SELECT log_ref_material_values_without_codelist_entry('an_contaminants_musk');
SELECT log_ref_material_values_without_codelist_entry('an_contaminants_pcb');
SELECT log_ref_material_values_without_codelist_entry('an_contaminants_pfc');
SELECT log_ref_material_values_without_codelist_entry('an_contaminants_tm');

SELECT log_values_without_codelist_entry('environment', 'import', 'co_data_sampling_environment');
SELECT log_values_without_codelist_entry('organism', 'import', 'co_data_sampling_organism');
SELECT log_values_without_codelist_entry('preparation', 'import', 'co_data_prep');
SELECT log_values_without_codelist_entry('moisture', 'import', 'an_moisture');
SELECT log_values_without_codelist_entry('contaminants_tm', 'import', 'an_contaminants_tm');
SELECT log_values_without_codelist_entry('contaminants_pfc', 'import', 'an_contaminants_pfc');
SELECT log_values_without_codelist_entry('contaminants_musk', 'import', 'an_contaminants_musk');
SELECT log_values_without_codelist_entry('aminoacids', 'import', 'an_amino_acids');
SELECT log_values_without_codelist_entry('otolith_morphometrics', 'import', 'an_otolith_morphometrics');
SELECT log_values_without_codelist_entry('contaminants_hg', 'import', 'an_contaminants_hg');
SELECT log_values_without_codelist_entry('lipidclasses', 'import', 'an_lipid_classes');
SELECT log_values_without_codelist_entry('totallipids', 'import', 'an_total_lipids');
SELECT log_values_without_codelist_entry('contaminants_pcb', 'import', 'an_contaminants_pcb');
SELECT log_values_without_codelist_entry('otolith_increment_counts', 'import', 'an_otolith_increment_counts');
SELECT log_values_without_codelist_entry('fattyacids', 'import', 'an_fatty_acids');
SELECT log_values_without_codelist_entry('stomach_content_category', 'import', 'an_stomach_content_category');
SELECT log_values_without_codelist_entry('stableisotopes', 'import', 'an_stable_isotopes');
SELECT log_values_without_codelist_entry('contaminants_dioxin', 'import', 'an_contaminants_dioxin');
SELECT log_values_without_codelist_entry('fatmeter', 'import', 'an_fatmeter');
SELECT log_values_without_codelist_entry('fecundity', 'import', 'an_repro_fecundity');
SELECT log_values_without_codelist_entry('proteins', 'import', 'an_proteins');
SELECT log_values_without_codelist_entry('maturity', 'import', 'an_repro_maturity');

-- Missing analysis values
SELECT log_analysis_values_without_codelist_entry('an_amino_acids');
SELECT log_analysis_values_without_codelist_entry('an_contaminants_dioxin');
SELECT log_analysis_values_without_codelist_entry('an_contaminants_hg');
SELECT log_analysis_values_without_codelist_entry('an_contaminants_musk');
SELECT log_analysis_values_without_codelist_entry('an_contaminants_pcb');
SELECT log_analysis_values_without_codelist_entry('an_contaminants_pfc');
SELECT log_analysis_values_without_codelist_entry('an_contaminants_tm');
SELECT log_analysis_values_without_codelist_entry('an_fatmeter');
SELECT log_analysis_values_without_codelist_entry('an_fatty_acids');
SELECT log_analysis_values_without_codelist_entry('an_lipid_classes');
SELECT log_analysis_values_without_codelist_entry('an_moisture');
SELECT log_analysis_values_without_codelist_entry('an_otolith_increment_counts');
SELECT log_analysis_values_without_codelist_entry('an_otolith_morphometrics');
SELECT log_analysis_values_without_codelist_entry('an_proteins');
SELECT log_analysis_values_without_codelist_entry('an_repro_fecundity');
SELECT log_analysis_values_without_codelist_entry('an_repro_maturity');
SELECT log_analysis_values_without_codelist_entry('an_stable_isotopes');
SELECT log_analysis_values_without_codelist_entry('an_total_lipids');
SELECT log_analysis_values_without_codelist_entry('an_stomach_content_category');

COMMIT;