DROP TABLE IF EXISTS references_tables.processing_replicates;

CREATE TABLE references_tables.processing_replicates
(
  l_process_rep character varying(255),
  desc_process_rep character varying(255)
);

ALTER TABLE references_tables.operator OWNER TO "dbaEmotion";
