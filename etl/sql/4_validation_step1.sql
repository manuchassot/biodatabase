BEGIN;

SET SEARCH_PATH TO import_log, metadata, public;

DROP TABLE IF EXISTS log_duplicate_metadata;
CREATE TABLE log_duplicate_metadata AS SELECT entity, variable, count(*) FROM md_ddd
GROUP BY entity, variable HAVING COUNT(*) > 1;

DROP TABLE IF EXISTS log_invalid_metadata;
CREATE TABLE log_invalid_metadata AS
SELECT 'Missing entity' as issue, count(*) AS count FROM md_ddd WHERE entity IS NULL UNION
SELECT 'Missing variable' as issue, count(*) AS count FROM md_ddd WHERE variable IS NULL UNION
SELECT 'Missing data type' as issue, count(*) AS count FROM md_ddd WHERE data_type IS NULL UNION
SELECT 'Unsupported data type' as issue, count(*) AS count FROM md_ddd WHERE data_type IS NOT NULL
                       AND lower(data_type) NOT IN ('string', 'dec', 'hour', 'date', 'integer');

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