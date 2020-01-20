-- Full data set of mercury analyses made in dry weight
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Values of mercury for each sample expressed in dry weight
-- Analyses replicates were averaged over sample_ids (analysis_tables.averaged_analysis_replicates_contaminants_hg)
-- E Chassot
-- 20/01/2020
-- Au Cap, Seychelles

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
sb.sample_origin_id AS sample_identifier,
am.sample_id AS subsample_identifier,
am.analysis_sample_description,
am.measure_name || '_dw' AS measure_name,
ROUND(am.measure_value_avg::numeric,4) AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
WHERE am.measure_name LIKE 'THg_c'
AND am.analysis_sample_description LIKE 'dry bulk'
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description;