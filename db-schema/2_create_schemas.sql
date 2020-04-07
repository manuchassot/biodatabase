-- THIS SCRIPT SHOULD BE RUN BY ROLE geodb_admin

BEGIN;

DROP SCHEMA IF EXISTS core CASCADE;
DROP SCHEMA IF EXISTS analysis CASCADE;
DROP SCHEMA IF EXISTS codelists CASCADE;
DROP SCHEMA IF EXISTS metadata CASCADE;
DROP SCHEMA IF EXISTS import CASCADE;

CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS analysis;
CREATE SCHEMA IF NOT EXISTS codelists;
CREATE SCHEMA IF NOT EXISTS metadata;
CREATE SCHEMA IF NOT EXISTS import;

SET SEARCH_PATH TO codelists, public;

CREATE TABLE cl_species
(
    c_sp_fao varchar(50) PRIMARY KEY,
	isscaap varchar(50),
	taxocode varchar(50),
	c_sp_id varchar(50),
	scientific_name varchar(100),
	english_name varchar(100),
	french_name varchar(100),
	seychelles_creole_name varchar(100),
	spanish_name varchar(100),
	arabic_name varchar(100),
	chinese_name varchar(100),
	russian_name varchar(100),
	author varchar(100),
	family varchar(100),
	"order" varchar(100),
	idguide_nevill_2013 varchar(100),
	diksyonner_pwason_savy varchar(100)
);

CREATE TABLE cl_fishing_mode
(
	c_tban integer PRIMARY KEY,
	l_tban varchar(50) UNIQUE NOT NULL,
	desc_tban_uk varchar(255) UNIQUE,
	desc_tban_fr varchar(255) UNIQUE
);

CREATE TABLE cl_gear
(
	c_gear_fao varchar(50) PRIMARY KEY,
	l_gear_fao_uk varchar(255) UNIQUE,
	l_gear_fao_fr varchar(255) UNIQUE,
	"ISSCFG_code" varchar(255),
	remarks TEXT
);

CREATE TABLE cl_afad
(
	c_afad varchar(5) PRIMARY KEY,
	l_afad varchar(19),
	afad_depth_meters integer,
	afad_distance_coast_miles double precision,
	afad_date_set timestamp(6),
	afad_longitude_deg_dec double precision,
	afad_latitude_deg_dec double precision,
	last_updated_date timestamp(6),
	last_updated_status varchar(6)
);

CREATE TABLE cl_amino_acid
(
	c_aa varchar(255) PRIMARY KEY,
	l_aa varchar(255),
	c_aa_grp varchar(255),
	l_aa_grp varchar(255)
);

CREATE TABLE cl_analysis_group
(
	analysis_group varchar(10) PRIMARY KEY,
	desc_analysis_group varchar(255)
);

CREATE TABLE cl_laboratory
(
	c_anal_lab varchar(15) primary key,
	l_anal_lab varchar(150) UNIQUE,
	city varchar(50),
	country varchar(25)
);

CREATE TABLE cl_analysis_matching_group
(
	analysis_group varchar(7),
	analysis_type varchar(255)
);

CREATE TABLE cl_analysis_mode
(
	c_anal_mod varchar(15) primary key,
	l_anal_mod varchar(255) UNIQUE
);

CREATE TABLE cl_analysis_replicate
(
	l_anal_rep varchar(5) primary key,
	desc_anal_rep varchar(55)
);

CREATE TABLE cl_analysis_sample_description
(
	c_anal_samp_descript varchar(25) primary key,
	desc_anal_samp_descript varchar(255)
);

CREATE TABLE cl_analysis_type
(
	l_anal varchar(10) primary key,
	desc_anal varchar(255)
);

CREATE TABLE cl_atresia
(
	c_atrsi_st integer primary key,
	desc_atrsi_st varchar(100)
);

CREATE TABLE cl_crm
(
	certified_material varchar(50) PRIMARY KEY,
	certified_material_type varchar(255),
	certified_material_supplier varchar(255),
	certified_material_datasheet varchar(255)
);

