-- Exclusive Economic Zone of Ivory Coast
UPDATE fishing_environment
SET geom = (SELECT geom FROM geo_data.eez WHERE iso_ter1 LIKE 'CIV'),
--geom_text = (SELECT ST_AsText(geom) FROM geo_data.eez WHERE iso_ter1 LIKE 'CIV'),
geom_uncertainty = (SELECT ROUND( (ST_Area(geom::geography)/1e6)::numeric,1) FROM geo_data.eez WHERE iso_ter1 LIKE 'CIV')
WHERE (geom IS NULL AND r_fishing LIKE '%Ivory Coast EEZ%');

-- Mahé Plateau of Seychelles
UPDATE fishing_environment
SET geom = (SELECT geom FROM geo_data.mahe_plateau),
geom_uncertainty = (SELECT ROUND( (ST_Area(geom::geography)/1e6)::numeric,1) FROM geo_data.mahe_plateau)
WHERE (geom IS NULL AND r_fishing LIKE '%Mahe Plateau%');

-- EEZ of Seychelles
UPDATE fishing_environment
SET geom = (SELECT geom FROM geo_data.eez WHERE iso_ter1 LIKE 'SYC'),
--geom_text = (SELECT ST_AsText(geom) FROM geo_data.eez WHERE iso_ter1 LIKE 'SYC'),
geom_uncertainty = (SELECT ROUND( (ST_Area(geom::geography)/1e6)::numeric,1) FROM geo_data.eez WHERE iso_ter1 LIKE 'SYC')
WHERE (geom IS NULL AND r_fishing LIKE '%SYC EEZ%');

-- Indian Ocean basin (indicated with WKT_IO in the remarks
UPDATE fishing_environment
SET geom = (SELECT geom FROM geo_data.rfmos WHERE gid = 4),
geom_uncertainty = (SELECT ST_area(ST_Transform(ST_Collect(geom),4326)::geography)/1000000 FROM geo_data.rfmos WHERE gid = 4)
WHERE (geom IS NULL AND r_fishing LIKE '%WKT_IO%');

-- Atlantic Ocean basin (indicated with WKT_AO in the remarks
UPDATE fishing_environment
SET geom = (SELECT geom FROM geo_data.rfmos WHERE gid = 3),
geom_uncertainty = (SELECT ST_area(ST_Transform(ST_Collect(geom),4326)::geography)/1000000 FROM geo_data.rfmos WHERE gid = 3)
WHERE (geom IS NULL AND r_fishing LIKE '%WKT_AO%');
