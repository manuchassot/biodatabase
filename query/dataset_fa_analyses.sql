-- Data set of fatty acids analyses
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Values of fatty acids expressed in proportion or concentration
-- Analyses replicates were averaged over sample_ids (analysis_tables.averaged_analysis_replicates_contaminants_hg)
-- E Chassot
-- 20/01/2020
-- Au Cap, Seychelles

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
sb.sample_origin_id,
am.sample_id,
am.analysis_sample_description,
(CASE WHEN am.fraction_type LIKE 'PL' THEN am.measure_name || '_pl' ELSE (CASE WHEN am.fraction_type LIKE 'NL' THEN am.measure_name || '_nl' ELSE (CASE WHEN am.fraction_type LIKE 'TL' THEN am.measure_name || '_tl' ELSE am.measure_name END) END)END) AS measure_name,
am.measure_value_avg AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
WHERE am.analysis_type LIKE 'FA'
AND ( (am.measure_name LIKE ('%_p')) OR (am.measure_name LIKE ('%_c') ) )
ORDER BY so.fish_identifier,so.tissue,so.sample_position,sb.sample_origin_id,am.sample_id,am.analysis_sample_description;