BEGIN;

SET SEARCH_PATH TO metadata, public;

-- md_ddd
INSERT INTO md_ddd (entity, variable, data_type, unit, basic_checks, comment, tracer, views_level)  SELECT CASE WHEN length(trim(entity)) > 0 THEN entity END, CASE WHEN length(trim(variable)) > 0 THEN variable END, CASE WHEN length(trim(data_type)) > 0 THEN data_type END, CASE WHEN length(trim(unit)) > 0 THEN unit END, CASE WHEN length(trim(basic_checks)) > 0 THEN 'cl_' || lower(basic_checks) END, comment, tracer, views_level FROM import.md_ddd_database;

-- md_analysis_tracer_detail
ALTER SEQUENCE md_analysis_tracer_detail_id_seq RESTART;
INSERT INTO md_analysis_tracer_detail(analysis_type, tracer_name, standard_unit, tracer_description, views_level, ref_table, data_type)
SELECT entity, variable, unit, comment, views_level, basic_checks, data_type FROM md_ddd a
WHERE tracer = 1 AND NOT EXISTS (SELECT 1 FROM metadata.md_ddd b WHERE a.entity = b.entity AND
                   a.variable = b.variable GROUP BY entity, variable HAVING COUNT(*) > 1) ORDER BY entity, variable;

-- md_organism_measure_detail
INSERT INTO md_organism_measure_detail(measure_name, standard_unit, measure_description) SELECT variable,
unit, comment FROM md_ddd WHERE tracer = 2 ORDER BY variable;

COMMIT;