CREATE TABLE cl_derivatization_mode
(
	c_extrac_mod varchar(50) PRIMARY KEY,
	desc_extrac_mod varchar(255) UNIQUE
);

CREATE TABLE cl_drying_mode
(
	l_dry_mod varchar(15) primary key,
	desc_dry_mod varchar(50)
);

CREATE TABLE cl_extraction_mode
(
	c_extrac_mod varchar(50) PRIMARY KEY,
	desc_extrac_mod varchar(255)
);

CREATE TABLE cl_fatty_acid
(
	c_fa varchar(255) PRIMARY KEY,
	l_fa varchar(255),
	l2_fa varchar(255),
	c_fa_grp varchar(255),
	l_fa_grp varchar(255),
	l_fa_omega varchar(255)
);

CREATE TABLE cl_grinding_mode
(
	l_grind_mod varchar(10) primary key,
	desc_grind_mod varchar(100)
);

CREATE TABLE cl_landing
(
	l_dbq varchar(255),
	l_dbq_country varchar(255),
	PRIMARY KEY (l_dbq, l_dbq_country)
);

CREATE TABLE cl_macro_maturity
(
	c_macro_mat int PRIMARY KEY,
	l_macro_mat varchar(255) UNIQUE NOT NULL,
	desc_macro_mat_iccat_males varchar(255),
	desc_macro_mat_iccat_females varchar(255)
);

CREATE TABLE cl_micro_maturity_stage
(
	c_micro_mat integer PRIMARY KEY,
	l_micro_mat_short varchar(255),
	l_micro_mat_long varchar(255),
	desc_micro_mat_females_zudaire2013 varchar(500)
);

CREATE TABLE cl_ocean
(
	c_ocean varchar(4) PRIMARY KEY,
	desc_ocean_code_fr varchar(25) UNIQUE,
	desc_ocean_code_uk varchar(25) UNIQUE,
	desc_ocean_code_sp varchar(25) UNIQUE
);

CREATE TABLE cl_operator
(
	l_operator varchar(25) primary key,
	affiliation varchar(25)
);

CREATE TABLE cl_otolith_measurement_type
(
	c_oto_mes varchar(25) primary key,
	desc_oto_mes text
);

CREATE TABLE cl_packaging
(
	l_samp_stor varchar(50) PRIMARY KEY,
	desc_samp_stor varchar(255),
	samp_stor_supplier_ref varchar(255),
	mean_mass_samp_stor_with_caps double precision,
	mean_mass_samp_stor_no_caps double precision,
	sd_mass_samp_stor double precision
);

CREATE TABLE cl_pof
(
	c_pof varchar(4) primary key,
	desc_c_pof varchar(400)
);

CREATE TABLE cl_prey_group
(
	l_stom_content_group varchar(50) PRIMARY KEY,
	desc_stomach_content_groups varchar(255) UNIQUE
);

CREATE TABLE cl_processing_replicate
(
	analysis_group varchar(7) PRIMARY KEY,
	analysis_type varchar(255) UNIQUE
);

CREATE TABLE cl_project
(
	c_proj varchar(50) PRIMARY KEY,
	l_proj varchar(255),
	l_proj_financing varchar(255),
	l_proj_lead varchar(255),
	d_proj varchar(255),
	l_proj_contact varchar(255)
);

CREATE TABLE cl_sample_position
(
	l_samp_pos varchar(50) PRIMARY KEY,
	desc_c_samp_pos varchar(255) UNIQUE
);

CREATE TABLE cl_sampling_platform
(
	l_samp_platform varchar(50) PRIMARY KEY,
	desc_samp_platform varchar(255) UNIQUE
);

CREATE TABLE cl_sex
(
	c_sex char(50) PRIMARY KEY,
	l_sex_uk varchar(255) UNIQUE,
	l_sex_en varchar(255) UNIQUE
);

