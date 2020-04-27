-- THIS SCRIPT NEEDS TO BE RUN BY A ROLE WITH CREATEROLE PRIVILEGE

-- The admin role that can create databases and roles
CREATE ROLE geodb_admin CREATEROLE CREATEDB LOGIN PASSWORD 'geodb_admin';
-- The group whose members have read-only access to data
CREATE ROLE sfa_view;
-- The group whose members have read-write access to data
CREATE ROLE sfa_update;
-- The group whose members can modify data in codelist and metadata tables
CREATE ROLE sfa_admin;

-- Create a standard user role and make it member of two groups
CREATE ROLE echassot LOGIN;
ALTER ROLE echassot password 'echassot';
GRANT sfa_update, sfa_admin TO echassot;