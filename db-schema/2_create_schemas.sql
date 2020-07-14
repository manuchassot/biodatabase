-- THIS SCRIPT SHOULD BE RUN BY ROLE geodb_admin

BEGIN;

DROP SCHEMA IF EXISTS core CASCADE;
DROP SCHEMA IF EXISTS analysis CASCADE;
DROP SCHEMA IF EXISTS codelists CASCADE;
DROP SCHEMA IF EXISTS metadata CASCADE;
DROP SCHEMA IF EXISTS import CASCADE;
DROP SCHEMA IF EXISTS spatial CASCADE;

CREATE SCHEMA import;

-- Define default privileges on schemas (requires PostgreSQL 10+)
ALTER DEFAULT PRIVILEGES GRANT USAGE ON SCHEMAS TO sfa_view, sfa_update, sfa_admin;

CREATE SCHEMA core;
CREATE SCHEMA analysis;
CREATE SCHEMA codelists;
CREATE SCHEMA metadata;
CREATE SCHEMA spatial;

-- Define default privileges on tables (including views) and sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA codelists GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sfa_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA codelists GRANT USAGE ON SEQUENCES TO sfa_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA codelists GRANT SELECT ON TABLES TO sfa_view, sfa_update;

ALTER DEFAULT PRIVILEGES IN SCHEMA metadata GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sfa_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA metadata GRANT USAGE ON SEQUENCES TO sfa_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA metadata GRANT SELECT ON TABLES TO sfa_view, sfa_update;

ALTER DEFAULT PRIVILEGES IN SCHEMA analysis GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sfa_update;
ALTER DEFAULT PRIVILEGES IN SCHEMA analysis GRANT USAGE ON SEQUENCES TO sfa_update;
ALTER DEFAULT PRIVILEGES IN SCHEMA analysis GRANT SELECT ON TABLES TO sfa_view;

ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sfa_update;
ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT USAGE ON SEQUENCES TO sfa_update;
ALTER DEFAULT PRIVILEGES IN SCHEMA core GRANT SELECT ON TABLES TO sfa_view;

ALTER DEFAULT PRIVILEGES IN SCHEMA spatial GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO sfa_update;
ALTER DEFAULT PRIVILEGES IN SCHEMA spatial GRANT USAGE ON SEQUENCES TO sfa_update;
ALTER DEFAULT PRIVILEGES IN SCHEMA spatial GRANT SELECT ON TABLES TO sfa_view;

SET SEARCH_PATH TO codelists, public;

CREATE TABLE cl_species
(
    species_code_fao varchar(50) PRIMARY KEY,
    species_code_old varchar(50),
	isscaap varchar(50),
	taxocode varchar(50),
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
	diksyonner_pwason_savy varchar(100),
	sfa_id_ppt text,
	sfs_life_history_table text
);

CREATE TABLE cl_aggregation
(
	aggregation varchar(50) PRIMARY KEY,
	desc_aggregation_en varchar(255) UNIQUE,
	desc_aggregation_fr varchar(255) UNIQUE
);

CREATE TABLE cl_gear
(
	code varchar(50) PRIMARY KEY,
	desc_gear_fao_en varchar(255) UNIQUE,
	desc_gear_fao_fr varchar(255) UNIQUE,
	desc_gear_fao_es varchar(255) UNIQUE,
	isscfg_code varchar(255),
	identifier int
);

CREATE TABLE cl_amino_acid
(
	aa varchar(255) PRIMARY KEY,
	aa_name varchar(255),
	aa_group varchar(255),
	aa_group_name varchar(255)
);

CREATE TABLE cl_analysis_lab
(
	analysis_lab varchar(15) primary key,
	l_analysis_lab text UNIQUE,
	city varchar(50),
	country varchar(50)
);

CREATE TABLE cl_analysis_mode
(
	analysis_mode varchar(15) primary key,
	desc_analysis_mode text UNIQUE
);

CREATE TABLE cl_otolith_number
(
	otolith_number int primary key,
	desc_otolith_number_en text UNIQUE
);

CREATE TABLE cl_analysis_replicate
(
	analysis_replicate varchar(5) primary key,
	desc_analysis_replicate text UNIQUE
);

CREATE TABLE cl_analysis_sample_description
(
	analysis_sample_description varchar(25) primary key,
	desc_analysis_sample_description text UNIQUE
);