CREATE TABLE cl_stomach_fullness
(
	c_stom_fullness integer PRIMARY KEY,
	desc_stom_fullness varchar(255) UNIQUE
);

CREATE TABLE cl_storage_mode
(
	c_stor_mod varchar(20) primary key,
	desc_stor_mod varchar(100)
);

CREATE TABLE cl_tissue
(
	c_tsu varchar(50) PRIMARY KEY,
	l_tsu_uk varchar(255) UNIQUE,
	l_tsu_fr varchar(255) UNIQUE
);

CREATE TABLE cl_otolith_breaking
(
	code int PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_vessel
(
	c_bat varchar(255), --PRIMARY KEY,
	c_quille integer,
	c_cfr varchar(255),
	c_nat varchar(255),
	l_bat varchar(255),
	c_vessel_type varchar(255),
	l_vessel_type varchar(255),
	v_l_ht double precision,
	v_ct_m3 double precision,
	v_p_cv double precision,
	c_flag_vessel integer,
	c_flag_fleet integer,
	remarks varchar(255)
);

CREATE TABLE cl_vessel_storage
(
    c_bat_stor_mod varchar(50) PRIMARY KEY,
	desc_bat_stor_mod_fr varchar(255) UNIQUE,
	desc_bat_stor_mod_uk varchar(255) UNIQUE
);

CREATE TABLE cl_sampling_status
(
    code varchar(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_mineral
(
	c_tm varchar(255) PRIMARY KEY,
	l_tm varchar(255),
	c_tm_grp1 varchar(255),
	l_tm_grp1 varchar(255),
	c_tm_grp2 varchar(255),
	l_tm_grp2 varchar(255),
	remark varchar(255)
);

CREATE TABLE cl_organic_contaminant
(
	c_oc varchar(255) PRIMARY KEY,
	l_oc1 varchar(255),
	l_oc2 varchar(255),
	c_oc_grp1 varchar(255),
	l_oc_grp1 varchar(255),
	c_oc_grp2 varchar(255),
	l_oc_grp2 varchar(255)
);

CREATE TABLE cl_measure_unit
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_drying_status
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_otolith_part
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_reading_method
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_increment_type
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_otolith_section_type
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_grinding_status
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_mago_substage
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_mago_stage
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_pof_2
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_fractionation_mode
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_fractionation_type
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_internal_standard
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_lipid_remov_mode
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_urea_remov_mode
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_carbonate_remov_mode
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_extraction_status
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

CREATE TABLE cl_fatm_mode
(
    code VARCHAR(50) PRIMARY KEY,
    description_en varchar(255) UNIQUE,
    description_fr varchar(255) UNIQUE
);

SET SEARCH_PATH TO metadata, public;

CREATE TABLE md_analysis_tracer_detail
(
    id SERIAL PRIMARY KEY,
	analysis_type varchar(100) NOT NULL,
	tracer_name varchar(100) NOT NULL,
	standard_unit varchar(255),
	tracer_description text,
	views_level integer,
	UNIQUE (analysis_type, tracer_name)
);

CREATE TABLE md_organism_measure_detail
(
	measure_name varchar(50) PRIMARY KEY,
	standard_unit varchar(255),
	measure_description text
);

SET SEARCH_PATH TO core, metadata, codelists, public;

CREATE TABLE co_sampling_environment
(
    id VARCHAR(20) PRIMARY KEY,
    landing_date DATE,
    landing_site VARCHAR(255),
    landing_country VARCHAR(255),
    FOREIGN KEY (landing_site, landing_country) REFERENCES cl_landing(l_dbq, l_dbq_country) ON UPDATE CASCADE ON DELETE RESTRICT,
    capture_date DATE,
    capture_date_min DATE,
    capture_date_max DATE,
    capture_time timetz,
    capture_time_start timetz,
    capture_time_end timetz,
    activityNumber INT,
    sea_surface_temperature_deg_celcius FLOAT,
    well_position VARCHAR(255),
    well_number VARCHAR(255),
    ocean_code VARCHAR(4) REFERENCES cl_ocean ON UPDATE CASCADE ON DELETE RESTRICT,
    gear_code VARCHAR(50) REFERENCES cl_gear ON UPDATE CASCADE ON DELETE RESTRICT,
    vessel_code varchar(255), --REFERENCES cl_vessel ON UPDATE CASCADE ON DELETE RESTRICT,
    vessel_name VARCHAR(255),
    vessel_storage_mode VARCHAR(50) REFERENCES cl_vessel_storage ON UPDATE CASCADE ON DELETE RESTRICT,
    sampling_remarks TEXT,
    capture_depth_m INT,
    aggregation varchar(50) REFERENCES cl_fishing_mode(l_tban) ON UPDATE CASCADE ON DELETE RESTRICT,
    description_aggregation TEXT,
    geom geometry(GEOMETRYCOLLECTION, 4326),
    geom_uncertainty_km INT
);

CREATE TABLE co_sampling_organism
(
    id varchar(20) PRIMARY KEY,
    sampling_platform VARCHAR(50) REFERENCES cl_sampling_platform ON UPDATE CASCADE ON DELETE RESTRICT,
    sampling_status varchar(50) REFERENCES cl_sampling_status ON UPDATE CASCADE ON DELETE RESTRICT,
    sampling_date date,
    sampling_remarks text,
    first_tag_number varchar(10),
    second_tag_number varchar(10),
    operator_name varchar(25) REFERENCES cl_operator ON UPDATE CASCADE ON DELETE RESTRICT,
    species_code_fao varchar(50) REFERENCES cl_species ON UPDATE CASCADE ON DELETE RESTRICT,
    project varchar(50) REFERENCES cl_project ON UPDATE CASCADE ON DELETE RESTRICT,
    data_file_name varchar(255),
    stomach_prey_groups varchar(50) REFERENCES cl_prey_group ON UPDATE CASCADE ON DELETE RESTRICT,
    stomach_fullness_stage int REFERENCES cl_stomach_fullness ON UPDATE CASCADE ON DELETE RESTRICT,
    organism_length_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    organism_weight_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    tissue_weight_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    macro_maturity_stage int REFERENCES cl_macro_maturity ON UPDATE CASCADE ON DELETE RESTRICT,
    sex varchar(50) REFERENCES cl_sex ON UPDATE CASCADE ON DELETE RESTRICT,
    otolith_count int,
    otolith_breaking int REFERENCES cl_otolith_breaking ON UPDATE CASCADE ON DELETE RESTRICT,
    genetic_fin_clip varchar(255),
    genetic_muscle varchar(255),
    sampling_environment varchar(20) REFERENCES co_sampling_environment ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE co_sample
(
    id varchar(20) PRIMARY KEY,
    tissue varchar(50) REFERENCES cl_tissue ON UPDATE CASCADE ON DELETE RESTRICT,
    position varchar(50) REFERENCES cl_sample_position ON UPDATE CASCADE ON DELETE RESTRICT,
    table_source varchar(255),
    sampling_organism varchar(20) REFERENCES co_sampling_organism ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE co_subsample
(
    id varchar(20) PRIMARY KEY,
    operator_name varchar(25) REFERENCES cl_operator ON UPDATE CASCADE ON DELETE RESTRICT,
    location varchar(255),
    analysis_group varchar(25) REFERENCES cl_analysis_group ON UPDATE CASCADE ON DELETE RESTRICT,
    sample varchar(20) REFERENCES co_sample ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE co_prep
(
    id varchar(20) PRIMARY KEY REFERENCES co_subsample ON UPDATE CASCADE ON DELETE RESTRICT,
    packaging1 varchar(50) REFERENCES cl_packaging ON UPDATE CASCADE ON DELETE RESTRICT,
    storage_mode1 varchar(20) REFERENCES cl_storage_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    storage_date date,
    drying_mode varchar(15) REFERENCES cl_drying_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    drying_status varchar(50) REFERENCES cl_drying_status ON UPDATE CASCADE ON DELETE RESTRICT,
    drying_date date,
    material_empty_mass float,
    material_sample_wet_weight float,
    material_sample_dry_weight float,
    sample_wet_weight float,
    sample_dry_weight float,
    water_content float,
    packaging_final varchar(50) REFERENCES cl_packaging ON UPDATE CASCADE ON DELETE RESTRICT,
    storage_mode_final varchar(20) REFERENCES cl_storage_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    grinding_mode varchar(50) REFERENCES cl_grinding_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    grinding_status varchar(50) REFERENCES cl_grinding_status ON UPDATE CASCADE ON DELETE RESTRICT,
    grinding_date date
);

CREATE TABLE co_organism_measure
(
    organism varchar(20) REFERENCES co_sampling_organism ON UPDATE CASCADE ON DELETE RESTRICT,
    measure_type varchar(50) REFERENCES md_organism_measure_detail ON UPDATE CASCADE ON DELETE RESTRICT,
    measure_value float,
    measure_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (organism, measure_type)
);

SET SEARCH_PATH TO analysis, core, codelists, metadata, public;

CREATE TABLE an_analysis
(
    id varchar(20) PRIMARY KEY,
    type varchar(10) REFERENCES cl_analysis_type ON UPDATE CASCADE ON DELETE RESTRICT,
    replicate varchar(5) REFERENCES cl_analysis_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    lab varchar(15) REFERENCES cl_laboratory ON UPDATE CASCADE ON DELETE RESTRICT,
    operator_name varchar(25) REFERENCES cl_operator ON UPDATE CASCADE ON DELETE RESTRICT,
    sample_description text,
    mode varchar(15) REFERENCES cl_analysis_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    remarks text,
    data_file_name varchar(255),
    check_date date,
    subsample varchar(20) REFERENCES co_subsample ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_lipid_classes
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_lab varchar(15) REFERENCES cl_laboratory ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_replicate varchar(7) REFERENCES cl_processing_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    iatro_development_number int,
    iatro_chromarod_number int,
    dilution_volume int,
    spotted_volume int,
    volume_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    lipidclasses_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_series int
);

CREATE TABLE an_amino_acids
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    aa_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_proteins
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_lab varchar(15) REFERENCES cl_laboratory ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_replicate varchar(7) REFERENCES cl_processing_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    dilution_factor int,
    prot_q_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    prot_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    spotted_volume int
);

CREATE TABLE an_otolith_morphometry
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    part varchar(50) REFERENCES cl_otolith_part ON UPDATE CASCADE ON DELETE RESTRICT,
    measurement_type varchar(25) REFERENCES cl_otolith_measurement_type ON UPDATE CASCADE ON DELETE RESTRICT,
    measurement_value float,
    measurement_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    reading_method varchar(50) REFERENCES cl_reading_method ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_otolith_increment_count
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    part varchar(50) REFERENCES cl_otolith_part ON UPDATE CASCADE ON DELETE RESTRICT,
    section_type varchar(50) REFERENCES cl_otolith_section_type ON UPDATE CASCADE ON DELETE RESTRICT,
    increment_type varchar(50) REFERENCES cl_increment_type ON UPDATE CASCADE ON DELETE RESTRICT,
    increment_count int,
    age_years int,
    reading_method varchar(50) REFERENCES cl_reading_method ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_stomach_contents
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    scc_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_reproduction_maturity
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    method varchar(50),
    micro_maturity_stage int REFERENCES cl_micro_maturity_stage ON UPDATE CASCADE ON DELETE RESTRICT,
    mago_substage varchar(50) REFERENCES cl_mago_substage ON UPDATE CASCADE ON DELETE RESTRICT,
    mago_stage varchar(50) REFERENCES cl_mago_stage ON UPDATE CASCADE ON DELETE RESTRICT,
    pof varchar(50) REFERENCES cl_pof_2 ON UPDATE CASCADE ON DELETE RESTRICT,
    a_atresia int REFERENCES cl_atresia ON UPDATE CASCADE ON DELETE RESTRICT,
    b_atresia int REFERENCES cl_atresia ON UPDATE CASCADE ON DELETE RESTRICT,
    brown_bodies boolean,
    muscle_bundles boolean,
    rho boolean,
    ovary_wall float,
    repro_phase varchar(255) REFERENCES cl_macro_maturity(l_macro_mat) ON UPDATE CASCADE ON DELETE RESTRICT,
    repro_subphase varchar(255) REFERENCES cl_macro_maturity(l_macro_mat) ON UPDATE CASCADE ON DELETE RESTRICT,
    maturity varchar(255) REFERENCES cl_macro_maturity(l_macro_mat) ON UPDATE CASCADE ON DELETE RESTRICT,
    atretic_oocyte_stage varchar(50) REFERENCES cl_mago_stage ON UPDATE CASCADE ON DELETE RESTRICT,
    atretic_oocyte_percent VARCHAR(10),
    atretic_stage INT CHECK (atretic_stage >= 0 AND atretic_stage <= 4)
);

CREATE TABLE an_fatty_acids
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_lab varchar(15) REFERENCES cl_laboratory ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_replicate varchar(7) REFERENCES cl_processing_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    fractionation_mode varchar(50) REFERENCES cl_fractionation_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    fractionation_type varchar(50) REFERENCES cl_fractionation_type ON UPDATE CASCADE ON DELETE RESTRICT,
    dilution_factor int,
    internal_standard varchar(50) REFERENCES cl_internal_standard ON UPDATE CASCADE ON DELETE RESTRICT,
    i_std_mass float,
    i_std_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    derivatization_mode varchar(50) REFERENCES cl_derivatization_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    faa_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_series int
);

CREATE TABLE an_total_lipids
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    material_empty_mass float,
    material_lipids_mass float,
    lipids_q float,
    lipids_q_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    lipids_c float,
    lipids_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_analysis_certified_material
(
    analysis_id varchar(20) REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    certified_material varchar(50) REFERENCES cl_crm ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (analysis_id, certified_material)
);

CREATE TABLE an_contaminants_hg
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    thg_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    thg_q_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_lab varchar(15) REFERENCES cl_laboratory ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_replicate varchar(7) REFERENCES cl_processing_replicate ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_stable_isotopes
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_lab varchar(15) REFERENCES cl_laboratory ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_replicate varchar(7) REFERENCES cl_processing_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    si_plate_code varchar(25),
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    lipid_remov_mode varchar(50) REFERENCES cl_lipid_remov_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    urea_remov_mode varchar(50) REFERENCES cl_urea_remov_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    carbonate_remov_mode varchar(50) REFERENCES cl_carbonate_remov_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_date date,
    extraction_status varchar(50) REFERENCES cl_extraction_status ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_fatmeter
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    fish_face varchar(1) CHECK (fish_face IN ('A', 'B')),
    fatm_mode varchar(50) REFERENCES cl_fatm_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_contaminants_dioxin
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    dioxon_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_contaminants_tm
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    tm_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_contaminants_musk
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    musk_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_contaminants_pfcdeoc
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    pfc_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_contaminants_pcbdeoc
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    pcbdeoc_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_moisture
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    weighing_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_analysis_measure
(
    analysis varchar(20) REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    measure_type int REFERENCES md_analysis_tracer_detail ON UPDATE CASCADE ON DELETE RESTRICT,
    measure_value float,
    measure_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (analysis, measure_type)
);

-- Set privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA codelists TO sfa_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA codelists TO sfa_view, sfa_update;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA analysis TO sfa_update;
GRANT SELECT ON ALL TABLES IN SCHEMA analysis TO sfa_view;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA core TO sfa_update;
GRANT SELECT ON ALL TABLES IN SCHEMA core TO sfa_view;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA metadata TO sfa_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA metadata TO sfa_view, sfa_update;

COMMIT;