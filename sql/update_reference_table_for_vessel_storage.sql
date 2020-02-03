DROP TABLE references_tables.vessel_storage;
CREATE TABLE references_tables.vessel_storage
(
  c_bat_stor_mod character varying(255),
  desc_bat_stor_mod_fr character varying(255),
  desc_bat_stor_mod_uk character varying(255) NOT NULL
);
ALTER TABLE references_tables.vessel_storage OWNER TO "dbaEmotion";