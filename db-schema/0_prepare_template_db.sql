CREATE EXTENSION IF NOT EXISTS postgis;
REVOKE CREATE ON SCHEMA public FROM public;
UPDATE pg_database SET datistemplate = true WHERE datname = 'template_postgis';
