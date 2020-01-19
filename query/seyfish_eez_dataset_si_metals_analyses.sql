-- Samples and current analyses results for all fishes sampled within the Seychelles EEZ
-- Local Emotion3 database: psql -d emotion3 -h localhost -U postgres
-- Indian Ocean
-- Area = SYC EEZ
-- USE eez_land_v2_201410 (only waters) to avoid excluding fish where geographic position is indicated on land (due to uncertain information)
-- Information on fish origin and morphometrics is provided (subquery fishes)
-- Data Fishing environment and Fish are required when any sample has been collected (present in sample bank) but not necessarily analysed
-- Data location and water content (in sample bank) are required (both aggregated by sample_identifier)
-- Data THg + TM + SI are required when available (in columns and aggregated by sample_identifier)
-- Analysis_group = FA + SI + O + M
-- Include data (average) for tracers: fat_content, d13c_permil, carbon_percent, d15n_permil, nitrogen_percent, carbon_nitrogen_percent_ratio, THg_c, TAs, Cd, Co, Cr, Cu, Fe, Mn, Ni, Pb, Se, V, Zn, Ag
-- SIs measured after delipidation: dry-lipid free
-- N Bodin & E Chassot
-- 08/11/2018
-- Ploemeur, Bretagne Sud, France, Europe
-- Updated on the 13th of December 2018: All tracers
-- Updated on the 5/05/2019

DROP TABLE IF EXISTS extractions.seyfish_eez_dataset_si_metals_analyses;
CREATE TABLE extractions.seyfish_eez_dataset_si_metals_analyses AS 

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

-- Values of stable isotopes in white muscle
-- The subquery depends on the view analysis_measures_over_analysis_replicates which accounts for replicates in analyses
si AS (

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
WHERE am.analysis_type LIKE 'SI'
AND am.analysis_sample_description NOT LIKE 'dry lipid-free'
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description
        ),

-- Values of stable isotopes after delipidation
si_lf AS (

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
sb.sample_origin_id,
am.sample_id,
am.analysis_sample_description,
am.measure_name || '_lf' AS measure_name,
am.measure_value_avg AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
WHERE am.analysis_type LIKE 'SI'
AND am.analysis_sample_description LIKE 'dry lipid-free'
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description
        ),
        
-- Values of metallic contaminants expressed in dry weight (conversion factor of 4)
-- No analysis replicate was made for metallic contaminants
-- Values are extracted from analysis_tables.analysis_measures
tm_dry AS (

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
sb.sample_origin_id,
am.sample_id,
am.analysis_sample_description,
am.measure_name || '_dw' AS measure_name,
--ROUND(CASE WHEN am.analysis_sample_description LIKE 'dry bulk' THEN am.measure_value_avg ELSE am.measure_value_avg * 4::double precision END::numeric,4) AS measure_value
ROUND(am.measure_value_avg::numeric,4) AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
WHERE am.analysis_type LIKE 'TM'
AND am.analysis_sample_description LIKE 'dry bulk'
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description
        ),

-- Values of mercury for each sample expressed in dry weight
-- Analyses replicates were averaged over sample_ids (analysis_tables.averaged_analysis_replicates_contaminants_hg)

hg_dry AS (

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
sb.sample_origin_id,
am.sample_id,
am.analysis_sample_description,
am.measure_name || '_dw' AS measure_name,
ROUND(am.measure_value_avg::numeric,4) AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
WHERE am.measure_name LIKE 'THg_c'
AND am.analysis_sample_description LIKE 'dry bulk'
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description
        ),

-- Values of mercury for each sample expressed in wet weight
-- Analyses replicates were averaged over sample_ids (analysis_tables.averaged_analysis_replicates_contaminants_hg)

hg_wet AS (

SELECT so.fish_identifier,
so.tissue,
so.sample_position,
sb.sample_origin_id,
am.sample_id,
am.analysis_sample_description,
am.measure_name || '_ww' AS measure_name,
ROUND(am.measure_value_avg::numeric,4) AS measure_value
FROM analysis_tables.analysis_measures_over_analysis_replicates am
INNER JOIN public.sample_bank sb ON (am.sample_id = sb.sample_id)
INNER JOIN public.samples_origin so ON (sb.sample_origin_id = so.sample_origin_id)
INNER JOIN public.fish ON (fish.fish_identifier = so.fish_identifier)
LEFT OUTER JOIN public.fishes_environments_calculated fc ON (fc.fish_identifier = fish.fish_identifier)
WHERE am.measure_name LIKE 'THg_c'
AND am.analysis_sample_description LIKE 'wet bulk'
ORDER BY so.fish_identifier,so.tissue,so.sample_position,am.sample_id,am.analysis_sample_description
        ),

tracers AS (
         SELECT hg_dry.fish_identifier,
            hg_dry.tissue,
            hg_dry.sample_position,
	    hg_dry.sample_origin_id,
	    hg_dry.sample_id,
--            hg_dry.analysis_sample_description,
            hg_dry.measure_name,
            hg_dry.measure_value
           FROM hg_dry
          UNION ALL
         SELECT hg_wet.fish_identifier,
            hg_wet.tissue,
            hg_wet.sample_position,
--            hg_wet.analysis_sample_description,
	    hg_wet.sample_origin_id,
	    hg_wet.sample_id,
            hg_wet.measure_name,
            hg_wet.measure_value
           FROM hg_wet
           UNION ALL 
	SELECT tm_dry.fish_identifier,
            tm_dry.tissue,
            tm_dry.sample_position,
	    tm_dry.sample_origin_id,
	    tm_dry.sample_id,
--           tm_dry.analysis_sample_description,
	    tm_dry.measure_name,
            tm_dry.measure_value
           FROM tm_dry
        UNION ALL
         SELECT si.fish_identifier,
            si.tissue,
            si.sample_position,
	    si.sample_origin_id,
	    si.sample_id,
--            si.analysis_sample_description,
            si.measure_name,
            si.measure_value
           FROM si
        UNION ALL
         SELECT si_lf.fish_identifier,
            si_lf.tissue,
            si_lf.sample_position,
--            si_lf.analysis_sample_description,
	    si_lf.sample_origin_id,
	    si_lf.sample_id,
            si_lf.measure_name,
            si_lf.measure_value
           FROM si_lf
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

ALTER TABLE extractions.seyfish_eez_dataset_si_metals_analyses OWNER TO postgres;

