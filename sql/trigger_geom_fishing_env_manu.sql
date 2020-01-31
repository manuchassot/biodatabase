CREATE OR REPLACE FUNCTION public.update_geom_fishing_env() RETURNS trigger AS
$BODY$
	BEGIN
		IF NEW.geom_text like 'MULTIP%' THEN
--			NEW.geom = ST_convexhull(ST_setSRID(ST_GeomFromText(NEW.geom_text),4326));
			NEW.geom = WITH io_waters AS (SELECT )
				   ST_Intersects ( ST_convexhull(ST_setSRID(ST_GeomFromText(NEW.geom_text),4326)), combined_eez_io);

			IF NEW.geom_uncertainty IS NULL THEN
				NEW.geom_uncertainty = ST_Area(NEW.geom::geography)/1000000;
			END IF;
		END IF;
		IF NEW.geom_text LIKE 'LINE%' THEN
			NEW.geom = ST_buffer(ST_setSRID(ST_GeomFromText(NEW.geom_text),4326)::geography,1852);
			IF NEW.geom_uncertainty IS NULL THEN
				NEW.geom_uncertainty = ST_Area(NEW.geom::geography)/1000000;
			END IF;
		END IF;
		IF NEW.geom_text LIKE 'POINT%' THEN
			NEW.geom = ST_setSRID(ST_GeomFromText(NEW.geom_text),4326);
			IF NEW.geom_uncertainty IS NULL then
				NEW.geom_uncertainty = 0;
			END IF;
		END IF;
		IF NEW.geom_text LIKE 'WKT_IO' THEN
			NEW.geom = (SELECT geom FROM geo_data.rfmos WHERE gid = 4);
			IF NEW.geom_uncertainty IS NULL THEN
				NEW.geom_uncertainty = (SELECT ST_area(ST_Transform(ST_Collect(geom),4326)::geography)/1000000 FROM geo_data.rfmos WHERE gid = 4); 
			END IF;
		END IF;
		IF NEW.geom_text like 'POLYGON%' THEN
			NEW.geom = ST_GeomFromText(NEW.geom_text,4326);
			IF NEW.geom_uncertainty is NULL then
				NEW.geom_uncertainty = ST_area(NEW.geom::geography)/1000000;
			END IF;
		END IF;
		RETURN NEW;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

ALTER FUNCTION public.update_geom_fishing_env() OWNER TO postgres;

