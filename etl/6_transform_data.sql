BEGIN;

SET SEARCH_PATH TO metadata, core, codelists, analysis, import_log, public;

TRUNCATE md_ddd CASCADE;
TRUNCATE md_analysis_tracer_detail CASCADE;
TRUNCATE md_organism_measure_detail CASCADE;
TRUNCATE co_sampling_organism CASCADE;
TRUNCATE co_sampling_environment CASCADE;
TRUNCATE co_organism_measure CASCADE;
TRUNCATE co_organism_captured CASCADE;
TRUNCATE co_sample CASCADE;
TRUNCATE co_subsample CASCADE;
TRUNCATE an_analysis CASCADE;
TRUNCATE an_analysis_reference_material CASCADE;
TRUNCATE an_analysis_measure CASCADE;

------------------
-- SCHEMA METADATA
------------------
-- md_ddd
INSERT INTO md_ddd SELECT * FROM import.md_ddd_database;

-- md_analysis_tracer_detail
ALTER SEQUENCE md_analysis_tracer_detail_id_seq RESTART;
INSERT INTO md_analysis_tracer_detail(analysis_type, tracer_name, standard_unit, tracer_description, views_level)
SELECT entity, variable, unit, comment, views_level FROM md_ddd a
WHERE tracer = 1 AND NOT EXISTS (SELECT 1 FROM metadata.md_ddd b WHERE a.entity = b.entity AND
                   a.variable = b.variable GROUP BY entity, variable HAVING COUNT(*) > 1) ORDER BY entity, variable;

-- md_organism_measure_detail
INSERT INTO md_organism_measure_detail(measure_name, standard_unit, measure_description) SELECT variable,
unit, comment FROM md_ddd WHERE tracer = 2 ORDER BY variable;

--------------
-- SCHEMA CORE
--------------
-- co_sampling_environment
ALTER TABLE co_sampling_environment DROP COLUMN IF EXISTS organism_ids;
ALTER TABLE co_sampling_environment ADD COLUMN organism_ids text[];
INSERT INTO co_sampling_environment(id, landing_date, landing_site, landing_country, capture_date, capture_date_min, capture_date_max, capture_time, capture_time_start, capture_time_end, activity_number, sea_surface_temperature_deg_celcius, well_position, well_number, ocean_code, gear_code, vessel_code, vessel_name, vessel_storage_mode, sampling_remarks, capture_depth_m, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max, organism_ids, geom)
 SELECT ocean_code || lpad((row_number() over ())::text, 8, '0'), landing_date, a.landing_site, b.landing_country, capture_date, capture_date_min, capture_date_max, CASE WHEN position(':' in capture_time) > 0 THEN capture_time::time ELSE time '00:00' + make_interval(secs => capture_time::decimal*86400) END, time '00:00' + make_interval(secs => capture_time_start::decimal*86400), time '00:00' + make_interval(secs => capture_time_end::decimal*86400), activity_number::float::int, sea_surface_temp, CASE WHEN well_position IN ('1', '2', '3', 'unknown') THEN well_position END, well_number, ocean_code, upper(gear_code), vessel_code, vessel_name, vessel_storage_mode, remarks_capture, capture_depth, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max, array_agg(organism_identifier), CASE WHEN latitude_deg_dec IS NOT NULL AND longitude_deg_dec IS NOT NULL THEN ST_SetSRID(ST_MakePoint(longitude_deg_dec, latitude_deg_dec), 4326) WHEN latitude_deg_dec_min IS NOT NULL AND longitude_deg_dec_min IS NOT NULL AND latitude_deg_dec_max IS NOT NULL AND longitude_deg_dec_max IS NOT NULL THEN ST_SetSRID(ST_MakePolygon(ST_MakeLine(ARRAY[ST_MakePoint(longitude_deg_dec_min, latitude_deg_dec_min), ST_MakePoint(longitude_deg_dec_min, latitude_deg_dec_max), ST_MakePoint(longitude_deg_dec_max, latitude_deg_dec_max), ST_MakePoint(longitude_deg_dec_max, latitude_deg_dec_min), ST_MakePoint(longitude_deg_dec_min, latitude_deg_dec_min)])), 4326) END FROM import.co_data_sampling_environment a LEFT JOIN codelists.cl_landing b ON a.landing_site = b.landing_site GROUP BY ocean_code, a.landing_site, b.landing_country, capture_date, capture_date_min, capture_date_max, capture_time, capture_time_start, capture_time_end, activity_number, sea_surface_temp, well_position, well_number, landing_date, gear_code, vessel_code, vessel_name, vessel_storage_mode, remarks_capture, capture_depth, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max ORDER BY ocean_code;

