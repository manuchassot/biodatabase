-- Fish and associated samples for the SEYFISH project
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Indian Ocean
-- Area = SYC EEZ
-- Use of eez_land_v2_201410 included in the scheme geo_data for the spatial extraction as it does not include the islands and enables to encompass ALL samples within the Seychelles waters, i.e. when samples are very coastal and could be apparently come from the land due to low resolution of the coasts
-- Information on fish origin and morphometrics is provided (subquery fishes)
-- Fishing environment and Fish are required when white muscle sample (position FD or blank) and/or liver have been collected (present in sample bank) but not necessarily analysed
-- Data location and water content (in sample bank) are required (both aggregated by sample_identifier)
-- Analysis_group = FA + SI + O + M
-- Information on water content of the sample is provided when available (subquery 2)
-- N Bodin & E Chassot
-- 06/07/2018
-- Au Cap, Seychelles
-- Updated on 20/01/2019
-- Updated on 05/05/2019
-- Addition of 'Mantle' in the tissue to get octopus

DROP TABLE IF EXISTS extractions.seyfish_eez_dataset_samples_description;
CREATE TABLE extractions.seyfish_eez_dataset_samples_description AS 

-- Subquery providing the list of fishes for which analyses of PCBs were made
-- Information on average geographic position and date is given
-- Size measurements are provided
-- Note the LEFT JOIN with fish_measures_pivot because some fish could be sampled without any morphometric measurement available

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
INNER JOIN geo_data.eez_land_v2_201410 eez ON ST_Within(ST_SetSRID(fe.geom_calc,4326),eez.geom)
WHERE eez.iso_3digit LIKE 'SYC'
AND fish.project NOT IN ('BIOMCO','BIOMCO1','PATUDO','IOT-stomachs')
AND extract(year FROM fish.fish_sampling_date)>2008
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
WHERE ((so.tissue LIKE 'White muscle' AND so.sample_position IN ('','FD') ) OR (so.tissue LIKE 'Liver') OR (so.tissue LIKE 'Mantle'))
AND analysis_group IN ('FA','SI','O','M')   -- TO CONFIRM
AND so.sample_origin_id NOT LIKE '%T6'
)

SELECT DISTINCT
-- Table Fish (fish_sampled)
-- Species information
fish_sampled.fish_identifier,
fish_sampled.fish_identifier_origin,
sbi.tissue,
sbi.sample_position,
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
fish_sampled.remarks_sampling,
string_agg(DISTINCT sbi.sample_origin_id::text, '|'::text)  AS sample_identifier,
string_agg(sbi.sample_id::text, '|'::text)  AS subsamples_identifiers,
string_agg(sbi.sample_location::text, '|'::text) AS subsamples_locations,
ROUND(AVG(sbi.water_content)::numeric,1) AS water_content_avg,
string_agg(sbi.water_content::text, '|'::text)  AS water_contents

FROM fish_sampled
     INNER JOIN sample_bank_info sbi ON (fish_sampled.fish_identifier=sbi.fish_identifier)
 
GROUP BY
fish_sampled.fish_identifier,
fish_sampled.fish_identifier_origin,
sbi.tissue,
sbi.sample_position,
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

--LIMIT 1;

ALTER TABLE extractions.seyfish_eez_dataset_samples_description OWNER TO postgres;

