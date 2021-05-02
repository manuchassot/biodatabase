BEGIN;

SET CLIENT_ENCODING TO 'UTF8';
SET SEARCH_PATH TO metadata, core, codelists, analysis, spatial, import_log, public;

--------------
-- SCHEMA core
--------------
-- co_sampling_environment
ALTER TABLE co_sampling_environment DROP COLUMN IF EXISTS organism_ids;
ALTER TABLE co_sampling_environment DROP COLUMN IF EXISTS well_number;
ALTER TABLE co_sampling_environment DROP COLUMN IF EXISTS well_position;
ALTER TABLE co_sampling_environment ADD COLUMN organism_ids text[];
ALTER TABLE co_sampling_environment ADD COLUMN well_number text;
ALTER TABLE co_sampling_environment ADD COLUMN well_position text;
INSERT INTO co_sampling_environment(id, landing_date, landing_site, landing_country, capture_date, capture_date_min, capture_date_max, capture_time, capture_time_start, capture_time_end, activity_number, sea_surface_temperature_deg_celcius, well_position, well_number, ocean_code, gear_code, vessel_code, vessel_name, vessel_storage_mode, sampling_remarks, capture_depth_m, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max, organism_ids, geom, turbidity, ph)
 SELECT ocean_code || lpad((row_number() over ())::text, 8, '0'), landing_date, a.landing_site, b.landing_country, capture_date, capture_date_min, capture_date_max, time '00:00' + make_interval(secs => capture_time::decimal*86400), time '00:00' + make_interval(secs => capture_time_start::decimal*86400), time '00:00' + make_interval(secs => capture_time_end::decimal*86400), activity_number::int, sea_surface_temp, well_position, well_number, ocean_code, gear_code, vessel_code, vessel_name, vessel_storage_mode, remarks_capture, capture_depth, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max, array_agg(organism_identifier), CASE WHEN latitude_deg_dec IS NOT NULL AND longitude_deg_dec IS NOT NULL THEN ST_SetSRID(ST_MakePoint(longitude_deg_dec, latitude_deg_dec), 4326) WHEN latitude_deg_dec_min IS NOT NULL AND longitude_deg_dec_min IS NOT NULL AND latitude_deg_dec_max IS NOT NULL AND longitude_deg_dec_max IS NOT NULL THEN ST_SetSRID(ST_MakePolygon(ST_MakeLine(ARRAY[ST_MakePoint(longitude_deg_dec_min, latitude_deg_dec_min), ST_MakePoint(longitude_deg_dec_min, latitude_deg_dec_max), ST_MakePoint(longitude_deg_dec_max, latitude_deg_dec_max), ST_MakePoint(longitude_deg_dec_max, latitude_deg_dec_min), ST_MakePoint(longitude_deg_dec_min, latitude_deg_dec_min)])), 4326) END, turbidity, ph FROM import.co_data_sampling_environment a LEFT JOIN codelists.cl_landing b ON a.landing_site = b.landing_site GROUP BY ocean_code, a.landing_site, b.landing_country, capture_date, capture_date_min, capture_date_max, capture_time, capture_time_start, capture_time_end, activity_number, sea_surface_temp, well_position, well_number, landing_date, gear_code, vessel_code, vessel_name, vessel_storage_mode, remarks_capture, capture_depth, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max, turbidity, ph ORDER BY ocean_code;

-- co_well_sampling_environment
WITH wells AS
(
    SELECT trim(unnest(string_to_array(well_number, ';'))) AS well_number, trim(unnest(string_to_array(well_position, ';'))) AS well_position, id
    FROM co_sampling_environment
)
INSERT INTO co_well_sampling_environment (well_number, well_position, sampling_environment)
SELECT well_number, well_position, id FROM wells;

