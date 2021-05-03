--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: st_eez; Type: TABLE; Schema: spatial; Owner: geodb_admin
--

CREATE TABLE spatial.st_eez (
    id integer NOT NULL,
    geom public.geometry(MultiPolygon,4326),
    polygonid integer,
    mrgid integer,
    geoname character varying(254),
    pol_type character varying(254),
    mrgid_ter1 integer,
    territory1 character varying(254),
    mrgid_sov1 integer,
    sovereign1 character varying(254),
    iso_ter1 character varying(254),
    mrgid_ter2 integer,
    territory2 character varying(254),
    mrgid_sov2 integer,
    sovereign2 character varying(254),
    iso_ter2 character varying(254),
    mrgid_ter3 integer,
    territory3 character varying(254),
    mrgid_sov3 integer,
    sovereign3 character varying(254),
    iso_ter3 character varying(254),
    x_1 double precision,
    y_1 double precision,
    area_km2 double precision,
    mrgid_eez integer
);


ALTER TABLE spatial.st_eez OWNER TO geodb_admin;

--
-- Name: eez_id_seq; Type: SEQUENCE; Schema: spatial; Owner: geodb_admin
--

CREATE SEQUENCE spatial.eez_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE spatial.eez_id_seq OWNER TO geodb_admin;

--
-- Name: eez_id_seq; Type: SEQUENCE OWNED BY; Schema: spatial; Owner: geodb_admin
--

ALTER SEQUENCE spatial.eez_id_seq OWNED BY spatial.st_eez.id;


--
-- Name: st_mahe_plateau; Type: TABLE; Schema: spatial; Owner: geodb_admin
--

CREATE TABLE spatial.st_mahe_plateau (
    gid integer NOT NULL,
    __gid integer,
    et_id integer,
    id integer,
    contour numeric,
    geom public.geometry(MultiPolygon,4326)
);


ALTER TABLE spatial.st_mahe_plateau OWNER TO geodb_admin;

--
-- Name: mahe_plateau_gid_seq; Type: SEQUENCE; Schema: spatial; Owner: geodb_admin
--

CREATE SEQUENCE spatial.mahe_plateau_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE spatial.mahe_plateau_gid_seq OWNER TO geodb_admin;

--
-- Name: mahe_plateau_gid_seq; Type: SEQUENCE OWNED BY; Schema: spatial; Owner: geodb_admin
--

ALTER SEQUENCE spatial.mahe_plateau_gid_seq OWNED BY spatial.st_mahe_plateau.gid;


--
-- Name: st_rfmos; Type: TABLE; Schema: spatial; Owner: geodb_admin
--

CREATE TABLE spatial.st_rfmos (
    gid integer NOT NULL,
    name character varying(254),
    french_nam character varying(18),
    english_na character varying(26),
    spanish_na character varying(32),
    id_origin_ double precision,
    geom public.geometry(MultiPolygon,4326)
);


ALTER TABLE spatial.st_rfmos OWNER TO geodb_admin;

--
-- Name: rfmos_gid_seq; Type: SEQUENCE; Schema: spatial; Owner: geodb_admin
--

CREATE SEQUENCE spatial.rfmos_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE spatial.rfmos_gid_seq OWNER TO geodb_admin;

--
-- Name: rfmos_gid_seq; Type: SEQUENCE OWNED BY; Schema: spatial; Owner: geodb_admin
--

ALTER SEQUENCE spatial.rfmos_gid_seq OWNED BY spatial.st_rfmos.gid;


--
-- Name: st_eez id; Type: DEFAULT; Schema: spatial; Owner: geodb_admin
--

ALTER TABLE ONLY spatial.st_eez ALTER COLUMN id SET DEFAULT nextval('spatial.eez_id_seq'::regclass);


--
-- Name: st_mahe_plateau gid; Type: DEFAULT; Schema: spatial; Owner: geodb_admin
--

ALTER TABLE ONLY spatial.st_mahe_plateau ALTER COLUMN gid SET DEFAULT nextval('spatial.mahe_plateau_gid_seq'::regclass);


--
-- Name: st_rfmos gid; Type: DEFAULT; Schema: spatial; Owner: geodb_admin
--

ALTER TABLE ONLY spatial.st_rfmos ALTER COLUMN gid SET DEFAULT nextval('spatial.rfmos_gid_seq'::regclass);


--
-- Name: st_eez eez_pkey; Type: CONSTRAINT; Schema: spatial; Owner: geodb_admin
--

ALTER TABLE ONLY spatial.st_eez
    ADD CONSTRAINT eez_pkey PRIMARY KEY (id);


--
-- Name: st_mahe_plateau mahe_plateau_pkey; Type: CONSTRAINT; Schema: spatial; Owner: geodb_admin
--

ALTER TABLE ONLY spatial.st_mahe_plateau
    ADD CONSTRAINT mahe_plateau_pkey PRIMARY KEY (gid);


--
-- Name: st_rfmos rfmos_pkey; Type: CONSTRAINT; Schema: spatial; Owner: geodb_admin
--

ALTER TABLE ONLY spatial.st_rfmos
    ADD CONSTRAINT rfmos_pkey PRIMARY KEY (gid);


--
-- Name: mahe_plateau_geom_idx; Type: INDEX; Schema: spatial; Owner: geodb_admin
--

CREATE INDEX mahe_plateau_geom_idx ON spatial.st_mahe_plateau USING gist (geom);


--
-- Name: rfmos_geom_idx; Type: INDEX; Schema: spatial; Owner: geodb_admin
--

CREATE INDEX rfmos_geom_idx ON spatial.st_rfmos USING gist (geom);


--
-- Name: sidx_eez_geom; Type: INDEX; Schema: spatial; Owner: geodb_admin
--

CREATE INDEX sidx_eez_geom ON spatial.st_eez USING gist (geom);


--
-- Name: SCHEMA spatial; Type: ACL; Schema: -; Owner: geodb_admin
--

GRANT USAGE ON SCHEMA spatial TO sfa_view;
GRANT USAGE ON SCHEMA spatial TO sfa_update;
GRANT USAGE ON SCHEMA spatial TO sfa_admin;


--
-- PostgreSQL database dump complete
--

