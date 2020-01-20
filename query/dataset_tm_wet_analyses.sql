-- Full data set of metallic contaminants analyses made in wet weight
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Values of metallic contaminants expressed in wet weight
-- No analysis replicate was made for metallic contaminants
-- Values are extracted from analysis_tables.analysis_measures
-- E Chassot
-- 20/01/2020
-- Au Cap, Seychelles

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
sb.sample_origin_id AS sample_identifier,
am.sample_id AS subsample_identifier,
am.analysis_sample_description,
am.measure_name || '_ww' AS measure_name,
--ROUND(CASE WHEN am.analysis_sample_description LIKE 'wet bulk' THEN am.measure_value_avg ELSE am.measure_value_avg / 4::double precision END::numeric,4) AS measure_value
ROUND(am.measure_value_avg::numeric,4) AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
WHERE am.analysis_type LIKE 'TM'
AND am.analysis_sample_description LIKE 'wet bulk'
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description;