-- co_sampling_organism
INSERT INTO co_sampling_organism(id, sampling_platform, sampling_status, sampling_date, sampling_remarks, first_tag_number, second_tag_number, species_code_fao, stomach_prey_groups, organism_length_unit, organism_weight_unit, tissue_weight_unit, macro_maturity_stage, sex, otolith_count, otolith_breaking, shell_length, shell_height)
SELECT organism_identifier, sampling_platform, organism_sampling_status, organism_sampling_date, remarks_sampling, first_tag_number, second_tag_number, species_code_fao, stomach_prey_groups, organism_length_unit, organism_weight_unit, tissue_weight_unit, macro_maturity_stage::int, sex, otolith_number, otolith_breaking, shell_length, shell_height FROM import.co_data_sampling_organism;

-- co_project_sampling_organism
WITH projects AS
(
    SELECT trim(unnest(string_to_array(project, '/'))) AS project_id, organism_identifier
    FROM import.co_data_sampling_organism
)
INSERT INTO co_project_sampling_organism (project, sampling_organism)
SELECT project_id, organism_identifier FROM projects ;

-- co_organism_captured
WITH xxx AS
(
    SELECT unnest(organism_ids) as organism_id, id as env_id
    from core.co_sampling_environment
)
INSERT INTO co_organism_captured(sampling_organism, sampling_environment)
SELECT * FROM xxx ON CONFLICT (sampling_organism, sampling_environment) DO NOTHING;

ALTER TABLE co_sampling_environment DROP COLUMN organism_ids;
ALTER TABLE co_sampling_environment DROP COLUMN well_number;
ALTER TABLE co_sampling_environment DROP COLUMN well_position;

-- co_organism_measure
SELECT import.populate_organism_measures();

-- co_sample
INSERT INTO co_sample (id, tissue, position, sampling_organism)
SELECT sample_identifier, tissue, CASE WHEN length(trim(sample_position)) > 0 THEN sample_position END AS position, organism_identifier FROM import.co_data_prep WHERE sample_identifier NOT IN (SELECT sample_identifier FROM log_non_distinct_sample_entries) GROUP BY sample_identifier, tissue,position, organism_identifier;

-- co_subsample
INSERT INTO co_subsample (id, operator_name, location, sample, packaging1, storage_mode1, storage_date, drying_mode, drying_date, packaging_final, storage_mode_final, grinding_mode, remarks)
SELECT subsample_identifier, operator_name, location, sample_identifier, packaging_1, storage_mode_1, storage_date, drying_mode, drying_date, packaging_final, storage_mode_final, grinding_mode, remarks_analysis FROM import.co_data_prep WHERE sample_identifier IN (SELECT id FROM co_sample);