-- co_sampling_organism
INSERT INTO cl_otolith_breaking VALUES('none', 'No otolith found') ON CONFLICT (otolith_breaking) DO NOTHING;
UPDATE cl_sex SET sex = upper(sex);

INSERT INTO co_sampling_organism(id, sampling_platform, sampling_status, sampling_date, sampling_remarks, first_tag_number, second_tag_number, species_code_fao, stomach_prey_groups, organism_length_unit, organism_weight_unit, tissue_weight_unit, macro_maturity_stage, sex, otolith_count, otolith_breaking)
SELECT organism_identifier, sampling_platform, organism_sampling_status, organism_sampling_date, remarks_sampling, first_tag_number, second_tag_number, species_code_fao, stomach_prey_groups, organism_length_unit, organism_weight_unit, tissue_weight_unit, macro_maturity_stage::int, upper(sex), otolith_number, otolith_breaking FROM import.co_data_sampling_organism;

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

-- co_organism_measure
CREATE OR REPLACE FUNCTION import.populate_organism_measures () RETURNS VOID AS
$func$
DECLARE
    measure_curs CURSOR FOR SELECT measure_name FROM metadata.md_organism_measure_detail;
BEGIN
    FOR recordvar IN measure_curs LOOP
        -- Log cases where text was stored in columns that are supposed to be numeric
        EXECUTE
        format('INSERT INTO import_log.log_invalid_organism_measure_values SELECT organism_identifier, $1, %I::text
               FROM import.co_data_sampling_organism WHERE length(trim(%I::text)) > 0 AND %I::text !~ ' || quote_literal('^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')
             , recordvar.measure_name, recordvar.measure_name, recordvar.measure_name)
        USING recordvar.measure_name;
        EXECUTE
        format('UPDATE import.co_data_sampling_organism SET %I = NULL WHERE length(trim(%I::text)) = 0 OR %I::text !~ ' || quote_literal('^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')
             , recordvar.measure_name, recordvar.measure_name, recordvar.measure_name);
        EXECUTE
        format('INSERT INTO core.co_organism_measure SELECT organism_identifier, $1, %I::double precision, NULL
               FROM import.co_data_sampling_organism WHERE %I IS NOT NULL'
             , recordvar.measure_name, recordvar.measure_name)
        USING recordvar.measure_name;
    END LOOP;
END
$func$ LANGUAGE plpgsql;

SELECT import.populate_organism_measures();

-- co_sample
INSERT INTO co_sample (id, tissue, position, sampling_organism)
SELECT sample_identifier, b.tissue_code, CASE WHEN length(trim(sample_position)) = 0 THEN NULL ELSE sample_position END AS position, organism_identifier FROM import.co_data_prep a LEFT JOIN cl_tissue b ON a.tissue = b.tissue_en WHERE sample_identifier NOT IN (SELECT sample_identifier FROM log_non_distinct_sample_entries) GROUP BY sample_identifier, b.tissue_code,position, organism_identifier;

-- co_subsample
INSERT INTO co_subsample (id, operator_name, location, sample, packaging1, storage_mode1, storage_date, drying_mode, drying_date, packaging_final, storage_mode_final, grinding_mode, remarks)
SELECT subsample_identifier, operator_name, location, sample_identifier, packaging_1, lower(storage_mode_1), CASE WHEN storage_date::text ~ '[a-zA-Z]' THEN NULL ELSE storage_date::date END, drying_mode, CASE WHEN drying_date::text ~ '[a-zA-Z]' THEN NULL ELSE drying_date::date END, packaging_final, lower(storage_mode_final), grinding_mode, remarks_analysis FROM import.co_data_prep WHERE sample_identifier IN (SELECT id FROM co_sample);

