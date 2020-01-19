-- Samples and current analyses results for all fishes sampled within the Seychelles EEZ
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Indian Ocean
-- Area = SYC EEZ 
-- Information on fish origin and morphometrics is provided (subquery fishes)
-- Data Fishing environment and Fish are required when white muscle sample (position FD or blank) and/or liver have been collected (present in sample bank) but not necessarily analysed
-- Data location and water content (in sample bank) are required (both aggregated by sample_identifier)
-- Data LC (concentrations for all lipid classes and total lipids) + FA (concentrations & percentages for all FA) + Prot are required when available (in columns and aggregated by sample_identifier)
-- Analysis_group = FA + SI + O + M
-- Information on water content of the sample is provided when available (subquery 2)
-- N Bodin & E Chassot
-- 06/07/2018
-- Au Cap, Seychelles
-- Updated on 20/01/2019
-- Updated on 05/05/2019

DROP TABLE IF EXISTS extractions.seyfish_eez_dataset_lc_fa_prot_analyses;
CREATE TABLE extractions.seyfish_eez_dataset_lc_fa_prot_analyses AS

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
ST_GeomFromText(unnest(fe.original_geoms)) AS geom,
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

-- Values of protein concentration
-- The subquery depends on the view analysis_measures_over_analysis_replicates which accounts for replicates in analyses

prot AS (

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
        ),

-- Values of lipid classes concentration
-- The subquery depends on the view analysis_measures_over_analysis_replicates which accounts for replicates in analyses
lc AS (

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
WHERE am.analysis_type LIKE 'LC'
--AND so.tissue IN ('White muscle')
--AND am.analysis_sample_description LIKE 'wet bulk'
AND am.measure_name LIKE ('%_concentration')
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description
        ),

-- Values of FA - NL, PL, TL - Both wet and dry bulk
fa AS (

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
ORDER BY so.fish_identifier,so.tissue,so.sample_position,sb.sample_origin_id,am.sample_id,am.analysis_sample_description
        ),

tracers AS (
          SELECT fa.fish_identifier,
	    fa.tissue,
	    fa.sample_position,
            fa.sample_origin_id,
	    fa.sample_id,
	    fa.analysis_sample_description,
	    fa.measure_name,
	    fa.measure_value
	    FROM fa
	UNION ALL
          SELECT prot.fish_identifier,
	    prot.tissue,
	    prot.sample_position,
            prot.sample_origin_id,
	    prot.sample_id,
	    prot.analysis_sample_description,
	    prot.measure_name,
	    prot.measure_value
	    FROM prot
	UNION ALL
          SELECT lc.fish_identifier,
	    lc.tissue,
	    lc.sample_position,
            lc.sample_origin_id,
	    lc.sample_id,
	    lc.analysis_sample_description,
	    lc.measure_name,
	    lc.measure_value
	    FROM lc
        )

SELECT DISTINCT
t.fish_identifier,
t.tissue,
t.sample_position,
string_agg(DISTINCT t.sample_origin_id::text, '|'::text) AS sample_identifier,
string_agg(t.sample_id::text, '|'::text) AS subsamples_identifiers,
t.measure_name,
ROUND(AVG(t.measure_value)::numeric,4) AS measure_value_avg

FROM fish_sampled f
     LEFT JOIN tracers t ON (f.fish_identifier = t.fish_identifier)
 
GROUP BY
t.fish_identifier,
t.tissue,
t.sample_position,  
t.measure_name

ORDER BY 
t.fish_identifier,
t.tissue,
t.sample_position;
--LIMIT 1;

ALTER TABLE extractions.seyfish_eez_dataset_lc_fa_prot_analyses OWNER TO postgres;