CREATE TABLE cl_analysis
(
	analysis_group varchar(10),
	desc_analysis_group text,
	analysis varchar(10),
	desc_analysis text,
	PRIMARY KEY (analysis_group, analysis)
);

CREATE TABLE cl_atresia
(
	code_atretic_stage integer primary key,
	atretic_stage_en VARCHAR(50) UNIQUE,
	desc_atretic_stage_en text UNIQUE
);

CREATE TABLE cl_reference_material
(
	reference_material varchar(50) PRIMARY KEY,
	reference_material_type varchar(255),
	reference_material_supplier varchar(255),
	reference_material_datasheet text
);

CREATE TABLE cl_derivatization_mode
(
	derivatization_mode varchar(50) PRIMARY KEY,
	desc_derivatization_mode text UNIQUE
);

CREATE TABLE cl_drying_mode
(
	drying_mode varchar(15) primary key,
	desc_drying_mode text UNIQUE
);

CREATE TABLE cl_fish_face
(
	fish_face varchar(15) primary key,
	desc_fish_face_en text UNIQUE
);

CREATE TABLE cl_well_position
(
	well_position varchar(15) primary key,
	well_position_en text UNIQUE,
    well_position_fr text UNIQUE
);

CREATE TABLE cl_extraction_mode
(
	extraction_mode varchar(50) PRIMARY KEY,
	desc_extraction_mode text
);

CREATE TABLE cl_fatty_acid
(
	fa varchar(255) PRIMARY KEY,
	fa_name varchar(255),
	fa_code varchar(255),
	fa_group1 varchar(255),
	fa_group1_name varchar(255),
	fa_omega varchar(255)
);

CREATE TABLE cl_grinding_mode
(
	grinding_mode varchar(10) primary key,
	desc_grinding_mode text UNIQUE
);

CREATE TABLE cl_landing
(
	landing_site varchar(255),
	landing_country varchar(255),
	PRIMARY KEY (landing_site, landing_country)
);

CREATE TABLE cl_macro_maturity
(
	macro_maturity_stage int PRIMARY KEY,
	l_macro_maturity_stage varchar(255) UNIQUE NOT NULL,
	desc_macro_maturity_iccat_males varchar(255),
	desc_macro_maturity_iccat_females varchar(255)
);

CREATE TABLE cl_micro_maturity
(
	micro_sex varchar(5),
	micro_maturity varchar(50),
	repro_phase varchar(50),
	repro_subphase varchar(50),
	mago_stage varchar(50),
	mago_stage_name varchar(255),
	mago_substage varchar(50),
	mago_substage_name varchar(255),
	alternative_repro_phaxe_terminology text,
	macro text,
	micro text,
	desc_micro_mat_females_zudaire2013 text,
	PRIMARY KEY(micro_sex, micro_maturity, mago_substage, mago_stage, repro_phase, repro_subphase)
);

CREATE TABLE cl_ocean
(
	code varchar(10) PRIMARY KEY,
    desc_ocean_code_en varchar(25) UNIQUE,
	desc_ocean_code_fr varchar(25) UNIQUE,
	desc_ocean_code_es varchar(25) UNIQUE
);

CREATE TABLE cl_operator
(
	operator_name varchar(25) primary key,
	affiliation1 varchar(100),
	affiliation2 varchar(100)
);

CREATE TABLE cl_otolith_measurement
(
	otolith_measurement_type varchar(25) primary key,
	desc_otolith_measurement_type text UNIQUE
);

CREATE TABLE cl_packaging
(
	packaging varchar(50) PRIMARY KEY,
	desc_packaging varchar(255),
	packaging_supplier_ref varchar(255),
	mean_mass_packaging_with_caps double precision,
	mean_mass_packaging_no_caps double precision,
	sd_mass_packaging double precision
);

CREATE TABLE cl_pof
(
	pof varchar(4) primary key,
	desc_post_ovulatory_follicle text UNIQUE
);

CREATE TABLE cl_prey_group
(
	stomach_prey_groups varchar(50) PRIMARY KEY,
	desc_stomach_prey_groups text UNIQUE
);

CREATE TABLE cl_processing_replicate
(
	processing_replicate varchar(10) PRIMARY KEY,
	desc_processing_replicate text UNIQUE
);

CREATE TABLE cl_project
(
	project varchar(50) PRIMARY KEY,
	project_title varchar(255),
	project_financing varchar(255),
	project_lead varchar(255),
	project_period varchar(255),
	project_contact varchar(255)
);