-- an_analysis
INSERT INTO cl_analysis_replicate VALUES('ran11', 'Eleventh analytical replicate') ON CONFLICT (analysis_replicate) DO NOTHING;
INSERT INTO cl_analysis_replicate VALUES('ran12', 'Twelfth analytical replicate') ON CONFLICT (analysis_replicate) DO NOTHING;
INSERT INTO cl_analysis_replicate VALUES('ran13', 'Thirteenth analytical replicate') ON CONFLICT (analysis_replicate) DO NOTHING;

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date::date, a.subsample_identifier FROM import.an_amino_acids a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date::date, a.subsample_identifier FROM import.an_contaminants_dioxin a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date::date, a.subsample_identifier FROM import.an_contaminants_hg a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, CASE WHEN analysis_date::text ~ '[a-zA-Z]' THEN NULL ELSE analysis_date::date END, a.subsample_identifier FROM import.an_contaminants_musk a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, CASE WHEN analysis_date::text ~ '(\d{2})/(\d{2})/(\d{4})' THEN to_date(analysis_date::text, 'DD/MM/YYYY') WHEN analysis_date::text ~ '(\d{4})-(\d{2})' THEN to_date(analysis_date::text, 'YYYY-MM') ELSE analysis_date::date END, a.subsample_identifier FROM import.an_contaminants_pcb a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, CASE WHEN analysis_date::text ~ '(\d{2})/(\d{2})/(\d{4})' THEN to_date(analysis_date::text, 'DD/MM/YYYY') WHEN analysis_date::text ~ '(\d{4})-(\d{2})' THEN to_date(analysis_date::text, 'YYYY-MM') ELSE analysis_date::date END, a.subsample_identifier FROM import.an_contaminants_pfc a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date::date, a.subsample_identifier FROM import.an_contaminants_tm a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, operator_name, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_fatmeter a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, a.subsample_identifier FROM import.an_fatty_acids a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, a.subsample_identifier FROM import.an_lipid_classes a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, lab, operator_name, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_lab, a.operator_name, analysis_mode, a.remarks_analysis, analysis_date::date, a.subsample_identifier FROM import.an_moisture a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, a.subsample_identifier FROM import.an_otolith_increment_counts a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name,  remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_otolith_morphometrics a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, analysis_date::date, a.subsample_identifier FROM import.an_proteins a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, lab, operator_name, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_lab, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_repro_fecundity a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, lab, operator_name, remarks, subsample)
SELECT talend_an_id, analysis, analysis_group, analysis_lab, a.operator_name, a.remarks_analysis, a.subsample_identifier FROM import.an_repro_maturity a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, mode, remarks, an_date, subsample)
SELECT talend_an_id, analysis, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, analysis_mode, a.remarks_analysis, CASE WHEN analysis_date::text ~ '(\d{2})/(\d{2})/(\d{4})' THEN to_date(analysis_date::text, 'DD/MM/YYYY') WHEN analysis_date::text ~ '(\d{4})-(\d{2})' THEN to_date(analysis_date::text, 'YYYY-MM') WHEN analysis_date::text ~ '(\d{4})-(\d{2})-(\d{2})' THEN analysis_date::date END, a.subsample_identifier FROM import.an_stable_isotopes a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