------------------
-- SCHEMA analysis
------------------
-- an_analysis
INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_amino_acids a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_contaminants_dioxin a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_contaminants_hg a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_contaminants_musk a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_contaminants_pcb a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_contaminants_pfc a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_contaminants_tm a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, operator_name, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_fatmeter a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, a.subsample_identifier FROM import.an_fatty_acids a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, a.subsample_identifier FROM import.an_lipid_classes a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, lab, operator_name, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_lab, a.operator_name, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_moisture a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, a.subsample_identifier FROM import.an_otolith_increment_counts a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name,  remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_otolith_morphometrics a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_proteins a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, lab, operator_name, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_lab, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_repro_fecundity a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, lab, operator_name, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_lab, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_repro_maturity a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_stable_isotopes a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_replicate, analysis_lab, a.operator_name, analysis_sample_description, a.remarks_analysis, analysis_date, a.subsample_identifier FROM import.an_total_lipids a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, lab, operator_name, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_lab, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_stomach_content_category a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_amino_acids
INSERT INTO an_amino_acids (analysis_id, aa_c_unit) SELECT talend_an_id, aa_c_unit FROM import.an_amino_acids WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_dioxin
INSERT INTO an_contaminants_dioxin (analysis_id, dioxin_c_unit, extraction_mode) SELECT talend_an_id, dioxin_c_unit, extraction_mode FROM import.an_contaminants_dioxin WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_hg
INSERT INTO an_contaminants_hg (analysis_id, analysis_sample_mass, analysis_sample_mass_unit, thg_c_unit, thg_q_unit) SELECT talend_an_id, analysis_sample_mass, analysis_sample_mass_unit, thg_c_unit, thg_q_unit FROM import.an_contaminants_hg WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_musk
INSERT INTO an_contaminants_musk (analysis_id, musk_c_unit, extraction_mode) SELECT talend_an_id, musk_c_unit, extraction_mode FROM import.an_contaminants_musk WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_pcb
INSERT INTO an_contaminants_pcbdeoc (analysis_id, pcbdeoc_c_unit, extraction_mode) SELECT talend_an_id, pcbdeoc_c_unit, extraction_mode FROM import.an_contaminants_pcb WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_pfc
INSERT INTO an_contaminants_pfc (analysis_id, pfc_c_unit, extraction_mode) SELECT talend_an_id, pfc_c_unit, extraction_mode FROM import.an_contaminants_pfc WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_tm
INSERT INTO an_contaminants_tm (analysis_id, analysis_sample_mass, analysis_sample_mass_unit, tm_c_unit) SELECT talend_an_id, analysis_sample_mass, analysis_sample_mass_unit, tm_c_unit FROM import.an_contaminants_tm WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_fatmeter
INSERT INTO an_fatmeter (analysis_id, fish_face, fatm_mode) SELECT talend_an_id, fish_face, fatm_mode FROM import.an_fatmeter WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_fatty_acids
INSERT INTO an_fatty_acids (analysis_id, processing_replicate, fractionation_mode, fraction_type, derivatization_mode, analysis_sample_mass, analysis_sample_mass_unit, fa_c_unit, extraction_mode, extraction_series)  SELECT talend_an_id, processing_replicate, fractionation_mode, fraction_type, derivatization_mode, analysis_sample_mass, analysis_sample_mass_unit, fa_c_unit, extraction_mode, extraction_serie FROM import.an_fatty_acids WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_lipid_classes
INSERT INTO an_lipid_classes (analysis_id, dilution_volume, spotted_volume, volume_unit, analysis_sample_mass, analysis_sample_mass_unit, lipidclasses_c_unit, extraction_mode, extraction_series)  SELECT talend_an_id, dilution_volume, spotted_volume, volume_unit, analysis_sample_mass, analysis_sample_mass_unit, lipidclasses_c_unit, extraction_mode, extraction_serie FROM import.an_lipid_classes WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_moisture
INSERT INTO an_moisture (analysis_id, weighing_unit)  SELECT talend_an_id, weighting_unit FROM import.an_moisture WHERE subsample_identifier IN (SELECT id FROM co_subsample)  AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_otolith_increment_count
INSERT INTO an_otolith_increment_count (analysis_id, part, section_type, increment_type, age_years, reading_method)  SELECT talend_an_id, otolith_part, otolith_section_type, increment_type, age_years, reading_method FROM import.an_otolith_increment_counts WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_otolith_morphometrics
INSERT INTO an_otolith_morphometrics (analysis_id, part, measurement_type, measurement_value, measurement_unit, reading_method)  SELECT talend_an_id, otolith_part, otolith_measurement_type, otolith_measurement_value, otolith_measurement_unit, reading_method FROM import.an_otolith_morphometrics WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_proteins
INSERT INTO an_proteins (analysis_id, analysis_sample_mass, analysis_sample_mass_unit, dilution_factor, prot_c_unit, prot_q_unit, spotted_volume)  SELECT talend_an_id, analysis_sample_mass, analysis_sample_mass_unit, dilution_factor, proteins_c_unit, proteins_q_unit, spotted_volume FROM import.an_proteins WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_reproduction_maturity
INSERT INTO an_reproduction_maturity (analysis_id, micro_sex, micro_maturity_stage, mago_substage, mago_stage, sample_state_before_process, pof, a_atresia, b_atresia, brown_bodies, muscle_bundles, rho, repro_phase, repro_subphase, atretic_oocyte_stage, atretic_oocyte_percent, atretic_stage)  SELECT talend_an_id, micro_sex, micro_maturity, mago_substage, mago_stage, sample_state_before_process, trim(pof), CASE WHEN upper(trim(a_atresia)) = 'Y' THEN TRUE WHEN upper(trim(a_atresia)) = 'N' THEN FALSE END, CASE WHEN upper(trim(b_atresia)) = 'Y' THEN TRUE WHEN upper(trim(b_atresia)) = 'N' THEN FALSE END, CASE WHEN upper(trim(brown_bodies)) = 'Y' THEN TRUE WHEN upper(trim(brown_bodies)) = 'N' THEN FALSE END, CASE WHEN upper(trim(muscle_bundles)) = 'Y' THEN TRUE WHEN upper(trim(muscle_bundles)) = 'N' THEN FALSE END, CASE WHEN upper(trim(rho)) = 'Y' THEN TRUE WHEN upper(trim(rho)) = 'N' THEN FALSE END, repro_phase, repro_subphase, trim(atretic_oocyte_stage), atresia_percent, atretic_stage FROM import.an_repro_maturity WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_missing_micro_maturity_combinations);

