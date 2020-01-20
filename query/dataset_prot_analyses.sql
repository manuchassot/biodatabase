-- Data set of protein analyses
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Values of protein concentration
-- Does not include the values of protein concentration that could be derived from the sum of amino-acids (TO ADD)
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
am.measure_name,
am.measure_value_avg AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
WHERE am.analysis_type LIKE 'Prot'
--AND so.tissue IN ('White muscle')
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description