INSERT INTO an_analysis (id, type, an_group, replicate, lab, operator_name, sample_description, remarks, an_date, subsample)
SELECT talend_an_id, CASE WHEN analysis = 'TLC' THEN 'TL' ELSE analysis END, analysis_group, lower(analysis_replicate), analysis_lab, a.operator_name, analysis_sample_description, a.remarks_analysis, analysis_date::date, a.subsample_identifier FROM import.an_total_lipids a join import.co_data_prep b on a.subsample_identifier = b.subsample_identifier WHERE a.subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

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
UPDATE import.an_contaminants_pcb SET pcbdeoc_c_unit = 'pg/g dw' WHERE pcbdeoc_c_unit = 'pg.g dw';
INSERT INTO an_contaminants_pcbdeoc (analysis_id, pcbdeoc_c_unit, extraction_mode) SELECT talend_an_id, pcbdeoc_c_unit, extraction_mode FROM import.an_contaminants_pcb WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_pfc
INSERT INTO an_contaminants_pfc (analysis_id, pfc_c_unit, extraction_mode) SELECT talend_an_id, pfc_c_unit, extraction_mode FROM import.an_contaminants_pfc WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_contaminants_tm
INSERT INTO an_contaminants_tm (analysis_id, analysis_sample_mass, analysis_sample_mass_unit, tm_c_unit) SELECT talend_an_id, analysis_sample_mass, analysis_sample_mass_unit, tm_c_unit FROM import.an_contaminants_tm WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_fatmeter
INSERT INTO an_fatmeter (analysis_id, fish_face, fatm_mode) SELECT talend_an_id, fish_face, fatm_mode FROM import.an_fatmeter WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_fatty_acids
UPDATE import.an_fatty_acids SET analysis_sample_mass_unit = NULL WHERE length(trim(analysis_sample_mass_unit)) = 0;
UPDATE import.an_fatty_acids SET fractionation_mode = 'SI µcolumn' WHERE fractionation_mode = 'Si µcolumn';
INSERT INTO an_fatty_acids (analysis_id, processing_replicate, fractionation_mode, fraction_type, derivatization_mode, analysis_sample_mass, analysis_sample_mass_unit, fa_c_unit, extraction_mode, extraction_series)  SELECT talend_an_id, processing_replicate, fractionation_mode, fraction_type, derivatization_mode, analysis_sample_mass, analysis_sample_mass_unit, fa_c_unit, extraction_mode, extraction_serie FROM import.an_fatty_acids WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_lipid_classes
INSERT INTO cl_measure_unit VALUES ('µl', 'microliter', 'volume') ON CONFLICT (measure_unit) DO NOTHING;
INSERT INTO an_lipid_classes (analysis_id, dilution_volume, spotted_volume, volume_unit, analysis_sample_mass, analysis_sample_mass_unit, lipidclasses_c_unit, extraction_mode, extraction_series)  SELECT talend_an_id, dilution_volume, spotted_volume, volume_unit, analysis_sample_mass, analysis_sample_mass_unit, lipidclasses_c_unit, extraction_mode, extraction_serie FROM import.an_lipid_classes WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_moisture
INSERT INTO an_moisture (analysis_id, weighing_unit)  SELECT talend_an_id, weighting_unit FROM import.an_moisture WHERE subsample_identifier IN (SELECT id FROM co_subsample)  AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_otolith_increment_count
UPDATE cl_increment_type SET increment_type = 'annually' WHERE increment_type = 'annualy';
UPDATE import.an_otolith_increment_counts SET increment_type = 'annually' WHERE increment_type ILIKE 'annual%';
INSERT INTO an_otolith_increment_count (analysis_id, part, section_type, increment_type, age_years, reading_method)  SELECT talend_an_id, otolith_part, otolith_section_type, increment_type, age_years, reading_method FROM import.an_otolith_increment_counts WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_otolith_morphometrics
INSERT INTO an_otolith_morphometrics (analysis_id, part, measurement_type, measurement_value, measurement_unit, reading_method)  SELECT talend_an_id, otolith_part, otolith_measurement_type, otolith_measurement_value, otolith_measurement_unit, reading_method FROM import.an_otolith_morphometrics WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_proteins
INSERT INTO an_proteins (analysis_id, analysis_sample_mass, analysis_sample_mass_unit, dilution_factor, prot_c_unit, prot_q_unit, spotted_volume)  SELECT talend_an_id, analysis_sample_mass, analysis_sample_mass_unit, dilution_factor, proteins_c_unit, proteins_q_unit, spotted_volume FROM import.an_proteins WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_reproduction_maturity
UPDATE import.an_repro_maturity SET atretic_oocyte_stage = NULL WHERE length(trim(atretic_oocyte_stage)) = 0;
INSERT INTO an_reproduction_maturity (analysis_id, micro_sex, micro_maturity_stage, mago_substage, mago_stage, pof, a_atresia, b_atresia, brown_bodies, muscle_bundles, rho, ovary_wall, repro_phase, repro_subphase, atretic_oocyte_stage, atretic_oocyte_percent, atretic_stage)  SELECT talend_an_id, micro_sex, micro_maturity, mago_substage, mago_stage, upper(trim(pof)), CASE WHEN upper(trim(a_atresia)) = 'Y' THEN TRUE WHEN upper(trim(a_atresia)) = 'N' THEN FALSE END, CASE WHEN upper(trim(b_atresia)) = 'Y' THEN TRUE WHEN upper(trim(b_atresia)) = 'N' THEN FALSE END, CASE WHEN upper(trim(brown_bodies)) = 'Y' THEN TRUE WHEN upper(trim(brown_bodies)) = 'N' THEN FALSE END, CASE WHEN upper(trim(muscle_bundles)) = 'Y' THEN TRUE WHEN upper(trim(muscle_bundles)) = 'N' THEN FALSE END, CASE WHEN upper(trim(rho)) = 'Y' THEN TRUE WHEN upper(trim(rho)) = 'N' THEN FALSE END, ovary_wall::numeric, repro_phase, repro_subphase, trim(atretic_oocyte_stage), atresia_percent, CASE WHEN atretic_stage ILIKE '%minor%' THEN 0 WHEN atretic_stage ILIKE '%moderate%' THEN 1 WHEN atretic_stage ILIKE '%major%' THEN 2 WHEN atretic_stage ILIKE '%complete%' THEN 3 END FROM import.an_repro_maturity WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_missing_micro_maturity_combinations);

