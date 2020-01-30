-- Fish collected with samples
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Anywhere in the world (i.e. all oceans)
-- Do not include historical fish collected as part of the IRD/DCR/DCF programs at the IOT Ltd. cannery
-- Filters: fish.project NOT IN ('BIOMCO','BIOMCO1','PATUDO','IOT-stomachs') AND extract(year FROM fish.fish_sampling_date)>2008
-- Link with the sample bank
-- Any type of sample: No filter in sample_bank_info except for the few fish collected as part of the SAUMTEST project (WHERE so.sample_origin_id NOT LIKE '%T6')
-- E Chassot
-- 28/01/2020
-- Victoria, Seychelles


DROP TABLE IF EXISTS fish_collected_with_samples;
CREATE TEMP TABLE fish_collected_with_samples AS 

WITH fish_sampled AS (

SELECT DISTINCT
fe.c_ocean, 
fe.gear_code,
g.l_gear_fao_uk,
fe.vessel_name,
fe.vessel_code,
fe.fishing_mode,
st.desc_tban_uk, 
fe.landsite,
fe.avg_landing_date::date,
fe.avg_fishing_date,
fe.min_fishing_date,
fe.max_fishing_date,
ROUND(CAST(ST_X(ST_Centroid(fe.geom_calc)) AS numeric),2) AS long_centroid,
ROUND(CAST(ST_Y(ST_Centroid(fe.geom_calc)) AS numeric),2) AS lat_centroid,
fe.stormode AS vessel_storage_mode,
fe.r_fishing AS remarks_fishing,
fish.fish_sampling_date,
fish.l_operator,
sp.family,
sp."order",
sp.c_sp_fao,
sp.english_name,
sp.scientific_name,
sp.seychelles_creole_name,
fish.project,
fish.fish_identifier_origin,
fish.fish_identifier,
fish.sex,
fish.macro_maturity_stage,
'cm'::text AS individual_length_unit,
(CASE WHEN fish.individual_length_unit LIKE 'mm'
      THEN fm.fork_length/1000 ELSE fm.fork_length END) AS fork_length,
(CASE WHEN fish.individual_length_unit LIKE 'mm'
      THEN fm.lowerjawfork_length/1000 ELSE fm.lowerjawfork_length END) AS lowerjawfork_length,
(CASE WHEN fish.individual_length_unit LIKE 'mm'
      THEN fm.total_length/1000 ELSE fm.total_length END) AS total_length,
(CASE WHEN fish.individual_length_unit LIKE 'mm'
      THEN fm.first_thorax_girth/1000 ELSE fm.first_thorax_girth END) AS first_thorax_girth,
(CASE WHEN fish.individual_length_unit LIKE 'mm'
      THEN fm.carapace_length/1000 ELSE fm.carapace_length END) AS carapace_length,
'kg'::text AS individual_weight_unit,
(CASE WHEN fish.individual_weight_unit LIKE 'g'
      THEN fm.whole_fishweight/1000 ELSE fm.whole_fishweight END) AS whole_fishweight,
(CASE WHEN fish.individual_weight_unit LIKE 'g'
      THEN fm.gutted_fishweight/1000 ELSE fm.gutted_fishweight END) AS gutted_fishweight,
(CASE WHEN fish.individual_weight_unit LIKE 'g' 
      THEN fm.gilledgutted_fishweight/1000 ELSE fm.gilledgutted_fishweight END) AS gilledgutted_fishweight,
fish.tissue_weight_unit,
fm.gonad_1_weight,
fm.gonad_2_weight,
fm.gonads_total_weight,
fm.liver_weight,
fm.rest_viscera_weight,
fm.full_stomach_weight,
fm.empty_stomach_weight,
fish.stomach_prey_groups,
fish.remarks_sampling,
fe.geom_calc AS geom_centroid,
--ST_GeomFromText(unnest(fe.original_geoms)) AS geom,
ROUND(fe.geom_uncertainty::numeric,0) AS geom_uncertainty,
fe.original_geoms
FROM public.fish
LEFT JOIN public.fishes_environments_calculated fe ON (fish.fish_identifier=fe.fish_identifier)
LEFT JOIN public.fish_measures_pivot fm ON (fm.fish_identifier = fish.fish_identifier)
LEFT JOIN references_tables.species sp ON (fish.c_sp_fao = sp.c_sp_fao)
LEFT JOIN references_tables.gear g ON (fe.gear_code = g.c_gear_fao)
LEFT JOIN references_tables.fishing_mode st ON (fe.fishing_mode=st.l_tban)
--INNER JOIN geo_data.eez ON ST_Within(fe.geom_calc,eez.geom)
--WHERE geo_data.eez.iso_ter1 LIKE 'SYC'
--INNER JOIN geo_data.eez_iho_union_v2 eez ON ST_Within(ST_SetSRID(fe.geom_calc,4326),eez.geom)
--WHERE eez.EEZ LIKE 'Seychellois Exclusive Economic Zone'
--INNER JOIN geo_data.eez_land_v2_201410 eez ON ST_Within(ST_SetSRID(fe.geom_calc,4326),eez.geom)
--WHERE eez.iso_3digit LIKE 'SYC'
WHERE fish.project NOT IN ('BIOM-BET','BIOMCO','BIOMCO1','PATUDO','IOT-stomachs','DCF-IO')
),