CREATE TABLE cl_sample_position
(
	sample_position varchar(50) PRIMARY KEY,
	desc_c_samp_pos varchar(255) UNIQUE
);

CREATE TABLE cl_sampling_platform
(
	sampling_platform varchar(50) PRIMARY KEY,
	desc_sampling_platform_en varchar(255) UNIQUE
);

CREATE TABLE cl_sex
(
    sex char(50) PRIMARY KEY,
	l_sex_en varchar(255) UNIQUE,
	l_sex_fr varchar(255) UNIQUE
);

CREATE TABLE cl_storage_mode
(
	storage_mode varchar(20) primary key,
	desc_storage_mode text
);

CREATE TABLE cl_tissue
(
	tissue_code varchar(50) PRIMARY KEY,
	tissue_en varchar(255) UNIQUE,
    tissue_fr varchar(255) UNIQUE
);

CREATE TABLE cl_otolith_breaking
(
	otolith_breaking VARCHAR(50) PRIMARY KEY,
    desc_otolith_breaking_en varchar(255) UNIQUE
);

CREATE TABLE cl_vessel
(
	vessel_code varchar(50), --PRIMARY KEY,
	vessel_name VARCHAR(100),
	c_quille varchar(50),
	c_cfr varchar(255),
	c_nat varchar(255),
	c_vessel_type varchar(255),
	l_vessel_type varchar(255),
	v_l_ht double precision,
	v_ct_m3 double precision,
	v_p_cv double precision,
	c_flag_vessel integer,
	c_flag_fleet integer,
	remarks text
);

CREATE TABLE cl_vessel_storage
(
    vessel_storage_mode varchar(50) PRIMARY KEY,
	desc_vessel_storage_mode_fr varchar(255) UNIQUE,
	desc_vessel_storage_mode_en varchar(255) UNIQUE
);

CREATE TABLE cl_organism_sampling_status
(
    organism_sampling_status varchar(50) PRIMARY KEY,
    desc_organism_sampling_status_en varchar(255) UNIQUE,
    desc_organism_sampling_status_fr varchar(255) UNIQUE
);

CREATE TABLE cl_mineral
(
	mineral varchar(255) PRIMARY KEY,
	mineral_name varchar(255),
	minderal_group1 varchar(255),
	minderal_group1_name varchar(255),
	minderal_group2 varchar(255),
	minderal_group2_name varchar(255),
	remarks text
);

CREATE TABLE cl_organic_contaminant
(
	oc varchar(255) PRIMARY KEY,
	oc_name varchar(255),
	oc_name2 varchar(255),
	oc_group1 varchar(255),
	oc_group1_name varchar(255),
	oc_group2 varchar(255),
	oc_group2_name varchar(255),
	oc_isomer_group varchar(255),
	oc_toxicity_group varchar(255),
	oc_toxicity_group_name varchar(255),
	i_tef_who_1998 decimal
);

CREATE TABLE cl_measure_unit
(
    measure_unit VARCHAR(50) PRIMARY KEY,
    desc_measure_unit_en varchar(255) UNIQUE,
    desc_measure_variable_en varchar(255)
);

CREATE TABLE cl_otolith_part
(
    otolith_part VARCHAR(50) PRIMARY KEY,
    desc_otolith_part_en varchar(255) UNIQUE,
    desc_otolith_part_fr varchar(255) UNIQUE
);

CREATE TABLE cl_reading_method
(
    reading_method VARCHAR(50) PRIMARY KEY,
    desc_reading_method_en varchar(255) UNIQUE,
    desc_reading_method_fr varchar(255) UNIQUE
);

CREATE TABLE cl_increment_type
(
    increment_type VARCHAR(50) PRIMARY KEY,
    desc_increment_type_en varchar(255) UNIQUE,
    desc_increment_type_fr varchar(255) UNIQUE
);

CREATE TABLE cl_otolith_section_type
(
    otolith_section_type VARCHAR(50) PRIMARY KEY,
    desc_otolith_section_type_en varchar(255) UNIQUE,
    desc_otolith_section_type_fr varchar(255) UNIQUE
);

CREATE TABLE cl_fractionation_mode
(
    fractionation_mode VARCHAR(50) PRIMARY KEY,
    desc_fractionation_mode_en text UNIQUE,
    desc_fractionation_mode_fr text UNIQUE
);

