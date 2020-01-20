-- Information on sample bank
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- E Chassot
-- 20/01/2020
-- Au Cap, Seychelles

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
so.sample_origin_id,
sb.sample_id,
ROUND( (( (sdb.material_sample_wet_weight-sdb.material_empty_mass) - (sdb.material_sample_dry_weight-sdb.material_empty_mass))/( (sdb.material_sample_wet_weight-sdb.material_empty_mass) ) * 100)::numeric,0) AS water_content,
sb.sample_location
FROM public.sample_bank sb
LEFT JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
LEFT JOIN public.sample_dryed_bank sdb ON (sb.sample_id=sdb.sample_id) 
LEFT JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
LEFT JOIN public.fishes_environments_calculated fc ON (fc.fish_identifier = fish.fish_identifier)
--WHERE ((so.tissue LIKE 'White muscle' AND so.sample_position IN ('','FD') ) OR (so.tissue LIKE 'Liver') OR (so.tissue LIKE 'Mantle'))
--AND analysis_group IN ('FA','SI','O','M')   -- TO CONFIRM
WHERE so.sample_origin_id NOT LIKE '%T6';