-- Information from the sample bank
-- Water content computed, white muscle only
sample_bank_info AS (

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
WHERE so.sample_origin_id NOT LIKE '%T6'
)

SELECT DISTINCT
-- Table Fish (fish_sampled)
-- Species information
fish_sampled.fish_identifier,
fish_sampled.fish_identifier_origin,
fish_sampled."order",
fish_sampled.family,
fish_sampled.c_sp_fao,
fish_sampled.scientific_name,
fish_sampled.english_name,
fish_sampled.seychelles_creole_name,
fish_sampled.project,
-- Fish origin
fish_sampled.c_ocean,
fish_sampled.gear_code,
fish_sampled.l_gear_fao_uk,
fish_sampled.vessel_code,
fish_sampled.vessel_name,
fish_sampled.avg_fishing_date,
fish_sampled.avg_landing_date,
(CASE WHEN fish_sampled.avg_fishing_date IS NOT NULL THEN fish_sampled.avg_fishing_date ELSE (CASE WHEN fish_sampled.avg_landing_date IS NOT NULL THEN fish_sampled.avg_landing_date ELSE fish_sampled.fish_sampling_date END)END) AS date,
fish_sampled.landsite AS landing_site,
fish_sampled.long_centroid,
fish_sampled.lat_centroid,
fish_sampled.geom_uncertainty,
fish_sampled.vessel_storage_mode,
fish_sampled.l_operator,
fish_sampled.remarks_fishing,
-- Fish morphometrics
fish_sampled.sex,
fish_sampled.macro_maturity_stage,
'cm'::text AS individual_length_unit,
fish_sampled.total_length,
fish_sampled.fork_length,
fish_sampled.lowerjawfork_length,
fish_sampled.carapace_length,
'kg'::text AS individual_weight_unit,
fish_sampled.whole_fishweight,
fish_sampled.gutted_fishweight,
fish_sampled.gilledgutted_fishweight,
fish_sampled.tissue_weight_unit,
fish_sampled.gonad_1_weight,
fish_sampled.gonad_2_weight,
fish_sampled.gonads_total_weight,
fish_sampled.liver_weight,
fish_sampled.rest_viscera_weight,
fish_sampled.full_stomach_weight,
fish_sampled.empty_stomach_weight,
fish_sampled.stomach_prey_groups,
fish_sampled.remarks_sampling

FROM fish_sampled
     INNER JOIN sample_bank_info sbi ON (fish_sampled.fish_identifier=sbi.fish_identifier)
 
GROUP BY
fish_sampled.fish_identifier,
fish_sampled.fish_identifier_origin,
fish_sampled."order",
fish_sampled.family,
fish_sampled.c_sp_fao,
fish_sampled.scientific_name,
fish_sampled.english_name,
fish_sampled.seychelles_creole_name,
fish_sampled.project,
-- Fish origin
fish_sampled.c_ocean,
fish_sampled.gear_code,
fish_sampled.l_gear_fao_uk,
fish_sampled.vessel_code,
fish_sampled.vessel_name,
fish_sampled.avg_fishing_date,
fish_sampled.avg_landing_date,
(CASE WHEN fish_sampled.avg_fishing_date IS NOT NULL THEN fish_sampled.avg_fishing_date ELSE (CASE WHEN fish_sampled.avg_landing_date IS NOT NULL THEN fish_sampled.avg_landing_date ELSE fish_sampled.fish_sampling_date END)END),
fish_sampled.long_centroid,
fish_sampled.lat_centroid,
fish_sampled.geom_uncertainty,
fish_sampled.landsite,
fish_sampled.vessel_storage_mode,
fish_sampled.l_operator,
fish_sampled.remarks_fishing,
-- Fish morphometrics
fish_sampled.sex,
fish_sampled.macro_maturity_stage,
'cm'::text,
fish_sampled.total_length,
fish_sampled.fork_length,
fish_sampled.lowerjawfork_length,
fish_sampled.carapace_length,
'kg'::text,
fish_sampled.whole_fishweight,
fish_sampled.gutted_fishweight,
fish_sampled.gilledgutted_fishweight,
fish_sampled.tissue_weight_unit,
fish_sampled.gonad_1_weight,
fish_sampled.gonad_2_weight,
fish_sampled.gonads_total_weight,
fish_sampled.liver_weight,
fish_sampled.rest_viscera_weight,
fish_sampled.full_stomach_weight,
fish_sampled.empty_stomach_weight,
fish_sampled.stomach_prey_groups,
fish_sampled.remarks_sampling;

-- Export the table
\copy fish_collected_with_samples TO '/home/stagiaire/Emotion3/queries/FISH/fish_collected_with_samples.csv' WITH DELIMITER ';' CSV HEADER