CREATE TABLE cl_fraction_type
(
    fraction_type VARCHAR(50) PRIMARY KEY,
    desc_fraction_type_en varchar(255) UNIQUE,
    desc_fraction_type_fr varchar(255) UNIQUE
);

CREATE TABLE cl_fatm_mode
(
    fatmeter_mode VARCHAR(50) PRIMARY KEY,
    desc_fatmeter_mode_en varchar(255) UNIQUE,
    desc_fatmeter_mode_fr varchar(255) UNIQUE
);

CREATE TABLE cl_atretic_oocyte_stage
(
    atretic_oocyte_stage VARCHAR(50) PRIMARY KEY,
    atretic_oocyte_stage_name varchar(255) UNIQUE
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

CREATE TABLE md_ddd
(
    entity varchar(255),
    variable varchar(255),
    data_type varchar(255),
    unit varchar(255),
    basic_checks varchar(255),
    comment text,
    tracer integer,
    views_level integer
);

SET SEARCH_PATH TO core, metadata, codelists, public;

CREATE TABLE co_sampling_environment
(
    id VARCHAR(20) PRIMARY KEY,
    landing_date DATE,
    landing_site VARCHAR(255),
    landing_country VARCHAR(255),
    FOREIGN KEY (landing_site, landing_country) REFERENCES cl_landing(landing_site, landing_country) ON UPDATE CASCADE ON DELETE RESTRICT,
    capture_date DATE,
    capture_date_min DATE,
    capture_date_max DATE,
    capture_time timetz,
    capture_time_start timetz,
    capture_time_end timetz,
    activity_number INT,
    sea_surface_temperature_deg_celcius FLOAT,
    well_position VARCHAR(15) REFERENCES cl_well_position ON UPDATE CASCADE ON DELETE RESTRICT,
    well_number VARCHAR(255),
    ocean_code VARCHAR(10) REFERENCES cl_ocean ON UPDATE CASCADE ON DELETE RESTRICT,
    gear_code VARCHAR(50) REFERENCES cl_gear ON UPDATE CASCADE ON DELETE RESTRICT,
    vessel_code varchar(50), -- REFERENCES cl_vessel ON UPDATE CASCADE ON DELETE RESTRICT,
    vessel_name VARCHAR(100),
    vessel_storage_mode VARCHAR(50) REFERENCES cl_vessel_storage ON UPDATE CASCADE ON DELETE RESTRICT,
    sampling_remarks TEXT,
    capture_depth_m INT,
    aggregation varchar(50) REFERENCES cl_aggregation ON UPDATE CASCADE ON DELETE RESTRICT,
    description_aggregation TEXT,
    geom geometry(GEOMETRYCOLLECTION, 4326),
    geom_uncertainty_km INT,
    latitude_deg_dec decimal,
    latitude_deg_dec_min decimal,
    latitude_deg_dec_max decimal,
    longitude_deg_dec decimal,
    longitude_deg_dec_min decimal,
    longitude_deg_dec_max decimal
);

CREATE TABLE co_sampling_organism
(
    id varchar(20) PRIMARY KEY,
    sampling_platform VARCHAR(50) REFERENCES cl_sampling_platform ON UPDATE CASCADE ON DELETE RESTRICT,
    sampling_status varchar(50) REFERENCES cl_organism_sampling_status ON UPDATE CASCADE ON DELETE RESTRICT,
    sampling_date date,
    sampling_remarks text,
    first_tag_number varchar(10),
    second_tag_number varchar(10),
    species_code_fao varchar(50) REFERENCES cl_species ON UPDATE CASCADE ON DELETE RESTRICT,
    project varchar(50) REFERENCES cl_project ON UPDATE CASCADE ON DELETE RESTRICT,
    stomach_prey_groups varchar(50) REFERENCES cl_prey_group ON UPDATE CASCADE ON DELETE RESTRICT,
    organism_length_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    organism_weight_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    tissue_weight_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    macro_maturity_stage int REFERENCES cl_macro_maturity ON UPDATE CASCADE ON DELETE RESTRICT,
    sex varchar(50) REFERENCES cl_sex ON UPDATE CASCADE ON DELETE RESTRICT,
    otolith_count int REFERENCES cl_otolith_number ON UPDATE CASCADE ON DELETE RESTRICT,
    otolith_breaking VARCHAR(50) REFERENCES cl_otolith_breaking ON UPDATE CASCADE ON DELETE RESTRICT,
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
    sample varchar(20) REFERENCES co_sample ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE co_prep
(
    id varchar(20) PRIMARY KEY REFERENCES co_subsample ON UPDATE CASCADE ON DELETE RESTRICT,
    packaging1 varchar(50) REFERENCES cl_packaging ON UPDATE CASCADE ON DELETE RESTRICT,
    storage_mode1 varchar(20) REFERENCES cl_storage_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    storage_date date,
    drying_mode varchar(15) REFERENCES cl_drying_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    drying_date date,
    packaging_final varchar(50) REFERENCES cl_packaging ON UPDATE CASCADE ON DELETE RESTRICT,
    storage_mode_final varchar(20) REFERENCES cl_storage_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    grinding_mode varchar(50) REFERENCES cl_grinding_mode ON UPDATE CASCADE ON DELETE RESTRICT
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
    type varchar(10),
    "group" varchar(10),
    FOREIGN KEY (type, "group") REFERENCES cl_analysis(analysis, analysis_group) ON UPDATE CASCADE ON DELETE RESTRICT,
    replicate varchar(5) REFERENCES cl_analysis_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    lab varchar(15) REFERENCES cl_analysis_lab ON UPDATE CASCADE ON DELETE RESTRICT,
    operator_name varchar(25) REFERENCES cl_operator ON UPDATE CASCADE ON DELETE RESTRICT,
    sample_description text,
    mode varchar(15) REFERENCES cl_analysis_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    remarks text,
    check_date date,
    subsample varchar(20) REFERENCES co_subsample ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_lipid_classes
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
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
    aa_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    extraction_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_proteins
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
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
    measurement_type varchar(25) REFERENCES cl_otolith_measurement ON UPDATE CASCADE ON DELETE RESTRICT,
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

CREATE TABLE an_stomach_content
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    scc_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_reproduction_maturity
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    method varchar(50),
    micro_sex varchar(3),
    micro_maturity_stage varchar(50),
    mago_substage varchar(50),
    mago_stage varchar(50),
    pof varchar(50) REFERENCES cl_pof ON UPDATE CASCADE ON DELETE RESTRICT,
    a_atresia boolean,
    b_atresia boolean,
    brown_bodies boolean,
    muscle_bundles boolean,
    rho boolean,
    ovary_wall decimal,
    repro_phase varchar(50),
    repro_subphase varchar(50),
    atretic_oocyte_stage varchar(50) REFERENCES cl_atretic_oocyte_stage ON UPDATE CASCADE ON DELETE RESTRICT,
    atretic_oocyte_percent varchar(10),
    atretic_stage INT REFERENCES cl_atresia ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(micro_sex, micro_maturity_stage, mago_substage, mago_stage, repro_phase, repro_subphase)
    REFERENCES cl_micro_maturity(micro_sex, micro_maturity, mago_substage, mago_stage, repro_phase, repro_subphase)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_fatty_acids
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_replicate varchar(7) REFERENCES cl_processing_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    fractionation_mode varchar(50) REFERENCES cl_fractionation_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    fraction_type varchar(50) REFERENCES cl_fraction_type ON UPDATE CASCADE ON DELETE RESTRICT,
    dilution_factor int,
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

CREATE TABLE an_analysis_reference_material
(
    analysis_id varchar(20) REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    reference_material varchar(50) REFERENCES cl_reference_material ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (analysis_id, reference_material)
);

CREATE TABLE an_contaminants_hg
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    thg_c_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    thg_q_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_stable_isotopes
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    processing_replicate varchar(7) REFERENCES cl_processing_replicate ON UPDATE CASCADE ON DELETE RESTRICT,
    si_plate_code varchar(25),
    analysis_sample_mass float,
    analysis_sample_mass_unit varchar(50) REFERENCES cl_measure_unit ON UPDATE CASCADE ON DELETE RESTRICT,
    lipid_remov_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    urea_remov_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT,
    carbonate_remov_mode varchar(50) REFERENCES cl_extraction_mode ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE an_fatmeter
(
    analysis_id varchar(20) PRIMARY KEY REFERENCES an_analysis ON UPDATE CASCADE ON DELETE RESTRICT,
    fish_face varchar(15) REFERENCES cl_fish_face ON UPDATE CASCADE ON DELETE RESTRICT,
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

COMMIT;