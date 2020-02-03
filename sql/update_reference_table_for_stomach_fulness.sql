DROP TABLE references_tables.stomach_fullness;

CREATE TABLE references_tables.stomach_fullness
(
  c_stom_fullness character varying(255) NOT NULL,
  desc_stom_fullness character varying(255)
);

ALTER TABLE references_tables.stomach_fullness OWNER TO "dbaEmotion";