-- an_stable_isotopes
INSERT INTO an_stable_isotopes (analysis_id, processing_replicate, si_plate_code, analysis_sample_mass, lipid_remov_mode, urea_remov_mode, carbonate_remov_mode)  SELECT talend_an_id, processing_replicate, si_plate_code, analysis_sample_mass, lipid_remov_mode, urea_remov_mode, carbonate_remov_mode FROM import.an_stable_isotopes WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_stomach_content
INSERT INTO an_stomach_content (analysis_id, scc_unit)  SELECT talend_an_id, scc_unit FROM import.an_stomach_content_category WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_total_lipids
INSERT INTO an_total_lipids (analysis_id, analysis_sample_mass, analysis_sample_mass_unit, material_empty_mass, material_lipids_mass, lipids_q_unit, lipids_c_unit, extraction_mode)  SELECT talend_an_id, analysis_sample_mass, analysis_sample_mass_unit, material_empty_mass, material_lipids_mass, lipids_q_unit, lipids_c_unit, extraction_mode FROM import.an_total_lipids WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_analysis_reference_material
CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_amino_acids;
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_dioxin;
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_hg;
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_musk;
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_pcb;
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_pfc;
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_tm;
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis);
DROP TABLE ref_mat;

-- an_analysis_measure
SELECT import.populate_analysis_measures();


-- Derive geometry for sampling environment entries without explicitly provided coordinates:
-- Exclusive Economic Zone of Ivory Coast
UPDATE co_sampling_environment
SET (geom, geom_uncertainty_sqkm) = (SELECT geom, ROUND((ST_Area(geom::geography)/1e6)::numeric, 1) FROM st_eez WHERE iso_ter1 LIKE 'CIV')
WHERE geom IS NULL AND sampling_remarks ILIKE '%Ivory Coast EEZ%';

-- Mahé Plateau of Seychelles
UPDATE co_sampling_environment
SET (geom, geom_uncertainty_sqkm) = (SELECT geom, ROUND((ST_Area(geom::geography)/1e6)::numeric, 1) FROM st_mahe_plateau)
WHERE geom IS NULL AND sampling_remarks ILIKE '%Mahe Plateau%';

-- EEZ of Seychelles
UPDATE co_sampling_environment
SET (geom, geom_uncertainty_sqkm) = (SELECT geom, ROUND((ST_Area(geom::geography)/1e6)::numeric, 1) FROM st_eez WHERE iso_ter1 LIKE 'SYC')
WHERE geom IS NULL AND sampling_remarks ILIKE '%SYC EEZ%';

-- Indian Ocean basin (indicated with WKT_IO in the remarks)
UPDATE co_sampling_environment
SET (geom, geom_uncertainty_sqkm) = (SELECT geom, ST_area(geom::geography)/1000000 FROM st_rfmos WHERE gid = 4)
WHERE (geom IS NULL AND sampling_remarks LIKE '%WKT_IO%');

-- Atlantic Ocean basin (indicated with WKT_AO in the remarks)
UPDATE co_sampling_environment
SET (geom, geom_uncertainty_sqkm) = (SELECT geom, ST_area(geom::geography)/1000000 FROM st_rfmos WHERE gid = 3)
WHERE (geom IS NULL AND sampling_remarks LIKE '%WKT_AO%');

COMMIT;
