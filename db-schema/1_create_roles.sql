-- THIS SCRIPT NEEDS TO BE RUN BY A USER WITH 'CREATEROLE' PRIVILEGE

-- The admin role that can create databases and roles
CREATE ROLE geodb_admin CREATEROLE CREATEDB LOGIN PASSWORD 'xxxxxxxx';
-- The group whose members have read-only access to data
CREATE ROLE sfa_view;
-- The group whose members have read-write access to data
CREATE ROLE sfa_update;
-- The group whose members can modify data in codelist and metadata tables
CREATE ROLE sfa_admin;

-- Example of how to create a standard user role and make it member of two groups
CREATE ROLE rgovinden LOGIN;
ALTER ROLE rgovinden password 'xxxxxxxx';
GRANT sfa_update, sfa_admin TO rgovinden;