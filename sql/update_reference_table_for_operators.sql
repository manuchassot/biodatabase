-- DELETE FROM references_tables.operator;
DROP TABLE IF EXISTS references_tables.operator;

CREATE TABLE references_tables.operator (

    l_operator character varying(255) NOT NULL,
    affiliation1 character varying(255),
    affiliation2 character varying(255)
    
);

ALTER TABLE references_tables.operator OWNER TO "dbaEmotion";



