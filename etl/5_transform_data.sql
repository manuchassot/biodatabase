------------------
-- SCHEMA METADATA
------------------
SET SEARCH_PATH TO metadata, public;

-- md_ddd
DELETE FROM md_ddd;
INSERT INTO md_ddd SELECT * FROM import.md_ddd_database;

-- md_analysis_tracer_detail
DELETE FROM md_analysis_tracer_detail;
ALTER SEQUENCE md_analysis_tracer_detail_id_seq RESTART;
INSERT INTO md_analysis_tracer_detail(analysis_type, tracer_name, standard_unit, tracer_description, views_level)
SELECT entity, variable, unit, comment, views_level FROM md_ddd a
WHERE tracer = 1 AND NOT EXISTS (SELECT 1 FROM metadata.md_ddd b WHERE a.entity = b.entity AND
                   a.variable = b.variable GROUP BY entity, variable HAVING COUNT(*) > 1) ORDER BY entity, variable;

DROP TABLE IF EXISTS import.err_duplicate_tracers;
CREATE TABLE import.err_duplicate_tracers AS SELECT entity, variable, count(*) FROM metadata.md_ddd
GROUP BY entity, variable HAVING COUNT(*) > 1;

-- md_organism_measure_detail
DELETE FROM md_organism_measure_detail;
INSERT INTO md_organism_measure_detail(measure_name, standard_unit, measure_description) SELECT variable,
unit, comment FROM md_ddd WHERE tracer = 2 ORDER BY variable;

--------------
-- SCHEMA CORE
--------------
SET SEARCH_PATH TO core, public;

-- co_sampling_environment
DELETE FROM co_sampling_environment;
INSERT INTO co_sampling_environment(id, landing_date, landing_site, landing_country, capture_date, capture_date_min, capture_date_max, capture_time, capture_time_start, capture_time_end, activity_number, sea_surface_temperature_deg_celcius, well_position, well_number, ocean_code, gear_code, vessel_code, vessel_name, vessel_storage_mode, sampling_remarks, capture_depth_m, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max)
 SELECT ocean_code || '_' || row_number() over (), landing_date, a.landing_site, b.landing_country, capture_date, capture_date_min, capture_date_max, CASE WHEN position(':' in capture_time) > 0 THEN capture_time::time ELSE time '00:00' + make_interval(secs => capture_time::decimal*86400) END, time '00:00' + make_interval(secs => capture_time_start::decimal*86400), time '00:00' + make_interval(secs => capture_time_end::decimal*86400), activity_number::float::int, sea_surface_temp, 'TB' AS well_position, well_number, ocean_code, upper(gear_code), vessel_code, vessel_name, vessel_storage_mode, remarks_capture, capture_depth, aggregation, description_aggregation, latitude_deg_dec, latitude_deg_dec_min, latitude_deg_dec_max, longitude_deg_dec, longitude_deg_dec_min, longitude_deg_dec_max FROM import.co_data_sampling_environment a LEFT JOIN codelists.cl_landing b ON a.landing_site = b.landing_site ORDER BY ocean_code;