-- an_stable_isotopes
INSERT INTO an_stable_isotopes (analysis_id, processing_replicate, si_plate_code, analysis_sample_mass, lipid_remov_mode, urea_remov_mode, carbonate_remov_mode)  SELECT talend_an_id, processing_replicate, si_plate_code, analysis_sample_mass, lipid_remov_mode, urea_remov_mode, carbonate_remov_mode FROM import.an_stable_isotopes WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_stomach_content
INSERT INTO an_stomach_content (analysis_id, scc_unit)  SELECT talend_an_id, scc_unit FROM import.an_stomach_content_category WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_total_lipids
INSERT INTO an_total_lipids (analysis_id, analysis_sample_mass, analysis_sample_mass_unit, material_empty_mass, material_lipids_mass, lipids_q_unit, lipids_c_unit, extraction_mode)  SELECT talend_an_id, analysis_sample_mass, analysis_sample_mass_unit, material_empty_mass, material_lipids_mass, lipids_q_unit, lipids_c_unit, extraction_mode FROM import.an_total_lipids WHERE subsample_identifier IN (SELECT id FROM co_subsample) AND talend_an_id NOT IN (SELECT talend_an_id FROM log_duplicate_analysis_ids);

-- an_analysis_reference_material
CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_amino_acids;
INSERT INTO log_missing_reference_material SELECT * FROM ref_mat WHERE mat NOT IN (SELECT reference_material FROm cl_reference_material);
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis) AND mat IN (SELECT reference_material FROM cl_reference_material);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_dioxin;
INSERT INTO log_missing_reference_material SELECT * FROM ref_mat WHERE mat NOT IN (SELECT reference_material FROm cl_reference_material);
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis) AND mat IN (SELECT reference_material FROM cl_reference_material);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_hg;
INSERT INTO log_missing_reference_material SELECT * FROM ref_mat WHERE mat NOT IN (SELECT reference_material FROm cl_reference_material);
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis) AND mat IN (SELECT reference_material FROM cl_reference_material);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_musk;
INSERT INTO log_missing_reference_material SELECT * FROM ref_mat WHERE mat NOT IN (SELECT reference_material FROm cl_reference_material);
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis) AND mat IN (SELECT reference_material FROM cl_reference_material);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_pcb;
INSERT INTO log_missing_reference_material SELECT * FROM ref_mat WHERE mat NOT IN (SELECT reference_material FROm cl_reference_material);
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis) AND mat IN (SELECT reference_material FROM cl_reference_material);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_pfc;
INSERT INTO log_missing_reference_material SELECT * FROM ref_mat WHERE mat NOT IN (SELECT reference_material FROm cl_reference_material);
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis) AND mat IN (SELECT reference_material FROM cl_reference_material);
DROP TABLE ref_mat;

CREATE TEMP TABLE ref_mat AS SELECT talend_an_id, trim(unnest(string_to_array(reference_material::text, ';'))) as mat FROM import.an_contaminants_tm;
INSERT INTO log_missing_reference_material SELECT * FROM ref_mat WHERE mat NOT IN (SELECT reference_material FROm cl_reference_material);
INSERT INTO an_analysis_reference_material SELECT * FROM ref_mat WHERE talend_an_id IN (SELECT id FROM an_analysis) AND mat IN (SELECT reference_material FROM cl_reference_material);
DROP TABLE ref_mat;

-- an_analysis_measure
CREATE OR REPLACE FUNCTION import.populate_analysis_measures() RETURNS VOID AS
$func$
DECLARE
    tracer_rec RECORD;
    test_count INT;
    tablename_curs CURSOR FOR SELECT tablename FROM pg_tables WHERE schemaname = 'import' AND tablename LIKE 'an_%';
BEGIN
    FOR table_rec IN tablename_curs LOOP
        FOR tracer_rec IN EXECUTE format ('SELECT id, lower(tracer_name) AS tracer_name FROM metadata.md_analysis_tracer_detail WHERE replace($1,' || quote_literal('_') ||  ',' || quote_literal('') || ') LIKE ' || quote_literal('%%') || ' || replace(analysis_type,' || quote_literal('_') ||  ',' || quote_literal('') || ')') USING table_rec.tablename
        LOOP
            EXECUTE format('SELECT count(*) FROM information_schema.columns WHERE table_schema = ' || quote_literal('import') || ' AND table_name = $1 AND column_name = $2') INTO test_count USING table_rec.tablename, tracer_rec.tracer_name;
            IF test_count = 0 THEN
                CONTINUE;
            END IF;
            -- Log cases where text was stored in columns that are supposed to be numeric
            EXECUTE
            format('INSERT INTO import_log.log_invalid_analysis_measure_values SELECT talend_an_id, $1, %I::text
                   FROM import.%I WHERE length(trim(%I::text)) > 0 AND %I::text !~ ' || quote_literal('^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')
                 , tracer_rec.tracer_name, table_rec.tablename, tracer_rec.tracer_name, tracer_rec.tracer_name)
            USING tracer_rec.tracer_name;
            EXECUTE
            format('UPDATE import.%I SET %I = NULL WHERE length(trim(%I::text)) = 0 OR %I::text !~ ' || quote_literal('^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$')
                 , table_rec.tablename, tracer_rec.tracer_name, tracer_rec.tracer_name, tracer_rec.tracer_name);
            EXECUTE
            format('INSERT INTO analysis.an_analysis_measure SELECT talend_an_id, $1, %I::double precision, NULL
                   FROM import.%I WHERE %I IS NOT NULL AND talend_an_id IN (SELECT id FROM analysis.an_analysis)'
                 , tracer_rec.tracer_name, table_rec.tablename, tracer_rec.tracer_name)
            USING tracer_rec.id;
        END LOOP;
    END LOOP;
END
$func$ LANGUAGE plpgsql;

SELECT import.populate_analysis_measures();

COMMIT;
