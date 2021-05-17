--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: depth_fdw; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA depth_fdw;


ALTER SCHEMA depth_fdw OWNER TO postgres;

--
-- Name: depth_tables; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA depth_tables;


ALTER SCHEMA depth_tables OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


SET search_path = public, pg_catalog;

--
-- Name: addbbox(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION addbbox(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_addBBOX';


ALTER FUNCTION public.addbbox(geometry) OWNER TO postgres;

--
-- Name: addpoint(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION addpoint(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_addpoint';


ALTER FUNCTION public.addpoint(geometry, geometry) OWNER TO postgres;

--
-- Name: addpoint(geometry, geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION addpoint(geometry, geometry, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_addpoint';


ALTER FUNCTION public.addpoint(geometry, geometry, integer) OWNER TO postgres;

--
-- Name: adjustsequence(character varying, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION adjustsequence(cname character varying, ivalue bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	iSeqVal bigint;
begin
	if iValue is null then
		return;
	end if;
	execute 'select last_value from ' || cName into iSeqVal;
	while iSeqVal < iValue
	loop
		iSeqVal := nextval( cName );
	end loop;
end;
$$;


ALTER FUNCTION public.adjustsequence(cname character varying, ivalue bigint) OWNER TO postgres;

--
-- Name: affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  $2, $3, 0,  $4, $5, 0,  0, 0, 1,  $6, $7, 0)$_$;


ALTER FUNCTION public.affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_affine';


ALTER FUNCTION public.affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: area(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION area(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_area_polygon';


ALTER FUNCTION public.area(geometry) OWNER TO postgres;

--
-- Name: area2d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION area2d(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_area_polygon';


ALTER FUNCTION public.area2d(geometry) OWNER TO postgres;

--
-- Name: asbinary(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asbinary(geometry) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asBinary';


ALTER FUNCTION public.asbinary(geometry) OWNER TO postgres;

--
-- Name: asbinary(geometry, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asbinary(geometry, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asBinary';


ALTER FUNCTION public.asbinary(geometry, text) OWNER TO postgres;

--
-- Name: asewkb(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asewkb(geometry) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'WKBFromLWGEOM';


ALTER FUNCTION public.asewkb(geometry) OWNER TO postgres;

--
-- Name: asewkb(geometry, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asewkb(geometry, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'WKBFromLWGEOM';


ALTER FUNCTION public.asewkb(geometry, text) OWNER TO postgres;

--
-- Name: asewkt(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asewkt(geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asEWKT';


ALTER FUNCTION public.asewkt(geometry) OWNER TO postgres;

--
-- Name: asgml(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asgml(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, 15, 0, null, null)$_$;


ALTER FUNCTION public.asgml(geometry) OWNER TO postgres;

--
-- Name: asgml(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asgml(geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, $2, 0, null, null)$_$;


ALTER FUNCTION public.asgml(geometry, integer) OWNER TO postgres;

--
-- Name: ashexewkb(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ashexewkb(geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asHEXEWKB';


ALTER FUNCTION public.ashexewkb(geometry) OWNER TO postgres;

--
-- Name: ashexewkb(geometry, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ashexewkb(geometry, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asHEXEWKB';


ALTER FUNCTION public.ashexewkb(geometry, text) OWNER TO postgres;

--
-- Name: askml(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION askml(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML(2, ST_Transform($1,4326), 15, null)$_$;


ALTER FUNCTION public.askml(geometry) OWNER TO postgres;

--
-- Name: askml(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION askml(geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML(2, ST_transform($1,4326), $2, null)$_$;


ALTER FUNCTION public.askml(geometry, integer) OWNER TO postgres;

--
-- Name: askml(integer, geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION askml(integer, geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML($1, ST_Transform($2,4326), $3, null)$_$;


ALTER FUNCTION public.askml(integer, geometry, integer) OWNER TO postgres;

--
-- Name: assvg(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION assvg(geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asSVG';


ALTER FUNCTION public.assvg(geometry) OWNER TO postgres;

--
-- Name: assvg(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION assvg(geometry, integer) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asSVG';


ALTER FUNCTION public.assvg(geometry, integer) OWNER TO postgres;

--
-- Name: assvg(geometry, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION assvg(geometry, integer, integer) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asSVG';


ALTER FUNCTION public.assvg(geometry, integer, integer) OWNER TO postgres;

--
-- Name: astext(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION astext(geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_asText';


ALTER FUNCTION public.astext(geometry) OWNER TO postgres;

--
-- Name: azimuth(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION azimuth(geometry, geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_azimuth';


ALTER FUNCTION public.azimuth(geometry, geometry) OWNER TO postgres;

--
-- Name: bdmpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION bdmpolyfromtext(text, integer) RETURNS geometry
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline geometry;
	geom geometry;
BEGIN
	mline := ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := ST_Multi(ST_BuildArea(mline));

	RETURN geom;
END;
$_$;


ALTER FUNCTION public.bdmpolyfromtext(text, integer) OWNER TO postgres;

--
-- Name: bdpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION bdpolyfromtext(text, integer) RETURNS geometry
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline geometry;
	geom geometry;
BEGIN
	mline := ST_MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := ST_BuildArea(mline);

	IF GeometryType(geom) != 'POLYGON'
	THEN
		RAISE EXCEPTION 'Input returns more then a single polygon, try using BdMPolyFromText instead';
	END IF;

	RETURN geom;
END;
$_$;


ALTER FUNCTION public.bdpolyfromtext(text, integer) OWNER TO postgres;

--
-- Name: boundary(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION boundary(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'boundary';


ALTER FUNCTION public.boundary(geometry) OWNER TO postgres;

--
-- Name: buffer(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION buffer(geometry, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'buffer';


ALTER FUNCTION public.buffer(geometry, double precision) OWNER TO postgres;

--
-- Name: buffer(geometry, double precision, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION buffer(geometry, double precision, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_Buffer($1, $2, $3)$_$;


ALTER FUNCTION public.buffer(geometry, double precision, integer) OWNER TO postgres;

--
-- Name: buildarea(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION buildarea(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'ST_BuildArea';


ALTER FUNCTION public.buildarea(geometry) OWNER TO postgres;

--
-- Name: centroid(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION centroid(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'centroid';


ALTER FUNCTION public.centroid(geometry) OWNER TO postgres;

--
-- Name: collect(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION collect(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE
    AS '$libdir/postgis-2.3', 'LWGEOM_collect';


ALTER FUNCTION public.collect(geometry, geometry) OWNER TO postgres;

--
-- Name: combine_bbox(box2d, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION combine_bbox(box2d, geometry) RETURNS box2d
    LANGUAGE c IMMUTABLE
    AS '$libdir/postgis-2.3', 'BOX2D_combine';


ALTER FUNCTION public.combine_bbox(box2d, geometry) OWNER TO postgres;

--
-- Name: combine_bbox(box3d, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION combine_bbox(box3d, geometry) RETURNS box3d
    LANGUAGE c IMMUTABLE
    AS '$libdir/postgis-2.3', 'BOX3D_combine';


ALTER FUNCTION public.combine_bbox(box3d, geometry) OWNER TO postgres;

--
-- Name: contains(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION contains(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'contains';


ALTER FUNCTION public.contains(geometry, geometry) OWNER TO postgres;

--
-- Name: convexhull(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION convexhull(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'convexhull';


ALTER FUNCTION public.convexhull(geometry) OWNER TO postgres;

--
-- Name: crosses(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION crosses(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'crosses';


ALTER FUNCTION public.crosses(geometry, geometry) OWNER TO postgres;

--
-- Name: difference(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION difference(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'difference';


ALTER FUNCTION public.difference(geometry, geometry) OWNER TO postgres;

--
-- Name: dimension(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dimension(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_dimension';


ALTER FUNCTION public.dimension(geometry) OWNER TO postgres;

--
-- Name: disjoint(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION disjoint(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'disjoint';


ALTER FUNCTION public.disjoint(geometry, geometry) OWNER TO postgres;

--
-- Name: distance(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION distance(geometry, geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'LWGEOM_mindistance2d';


ALTER FUNCTION public.distance(geometry, geometry) OWNER TO postgres;

--
-- Name: distance_sphere(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION distance_sphere(geometry, geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'LWGEOM_distance_sphere';


ALTER FUNCTION public.distance_sphere(geometry, geometry) OWNER TO postgres;

--
-- Name: distance_spheroid(geometry, geometry, spheroid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION distance_spheroid(geometry, geometry, spheroid) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'LWGEOM_distance_ellipsoid';


ALTER FUNCTION public.distance_spheroid(geometry, geometry, spheroid) OWNER TO postgres;

--
-- Name: dropbbox(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dropbbox(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_dropBBOX';


ALTER FUNCTION public.dropbbox(geometry) OWNER TO postgres;

--
-- Name: dump(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dump(geometry) RETURNS SETOF geometry_dump
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_dump';


ALTER FUNCTION public.dump(geometry) OWNER TO postgres;

--
-- Name: dumprings(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dumprings(geometry) RETURNS SETOF geometry_dump
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_dump_rings';


ALTER FUNCTION public.dumprings(geometry) OWNER TO postgres;

--
-- Name: endpoint(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION endpoint(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_endpoint_linestring';


ALTER FUNCTION public.endpoint(geometry) OWNER TO postgres;

--
-- Name: envelope(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION envelope(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_envelope';


ALTER FUNCTION public.envelope(geometry) OWNER TO postgres;

--
-- Name: estimated_extent(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION estimated_extent(text, text) RETURNS box2d
    LANGUAGE c IMMUTABLE STRICT SECURITY DEFINER
    AS '$libdir/postgis-2.3', 'geometry_estimated_extent';


ALTER FUNCTION public.estimated_extent(text, text) OWNER TO postgres;

--
-- Name: estimated_extent(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION estimated_extent(text, text, text) RETURNS box2d
    LANGUAGE c IMMUTABLE STRICT SECURITY DEFINER
    AS '$libdir/postgis-2.3', 'geometry_estimated_extent';


ALTER FUNCTION public.estimated_extent(text, text, text) OWNER TO postgres;

--
-- Name: expand(box2d, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION expand(box2d, double precision) RETURNS box2d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX2D_expand';


ALTER FUNCTION public.expand(box2d, double precision) OWNER TO postgres;

--
-- Name: expand(box3d, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION expand(box3d, double precision) RETURNS box3d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_expand';


ALTER FUNCTION public.expand(box3d, double precision) OWNER TO postgres;

--
-- Name: expand(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION expand(geometry, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_expand';


ALTER FUNCTION public.expand(geometry, double precision) OWNER TO postgres;

--
-- Name: exteriorring(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION exteriorring(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_exteriorring_polygon';


ALTER FUNCTION public.exteriorring(geometry) OWNER TO postgres;

--
-- Name: fib_track_info(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fib_track_info() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
 new.id := nextval( 'public.seq_tif' );
 return new;
end;
$$;


ALTER FUNCTION public.fib_track_info() OWNER TO postgres;

--
-- Name: find_extent(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION find_extent(text, text) RETURNS box2d
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	tablename alias for $1;
	columnname alias for $2;
	myrec RECORD;

BEGIN
	FOR myrec IN EXECUTE 'SELECT ST_Extent("' || columnname || '") As extent FROM "' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP;
END;
$_$;


ALTER FUNCTION public.find_extent(text, text) OWNER TO postgres;

--
-- Name: find_extent(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION find_extent(text, text, text) RETURNS box2d
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	schemaname alias for $1;
	tablename alias for $2;
	columnname alias for $3;
	myrec RECORD;

BEGIN
	FOR myrec IN EXECUTE 'SELECT ST_Extent("' || columnname || '") FROM "' || schemaname || '"."' || tablename || '" As extent ' LOOP
		return myrec.extent;
	END LOOP;
END;
$_$;


ALTER FUNCTION public.find_extent(text, text, text) OWNER TO postgres;

--
-- Name: fix_geometry_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fix_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	mislinked record;
	result text;
	linked integer;
	deleted integer;
	foundschema integer;
BEGIN

	-- Since 7.3 schema support has been added.
	-- Previous postgis versions used to put the database name in
	-- the schema column. This needs to be fixed, so we try to
	-- set the correct schema for each geometry_colums record
	-- looking at table, column, type and srid.

	return 'This function is obsolete now that geometry_columns is a view';

END;
$$;


ALTER FUNCTION public.fix_geometry_columns() OWNER TO postgres;

--
-- Name: force_2d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION force_2d(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_2d';


ALTER FUNCTION public.force_2d(geometry) OWNER TO postgres;

--
-- Name: force_3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION force_3d(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_3dz';


ALTER FUNCTION public.force_3d(geometry) OWNER TO postgres;

--
-- Name: force_3dm(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION force_3dm(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_3dm';


ALTER FUNCTION public.force_3dm(geometry) OWNER TO postgres;

--
-- Name: force_3dz(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION force_3dz(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_3dz';


ALTER FUNCTION public.force_3dz(geometry) OWNER TO postgres;

--
-- Name: force_4d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION force_4d(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_4d';


ALTER FUNCTION public.force_4d(geometry) OWNER TO postgres;

--
-- Name: force_collection(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION force_collection(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_collection';


ALTER FUNCTION public.force_collection(geometry) OWNER TO postgres;

--
-- Name: forcerhr(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION forcerhr(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_clockwise_poly';


ALTER FUNCTION public.forcerhr(geometry) OWNER TO postgres;

--
-- Name: geomcollfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromtext(text) OWNER TO postgres;

--
-- Name: geomcollfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromtext(text, integer) OWNER TO postgres;

--
-- Name: geomcollfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromWKB($1)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromwkb(bytea) OWNER TO postgres;

--
-- Name: geomcollfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromWKB($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: geometryfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geometryfromtext(text) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_from_text';


ALTER FUNCTION public.geometryfromtext(text) OWNER TO postgres;

--
-- Name: geometryfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geometryfromtext(text, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_from_text';


ALTER FUNCTION public.geometryfromtext(text, integer) OWNER TO postgres;

--
-- Name: geometryn(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geometryn(geometry, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_geometryn_collection';


ALTER FUNCTION public.geometryn(geometry, integer) OWNER TO postgres;

--
-- Name: geomfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_GeomFromText($1)$_$;


ALTER FUNCTION public.geomfromtext(text) OWNER TO postgres;

--
-- Name: geomfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_GeomFromText($1, $2)$_$;


ALTER FUNCTION public.geomfromtext(text, integer) OWNER TO postgres;

--
-- Name: geomfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomfromwkb(bytea) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_from_WKB';


ALTER FUNCTION public.geomfromwkb(bytea) OWNER TO postgres;

--
-- Name: geomfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_SetSRID(ST_GeomFromWKB($1), $2)$_$;


ALTER FUNCTION public.geomfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: geomunion(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomunion(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'geomunion';


ALTER FUNCTION public.geomunion(geometry, geometry) OWNER TO postgres;

--
-- Name: getbbox(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getbbox(geometry) RETURNS box2d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_to_BOX2D';


ALTER FUNCTION public.getbbox(geometry) OWNER TO postgres;

--
-- Name: getsrid(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getsrid(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_get_srid';


ALTER FUNCTION public.getsrid(geometry) OWNER TO postgres;

--
-- Name: hasbbox(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION hasbbox(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_hasBBOX';


ALTER FUNCTION public.hasbbox(geometry) OWNER TO postgres;

--
-- Name: interiorringn(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION interiorringn(geometry, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_interiorringn_polygon';


ALTER FUNCTION public.interiorringn(geometry, integer) OWNER TO postgres;

--
-- Name: intersection(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION intersection(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'intersection';


ALTER FUNCTION public.intersection(geometry, geometry) OWNER TO postgres;

--
-- Name: intersects(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION intersects(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'intersects';


ALTER FUNCTION public.intersects(geometry, geometry) OWNER TO postgres;

--
-- Name: isclosed(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION isclosed(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_isclosed';


ALTER FUNCTION public.isclosed(geometry) OWNER TO postgres;

--
-- Name: isempty(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION isempty(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_isempty';


ALTER FUNCTION public.isempty(geometry) OWNER TO postgres;

--
-- Name: isring(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION isring(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'isring';


ALTER FUNCTION public.isring(geometry) OWNER TO postgres;

--
-- Name: issimple(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION issimple(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'issimple';


ALTER FUNCTION public.issimple(geometry) OWNER TO postgres;

--
-- Name: isvalid(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION isvalid(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'isvalid';


ALTER FUNCTION public.isvalid(geometry) OWNER TO postgres;

--
-- Name: length(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION length(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_length_linestring';


ALTER FUNCTION public.length(geometry) OWNER TO postgres;

--
-- Name: length2d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION length2d(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_length2d_linestring';


ALTER FUNCTION public.length2d(geometry) OWNER TO postgres;

--
-- Name: length2d_spheroid(geometry, spheroid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION length2d_spheroid(geometry, spheroid) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'LWGEOM_length2d_ellipsoid';


ALTER FUNCTION public.length2d_spheroid(geometry, spheroid) OWNER TO postgres;

--
-- Name: length3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION length3d(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_length_linestring';


ALTER FUNCTION public.length3d(geometry) OWNER TO postgres;

--
-- Name: length3d_spheroid(geometry, spheroid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION length3d_spheroid(geometry, spheroid) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_length_ellipsoid_linestring';


ALTER FUNCTION public.length3d_spheroid(geometry, spheroid) OWNER TO postgres;

--
-- Name: length_spheroid(geometry, spheroid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION length_spheroid(geometry, spheroid) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'LWGEOM_length_ellipsoid_linestring';


ALTER FUNCTION public.length_spheroid(geometry, spheroid) OWNER TO postgres;

--
-- Name: line_interpolate_point(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION line_interpolate_point(geometry, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_line_interpolate_point';


ALTER FUNCTION public.line_interpolate_point(geometry, double precision) OWNER TO postgres;

--
-- Name: line_locate_point(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION line_locate_point(geometry, geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_line_locate_point';


ALTER FUNCTION public.line_locate_point(geometry, geometry) OWNER TO postgres;

--
-- Name: line_substring(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION line_substring(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_line_substring';


ALTER FUNCTION public.line_substring(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: linefrommultipoint(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefrommultipoint(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_line_from_mpoint';


ALTER FUNCTION public.linefrommultipoint(geometry) OWNER TO postgres;

--
-- Name: linefromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'LINESTRING'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromtext(text) OWNER TO postgres;

--
-- Name: linefromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'LINESTRING'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromtext(text, integer) OWNER TO postgres;

--
-- Name: linefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'LINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromwkb(bytea) OWNER TO postgres;

--
-- Name: linefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: linemerge(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linemerge(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'linemerge';


ALTER FUNCTION public.linemerge(geometry) OWNER TO postgres;

--
-- Name: linestringfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT LineFromText($1)$_$;


ALTER FUNCTION public.linestringfromtext(text) OWNER TO postgres;

--
-- Name: linestringfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT LineFromText($1, $2)$_$;


ALTER FUNCTION public.linestringfromtext(text, integer) OWNER TO postgres;

--
-- Name: linestringfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'LINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linestringfromwkb(bytea) OWNER TO postgres;

--
-- Name: linestringfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linestringfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: locate_along_measure(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION locate_along_measure(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT ST_locate_between_measures($1, $2, $2) $_$;


ALTER FUNCTION public.locate_along_measure(geometry, double precision) OWNER TO postgres;

--
-- Name: locate_between_measures(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION locate_between_measures(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_locate_between_m';


ALTER FUNCTION public.locate_between_measures(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: m(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION m(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_m_point';


ALTER FUNCTION public.m(geometry) OWNER TO postgres;

--
-- Name: makebox2d(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makebox2d(geometry, geometry) RETURNS box2d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX2D_construct';


ALTER FUNCTION public.makebox2d(geometry, geometry) OWNER TO postgres;

--
-- Name: makebox3d(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makebox3d(geometry, geometry) RETURNS box3d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_construct';


ALTER FUNCTION public.makebox3d(geometry, geometry) OWNER TO postgres;

--
-- Name: makeline(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makeline(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makeline';


ALTER FUNCTION public.makeline(geometry, geometry) OWNER TO postgres;

--
-- Name: makeline_garray(geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makeline_garray(geometry[]) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makeline_garray';


ALTER FUNCTION public.makeline_garray(geometry[]) OWNER TO postgres;

--
-- Name: makepoint(double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makepoint(double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makepoint';


ALTER FUNCTION public.makepoint(double precision, double precision) OWNER TO postgres;

--
-- Name: makepoint(double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makepoint(double precision, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makepoint';


ALTER FUNCTION public.makepoint(double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: makepoint(double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makepoint(double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makepoint';


ALTER FUNCTION public.makepoint(double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: makepointm(double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makepointm(double precision, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makepoint3dm';


ALTER FUNCTION public.makepointm(double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: makepolygon(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makepolygon(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makepoly';


ALTER FUNCTION public.makepolygon(geometry) OWNER TO postgres;

--
-- Name: makepolygon(geometry, geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makepolygon(geometry, geometry[]) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makepoly';


ALTER FUNCTION public.makepolygon(geometry, geometry[]) OWNER TO postgres;

--
-- Name: max_distance(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION max_distance(geometry, geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_maxdistance2d_linestring';


ALTER FUNCTION public.max_distance(geometry, geometry) OWNER TO postgres;

--
-- Name: mem_size(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mem_size(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_mem_size';


ALTER FUNCTION public.mem_size(geometry) OWNER TO postgres;

--
-- Name: mlinefromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTILINESTRING'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromtext(text) OWNER TO postgres;

--
-- Name: mlinefromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromtext(text, integer) OWNER TO postgres;

--
-- Name: mlinefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromwkb(bytea) OWNER TO postgres;

--
-- Name: mlinefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: mpointfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTIPOINT'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromtext(text) OWNER TO postgres;

--
-- Name: mpointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1,$2)) = 'MULTIPOINT'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromtext(text, integer) OWNER TO postgres;

--
-- Name: mpointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromwkb(bytea) OWNER TO postgres;

--
-- Name: mpointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: mpolyfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTIPOLYGON'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromtext(text) OWNER TO postgres;

--
-- Name: mpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromtext(text, integer) OWNER TO postgres;

--
-- Name: mpolyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromwkb(bytea) OWNER TO postgres;

--
-- Name: mpolyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multi(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multi(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_force_multi';


ALTER FUNCTION public.multi(geometry) OWNER TO postgres;

--
-- Name: multilinefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinefromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multilinefromwkb(bytea) OWNER TO postgres;

--
-- Name: multilinefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinefromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multilinefromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multilinestringfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinestringfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_MLineFromText($1)$_$;


ALTER FUNCTION public.multilinestringfromtext(text) OWNER TO postgres;

--
-- Name: multilinestringfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinestringfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MLineFromText($1, $2)$_$;


ALTER FUNCTION public.multilinestringfromtext(text, integer) OWNER TO postgres;

--
-- Name: multipointfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPointFromText($1)$_$;


ALTER FUNCTION public.multipointfromtext(text) OWNER TO postgres;

--
-- Name: multipointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPointFromText($1, $2)$_$;


ALTER FUNCTION public.multipointfromtext(text, integer) OWNER TO postgres;

--
-- Name: multipointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipointfromwkb(bytea) OWNER TO postgres;

--
-- Name: multipointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipointfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multipolyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolyfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipolyfromwkb(bytea) OWNER TO postgres;

--
-- Name: multipolyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolyfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipolyfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multipolygonfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolygonfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPolyFromText($1)$_$;


ALTER FUNCTION public.multipolygonfromtext(text) OWNER TO postgres;

--
-- Name: multipolygonfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolygonfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPolyFromText($1, $2)$_$;


ALTER FUNCTION public.multipolygonfromtext(text, integer) OWNER TO postgres;

--
-- Name: ndims(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ndims(geometry) RETURNS smallint
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_ndims';


ALTER FUNCTION public.ndims(geometry) OWNER TO postgres;

--
-- Name: noop(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION noop(geometry) RETURNS geometry
    LANGUAGE c STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_noop';


ALTER FUNCTION public.noop(geometry) OWNER TO postgres;

--
-- Name: npoints(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION npoints(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_npoints';


ALTER FUNCTION public.npoints(geometry) OWNER TO postgres;

--
-- Name: nrings(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION nrings(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_nrings';


ALTER FUNCTION public.nrings(geometry) OWNER TO postgres;

--
-- Name: numgeometries(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION numgeometries(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_numgeometries_collection';


ALTER FUNCTION public.numgeometries(geometry) OWNER TO postgres;

--
-- Name: numinteriorring(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION numinteriorring(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_numinteriorrings_polygon';


ALTER FUNCTION public.numinteriorring(geometry) OWNER TO postgres;

--
-- Name: numinteriorrings(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION numinteriorrings(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_numinteriorrings_polygon';


ALTER FUNCTION public.numinteriorrings(geometry) OWNER TO postgres;

--
-- Name: numpoints(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION numpoints(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_numpoints_linestring';


ALTER FUNCTION public.numpoints(geometry) OWNER TO postgres;

--
-- Name: overlaps(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "overlaps"(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'overlaps';


ALTER FUNCTION public."overlaps"(geometry, geometry) OWNER TO postgres;

--
-- Name: perimeter2d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION perimeter2d(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_perimeter2d_poly';


ALTER FUNCTION public.perimeter2d(geometry) OWNER TO postgres;

--
-- Name: perimeter3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION perimeter3d(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_perimeter_poly';


ALTER FUNCTION public.perimeter3d(geometry) OWNER TO postgres;

--
-- Name: point_inside_circle(geometry, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION point_inside_circle(geometry, double precision, double precision, double precision) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_inside_circle_point';


ALTER FUNCTION public.point_inside_circle(geometry, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: pointfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'POINT'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromtext(text) OWNER TO postgres;

--
-- Name: pointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'POINT'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromtext(text, integer) OWNER TO postgres;

--
-- Name: pointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromwkb(bytea) OWNER TO postgres;

--
-- Name: pointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(ST_GeomFromWKB($1, $2)) = 'POINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: pointn(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointn(geometry, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_pointn_linestring';


ALTER FUNCTION public.pointn(geometry, integer) OWNER TO postgres;

--
-- Name: pointonsurface(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointonsurface(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'pointonsurface';


ALTER FUNCTION public.pointonsurface(geometry) OWNER TO postgres;

--
-- Name: polyfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'POLYGON'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromtext(text) OWNER TO postgres;

--
-- Name: polyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'POLYGON'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromtext(text, integer) OWNER TO postgres;

--
-- Name: polyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromwkb(bytea) OWNER TO postgres;

--
-- Name: polyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'POLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: polygonfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT PolyFromText($1)$_$;


ALTER FUNCTION public.polygonfromtext(text) OWNER TO postgres;

--
-- Name: polygonfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT PolyFromText($1, $2)$_$;


ALTER FUNCTION public.polygonfromtext(text, integer) OWNER TO postgres;

--
-- Name: polygonfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polygonfromwkb(bytea) OWNER TO postgres;

--
-- Name: polygonfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'POLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polygonfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: polygonize_garray(geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonize_garray(geometry[]) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'polygonize_garray';


ALTER FUNCTION public.polygonize_garray(geometry[]) OWNER TO postgres;

--
-- Name: probe_geometry_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION probe_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	inserted integer;
	oldcount integer;
	probed integer;
	stale integer;
BEGIN


	RETURN 'This function is obsolete now that geometry_columns is a view';
END

$$;


ALTER FUNCTION public.probe_geometry_columns() OWNER TO postgres;

--
-- Name: pullfromdepth(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pullfromdepth() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
	iRowId bigint;
	iRplId bigint;
	recRpl depth_tables.rpl_journal_shadow;
	recUtr depth_fdw.user_tracks;
	recTif depth_fdw.track_info;
	iRows integer := 0;
	iMaxId bigint;
	iSeqVal bigint;
	cUser varchar;
begin
	execute 'set session_replication_role = replica';

	select max(id) into iRplId from depth_tables.rpl_journal_shadow;
	if iRplId is null then
		iRplId := 0;
	end if;
	insert into depth_tables.rpl_journal_shadow ( select * from depth_fdw.rpl_journal where id > iRplId );

	for recRpl in select * from depth_tables.rpl_journal_shadow where copied is null order by id
	loop
		if recRpl.opcode = 'I' then
			if recRpl.table_name = 'track_info' then
				insert into track_info select * from depth_fdw.track_info where id = recRpl.row_id;
			elsif recRpl.table_name = 'user_tracks' then
				select * into recUtr from depth_fdw.user_tracks where track_id = recRpl.row_id;
				select user_name into cUser from user_profiles where id = recUtr.upr_id;
				insert into user_tracks values(
					recUtr.track_id,
					cUser,
					recUtr.file_ref,
					recUtr.upload_state,
					recUtr.filetype,
					recUtr.compression,
					recUtr.containertrack,
					recUtr.vesselconfigid,
					recUtr.license,
					recUtr.gauge_name,
					recUtr.gauge,
					recUtr.height_ref,
					recUtr.comment,
					recUtr.watertype,
					recUtr.uploaddate,
					recUtr.bbox,
					recUtr.clusteruuid,
					recUtr.clusterseq,
					recUtr.upr_id,
					recUtr.num_points,
					recUtr.is_container);
--				insert into user_tracks select * from depth_fdw.user_tracks where track_id = recRpl.row_id;
--				update user_tracks set user_name = ( select user_name from user_profiles where upr_id = user_tracks.id ) where track_id = recRpl.row_id;
			end if;
		elsif recRpl.opcode = 'U' then
			if recRpl.table_name = 'user_tracks' then
				select * into recUtr from depth_fdw.user_tracks where track_id = recRpl.row_id;
				update user_tracks set
					num_points = recUtr.num_points,
					upload_state = recUtr.upload_state,
					is_container = recUtr.is_container,
					bbox = recUtr.bbox,
					filetype = recUtr.filetype,
					compression = recUtr.compression
				where track_id = recRpl.row_id;
			elsif recRpl.table_name = 'track_info' then
				select * into recTif from depth_fdw.track_info where id = recRpl.row_id;
				update track_info set
					short_info = recTif.short_info,
					long_info = recTif.long_info,
					reprocess = recTif.reprocess,
					discard = recTif.discard
				where id = recRpl.row_id;
			end if;
		elsif recRpl.opcode = 'D' then
			if recRpl.table_name = 'track_info' then
				delete from track_info where id = recRpl.row_id;
			end if;
		end if;
		update depth_tables.rpl_journal_shadow set copied = now() where id = recRpl.id;
		iRows := iRows+1;
	end loop;

	perform adjustsequence( 'user_tracks_track_id_seq', ( select max( track_id ) from user_tracks ) );
	perform adjustsequence( 'seq_tif', ( select max( id ) from track_info ) );

	execute 'set session_replication_role = origin';

	return iRows;
end;
$$;


ALTER FUNCTION public.pullfromdepth() OWNER TO postgres;

--
-- Name: relate(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION relate(geometry, geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'relate_full';


ALTER FUNCTION public.relate(geometry, geometry) OWNER TO postgres;

--
-- Name: relate(geometry, geometry, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION relate(geometry, geometry, text) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'relate_pattern';


ALTER FUNCTION public.relate(geometry, geometry, text) OWNER TO postgres;

--
-- Name: removepoint(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION removepoint(geometry, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_removepoint';


ALTER FUNCTION public.removepoint(geometry, integer) OWNER TO postgres;

--
-- Name: rename_geometry_table_constraints(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rename_geometry_table_constraints() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT 'rename_geometry_table_constraint() is obsoleted'::text
$$;


ALTER FUNCTION public.rename_geometry_table_constraints() OWNER TO postgres;

--
-- Name: reverse(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION reverse(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_reverse';


ALTER FUNCTION public.reverse(geometry) OWNER TO postgres;

--
-- Name: rotate(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotate(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_rotateZ($1, $2)$_$;


ALTER FUNCTION public.rotate(geometry, double precision) OWNER TO postgres;

--
-- Name: rotatex(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotatex(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1, 1, 0, 0, 0, cos($2), -sin($2), 0, sin($2), cos($2), 0, 0, 0)$_$;


ALTER FUNCTION public.rotatex(geometry, double precision) OWNER TO postgres;

--
-- Name: rotatey(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotatey(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  cos($2), 0, sin($2),  0, 1, 0,  -sin($2), 0, cos($2), 0,  0, 0)$_$;


ALTER FUNCTION public.rotatey(geometry, double precision) OWNER TO postgres;

--
-- Name: rotatez(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotatez(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)$_$;


ALTER FUNCTION public.rotatez(geometry, double precision) OWNER TO postgres;

--
-- Name: rpl_log(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rpl_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
 iId bigint;
begin
 if tg_op = 'DELETE' then
 if tg_table_name = 'user_tracks' then
 iId := old.track_id;
 else
 iId := old.id;
 end if;
 else
 if tg_table_name = 'user_tracks' then
 iId := new.track_id;
 else
 iId := new.id;
 end if;
 end if;

 insert into public.rpl_journal( table_name, row_id, opcode )
values( tg_table_name, iId, substr( tg_op, 1, 1 ) );

 return new;
end;
$$;


ALTER FUNCTION public.rpl_log() OWNER TO postgres;

--
-- Name: scale(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION scale(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_scale($1, $2, $3, 1)$_$;


ALTER FUNCTION public.scale(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: scale(geometry, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION scale(geometry, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  $2, 0, 0,  0, $3, 0,  0, 0, $4,  0, 0, 0)$_$;


ALTER FUNCTION public.scale(geometry, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: se_envelopesintersect(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_envelopesintersect(geometry, geometry) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT $1 && $2
	$_$;


ALTER FUNCTION public.se_envelopesintersect(geometry, geometry) OWNER TO postgres;

--
-- Name: se_is3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_is3d(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_hasz';


ALTER FUNCTION public.se_is3d(geometry) OWNER TO postgres;

--
-- Name: se_ismeasured(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_ismeasured(geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_hasm';


ALTER FUNCTION public.se_ismeasured(geometry) OWNER TO postgres;

--
-- Name: se_locatealong(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_locatealong(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT SE_LocateBetween($1, $2, $2) $_$;


ALTER FUNCTION public.se_locatealong(geometry, double precision) OWNER TO postgres;

--
-- Name: se_locatebetween(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_locatebetween(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_locate_between_m';


ALTER FUNCTION public.se_locatebetween(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: se_m(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_m(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_m_point';


ALTER FUNCTION public.se_m(geometry) OWNER TO postgres;

--
-- Name: se_z(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_z(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_z_point';


ALTER FUNCTION public.se_z(geometry) OWNER TO postgres;

--
-- Name: segmentize(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION segmentize(geometry, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_segmentize2d';


ALTER FUNCTION public.segmentize(geometry, double precision) OWNER TO postgres;

--
-- Name: setpoint(geometry, integer, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION setpoint(geometry, integer, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_setpoint_linestring';


ALTER FUNCTION public.setpoint(geometry, integer, geometry) OWNER TO postgres;

--
-- Name: setsrid(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION setsrid(geometry, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_set_srid';


ALTER FUNCTION public.setsrid(geometry, integer) OWNER TO postgres;

--
-- Name: shift_longitude(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION shift_longitude(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_longitude_shift';


ALTER FUNCTION public.shift_longitude(geometry) OWNER TO postgres;

--
-- Name: simplify(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION simplify(geometry, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_simplify2d';


ALTER FUNCTION public.simplify(geometry, double precision) OWNER TO postgres;

--
-- Name: snaptogrid(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION snaptogrid(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_SnapToGrid($1, 0, 0, $2, $2)$_$;


ALTER FUNCTION public.snaptogrid(geometry, double precision) OWNER TO postgres;

--
-- Name: snaptogrid(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION snaptogrid(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_SnapToGrid($1, 0, 0, $2, $3)$_$;


ALTER FUNCTION public.snaptogrid(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: snaptogrid(geometry, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION snaptogrid(geometry, double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_snaptogrid';


ALTER FUNCTION public.snaptogrid(geometry, double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: snaptogrid(geometry, geometry, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION snaptogrid(geometry, geometry, double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_snaptogrid_pointoff';


ALTER FUNCTION public.snaptogrid(geometry, geometry, double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: srid(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION srid(geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_get_srid';


ALTER FUNCTION public.srid(geometry) OWNER TO postgres;

--
-- Name: st_asbinary(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asbinary(text) RETURNS bytea
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT ST_AsBinary($1::geometry);$_$;


ALTER FUNCTION public.st_asbinary(text) OWNER TO postgres;

--
-- Name: st_astext(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_astext(bytea) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT ST_AsText($1::geometry);$_$;


ALTER FUNCTION public.st_astext(bytea) OWNER TO postgres;

--
-- Name: st_box(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box(box3d) RETURNS box
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_to_BOX';


ALTER FUNCTION public.st_box(box3d) OWNER TO postgres;

--
-- Name: st_box(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box(geometry) RETURNS box
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_to_BOX';


ALTER FUNCTION public.st_box(geometry) OWNER TO postgres;

--
-- Name: st_box2d(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box2d(box3d) RETURNS box2d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_to_BOX2D';


ALTER FUNCTION public.st_box2d(box3d) OWNER TO postgres;

--
-- Name: st_box2d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box2d(geometry) RETURNS box2d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_to_BOX2D';


ALTER FUNCTION public.st_box2d(geometry) OWNER TO postgres;

--
-- Name: st_box3d(box2d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box3d(box2d) RETURNS box3d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX2D_to_BOX3D';


ALTER FUNCTION public.st_box3d(box2d) OWNER TO postgres;

--
-- Name: st_box3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box3d(geometry) RETURNS box3d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_to_BOX3D';


ALTER FUNCTION public.st_box3d(geometry) OWNER TO postgres;

--
-- Name: st_box3d_in(cstring); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box3d_in(cstring) RETURNS box3d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_in';


ALTER FUNCTION public.st_box3d_in(cstring) OWNER TO postgres;

--
-- Name: st_box3d_out(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_box3d_out(box3d) RETURNS cstring
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_out';


ALTER FUNCTION public.st_box3d_out(box3d) OWNER TO postgres;

--
-- Name: st_bytea(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_bytea(geometry) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_to_bytea';


ALTER FUNCTION public.st_bytea(geometry) OWNER TO postgres;

--
-- Name: st_geometry(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry(bytea) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_from_bytea';


ALTER FUNCTION public.st_geometry(bytea) OWNER TO postgres;

--
-- Name: st_geometry(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry(text) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'parse_WKT_lwgeom';


ALTER FUNCTION public.st_geometry(text) OWNER TO postgres;

--
-- Name: st_geometry(box2d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry(box2d) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX2D_to_LWGEOM';


ALTER FUNCTION public.st_geometry(box2d) OWNER TO postgres;

--
-- Name: st_geometry(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry(box3d) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_to_LWGEOM';


ALTER FUNCTION public.st_geometry(box3d) OWNER TO postgres;

--
-- Name: st_geometry_cmp(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry_cmp(geometry, geometry) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'lwgeom_cmp';


ALTER FUNCTION public.st_geometry_cmp(geometry, geometry) OWNER TO postgres;

--
-- Name: st_geometry_eq(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry_eq(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'lwgeom_eq';


ALTER FUNCTION public.st_geometry_eq(geometry, geometry) OWNER TO postgres;

--
-- Name: st_geometry_ge(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry_ge(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'lwgeom_ge';


ALTER FUNCTION public.st_geometry_ge(geometry, geometry) OWNER TO postgres;

--
-- Name: st_geometry_gt(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry_gt(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'lwgeom_gt';


ALTER FUNCTION public.st_geometry_gt(geometry, geometry) OWNER TO postgres;

--
-- Name: st_geometry_le(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry_le(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'lwgeom_le';


ALTER FUNCTION public.st_geometry_le(geometry, geometry) OWNER TO postgres;

--
-- Name: st_geometry_lt(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geometry_lt(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'lwgeom_lt';


ALTER FUNCTION public.st_geometry_lt(geometry, geometry) OWNER TO postgres;

--
-- Name: st_length3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_length3d(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_length_linestring';


ALTER FUNCTION public.st_length3d(geometry) OWNER TO postgres;

--
-- Name: st_length_spheroid3d(geometry, spheroid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_length_spheroid3d(geometry, spheroid) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'LWGEOM_length_ellipsoid_linestring';


ALTER FUNCTION public.st_length_spheroid3d(geometry, spheroid) OWNER TO postgres;

--
-- Name: st_makebox3d(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_makebox3d(geometry, geometry) RETURNS box3d
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_construct';


ALTER FUNCTION public.st_makebox3d(geometry, geometry) OWNER TO postgres;

--
-- Name: st_makeline_garray(geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_makeline_garray(geometry[]) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_makeline_garray';


ALTER FUNCTION public.st_makeline_garray(geometry[]) OWNER TO postgres;

--
-- Name: st_perimeter3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_perimeter3d(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_perimeter_poly';


ALTER FUNCTION public.st_perimeter3d(geometry) OWNER TO postgres;

--
-- Name: st_polygonize_garray(geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_polygonize_garray(geometry[]) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT COST 100
    AS '$libdir/postgis-2.3', 'polygonize_garray';


ALTER FUNCTION public.st_polygonize_garray(geometry[]) OWNER TO postgres;

--
-- Name: st_text(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_text(geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_to_text';


ALTER FUNCTION public.st_text(geometry) OWNER TO postgres;

--
-- Name: st_unite_garray(geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_unite_garray(geometry[]) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'pgis_union_geometry_array';


ALTER FUNCTION public.st_unite_garray(geometry[]) OWNER TO postgres;

--
-- Name: startpoint(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION startpoint(geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_startpoint_linestring';


ALTER FUNCTION public.startpoint(geometry) OWNER TO postgres;

--
-- Name: summary(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION summary(geometry) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_summary';


ALTER FUNCTION public.summary(geometry) OWNER TO postgres;

--
-- Name: symdifference(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION symdifference(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'symdifference';


ALTER FUNCTION public.symdifference(geometry, geometry) OWNER TO postgres;

--
-- Name: symmetricdifference(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION symmetricdifference(geometry, geometry) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'symdifference';


ALTER FUNCTION public.symmetricdifference(geometry, geometry) OWNER TO postgres;

--
-- Name: tif_upr_integrity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION tif_upr_integrity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	iUprId bigint;
begin
	select id into iUprId from user_profiles where user_name = new.user_name;
	new.upr_id := iUprId;
	return new;
end;
$$;


ALTER FUNCTION public.tif_upr_integrity() OWNER TO postgres;

--
-- Name: touches(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION touches(geometry, geometry) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'touches';


ALTER FUNCTION public.touches(geometry, geometry) OWNER TO postgres;

--
-- Name: transform(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION transform(geometry, integer) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'transform';


ALTER FUNCTION public.transform(geometry, integer) OWNER TO postgres;

--
-- Name: translate(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION translate(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_translate($1, $2, $3, 0)$_$;


ALTER FUNCTION public.translate(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: translate(geometry, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION translate(geometry, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1, 1, 0, 0, 0, 1, 0, 0, 0, 1, $2, $3, $4)$_$;


ALTER FUNCTION public.translate(geometry, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: transscale(geometry, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION transscale(geometry, double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT st_affine($1,  $4, 0, 0,  0, $5, 0,
		0, 0, 1,  $2 * $4, $3 * $5, 0)$_$;


ALTER FUNCTION public.transscale(geometry, double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: unite_garray(geometry[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION unite_garray(geometry[]) RETURNS geometry
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'pgis_union_geometry_array';


ALTER FUNCTION public.unite_garray(geometry[]) OWNER TO postgres;

--
-- Name: within(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION within(geometry, geometry) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_Within($1, $2)$_$;


ALTER FUNCTION public.within(geometry, geometry) OWNER TO postgres;

--
-- Name: x(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION x(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_x_point';


ALTER FUNCTION public.x(geometry) OWNER TO postgres;

--
-- Name: xmax(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xmax(box3d) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_xmax';


ALTER FUNCTION public.xmax(box3d) OWNER TO postgres;

--
-- Name: xmin(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION xmin(box3d) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_xmin';


ALTER FUNCTION public.xmin(box3d) OWNER TO postgres;

--
-- Name: y(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION y(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_y_point';


ALTER FUNCTION public.y(geometry) OWNER TO postgres;

--
-- Name: ymax(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ymax(box3d) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_ymax';


ALTER FUNCTION public.ymax(box3d) OWNER TO postgres;

--
-- Name: ymin(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ymin(box3d) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_ymin';


ALTER FUNCTION public.ymin(box3d) OWNER TO postgres;

--
-- Name: z(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION z(geometry) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_z_point';


ALTER FUNCTION public.z(geometry) OWNER TO postgres;

--
-- Name: zmax(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION zmax(box3d) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_zmax';


ALTER FUNCTION public.zmax(box3d) OWNER TO postgres;

--
-- Name: zmflag(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION zmflag(geometry) RETURNS smallint
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'LWGEOM_zmflag';


ALTER FUNCTION public.zmflag(geometry) OWNER TO postgres;

--
-- Name: zmin(box3d); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION zmin(box3d) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/postgis-2.3', 'BOX3D_zmin';


ALTER FUNCTION public.zmin(box3d) OWNER TO postgres;

--
-- Name: accum(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE accum(geometry) (
    SFUNC = public.pgis_geometry_accum_transfn,
    STYPE = pgis_abs,
    FINALFUNC = pgis_geometry_accum_finalfn
);


ALTER AGGREGATE public.accum(geometry) OWNER TO postgres;

--
-- Name: extent(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE extent(geometry) (
    SFUNC = public.st_combine_bbox,
    STYPE = box3d,
    FINALFUNC = public.box2d
);


ALTER AGGREGATE public.extent(geometry) OWNER TO postgres;

--
-- Name: extent3d(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE extent3d(geometry) (
    SFUNC = public.combine_bbox,
    STYPE = box3d
);


ALTER AGGREGATE public.extent3d(geometry) OWNER TO postgres;

--
-- Name: makeline(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE makeline(geometry) (
    SFUNC = public.pgis_geometry_accum_transfn,
    STYPE = pgis_abs,
    FINALFUNC = pgis_geometry_makeline_finalfn
);


ALTER AGGREGATE public.makeline(geometry) OWNER TO postgres;

--
-- Name: memcollect(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE memcollect(geometry) (
    SFUNC = public.st_collect,
    STYPE = geometry
);


ALTER AGGREGATE public.memcollect(geometry) OWNER TO postgres;

--
-- Name: memgeomunion(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE memgeomunion(geometry) (
    SFUNC = geomunion,
    STYPE = geometry
);


ALTER AGGREGATE public.memgeomunion(geometry) OWNER TO postgres;

--
-- Name: st_extent3d(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE st_extent3d(geometry) (
    SFUNC = public.st_combine_bbox,
    STYPE = box3d
);


ALTER AGGREGATE public.st_extent3d(geometry) OWNER TO postgres;

--
-- Name: depth; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER depth FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'depth',
    host 'localhost',
    port '5435'
);


ALTER SERVER depth OWNER TO postgres;

--
-- Name: USER MAPPING public SERVER depth; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR public SERVER depth OPTIONS (
    "user" 'osm'
);


SET search_path = depth_fdw, pg_catalog;

SET default_tablespace = '';

--
-- Name: rpl_journal; Type: FOREIGN TABLE; Schema: depth_fdw; Owner: postgres
--

CREATE FOREIGN TABLE rpl_journal (
    id bigint NOT NULL,
    table_name character varying(50) NOT NULL,
    row_id bigint NOT NULL,
    opcode character varying(1) NOT NULL,
    time_stamp timestamp without time zone NOT NULL
)
SERVER depth
OPTIONS (
    schema_name 'public',
    table_name 'rpl_journal'
);
ALTER FOREIGN TABLE rpl_journal ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE rpl_journal ALTER COLUMN table_name OPTIONS (
    column_name 'table_name'
);
ALTER FOREIGN TABLE rpl_journal ALTER COLUMN row_id OPTIONS (
    column_name 'row_id'
);
ALTER FOREIGN TABLE rpl_journal ALTER COLUMN opcode OPTIONS (
    column_name 'opcode'
);
ALTER FOREIGN TABLE rpl_journal ALTER COLUMN time_stamp OPTIONS (
    column_name 'time_stamp'
);


ALTER FOREIGN TABLE rpl_journal OWNER TO postgres;

--
-- Name: track_info; Type: FOREIGN TABLE; Schema: depth_fdw; Owner: postgres
--

CREATE FOREIGN TABLE track_info (
    id bigint NOT NULL,
    tra_id bigint NOT NULL,
    short_info character varying(20),
    long_info character varying,
    reprocess boolean,
    discard boolean,
    ignore boolean
)
SERVER depth
OPTIONS (
    schema_name 'osmapi_tables',
    table_name 'track_info'
);
ALTER FOREIGN TABLE track_info ALTER COLUMN id OPTIONS (
    column_name 'id'
);
ALTER FOREIGN TABLE track_info ALTER COLUMN tra_id OPTIONS (
    column_name 'tra_id'
);
ALTER FOREIGN TABLE track_info ALTER COLUMN short_info OPTIONS (
    column_name 'short_info'
);
ALTER FOREIGN TABLE track_info ALTER COLUMN long_info OPTIONS (
    column_name 'long_info'
);
ALTER FOREIGN TABLE track_info ALTER COLUMN reprocess OPTIONS (
    column_name 'reprocess'
);
ALTER FOREIGN TABLE track_info ALTER COLUMN discard OPTIONS (
    column_name 'discard'
);
ALTER FOREIGN TABLE track_info ALTER COLUMN ignore OPTIONS (
    column_name 'ignore'
);


ALTER FOREIGN TABLE track_info OWNER TO postgres;

--
-- Name: user_tracks; Type: FOREIGN TABLE; Schema: depth_fdw; Owner: postgres
--

CREATE FOREIGN TABLE user_tracks (
    track_id bigint NOT NULL,
    file_ref character varying(255),
    upload_state smallint,
    filetype character varying(80),
    compression character varying(80),
    containertrack integer,
    vesselconfigid integer,
    license integer,
    gauge_name character varying(100),
    gauge numeric(6,2),
    height_ref character varying(100),
    comment character varying,
    watertype character varying(20),
    uploaddate timestamp without time zone,
    bbox public.geometry,
    clusteruuid character varying,
    clusterseq bigint,
    upr_id bigint NOT NULL,
    num_points bigint,
    is_container boolean
)
SERVER depth
OPTIONS (
    schema_name 'osmapi_tables',
    table_name 'user_tracks'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN track_id OPTIONS (
    column_name 'track_id'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN file_ref OPTIONS (
    column_name 'file_ref'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN upload_state OPTIONS (
    column_name 'upload_state'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN filetype OPTIONS (
    column_name 'filetype'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN compression OPTIONS (
    column_name 'compression'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN containertrack OPTIONS (
    column_name 'containertrack'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN vesselconfigid OPTIONS (
    column_name 'vesselconfigid'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN license OPTIONS (
    column_name 'license'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN gauge_name OPTIONS (
    column_name 'gauge_name'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN gauge OPTIONS (
    column_name 'gauge'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN height_ref OPTIONS (
    column_name 'height_ref'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN comment OPTIONS (
    column_name 'comment'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN watertype OPTIONS (
    column_name 'watertype'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN uploaddate OPTIONS (
    column_name 'uploaddate'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN bbox OPTIONS (
    column_name 'bbox'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN clusteruuid OPTIONS (
    column_name 'clusteruuid'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN clusterseq OPTIONS (
    column_name 'clusterseq'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN upr_id OPTIONS (
    column_name 'upr_id'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN num_points OPTIONS (
    column_name 'num_points'
);
ALTER FOREIGN TABLE user_tracks ALTER COLUMN is_container OPTIONS (
    column_name 'is_container'
);


ALTER FOREIGN TABLE user_tracks OWNER TO postgres;

SET search_path = depth_tables, pg_catalog;

SET default_with_oids = false;

--
-- Name: rpl_journal_shadow; Type: TABLE; Schema: depth_tables; Owner: postgres
--

CREATE TABLE rpl_journal_shadow (
    id bigint NOT NULL,
    table_name character varying(50) NOT NULL,
    row_id bigint NOT NULL,
    opcode character varying(1) NOT NULL,
    time_stamp timestamp without time zone NOT NULL,
    copied timestamp without time zone
);


ALTER TABLE rpl_journal_shadow OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: depthsensor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE depthsensor_id_seq
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE depthsensor_id_seq OWNER TO postgres;

--
-- Name: depthsensor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE depthsensor (
    vesselconfigid integer NOT NULL,
    x numeric(5,2),
    y numeric(5,2),
    z numeric(5,2),
    sensorid character varying,
    manufacturer character varying(100),
    model character varying(100),
    frequency numeric(5,0),
    angleofbeam numeric(3,0),
    offsetkeel numeric(5,2),
    offsettype character varying(12),
    id bigint DEFAULT nextval('depthsensor_id_seq'::regclass) NOT NULL
);


ALTER TABLE depthsensor OWNER TO postgres;

--
-- Name: gauge; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE gauge (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    gaugetype character varying(10) DEFAULT 'UNKNOWN'::character varying,
    lat numeric(11,3),
    lon numeric(11,3),
    geom geometry,
    provider character varying,
    water character varying,
    remoteid character varying,
    waterlevel numeric(6,2),
    CONSTRAINT enforce_dims_geom CHECK ((st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((st_srid(geom) = 4326))
);


ALTER TABLE gauge OWNER TO postgres;

--
-- Name: gauge_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE gauge_id_seq
    START WITH 20
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gauge_id_seq OWNER TO postgres;

--
-- TOC entry 4748 (class 0 OID 24614)
-- Dependencies: 221
-- Data for Name: gauge; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY gauge (id, name, gaugetype, lat, lon, geom, provider, water, remoteid, waterlevel) FROM stdin;
1139	test	SEA	\N	\N	0101000020E610000000000000000024400000000000002440	\N	\N	\N	\N
576	EITZE	RIVER	52.904	9.277	0101000020E6100000210725CCB48D2240D7BE805EB8734A40	Wasser und Schifffahrsdirektion Germany	ALLER	48900237	\N
577	RETHEM	RIVER	52.789	9.383	0101000020E6100000C9224DBC03C42240942F682101654A40	Wasser und Schifffahrsdirektion Germany	ALLER	48900204	\N
578	AHLDEN	RIVER	52.762	9.571	0101000020E6100000C8D0B1834A24234041B62C5F97614A40	Wasser und Schifffahrsdirektion Germany	ALLER	48900102	\N
579	MARKLENDORF	RIVER	52.683	9.703	0101000020E6100000965984622B6823402C82FFAD64574A40	Wasser und Schifffahrsdirektion Germany	ALLER	48700103	\N
580	CELLE	RIVER	52.623	10.062	0101000020E610000022FAB5F5D31F2440C1FEEBDCB44F4A40	Wasser und Schifffahrsdirektion Germany	ALLER	48300105	\N
581	BERLIN-PLOETZENSEE OP	RIVER	52.544	13.323	0101000020E610000096ED43DE72A52A40E86A2BF697454A40	Wasser und Schifffahrsdirektion Germany	BERLIN-SPANDAUER-SCHIFFFAHRTSKANAL	586640	\N
582	BERLIN-PLOETZENSEE UP	RIVER	52.543	13.324	0101000020E6100000D107CBD8D0A52A40DB4E5B2382454A40	Wasser und Schifffahrsdirektion Germany	BERLIN-SPANDAUER-SCHIFFFAHRTSKANAL	586650	\N
583	KONSTANZ	RIVER	47.668	9.173	0101000020E6100000D25625917D58224049A12C7C7DD54740	Wasser und Schifffahrsdirektion Germany	BODENSEE	906	\N
584	ABBENFLETH SPERRWERK	RIVER	53.669	9.494	0101000020E6100000245E9ECE15FD2240C619C39CA0D54A40	Wasser und Schifffahrsdirektion Germany	B�TZFLETHER S�DERELBE	126013	\N
585	NEUE M�HLE SCHLEUSE UP	RIVER	52.297	13.650	0101000020E61000000F48C2BE9D4C2B4085B4C6A013264A40	Wasser und Schifffahrsdirektion Germany	DAHME-WASSERSTRASSE	586280	\N
586	NEUE M�HLE SCHLEUSE OP	RIVER	52.297	13.652	0101000020E6100000CEE0EF17B34D2B405A7F4B00FE254A40	Wasser und Schifffahrsdirektion Germany	DAHME-WASSERSTRASSE	586270	\N
587	HELMINGHAUSEN	RIVER	51.381	8.731	0101000020E61000008C135FED287621401C23D923D4B04940	Wasser und Schifffahrsdirektion Germany	DIEMEL	44100206	\N
588	DIEMELTALSPERRE	RIVER	51.378	8.729	0101000020E61000007497C459117521400E66136058B04940	Wasser und Schifffahrsdirektion Germany	DIEMEL	44100104	\N
589	WILHELMSBR�CKE	RIVER	51.346	8.724	0101000020E6100000A3AEB5F7A9722140FF9600FC53AC4940	Wasser und Schifffahrsdirektion Germany	DIEMEL	44100024	\N
590	DANDLBACHM�NDUNG	RIVER	48.514	13.727	0101000020E610000045F295404A742B400F27309DD6414840	Wasser und Schifffahrsdirektion Germany	DONAU	10098007	\N
591	ERLAU	RIVER	48.567	13.587	0101000020E6100000BCCADAA6782C2B400266BE839F484840	Wasser und Schifffahrsdirektion Germany	DONAU	10096001	\N
592	PASSAU ILZSTADT	RIVER	48.575	13.478	0101000020E6100000B6BB07E8BEF42A4013B70A62A0494840	Wasser und Schifffahrsdirektion Germany	DONAU	10092000	\N
593	PASSAU DONAU	RIVER	48.576	13.459	0101000020E61000000CB1FA230CEB2A402849D74CBE494840	Wasser und Schifffahrsdirektion Germany	DONAU	10091008	\N
594	PASSAU STEINBACHBR�CKE DFH	RIVER	48.576	13.475	0101000020E610000044FB58C16FF32A40E8A4F78DAF494840	Wasser und Schifffahrsdirektion Germany	DONAU	10090710	\N
595	VILSHOFEN	RIVER	48.637	13.182	0101000020E6100000F4531C075E5D2A406F8104C58F514840	Wasser und Schifffahrsdirektion Germany	DONAU	10089006	\N
596	HOFKIRCHEN	RIVER	48.677	13.115	0101000020E61000005E9D6340F63A2A40AAB69BE09B564840	Wasser und Schifffahrsdirektion Germany	DONAU	10088003	\N
597	M�HLHAM	RIVER	48.722	13.013	0101000020E610000049D74CBED9062A40554CA59F705C4840	Wasser und Schifffahrsdirektion Germany	DONAU	10086008	\N
598	NIEDERALTEICH	RIVER	48.765	13.019	0101000020E6100000D8497D59DA092A40855D143DF0614840	Wasser und Schifffahrsdirektion Germany	DONAU	10084002	\N
599	HALBMEILE	RIVER	48.796	12.993	0101000020E6100000598AE42B81FC294012143FC6DC654840	Wasser und Schifffahrsdirektion Germany	DONAU	10082007	\N
600	DEGGENAU	RIVER	48.807	12.973	0101000020E610000076C1E09A3BF2294010AE80423D674840	Wasser und Schifffahrsdirektion Germany	DONAU	10081503	\N
601	DEGGENDORF	RIVER	48.825	12.962	0101000020E6100000789CA223B9EC294041B62C5F97694840	Wasser und Schifffahrsdirektion Germany	DONAU	10081004	\N
602	KLEINSCHWARZACH	RIVER	48.844	12.860	0101000020E6100000E9D66B7A50B8294047E6913F186C4840	Wasser und Schifffahrsdirektion Germany	DONAU	10080001	\N
603	PFELLING	RIVER	48.880	12.747	0101000020E6100000ADA3AA09A27E29405BB1BFEC9E704840	Wasser und Schifffahrsdirektion Germany	DONAU	10078000	\N
604	STRAUBING	RIVER	48.886	12.574	0101000020E610000009A4C4AEED252940B85B920376714840	Wasser und Schifffahrsdirektion Germany	DONAU	10074009	\N
605	PFATTER	RIVER	48.980	12.384	0101000020E6100000EF6FD05E7DC42840EE21E17B7F7D4840	Wasser und Schifffahrsdirektion Germany	DONAU	10068006	\N
606	SCHWABELWEIS	RIVER	49.024	12.139	0101000020E6100000B8054B7501472840E030D12005834840	Wasser und Schifffahrsdirektion Germany	DONAU	10062000	\N
607	EISERNE BR�CKE	RIVER	49.021	12.102	0101000020E6100000E8FA3E1C243428404C6DA983BC824840	Wasser und Schifffahrsdirektion Germany	DONAU	10061007	\N
608	NIEDERWINZER	RIVER	49.029	12.072	0101000020E61000008350DEC7D12428405B22179CC1834840	Wasser und Schifffahrsdirektion Germany	DONAU	10060208	\N
609	OBERNDORF	RIVER	48.947	12.015	0101000020E61000002EC6C03A8E0728408D7E349C32794840	Wasser und Schifffahrsdirektion Germany	DONAU	10056302	\N
610	KELHEIMWINZER	RIVER	48.912	11.932	0101000020E6100000A7936C7539DD2740494C50C3B7744840	Wasser und Schifffahrsdirektion Germany	DONAU	10054500	\N
611	INGOLSTADT LUITPOLDSTRASSE	RIVER	48.757	11.426	0101000020E6100000F4A8F8BF23DA2640CBBBEA01F3604840	Wasser und Schifffahrsdirektion Germany	DONAU	10046105	\N
612	RHEDE	RIVER	53.072	7.287	0101000020E61000001D8EAED2DD251D40C5C9FD0E45894A40	Wasser und Schifffahrsdirektion Germany	DORTMUND-EMS-KANAL	3770040	\N
613	AFFOLDERN	RIVER	51.164	9.085	0101000020E6100000E63DCE34612B2240056F48A302954940	Wasser und Schifffahrsdirektion Germany	EDER	42800502	\N
614	EDERTALSPERRE	RIVER	51.184	9.059	0101000020E61000002BA391CF2B1E2240F3936A9F8E974940	Wasser und Schifffahrsdirektion Germany	EDER	42800310	\N
615	SCHMITTLOTHEIM	RIVER	51.157	8.899	0101000020E6100000AE4676A565CC2140B98D06F016944940	Wasser und Schifffahrsdirektion Germany	EDER	42800309	\N
616	AUHAMMER	RIVER	51.035	8.624	0101000020E61000002C6519E2583F2140CE52B29C84844940	Wasser und Schifffahrsdirektion Germany	EDER	42810204	\N
617	MUESSE	RIVER	51.050	8.284	0101000020E610000022FB20CB82912040D097DEFE5C864940	Wasser und Schifffahrsdirektion Germany	EDER	42810506	\N
618	LEXF�HRE OW	RIVER	54.222	9.436	0101000020E610000037C2A2224EDF22401B9FC9FE791C4B40	Wasser und Schifffahrsdirektion Germany	EIDER	9520020	\N
619	LEXF�HRE UW	RIVER	54.223	9.436	0101000020E6100000E04DB7EC10DF224014E81379921C4B40	Wasser und Schifffahrsdirektion Germany	EIDER	9520030	\N
620	NORDFELD OBERWASSER	RIVER	54.339	9.140	0101000020E61000004E2A1A6B7F4722408A05BEA25B2B4B40	Wasser und Schifffahrsdirektion Germany	EIDER	9520040	\N
621	NORDFELD UNTERWASSER	RIVER	54.339	9.138	0101000020E61000004C8A8F4FC84622400C1EA67D732B4B40	Wasser und Schifffahrsdirektion Germany	EIDER	9520050	\N
622	FRIEDRICHSTADT STRASSENBR�CKE	RIVER	54.368	9.095	0101000020E6100000FC34EECD6F30224050C763062A2F4B40	Wasser und Schifffahrsdirektion Germany	EIDER	9520060	\N
623	T�NNING	RIVER	54.315	8.950	0101000020E61000007AA702EE79E62140E751F17F47284B40	Wasser und Schifffahrsdirektion Germany	EIDER	9520070	\N
624	EIDER-SPERRWERK BP	RIVER	54.266	8.849	0101000020E6100000E71BD13DEBB2214061C1FD8007224B40	Wasser und Schifffahrsdirektion Germany	EIDER	9520081	\N
625	SCH�NA	RIVER	50.876	14.235	0101000020E61000003E247CEF6F782C40FF05820019704940	Wasser und Schifffahrsdirektion Germany	ELBE	501010	\N
626	PIRNA	RIVER	50.965	13.930	0101000020E6100000C095ECD808DC2B40581F0F7D777B4940	Wasser und Schifffahrsdirektion Germany	ELBE	501040	\N
627	DRESDEN	RIVER	51.054	13.739	0101000020E61000005E82531F487A2B405778978BF8864940	Wasser und Schifffahrsdirektion Germany	ELBE	501060	\N
628	MEISSEN	RIVER	51.164	13.475	0101000020E6100000CC96AC8A70F32A4012A27C410B954940	Wasser und Schifffahrsdirektion Germany	ELBE	501080	\N
629	RIESA	RIVER	51.311	13.293	0101000020E6100000E126A3CA30962A40D6AD9E93DEA74940	Wasser und Schifffahrsdirektion Germany	ELBE	501110	\N
630	M�HLBERG	RIVER	51.437	13.192	0101000020E61000002A3BFDA02E622A40EB73B515FBB74940	Wasser und Schifffahrsdirektion Germany	ELBE	501160	\N
631	TORGAU	RIVER	51.554	13.010	0101000020E6100000FF59F3E32F052A40C328081EDFC64940	Wasser und Schifffahrsdirektion Germany	ELBE	501261	\N
632	PRETZSCH-MAUKEN	RIVER	51.717	12.823	0101000020E610000032CA332F87A529408FC70C54C6DB4940	Wasser und Schifffahrsdirektion Germany	ELBE	501330	\N
633	ELSTER	RIVER	51.827	12.827	0101000020E61000002EC6C03A8EA729404B598638D6E94940	Wasser und Schifffahrsdirektion Germany	ELBE	501390	\N
634	WITTENBERG	RIVER	51.857	12.646	0101000020E610000012178046E94A29407D0569C6A2ED4940	Wasser und Schifffahrsdirektion Germany	ELBE	501420	\N
635	COSWIG	RIVER	51.877	12.454	0101000020E6100000ADFBC74274E82840F146E6913FF04940	Wasser und Schifffahrsdirektion Germany	ELBE	501470	\N
636	VOCKERODE	RIVER	51.851	12.355	0101000020E6100000DCD8EC48F5B5284087FC3383F8EC4940	Wasser und Schifffahrsdirektion Germany	ELBE	501480	\N
637	ROSSLAU	RIVER	51.881	12.237	0101000020E61000008753E6E61B792840062FFA0AD2F04940	Wasser und Schifffahrsdirektion Germany	ELBE	501490	\N
638	DESSAU	RIVER	51.857	12.223	0101000020E6100000E2E5E95C51722840DC2A8881AEED4940	Wasser und Schifffahrsdirektion Germany	ELBE	502000	\N
639	AKEN	RIVER	51.858	12.059	0101000020E6100000892650C4221E2840191C25AFCEED4940	Wasser und Schifffahrsdirektion Germany	ELBE	502010	\N
640	BARBY	RIVER	51.985	11.882	0101000020E6100000BB0D6ABFB5C32740C382FB010FFE4940	Wasser und Schifffahrsdirektion Germany	ELBE	502070	\N
641	SCH�NEBECK	RIVER	52.025	11.739	0101000020E610000054707841447A27404DDA54DD23034A40	Wasser und Schifffahrsdirektion Germany	ELBE	502130	\N
642	MAGDEBURG-BUCKAU	RIVER	52.119	11.635	0101000020E6100000F1D58EE21C4527406CB2463D440F4A40	Wasser und Schifffahrsdirektion Germany	ELBE	502170	\N
643	MAGDEBURG-STROMBR�CKE	RIVER	52.130	11.644	0101000020E61000001956F146E64927400536E7E099104A40	Wasser und Schifffahrsdirektion Germany	ELBE	502180	\N
644	ROTHENSEE	RIVER	52.181	11.683	0101000020E61000005708ABB1845D27404A0A2C8029174A40	Wasser und Schifffahrsdirektion Germany	ELBE	502210	\N
645	NIEGRIPP AP	RIVER	52.250	11.738	0101000020E6100000A80018CFA07927408716D9CEF71F4A40	Wasser und Schifffahrsdirektion Germany	ELBE	502240	\N
646	ROG�TZ	RIVER	52.314	11.769	0101000020E6100000111B2C9CA48927404F7974232C284A40	Wasser und Schifffahrsdirektion Germany	ELBE	502250	\N
647	TANGERM�NDE	RIVER	52.541	11.978	0101000020E61000002B508BC1C3F427407590D78349454A40	Wasser und Schifffahrsdirektion Germany	ELBE	502350	\N
648	STORKAU	RIVER	52.610	12.002	0101000020E610000048A81952450128404E2844C0214E4A40	Wasser und Schifffahrsdirektion Germany	ELBE	502370	\N
649	SANDAU	RIVER	52.785	12.031	0101000020E61000000E677E3507102840E370E65773644A40	Wasser und Schifffahrsdirektion Germany	ELBE	502430	\N
650	SCHARLEUK	RIVER	52.957	11.838	0101000020E61000009F01F566D4AC274066A032FE7D7A4A40	Wasser und Schifffahrsdirektion Germany	ELBE	503030	\N
651	WITTENBERGE	RIVER	52.986	11.759	0101000020E61000002D5A80B6D58427409929ADBF257E4A40	Wasser und Schifffahrsdirektion Germany	ELBE	503050	\N
652	M�GGENDORF	RIVER	53.008	11.656	0101000020E61000008B6B7C26FB4F2740B7D100DE02814A40	Wasser und Schifffahrsdirektion Germany	ELBE	503070	\N
653	SCHNACKENBURG	RIVER	53.038	11.569	0101000020E61000003B5112126923274037894160E5844A40	Wasser und Schifffahrsdirektion Germany	ELBE	5910010	\N
654	LENZEN	RIVER	53.080	11.456	0101000020E6100000EA7B0DC171E9264028F04E3E3D8A4A40	Wasser und Schifffahrsdirektion Germany	ELBE	503120	\N
655	D�MITZ	RIVER	53.140	11.243	0101000020E6100000C24D4695617C2640B1DD3D40F7914A40	Wasser und Schifffahrsdirektion Germany	ELBE	5910025	\N
656	DAMNATZ	RIVER	53.138	11.179	0101000020E6100000E1270EA0DF5B26405A2F8672A2914A40	Wasser und Schifffahrsdirektion Germany	ELBE	5910030	\N
657	HITZACKER	RIVER	53.155	11.045	0101000020E6100000BD70E7C248172640807D74EACA934A40	Wasser und Schifffahrsdirektion Germany	ELBE	5920010	\N
658	NEU DARCHAU	RIVER	53.232	10.889	0101000020E61000002CB7B41A12C72540355F251FBB9D4A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930010	\N
659	BLECKEDE	RIVER	53.294	10.735	0101000020E61000000D897B2C7D782540185DDE1CAEA54A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930020	\N
660	BOIZENBURG	RIVER	53.375	10.718	0101000020E6100000F646AD307D6F254075E5B33C0FB04A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930033	\N
661	HOHNSTORF	RIVER	53.366	10.559	0101000020E6100000D95F764F1E1E2540C2C073EFE1AE4A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930040	\N
662	ARTLENBURG	RIVER	53.376	10.489	0101000020E61000005114E81379FA2440CF6A813D26B04A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930050	\N
663	GEESTHACHT	RIVER	53.427	10.375	0101000020E6100000FE8172DBBEBF2440DCD6169E97B64A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930060	\N
664	WEHR GEESTHACHT OP	RIVER	53.424	10.338	0101000020E6100000E54526E0D7AC2440AE9E93DE37B64A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930064	\N
665	WEHR GEESTHACHT UP	RIVER	53.423	10.335	0101000020E6100000DEB06D5166AB2440E84B6F7F2EB64A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930062	\N
666	ALTENGAMME	RIVER	53.431	10.297	0101000020E6100000492A53CC4198244022FC8BA031B74A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930070	\N
667	ZOLLENSPIEKER	RIVER	53.399	10.185	0101000020E61000008DD0CFD4EB5E244037E0F3C308B34A40	Wasser und Schifffahrsdirektion Germany	ELBE	5930090	\N
668	OVER	RIVER	53.429	10.101	0101000020E6100000BB2A508BC13324400518963FDFB64A40	Wasser und Schifffahrsdirektion Germany	ELBE	5950010	\N
669	HAMBURG ST. PAULI	RIVER	53.546	9.970	0101000020E61000006B80D250A3F0234079758E01D9C54A40	Wasser und Schifffahrsdirektion Germany	ELBE	5952050	\N
670	BLANKENESE UF	RIVER	53.558	9.796	0101000020E6100000ACADD85F76972340200890A163C74A40	Wasser und Schifffahrsdirektion Germany	ELBE	5952065	\N
671	SCHULAU	RIVER	53.569	9.703	0101000020E6100000AA436E861B6823408333F8FBC5C84A40	Wasser und Schifffahrsdirektion Germany	ELBE	5950090	\N
672	L�HORT	RIVER	53.571	9.634	0101000020E610000050C3B7B06E44234095BA641C23C94A40	Wasser und Schifffahrsdirektion Germany	ELBE	5960010	\N
673	HETLINGEN	RIVER	53.609	9.584	0101000020E610000014950D6B2A2B23407CED992501CE4A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970010	\N
674	STADERSAND	RIVER	53.630	9.527	0101000020E6100000C806D2C5A60D2340FB230C0396D04A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970013	\N
675	GRAUERORT	RIVER	53.678	9.495	0101000020E6100000AAD72D0263FD22404EF2237EC5D64A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970020	\N
676	KOLLMAR	RIVER	53.732	9.461	0101000020E6100000DFDC5F3DEEEB224041BCAE5FB0DD4A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970025	\N
677	KRAUTSAND	RIVER	53.754	9.391	0101000020E61000003E3C4B9011C8224070B20DDC81E04A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970030	\N
678	GL�CKSTADT	RIVER	53.784	9.409	0101000020E6100000A80018CFA0D12240A298BC0166E44A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970035	\N
679	BROKDORF	RIVER	53.863	9.316	0101000020E610000008E57D1CCDA122404B3ACAC16CEE4A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970050	\N
680	SCH�NEWORTH SIEL	RIVER	53.847	9.288	0101000020E6100000166A4DF38E9322404E0AF31E67EC4A40	Wasser und Schifffahrsdirektion Germany	ELBE	126005	\N
681	BRUNSB�TTEL MOLE 1	RIVER	53.889	9.144	0101000020E6100000AA27F38FBE492240EF0390DAC4F14A40	Wasser und Schifffahrsdirektion Germany	ELBE	5970093	\N
682	CUXHAVEN STEUBENH�FT	RIVER	53.868	8.717	0101000020E610000065AA6054526F214009151C5E10EF4A40	Wasser und Schifffahrsdirektion Germany	ELBE	5990020	\N
683	DETERSHAGEN	RIVER	52.251	11.763	0101000020E610000075CDE49B6D862740780C8FFD2C204A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587505	\N
684	BURG	RIVER	52.277	11.832	0101000020E61000002AC76471FFA92740EC4B361E6C234A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587507	\N
685	ZERBEN OP	RIVER	52.344	11.962	0101000020E61000002829B000A6EC274039622D3E052C4A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587510	\N
686	ZERBEN UP	RIVER	52.347	11.965	0101000020E6100000E1CFF0660DEE27400D1B65FD662C4A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587520	\N
687	GENTHIN	RIVER	52.411	12.140	0101000020E6100000A6811FD5B0472840069E7B0F97344A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587535	\N
688	KADE	RIVER	52.397	12.279	0101000020E6100000B5352218078F28403B70CE88D2324A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587541	\N
689	WUSTERWITZ OP	RIVER	52.392	12.356	0101000020E6100000202922C32AB6284011FC6F253B324A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587540	\N
690	WUSTERWITZ UP	RIVER	52.393	12.362	0101000020E610000075CAA31B61B928406E3480B740324A40	Wasser und Schifffahrsdirektion Germany	ELBE-HAVEL-KANAL	587550	\N
691	OSLOSS	RIVER	52.478	10.668	0101000020E61000004BB0389CF9552540E223624A243D4A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100100	\N
692	WITTINGEN	RIVER	52.728	10.664	0101000020E61000006DE34F543654254075392520265D4A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100101	\N
693	UELZEN OW	RIVER	52.909	10.615	0101000020E6100000AB75E272BC3A2540A9893E1F65744A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100111	\N
694	UELZEN	RIVER	52.912	10.614	0101000020E61000003E25E7C41E3A2540E21E4B1FBA744A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100113	\N
695	UELZEN UW	RIVER	52.915	10.612	0101000020E61000004DF6CFD3803925405DA3E5400F754A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100110	\N
696	BEVENSEN	RIVER	53.075	10.603	0101000020E61000008847E2E5E9342540C173EFE192894A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100112	\N
697	LUENEBURG OW	RIVER	53.272	10.485	0101000020E6100000051901158EF82440B74604E3E0A24A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100121	\N
698	LUENEBURG	RIVER	53.283	10.487	0101000020E6100000C216BB7D56F92440C009850838A44A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100123	\N
699	LUENEBURG UW	RIVER	53.293	10.489	0101000020E61000008201840F25FA2440B76114048FA54A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100120	\N
700	ELBE (ARTLENBURG)	RIVER	53.369	10.502	0101000020E61000002711E15F04012540A1B94E232DAF4A40	Wasser und Schifffahrsdirektion Germany	ELBESEITENKANAL	90100122	\N
701	PAPENBURG	RIVER	53.108	7.366	0101000020E6100000115322895E761D402CD8463CD98D4A40	Wasser und Schifffahrsdirektion Germany	EMS	3790010	\N
702	WEENER	RIVER	53.161	7.372	0101000020E6100000D4C6C7DDD67C1D405A492BBEA1944A40	Wasser und Schifffahrsdirektion Germany	EMS	3790020	\N
703	LEERORT	RIVER	53.215	7.426	0101000020E6100000ED65DB696BB41D4063D34A21909B4A40	Wasser und Schifffahrsdirektion Germany	EMS	3910010	\N
704	TERBORG	RIVER	53.293	7.396	0101000020E6100000EC7717DE9B951D40E7ABE46377A54A40	Wasser und Schifffahrsdirektion Germany	EMS	3910020	\N
705	POGUM	RIVER	53.321	7.260	0101000020E610000055DFF945090A1D40E9482EFF21A94A40	Wasser und Schifffahrsdirektion Germany	EMS	3950020	\N
706	EMDEN NEUE SEESCHLEUSE	RIVER	53.337	7.186	0101000020E610000035B39602D2BE1C4033F9669B1BAB4A40	Wasser und Schifffahrsdirektion Germany	EMS	3970010	\N
707	RHEINE UNTERSCHLEUSE	RIVER	52.288	7.434	0101000020E610000001A777F17EBC1D4017B7D100DE244A40	Wasser und Schifffahrsdirektion Germany	EMS	3390020	\N
708	KNOCK	RIVER	53.327	7.031	0101000020E6100000596ABDDF681F1C40BD1DE1B4E0A94A40	Wasser und Schifffahrsdirektion Germany	EMS	3990010	\N
709	DUKEGAT	RIVER	53.434	6.926	0101000020E6100000805BC1806FB41B40D6C56D3480B74A40	Wasser und Schifffahrsdirektion Germany	EMS	3990020	\N
710	EMSH�RN	RIVER	53.494	6.841	0101000020E6100000A3FA18BD645D1B40F08AE07F2BBF4A40	Wasser und Schifffahrsdirektion Germany	EMS	9340010	\N
711	LINGEN-DARME	RIVER	52.497	7.288	0101000020E61000007E5182FE42271D40A4C2D842903F4A40	Wasser und Schifffahrsdirektion Germany	EMS	3500015	\N
712	FUESTRUP	RIVER	52.040	7.680	0101000020E61000004BA5E9FD90B81E40A489778027054A40	Wasser und Schifffahrsdirektion Germany	EMS	3310010	\N
713	DALUM	RIVER	52.596	7.249	0101000020E6100000AD4CF8A57EFE1C40F3AE7AC03C4C4A40	Wasser und Schifffahrsdirektion Germany	EMS	3550040	\N
714	VERSEN-WD	RIVER	52.733	7.242	0101000020E6100000FE8172DBBEF71C4011C30E63D25D4A40	Wasser und Schifffahrsdirektion Germany	EMS	3730010	\N
715	BUXTEHUDE	RIVER	53.480	9.703	0101000020E61000008318E8DA17682340C45A7C0A80BD4A40	Wasser und Schifffahrsdirektion Germany	ESTE	5950080	\N
716	INNERES ESTE-SPERRWERK BP	RIVER	53.533	9.776	0101000020E6100000D446753A908D2340CE531D7233C44A40	Wasser und Schifffahrsdirektion Germany	ESTE	5950081	\N
717	INNERES ESTESPERRWERK AP	RIVER	53.533	9.777	0101000020E610000070404B57B08D234018EDF1423AC44A40	Wasser und Schifffahrsdirektion Germany	ESTE	5950082	\N
718	FREIBURG SPERRWERK	RIVER	53.827	9.295	0101000020E610000007793D9814972240F69672BED8E94A40	Wasser und Schifffahrsdirektion Germany	FREIBURGER HAFENPRIEL	126006	\N
719	BONAFORTH	RIVER	51.403	9.632	0101000020E6100000DA54DD239B4323404C1938A0A5B34940	Wasser und Schifffahrsdirektion Germany	FULDA	42900201	\N
720	GUNTERSHAUSEN	RIVER	51.227	9.469	0101000020E61000003ECDC98B4CF02240BEF6CC92009D4940	Wasser und Schifffahrsdirektion Germany	FULDA	42900100	\N
721	GREBENAU	RIVER	51.193	9.498	0101000020E6100000BB0F406A13FF224030F0DC7BB8984940	Wasser und Schifffahrsdirektion Germany	FULDA	42700202	\N
722	ROTENBURG	RIVER	51.004	9.720	0101000020E61000002FDFFAB0DE7023405C5A0D897B804940	Wasser und Schifffahrsdirektion Germany	FULDA	42700100	\N
723	RITTERHUDE	RIVER	53.182	8.763	0101000020E610000099107349D586214034A1496249974A40	Wasser und Schifffahrsdirektion Germany	HAMME	4940030	\N
724	BERLIN-SPANDAU SCHLEUSE UP	RIVER	52.540	13.209	0101000020E6100000CA181F662F6B2A403DD7F7E120454A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	580310	\N
725	BERLIN-SPANDAU SCHLEUSE OP	RIVER	52.542	13.209	0101000020E61000001AFB928D076B2A40481630815B454A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	580300	\N
726	BORGSDORF	RIVER	52.692	13.251	0101000020E610000052D4997B48802A40F9872D3D9A584A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	581591	\N
727	LEHNITZ UP	RIVER	52.767	13.280	0101000020E6100000C87BD5CA848F2A4089601C5C3A624A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	581590	\N
728	LEHNITZ OP	RIVER	52.768	13.280	0101000020E6100000207C28D1928F2A40CE70033E3F624A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	581580	\N
729	DGW3	RIVER	52.855	13.657	0101000020E6100000CA1B60E63B502B40444C89247A6D4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	31480006	\N
730	D5	RIVER	52.856	13.657	0101000020E610000040683D7C99502B405725917D906D4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	31480001	\N
731	DGW2	RIVER	52.855	13.657	0101000020E6100000193DB7D095502B40F67AF7C77B6D4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	31480004	\N
732	D7	RIVER	52.856	13.659	0101000020E6100000280AF4893C512B40D3DEE00B936D4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	31480002	\N
733	D11	RIVER	52.855	13.658	0101000020E6100000EBE5779ACC502B40103FFF3D786D4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	31480003	\N
734	DGW1	RIVER	52.856	13.658	0101000020E6100000A0C03BF9F4502B40BD5296218E6D4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	31480005	\N
735	NIEDERFINOW SHW OP	RIVER	52.849	13.941	0101000020E610000000E48409A3E12B40452BF702B36C4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	692080	\N
736	NIEDERFINOW SHW UP	RIVER	52.849	13.943	0101000020E61000004E7E8B4E96E22B406B9DB81CAF6C4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	692090	\N
737	HOHENSAATEN WEST BP	RIVER	52.874	14.149	0101000020E610000012C138B8744C2C40B9196EC0E76F4A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	603310	\N
738	HOHENSAATEN WEST AP	RIVER	52.877	14.152	0101000020E61000007EA7C98CB74D2C40BA4C4D8237704A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	603400	\N
739	SCHWEDT SCHLEUSE BP	RIVER	53.069	14.322	0101000020E6100000B01BB62DCAA42C403CA41820D1884A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	603410	\N
740	FRIEDRICHSTHAL	RIVER	53.156	14.357	0101000020E61000002F302B14E9B62C4024B9FC87F4934A40	Wasser und Schifffahrsdirektion Germany	HAVEL-ODER-WASSERSTRASSE	603420	\N
741	SCH�NWALDE OP	RIVER	52.608	13.089	0101000020E6100000359A5C8C812D2A4043E38920CE4D4A40	Wasser und Schifffahrsdirektion Germany	HAVELKANAL	587050	\N
742	SCH�NWALDE UP	RIVER	52.608	13.084	0101000020E6100000B05417F0322B2A40750305DEC94D4A40	Wasser und Schifffahrsdirektion Germany	HAVELKANAL	587060	\N
743	OLDENBURG-DRIELAKE	RIVER	53.140	8.234	0101000020E6100000DE3AFF76D977204084F57F0EF3914A40	Wasser und Schifffahrsdirektion Germany	HUNTE	4960030	\N
744	REITHOERNE	RIVER	53.161	8.323	0101000020E61000009CDF30D120A52040E2E47E87A2944A40	Wasser und Schifffahrsdirektion Germany	HUNTE	4960040	\N
745	HOLLERSIEL	RIVER	53.168	8.378	0101000020E6100000AA44D95BCAC1204062821ABE85954A40	Wasser und Schifffahrsdirektion Germany	HUNTE	4960050	\N
746	BUTTELERH�RNE	RIVER	53.180	8.413	0101000020E61000005001309E41D3204002D369DD06974A40	Wasser und Schifffahrsdirektion Germany	HUNTE	4960060	\N
747	HUNTEBRUECK	RIVER	53.200	8.447	0101000020E6100000ECFB709010E52040EE7893DFA2994A40	Wasser und Schifffahrsdirektion Germany	HUNTE	4960070	\N
748	ELSFLETH OHRT	RIVER	53.221	8.460	0101000020E6100000554FE61F7DEB2040EE93A300519C4A40	Wasser und Schifffahrsdirektion Germany	HUNTE	4960080	\N
749	ILMENAU	RIVER	50.681	10.929	0101000020E610000024B4E55C8ADB2540D3D9C9E028574940	Wasser und Schifffahrsdirektion Germany	ILM	166640	\N
750	L�NE	RIVER	53.261	10.420	0101000020E6100000D9EE1EA0FBD6244053793BC269A14A40	Wasser und Schifffahrsdirektion Germany	ILMENAU	5940920	\N
751	FAHRENHOLZ	RIVER	53.360	10.315	0101000020E6100000FDBCA94885A12440200C3CF71EAE4A40	Wasser und Schifffahrsdirektion Germany	ILMENAU	5940060	\N
752	KOTTHAUSEN	RIVER	51.364	8.683	0101000020E610000054556820965D21401F11532289AE4940	Wasser und Schifffahrsdirektion Germany	ITTER ZUR DIEMEL	44100013	\N
753	WHV ALTER VORHAFEN	RIVER	53.514	8.145	0101000020E61000004913EF004F4A20401FF64201DBC14A40	Wasser und Schifffahrsdirektion Germany	JADE	9440020	\N
754	VOSLAPP	RIVER	53.611	8.123	0101000020E61000003E40F7E5CC3E2040234A7B832FCE4A40	Wasser und Schifffahrsdirektion Germany	JADE	9430010	\N
755	HOOKSIELPLATE	RIVER	53.669	8.149	0101000020E610000079060DFD134C2040FE47A643A7D54A40	Wasser und Schifffahrsdirektion Germany	JADE	9430020	\N
756	SCHILLIG	RIVER	53.699	8.047	0101000020E6100000990CC7F319182040C85EEFFE78D94A40	Wasser und Schifffahrsdirektion Germany	JADE	9430030	\N
757	MELLUMPLATE	RIVER	53.772	8.093	0101000020E6100000594DD7135D2F2040F372D87DC7E24A40	Wasser und Schifffahrsdirektion Germany	JADE	9420010	\N
758	WANGEROOGE OST	RIVER	53.767	7.985	0101000020E6100000823AE5D18DF01F4035B56CAD2FE24A40	Wasser und Schifffahrsdirektion Germany	JADE	9420020	\N
759	WANGEROOGE NORD	RIVER	53.806	7.929	0101000020E6100000D6C56D3480B71F4074EE76BD34E74A40	Wasser und Schifffahrsdirektion Germany	JADE	9420030	\N
760	WANGEROOGE WEST 	RIVER	53.776	7.868	0101000020E6100000D7C1C1DEC4781F40FB78E8BB5BE34A40	Wasser und Schifffahrsdirektion Germany	JADE	9420040	\N
761	KARNIN	RIVER	53.844	13.858	0101000020E6100000DC9F8B868CB72B40A25F5B3FFDEB4A40	Wasser und Schifffahrsdirektion Germany	KLEINES HAFF	9690084	\N
762	UECKERM�NDE	RIVER	53.750	14.066	0101000020E610000096CE876709222C404EEE77280AE04A40	Wasser und Schifffahrsdirektion Germany	KLEINES HAFF	9690088	\N
763	ELMSHORN	RIVER	53.750	9.648	0101000020E61000008A558330B74B2340042159C004E04A40	Wasser und Schifffahrsdirektion Germany	KR�CKAU	5970021	\N
764	KR�CKAU-SPERRWERK BP	RIVER	53.716	9.526	0101000020E61000002429E961680D2340B1FB8EE1B1DB4A40	Wasser und Schifffahrsdirektion Germany	KR�CKAU	5970023	\N
765	KR�CKAU-SPERRWERK AP	RIVER	53.716	9.526	0101000020E6100000F92D3A596A0D2340B1FB8EE1B1DB4A40	Wasser und Schifffahrsdirektion Germany	KR�CKAU	5970024	\N
766	HUNDSM�HLEN	RIVER	53.109	8.173	0101000020E610000062D68BA19C582040B515FBCBEE8D4A40	Wasser und Schifffahrsdirektion Germany	K�STENKANAL	4960020	\N
767	MARBURG	RIVER	50.799	8.764	0101000020E6100000B14D2A1A6B872140BD6DA6423C664940	Wasser und Schifffahrsdirektion Germany	LAHN	25830056	\N
768	GIESSEN KL�RWERK	RIVER	50.575	8.649	0101000020E61000008A3DB48F154C214028F224E99A494940	Wasser und Schifffahrsdirektion Germany	LAHN	25800100	\N
769	LEUN NEU	RIVER	50.545	8.355	0101000020E610000056F0DB10E3B52040CF8250DEC7454940	Wasser und Schifffahrsdirektion Germany	LAHN	25800200	\N
770	DIEZ HAFEN	RIVER	50.372	8.005	0101000020E61000002CF3565D87022040EB8B84B69C2F4940	Wasser und Schifffahrsdirektion Germany	LAHN	25800500	\N
771	KALKOFEN NEU	RIVER	50.318	7.890	0101000020E6100000A7EF90BD398F1F40E2CD1ABCAF284940	Wasser und Schifffahrsdirektion Germany	LAHN	25800600	\N
772	LAHNSTEIN SCHLEUSE UP	RIVER	50.308	7.613	0101000020E6100000671A03A1AB731E40C84109336D274940	Wasser und Schifffahrsdirektion Germany	LAHN	25800800	\N
773	BERLIN-UNTERSCHLEUSE UP	RIVER	52.512	13.335	0101000020E610000060E63BF889AB2A403D27BD6F7C414A40	Wasser und Schifffahrsdirektion Germany	LANDWEHRKANAL	586630	\N
774	BERLIN-UNTERSCHLEUSE OP	RIVER	52.511	13.337	0101000020E6100000D90759164CAC2A40F38DE89E75414A40	Wasser und Schifffahrsdirektion Germany	LANDWEHRKANAL	586620	\N
823	LOHNDE	RIVER	52.399	9.564	0101000020E6100000EB025E66D82023409E7B0F971C334A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010050	\N
775	BERLIN-OBERSCHLEUSE UP	RIVER	52.497	13.449	0101000020E61000008BC3995FCDE52A40085A8121AB3F4A40	Wasser und Schifffahrsdirektion Germany	LANDWEHRKANAL	586610	\N
776	BERLIN-OBERSCHLEUSE OP	RIVER	52.498	13.450	0101000020E6100000670FB40243E62A401D2098A3C73F4A40	Wasser und Schifffahrsdirektion Germany	LANDWEHRKANAL	586600	\N
777	DREYSCHLOOT	RIVER	53.178	7.669	0101000020E610000021C8410933AD1E402E71E481C8964A40	Wasser und Schifffahrsdirektion Germany	LEDA	3880010	\N
778	LEDASPERRWERK UP	RIVER	53.214	7.473	0101000020E6100000353685DF97E41D40C8073D9B559B4A40	Wasser und Schifffahrsdirektion Germany	LEDA	3880050	\N
779	SCHWARMSTEDT	RIVER	52.683	9.604	0101000020E61000008542041C423523400F0BB5A679574A40	Wasser und Schifffahrsdirektion Germany	LEINE	48800301	\N
780	NEUSTADT	RIVER	52.510	9.467	0101000020E6100000B8E864A9F5EE2240711E4E603A414A40	Wasser und Schifffahrsdirektion Germany	LEINE	48800200	\N
781	HERRENHAUSEN	RIVER	52.388	9.676	0101000020E6100000FF2268CC245A234084471B47AC314A40	Wasser und Schifffahrsdirektion Germany	LEINE	48800108	\N
782	WASSERHORST	RIVER	53.163	8.718	0101000020E61000007E737FF5B86F2140F1F3DF83D7944A40	Wasser und Schifffahrsdirektion Germany	LESUM	4930010	\N
783	HIMMELPFORT OP	RIVER	53.177	13.231	0101000020E6100000425DA45016762A40912C6002B7964A40	Wasser und Schifffahrsdirektion Germany	LYCHENER GEW�SSER	581110	\N
784	HIMMELPFORT UP	RIVER	53.177	13.230	0101000020E61000000FED6305BF752A403C4D66BCAD964A40	Wasser und Schifffahrsdirektion Germany	LYCHENER GEW�SSER	581120	\N
785	HORNEBURG	RIVER	53.512	9.591	0101000020E61000002A8BC22E8A2E23408675E3DD91C14A40	Wasser und Schifffahrsdirektion Germany	L�HE	5960021	\N
786	L�HESPERRWERK	RIVER	53.571	9.634	0101000020E610000026C808A870442340E257ACE122C94A40	Wasser und Schifffahrsdirektion Germany	L�HE	126016	\N
787	RAUNHEIM	RIVER	50.016	8.448	0101000020E6100000A471A8DF85E520406EC0E78711024940	Wasser und Schifffahrsdirektion Germany	MAIN	24900108	\N
788	FRANKFURT OSTHAFEN	RIVER	50.106	8.715	0101000020E610000026AC8DB1136E21404301DBC1880D4940	Wasser und Schifffahrsdirektion Germany	MAIN	24700404	\N
789	HANAU BR�CKE DFH	RIVER	50.120	8.918	0101000020E6100000A9DC442DCDD52140B0C8AF1F620F4940	Wasser und Schifffahrsdirektion Germany	MAIN	24700347	\N
790	AUHEIM BR�CKE DFH	RIVER	50.107	8.936	0101000020E6100000705E9CF86ADF214092AE997CB30D4940	Wasser und Schifffahrsdirektion Germany	MAIN	24700346	\N
791	KROTZENBURG	RIVER	50.080	8.954	0101000020E61000005D3123BC3DE82140E57B4622340A4940	Wasser und Schifffahrsdirektion Germany	MAIN	24700335	\N
792	MAINFLINGEN	RIVER	50.015	9.034	0101000020E61000008997A7734511224034BC5983F7014940	Wasser und Schifffahrsdirektion Germany	MAIN	24700325	\N
793	OBERNAU	RIVER	49.934	9.129	0101000020E610000060764F1E164222409D8026C286F74840	Wasser und Schifffahrsdirektion Germany	MAIN	24700302	\N
794	KLEINHEUBACH	RIVER	49.714	9.233	0101000020E6100000EA58A5F44C772240C1E270E657DB4840	Wasser und Schifffahrsdirektion Germany	MAIN	24700200	\N
795	FAULBACH	RIVER	49.785	9.439	0101000020E6100000BF2B82FFADE02240DF6C73637AE44840	Wasser und Schifffahrsdirektion Germany	MAIN	24700109	\N
796	WERTHEIM	RIVER	49.761	9.518	0101000020E6100000A0C552245F092340310BED9C66E14840	Wasser und Schifffahrsdirektion Germany	MAIN	24709089	\N
797	STEINBACH	RIVER	50.011	9.602	0101000020E61000000116F9F543342340764F1E166A014940	Wasser und Schifffahrsdirektion Germany	MAIN	24500100	\N
798	W�RZBURG	RIVER	49.796	9.926	0101000020E61000003B38D89B18DA234053EC681CEAE54840	Wasser und Schifffahrsdirektion Germany	MAIN	24300600	\N
799	ASTHEIM	RIVER	49.858	10.218	0101000020E61000002C9FE579706F24409947FE60E0ED4840	Wasser und Schifffahrsdirektion Germany	MAIN	24300406	\N
800	SCHWEINFURT NEUER HAFEN	RIVER	50.031	10.222	0101000020E610000041B62C5F97712440B1DD3D40F7034940	Wasser und Schifffahrsdirektion Germany	MAIN	24300304	\N
801	TRUNSTADT	RIVER	49.930	10.755	0101000020E6100000268DD13AAA8225409B20EA3E00F74840	Wasser und Schifffahrsdirektion Germany	MAIN	24300202	\N
802	SCHW�RBITZ	RIVER	50.166	11.152	0101000020E6100000F3CCCB61F74D2640B492567C43154940	Wasser und Schifffahrsdirektion Germany	MAIN	24006007	\N
803	BAMBERG	RIVER	49.872	10.904	0101000020E610000038F7578FFBCE2540882EA86F99EF4840	Wasser und Schifffahrsdirektion Germany	MAIN-DONAU-KANAL	24300042	\N
804	RIEDENBURG_UP	RIVER	48.973	11.688	0101000020E61000001424B6BB07602740F9872D3D9A7C4840	Wasser und Schifffahrsdirektion Germany	MAIN-DONAU-KANAL	13409200	\N
805	LIEBENWALDE UP	RIVER	52.850	13.396	0101000020E6100000E7C41EDAC7CA2A40AA471ADCD66C4A40	Wasser und Schifffahrsdirektion Germany	MALZER KANAL	581550	\N
806	LIEBENWALDE OP	RIVER	52.851	13.396	0101000020E61000004565C39ACACA2A409F3BC1FEEB6C4A40	Wasser und Schifffahrsdirektion Germany	MALZER KANAL	581540	\N
807	HALDENSLEBEN	RIVER	52.278	11.409	0101000020E6100000E012807F4AD1264002637D0393234A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	3101013	\N
808	HOERSTEL	RIVER	52.283	7.605	0101000020E610000056CE8360FA6B1E401C42959A3D244A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010010	\N
809	RECKE	RIVER	52.354	7.706	0101000020E6100000DD1CF86239D31E40EFFE78AF5A2D4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010011	\N
810	BRAMSCHE	RIVER	52.396	7.978	0101000020E61000002252D32EA6E91F4062DC0DA2B5324A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010020	\N
811	BROXTEN	RIVER	52.391	8.190	0101000020E6100000A5828AAA5F6120402F50526001324A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010032	\N
928	BARTH	RIVER	54.371	12.723	0101000020E6100000938FDD054A72294081CF0F23842F4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650030	\N
812	BAD ESSEN	RIVER	52.325	8.343	0101000020E6100000AC730CC85EAF2040361FD7868A294A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010030	\N
813	LUEBBECKE	RIVER	52.335	8.617	0101000020E61000009E0AB8E7F93B2140EDBB22F8DF2A4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010031	\N
814	HAHLEN	RIVER	52.297	8.869	0101000020E610000022FDF675E0BC21400B630B410E264A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010041	\N
815	MINDEN	RIVER	52.303	8.927	0101000020E6100000A374E95F92DA21404B22FB20CB264A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010046	\N
816	WESER	RIVER	52.304	8.932	0101000020E6100000FCC3961E4DDD2140A777F17EDC264A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010045	\N
817	BERENBUSCH	RIVER	52.295	8.991	0101000020E61000007ADFF8DA33FB214044FAEDEBC0254A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010042	\N
818	WARBER GRABEN	RIVER	52.311	9.053	0101000020E6100000B9382A37511B2240D690B8C7D2274A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010040	\N
819	RUSBEND	RIVER	52.313	9.058	0101000020E610000063B5F97FD51D224088D51F6118284A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010043	\N
820	NIENBRUEGGE	RIVER	52.379	9.229	0101000020E6100000CF2D7425027522401363997E89304A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010044	\N
821	RODENBERGER AUE-WEST	RIVER	52.388	9.316	0101000020E610000033C34659BFA12240C8B5A1629C314A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010052	\N
822	RODENBERGER AUE-OST	RIVER	52.388	9.329	0101000020E61000006C98A1F144A82240C39ACAA2B0314A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010051	\N
824	HANN. LIST	RIVER	52.406	9.746	0101000020E6100000FEEF880AD57D23403AADDBA0F6334A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010062	\N
825	ANDERTEN UW	RIVER	52.367	9.859	0101000020E61000002E1D739EB1B72340207EFE7BF02E4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010060	\N
826	ANDERTEN	RIVER	52.358	9.867	0101000020E6100000058A58C4B0BB23407D96E7C1DD2D4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010063	\N
827	ANDERTEN OW	RIVER	52.355	9.870	0101000020E6100000D2C8E7154FBD2340CC457C27662D4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010061	\N
828	SEHNDE	RIVER	52.306	9.962	0101000020E6100000478D093197EC23406C787AA52C274A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010070	\N
829	MEHRUM	RIVER	52.311	10.093	0101000020E610000023DDCF29C82F2440A032FE7DC6274A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010071	\N
830	FUHSE-OST	RIVER	52.305	10.230	0101000020E6100000C9E9EBF99A752440368FC360FE264A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010081	\N
831	THUNE	RIVER	52.335	10.517	0101000020E6100000E23B31EBC50825408F386403E92A4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010080	\N
832	SUELFELD OW	RIVER	52.417	10.647	0101000020E6100000003CA242754B254090F63FC05A354A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010092	\N
833	SUELFELD	RIVER	52.421	10.662	0101000020E61000005036E50AEF522540D2A92B9FE5354A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010094	\N
834	SUELFELD UW	RIVER	52.425	10.678	0101000020E610000069E21DE0495B25405F419AB168364A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010091	\N
835	VORSFELDE	RIVER	52.433	10.841	0101000020E61000007D5A457F68AE2540596ABDDF68374A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010090	\N
836	RUEHEN	RIVER	52.479	10.910	0101000020E6100000BC41B456B4D12540DA5548F9493D4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	31010093	\N
837	KANALBR�CKE	RIVER	52.230	11.689	0101000020E6100000DC9BDF30D16027407EA83462661D4A40	Wasser und Schifffahrsdirektion Germany	MITTELLANDKANAL	3101018	\N
838	KOBLENZ-L�TZEL DFH	RIVER	50.365	7.591	0101000020E6100000159D7642F95C1E4020ED7F80B52E4940	Wasser und Schifffahrsdirektion Germany	MOSEL	26900910	\N
839	KOBLENZ UP	RIVER	50.366	7.586	0101000020E6100000E7C75F5AD4571E4082397AFCDE2E4940	Wasser und Schifffahrsdirektion Germany	MOSEL	26900900	\N
840	ALKEN	RIVER	50.251	7.446	0101000020E61000009213DCFE4BC81D40C1374D9F1D204940	Wasser und Schifffahrsdirektion Germany	MOSEL	26900510	\N
841	COCHEM	RIVER	50.143	7.168	0101000020E61000008F8B6A1151AC1C40BAD7497D59124940	Wasser und Schifffahrsdirektion Germany	MOSEL	26900400	\N
842	ZELTINGEN UP	RIVER	49.950	7.016	0101000020E6100000B1EBCD5E6C101C401AA88C7F9FF94840	Wasser und Schifffahrsdirektion Germany	MOSEL	26700600	\N
843	RUWER	RIVER	49.783	6.704	0101000020E610000036FAE29C22D11A4000917EFB3AE44840	Wasser und Schifffahrsdirektion Germany	MOSEL	26500150	\N
844	TRIER UP	RIVER	49.733	6.624	0101000020E6100000D40D1478277F1A40779FE3A3C5DD4840	Wasser und Schifffahrsdirektion Germany	MOSEL	26500100	\N
845	GREVENMACHER UP	RIVER	49.674	6.439	0101000020E61000009180D1E5CDC11940795DBF6037D64840	Wasser und Schifffahrsdirektion Germany	MOSEL	26100200	\N
846	WINCHERINGEN	RIVER	49.607	6.404	0101000020E6100000978DCEF9299E1940BABC395CABCD4840	Wasser und Schifffahrsdirektion Germany	MOSEL	26100140	\N
847	STADTBREDIMUS UP	RIVER	49.563	6.372	0101000020E61000002DCE18E6047D19405C55F65D11C84840	Wasser und Schifffahrsdirektion Germany	MOSEL	26100130	\N
848	PERL	RIVER	49.473	6.369	0101000020E61000004451A04FE4791940EF6FD05E7DBC4840	Wasser und Schifffahrsdirektion Germany	MOSEL	26100100	\N
849	GROSSE TR�NKE WEHR UP	RIVER	52.369	13.996	0101000020E6100000F240649126FE2B40CFBEF2203D2F4A40	Wasser und Schifffahrsdirektion Germany	M�GGELSPREE	582670	\N
850	GROSSE TR�NKE WEHR OP	RIVER	52.368	13.997	0101000020E61000001A1A4F0471FE2B40A5A0DB4B1A2F4A40	Wasser und Schifffahrsdirektion Germany	M�GGELSPREE	582660	\N
851	FINDSHIER OP	RIVER	53.178	11.295	0101000020E6100000C93CF207039726402E20B41EBE964A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596410	\N
852	MALLISS OP	RIVER	53.191	11.345	0101000020E6100000DC7EF964C5B0264096EA025E66984A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596390	\N
853	ELDENA OP	RIVER	53.232	11.428	0101000020E61000008B33863941DB2640B6847CD0B39D4A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596370	\N
854	GRABOW OP	RIVER	53.283	11.573	0101000020E61000008ACA863595252740E00F3FFF3DA44A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596330	\N
855	LEWITZ OP	RIVER	53.419	11.602	0101000020E610000066BE839F38342740BC07E8BE9CB54A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596250	\N
856	PLAU UP	RIVER	53.457	12.260	0101000020E6100000499C155113852840177E703E75BA4A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596090	\N
857	PLAU OP	RIVER	53.457	12.261	0101000020E610000010B3976DA7852840BDFE243E77BA4A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596080	\N
858	WAREN	RIVER	53.514	12.678	0101000020E6100000BC5AEECC045B294026E1421EC1C14A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-ELDE-WASSERSTRASSE	596030	\N
859	MIROW OP	RIVER	53.273	12.800	0101000020E6100000B9718BF9B99929402D431CEBE2A24A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-HAVEL-WASSERSTRASSE	581000	\N
860	MIROW UP	RIVER	53.271	12.803	0101000020E6100000EC12D55B039B294074982F2FC0A24A40	Wasser und Schifffahrsdirektion Germany	M�RITZ-HAVEL-WASSERSTRASSE	581010	\N
861	MANNHEIM NECKAR	RIVER	49.494	8.469	0101000020E61000002AC6F99B50F0204088635DDC46BF4840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800900	\N
862	HEIDELBERG UP	RIVER	49.415	8.718	0101000020E610000020425C397B6F214037FDD98F14B54840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800760	\N
863	ZIEGELHAUSEN AMS	RIVER	49.411	8.777	0101000020E61000001288D7F50B8E21400536E7E099B44840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800745	\N
864	ROCKENAU SKA	RIVER	49.438	9.005	0101000020E6100000E5637781920222407C2766BD18B84840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800690	\N
865	GUNDELSHEIM UP	RIVER	49.281	9.154	0101000020E610000069E4F38AA74E2240158C4AEA04A44840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800620	\N
866	LAUFFEN	RIVER	49.072	9.160	0101000020E6100000A2B77878CF5122408542041C42894840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800500	\N
867	HESSIGHEIM SCHLEUSE UP	RIVER	48.993	9.192	0101000020E610000073486AA16462224049B9FB1C1F7F4840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800420	\N
868	PLOCHINGEN	RIVER	48.707	9.419	0101000020E610000096AFCBF09FD62240AC014A438D5A4840	Wasser und Schifffahrsdirektion Germany	NECKAR	23800100	\N
869	NEUHAUS OP	RIVER	52.266	14.291	0101000020E6100000C23577F4BF942C40AB77B81D1A224A40	Wasser und Schifffahrsdirektion Germany	NEUHAUSER SPEISEKANAL	585850	\N
870	NEUHAUS UP	RIVER	52.266	14.290	0101000020E61000006C054D4BAC942C404510E7E104224A40	Wasser und Schifffahrsdirektion Germany	NEUHAUSER SPEISEKANAL	585860	\N
871	NIEGRIPP BP	RIVER	52.249	11.742	0101000020E6100000AA2D7590D77B2740809A5AB6D61F4A40	Wasser und Schifffahrsdirektion Germany	NIEGRIPPER VERBINDUNGSKANAL	587500	\N
872	NOK BRUNSB�TTEL	RIVER	53.898	9.150	0101000020E610000089D349B6BA4C2240FB5C6DC5FEF24A40	Wasser und Schifffahrsdirektion Germany	NORD-OSTSEE-KANAL	5970091	\N
873	NOK K�NIGSF�RDE	RIVER	54.357	9.883	0101000020E6100000D1402C9B39C4234037AAD381AC2D4B40	Wasser und Schifffahrsdirektion Germany	NORD-OSTSEE-KANAL	5970067	\N
874	NOK HOLTENAU	RIVER	54.368	10.140	0101000020E61000006C76A4FACE47244080457EFD102F4B40	Wasser und Schifffahrsdirektion Germany	NORD-OSTSEE-KANAL	5970962	\N
875	ASK STROHBR�CK	RIVER	54.341	9.969	0101000020E610000091B932A836F02340EB8B84B69C2B4B40	Wasser und Schifffahrsdirektion Germany	NORD-OSTSEE-KANAL	5970069	\N
876	NOK BREIHOLZ	RIVER	54.200	9.552	0101000020E61000007BDAE1AFC91A2340E466B8019F194B40	Wasser und Schifffahrsdirektion Germany	NORD-OSTSEE-KANAL	5970075	\N
877	NOK D�KERSWISCH	RIVER	54.041	9.302	0101000020E6100000CEE33098BF9A2240E42D573F36054B40	Wasser und Schifffahrsdirektion Germany	NORD-OSTSEE-KANAL	5970085	\N
878	HELGOLAND BINNENHAFEN	RIVER	54.179	7.890	0101000020E61000007E5182FE428F1F40AEB9A3FFE5164B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510070	\N
879	PELLWORM ANLEGER	RIVER	54.501	8.702	0101000020E6100000D978B0C56E672140C7F484251E404B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9550021	\N
880	WITTD�N	RIVER	54.632	8.384	0101000020E6100000670E492D94C42040E275FD82DD504B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9570010	\N
881	BORKUM FISCHERBALJE	RIVER	53.557	6.748	0101000020E6100000AF46D15ED8FD1A40D8D64FFF59C74A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9340020	\N
882	BORKUM S�DSTRAND	RIVER	53.577	6.661	0101000020E61000009E23F25D4AA51A405DC47762D6C94A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9340030	\N
883	HELGOLAND S�DHAFEN	RIVER	54.175	7.894	0101000020E6100000F48C7DC9C6931F406D57E88365164B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510075	\N
884	B�SUM	RIVER	54.122	8.859	0101000020E61000003CDBA337DCB7214001FBE8D4950F4B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510095	\N
885	HUSUM	RIVER	54.472	9.025	0101000020E610000006D847A7AE0C2240A73E90BC733C4B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9530020	\N
886	DAGEB�LL	RIVER	54.731	8.687	0101000020E61000005378D0ECBA5F2140E23FDD40815D4B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9570040	\N
887	H�RNUM	RIVER	54.758	8.296	0101000020E610000056F146E6919720406C21C84109614B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9570050	\N
888	LIST AUF SYLT	RIVER	55.017	8.440	0101000020E610000067BAD7497DE12040F778211D1E824B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9570070	\N
889	EIDER-SPERRWERK AP	RIVER	54.266	8.842	0101000020E610000010069E7B0FAF2140F5A276BF0A224B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9530010	\N
890	NORDERNEY RIFFGAT	RIVER	53.697	7.158	0101000020E61000004DA3247F8BA11C40FED478E926D94A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9360010	\N
891	LANGEOOG	RIVER	53.723	7.502	0101000020E61000006AABED81B1011E40D9B5BDDD92DC4A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9390010	\N
892	SPIEKEROOG	RIVER	53.749	7.682	0101000020E6100000B5FD2B2B4DBA1E4001FA7DFFE6DF4A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9410010	\N
893	ZEHNERLOCH	RIVER	53.956	8.658	0101000020E6100000FE7DC685035121401F80D4264EFA4A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510010	\N
894	MITTELGRUND	RIVER	53.942	8.636	0101000020E61000006AA0F99CBB452140B9347EE195F84A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510132	\N
895	BAKE C - SCHARH�RN	RIVER	53.967	8.463	0101000020E610000064CF9ECBD4EC204040F67AF7C7FB4A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510060	\N
896	BAKE A	RIVER	53.984	8.315	0101000020E6100000A852B3075AA12040A0C37C7901FE4A40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510063	\N
897	BAKE Z	RIVER	54.014	8.315	0101000020E61000002C836A8313A12040C4EBFA05BB014B40	Wasser und Schifffahrsdirektion Germany	NORDSEE	9510066	\N
898	BISCHOFSWERDER UP	RIVER	52.892	13.381	0101000020E61000008E8F16670CC32A40D9CD8C7E34724A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	581530	\N
899	BISCHOFSWERDER OP	RIVER	52.893	13.381	0101000020E6100000FDA02E5228C32A402ECA6C9049724A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	581520	\N
900	ZEHDENICK UP	RIVER	52.982	13.333	0101000020E61000005FD218ADA3AA2A40E63C635FB27D4A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580170	\N
901	ZEHDENICK OP	RIVER	52.983	13.331	0101000020E610000061376C5B94A92A404B766C04E27D4A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580160	\N
902	BREDEREICHE UP	RIVER	53.135	13.241	0101000020E61000001C446B459B7B2A40D9D0CDFE40914A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580090	\N
903	BREDEREICHE OP	RIVER	53.138	13.239	0101000020E61000001EA9BEF38B7A2A405227A089B0914A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580080	\N
904	F�RSTENBERG UP	RIVER	53.182	13.146	0101000020E6100000DBDB2DC9014B2A4062A06B5F40974A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580070	\N
905	F�RSTENBERG OP	RIVER	53.182	13.144	0101000020E6100000F7CABC55D7492A409A7D1EA33C974A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580060	\N
906	WESENBERG OP	RIVER	53.292	12.989	0101000020E6100000232C2AE274FA2940274A42226DA54A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580020	\N
907	WESENBERG UP	RIVER	53.274	12.989	0101000020E61000006D1CB1169FFA294051F52B9D0FA34A40	Wasser und Schifffahrsdirektion Germany	OBERE HAVEL-WASSERSTRASSE	580030	\N
908	RATZDORF	RIVER	52.071	14.753	0101000020E6100000E10B93A982812D40C7A0134207094A40	Wasser und Schifffahrsdirektion Germany	ODER	603140	\N
909	EISENH�TTENSTADT	RIVER	52.153	14.688	0101000020E61000002882380F27602D4093A8177C9A134A40	Wasser und Schifffahrsdirektion Germany	ODER	603000	\N
910	FRANKFURT1 (ODER)	RIVER	52.358	14.552	0101000020E6100000215C01857A1A2D40D3A3A99ECC2D4A40	Wasser und Schifffahrsdirektion Germany	ODER	603031	\N
911	KIETZ	RIVER	52.578	14.630	0101000020E61000000E4E44BFB6422D40A4AA09A2EE494A40	Wasser und Schifffahrsdirektion Germany	ODER	603040	\N
912	KIENITZ	RIVER	52.680	14.433	0101000020E6100000CB4A9352D0DD2C405D52B5DD04574A40	Wasser und Schifffahrsdirektion Germany	ODER	603050	\N
913	HOHENSAATEN-FINOW	RIVER	52.865	14.141	0101000020E6100000C74B378941482C4082C5E1CCAF6E4A40	Wasser und Schifffahrsdirektion Germany	ODER	603080	\N
914	ST�TZKOW	RIVER	52.984	14.193	0101000020E61000007E3B8908FF622C40E7357689EA7D4A40	Wasser und Schifffahrsdirektion Germany	ODER	603100	\N
915	SCHWEDT-ODERBR�CKE	RIVER	53.036	14.312	0101000020E61000006AF816D68D9F2C40E1421EC18D844A40	Wasser und Schifffahrsdirektion Germany	ODER	603130	\N
916	SACHSENHAUSEN OP	RIVER	52.776	13.243	0101000020E6100000702711E15F7C2A40E509849D62634A40	Wasser und Schifffahrsdirektion Germany	ORANIENBURGER KANAL	580240	\N
917	SACHSENHAUSEN UP	RIVER	52.776	13.243	0101000020E61000000420EEEA557C2A40C9586DFE5F634A40	Wasser und Schifffahrsdirektion Germany	ORANIENBURGER KANAL	581840	\N
918	DALWIGKSTHAL	RIVER	51.150	8.796	0101000020E6100000D369DD06B59721409EB5DB2E34934940	Wasser und Schifffahrsdirektion Germany	ORKE	42840453	\N
919	BREMERV�RDE	RIVER	53.484	9.155	0101000020E610000015376E313F4F224075ABE7A4F7BD4A40	Wasser und Schifffahrsdirektion Germany	OSTE	5980010	\N
920	HECHTHAUSEN	RIVER	53.641	9.253	0101000020E6100000A0E238F06A8122406D1E87C1FCD14A40	Wasser und Schifffahrsdirektion Germany	OSTE	5980030	\N
921	GEVERSDORF BR�CKE	RIVER	53.801	9.080	0101000020E610000034677DCA31292240109370218FE64A40	Wasser und Schifffahrsdirektion Germany	OSTE	126002	\N
922	OSTE SPERRWERK BP	RIVER	53.820	9.040	0101000020E6100000A6B915C26A1422408E3EE60302E94A40	Wasser und Schifffahrsdirektion Germany	OSTE	53	\N
923	OSTE SPERRWERK AP	RIVER	53.820	9.040	0101000020E6100000A6B915C26A1422408E3EE60302E94A40	Wasser und Schifffahrsdirektion Germany	OSTE	59	\N
924	BELUM	RIVER	53.823	9.037	0101000020E6100000A5660FB4021322408FA50F5D50E94A40	Wasser und Schifffahrsdirektion Germany	OSTE	5980060	\N
925	NALJE SIEL	RIVER	53.831	9.034	0101000020E6100000094FE8F527112240522B4CDF6BEA4A40	Wasser und Schifffahrsdirektion Germany	OSTE	126001	\N
926	WARNEM�NDE	RIVER	54.170	12.103	0101000020E610000003999D45EF34284036936FB6B9154B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9640015	\N
927	ALTHAGEN	RIVER	54.372	12.419	0101000020E61000005299620E82D62840600322C4952F4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650024	\N
929	BARH�FT	RIVER	54.435	13.032	0101000020E6100000247D5A457F102A40E466B8019F374B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650040	\N
930	STRALSUND	RIVER	54.306	13.119	0101000020E61000008577B988EF3C2A40BAF8DB9E20274B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650043	\N
931	STAHLBRODE	RIVER	54.234	13.290	0101000020E61000003F52448655942A409F8F32E2021E4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650070	\N
932	GREIFSWALD-ELDENA	RIVER	54.093	13.446	0101000020E6100000959F54FB74E42A408E01D9EBDD0B4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650072	\N
933	WOLGAST	RIVER	54.042	13.770	0101000020E6100000E50CC51D6F8A2B403E0455A357054B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650080	\N
934	NEUENDORF HAFEN	RIVER	54.524	13.094	0101000020E61000002BC1E270E62F2A405F79909E22434B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670046	\N
935	KLOSTER	RIVER	54.585	13.111	0101000020E6100000C808A87004392A4008E8BE9CD94A4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670050	\N
936	WITTOWER F�HRE	RIVER	54.558	13.245	0101000020E61000007C462234827D2A4011397D3D5F474B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670055	\N
937	LAUTERBACH	RIVER	54.340	13.502	0101000020E6100000A06EA0C03B012B400F45813E912B4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670063	\N
938	SASSNITZ	RIVER	54.511	13.643	0101000020E6100000C899266C3F492B407EA8346266414B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670065	\N
939	THIESSOW	RIVER	54.281	13.710	0101000020E6100000D236FE44656B2B40B08C0DDDEC234B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670067	\N
940	RUDEN	RIVER	54.204	13.772	0101000020E61000001F2C6343378B2B4003780B24281A4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9690077	\N
941	GREIFSWALD OIE	RIVER	54.241	13.907	0101000020E6100000D25625917DD02B4092088D60E31E4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9690078	\N
942	KARLSHAGEN	RIVER	54.108	13.808	0101000020E61000006B0F7BA1809D2B40F645425BCE0D4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9690085	\N
943	KOSEROW	RIVER	54.060	14.001	0101000020E6100000EBE0606F62002C40001E51A1BA074B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9690093	\N
944	GREIFSWALD-WIECK	RIVER	54.098	13.457	0101000020E61000005D8940F50FEA2A40FF3EE3C2810C4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650073	\N
945	FLENSBURG	RIVER	54.795	9.433	0101000020E6100000299485AFAFDD224007600322C4654B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610010	\N
946	LANGBALLIGAU	RIVER	54.823	9.654	0101000020E6100000546EA296E64E23406F0D6C9560694B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610015	\N
947	LT KALKGRUND	RIVER	54.825	9.888	0101000020E610000082A8FB00A4C6234059C16F438C694B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610020	\N
948	KIEL ALTE SCHLEUSE	RIVER	54.368	10.143	0101000020E61000009D12109370492440508D976E122F4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9650067	\N
949	WISMAR-BAUMHAUS	RIVER	53.904	11.458	0101000020E61000000ABFD4CF9BEA264019AE0E80B8F34A40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670030	\N
950	TIMMENDORF POEL	RIVER	53.992	11.376	0101000020E610000052F17F4754C02640745DF8C1F9FE4A40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9670070	\N
951	HEILIGENHAFEN	RIVER	54.373	11.006	0101000020E6100000D3F71A82E30226401CCF6740BD2F4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610070	\N
952	KIEL-HOLTENAU	RIVER	54.372	10.157	0101000020E61000008B7093516550244055A69883A02F4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610066	\N
953	LT KIEL	RIVER	54.500	10.273	0101000020E6100000908653E6E68B2440AEBCE47FF23F4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610050	\N
954	NEUSTADT	RIVER	54.097	10.805	0101000020E6100000F374AE28259C2540E9279CDD5A0C4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610080	\N
955	MARIENLEUCHTE	RIVER	54.497	11.239	0101000020E6100000575D876A4A7A2640448655BC913F4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610075	\N
956	KAPPELN	RIVER	54.664	9.938	0101000020E61000003E93FDF334E023405A828C800A554B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610035	\N
957	SCHLESWIG	RIVER	54.511	9.569	0101000020E61000000B992B836A232340A0FF1EBC76414B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610040	\N
958	ECKERNF�RDE	RIVER	54.475	9.836	0101000020E61000009E279EB305AC2340A2B437F8C23C4B40	Wasser und Schifffahrsdirektion Germany	OSTSEE	9610045	\N
959	PAREY EP	RIVER	52.404	11.977	0101000020E610000023F3C81F0CF427403ACB2C42B1334A40	Wasser und Schifffahrsdirektion Germany	PAREYER VERBINDUNGSKANAL	502300	\N
960	PAREY UP	RIVER	52.403	11.979	0101000020E6100000713B342C46F52740C49448A297334A40	Wasser und Schifffahrsdirektion Germany	PAREYER VERBINDUNGSKANAL	587530	\N
961	AALBUDE	RIVER	53.848	12.888	0101000020E610000048FB1F60ADC629409C3237DF88EC4A40	Wasser und Schifffahrsdirektion Germany	PEENE	9660009	\N
962	DEMMIN-MEYENKREBSBR�CKE	RIVER	53.916	13.027	0101000020E61000003A9160AA990D2A405743E21E4BF54A40	Wasser und Schifffahrsdirektion Germany	PEENE	9660007	\N
963	JARMEN	RIVER	53.929	13.342	0101000020E6100000DA0418963FAF2A40EC87D860E1F64A40	Wasser und Schifffahrsdirektion Germany	PEENE	9660005	\N
964	ANKLAM	RIVER	53.863	13.704	0101000020E6100000A795422097682B40F1BA7EC16EEE4A40	Wasser und Schifffahrsdirektion Germany	PEENE	9660001	\N
965	UETERSEN	RIVER	53.678	9.677	0101000020E610000023F77475C75A23405F46B1DCD2D64A40	Wasser und Schifffahrsdirektion Germany	PINNAU	5970016	\N
966	PINNAU-SPERRWERK BP	RIVER	53.671	9.558	0101000020E61000001E1A16A3AE1D23407DB3CD8DE9D54A40	Wasser und Schifffahrsdirektion Germany	PINNAU	5970018	\N
967	PINNAU-SPERRWERK AP	RIVER	53.671	9.558	0101000020E6100000761A69A9BC1D23409A982EC4EAD54A40	Wasser und Schifffahrsdirektion Germany	PINNAU	5970019	\N
968	POTSDAM	RIVER	52.394	13.062	0101000020E610000084D90418961F2A406EDC627E6E324A40	Wasser und Schifffahrsdirektion Germany	POTSDAMER HAVEL	580412	\N
969	RHEINWEILER	RIVER	47.711	7.529	0101000020E6100000925CFE43FA1D1E4034BF9A0304DB4740	Wasser und Schifffahrsdirektion Germany	RHEIN	23300130	\N
970	BREISACH	RIVER	48.043	7.573	0101000020E6100000D1AE42CA4F4A1E401A6EC0E787054840	Wasser und Schifffahrsdirektion Germany	RHEIN	23300320	\N
971	KEHL-KRONENHOF	RIVER	48.563	7.808	0101000020E61000000204BD81133B1F406397A8DE1A484840	Wasser und Schifffahrsdirektion Germany	RHEIN	23300900	\N
972	IFFEZHEIM	RIVER	48.822	8.111	0101000020E6100000151BF33AE23820409D9E776341694840	Wasser und Schifffahrsdirektion Germany	RHEIN	23500600	\N
973	PLITTERSDORF	RIVER	48.886	8.136	0101000020E61000006B49473998452040E92ADD5D67714840	Wasser und Schifffahrsdirektion Germany	RHEIN	23500700	\N
974	MAXAU	RIVER	49.039	8.306	0101000020E6100000C5573B8A739C20403D80457EFD844840	Wasser und Schifffahrsdirektion Germany	RHEIN	23700200	\N
975	SPEYER	RIVER	49.324	8.449	0101000020E6100000C8409E5DBEE5204054FEB5BC72A94840	Wasser und Schifffahrsdirektion Germany	RHEIN	23700600	\N
976	MANNHEIM	RIVER	49.485	8.454	0101000020E61000009CE1067C7EE8204052431B800DBE4840	Wasser und Schifffahrsdirektion Germany	RHEIN	23700700	\N
977	WORMS	RIVER	49.632	8.378	0101000020E61000006FD39FFD48C120406F66F4A3E1D04840	Wasser und Schifffahrsdirektion Germany	RHEIN	23900200	\N
978	NIERSTEIN-OPPENHEIM	RIVER	49.865	8.352	0101000020E6100000CDE49B6D6EB42040BABF7ADCB7EE4840	Wasser und Schifffahrsdirektion Germany	RHEIN	23900600	\N
979	MAINZ	RIVER	50.004	8.275	0101000020E610000011001C7BF68C2040ABB019E082004940	Wasser und Schifffahrsdirektion Germany	RHEIN	25100100	\N
980	OESTRICH	RIVER	50.003	8.030	0101000020E610000092AF0452620F2040CAA65CE15D004940	Wasser und Schifffahrsdirektion Germany	RHEIN	25100300	\N
981	BINGEN	RIVER	49.970	7.900	0101000020E6100000F611537D42991F401500E31934FC4840	Wasser und Schifffahrsdirektion Germany	RHEIN	25300200	\N
982	KAUB	RIVER	50.085	7.765	0101000020E61000002FC5B01E520F1F40F7EAE3A1EF0A4940	Wasser und Schifffahrsdirektion Germany	RHEIN	25700100	\N
983	SANKT GOAR	RIVER	50.153	7.713	0101000020E6100000618E1EBFB7D91E4050E3DEFC86134940	Wasser und Schifffahrsdirektion Germany	RHEIN	25700300	\N
984	BRAUBACH	RIVER	50.271	7.646	0101000020E6100000E55828E329951E40B4C876BE9F224940	Wasser und Schifffahrsdirektion Germany	RHEIN	25700600	\N
985	KOBLENZ	RIVER	50.359	7.605	0101000020E6100000F140AE1E416B1E40CB845FEAE72D4940	Wasser und Schifffahrsdirektion Germany	RHEIN	25900700	\N
986	NEUWIED STADT	RIVER	50.424	7.457	0101000020E61000000FD4298F6ED41D40672C9ACE4E364940	Wasser und Schifffahrsdirektion Germany	RHEIN	27100370	\N
987	ANDERNACH	RIVER	50.443	7.392	0101000020E610000064CDC82077911D40CDAFE600C1384940	Wasser und Schifffahrsdirektion Germany	RHEIN	27100400	\N
988	OBERWINTER	RIVER	50.601	7.215	0101000020E6100000A60BB1FA23DC1C40F7EAE3A1EF4C4940	Wasser und Schifffahrsdirektion Germany	RHEIN	27100700	\N
989	BONN	RIVER	50.736	7.108	0101000020E610000023E87981A36E1C40AEEFC341425E4940	Wasser und Schifffahrsdirektion Germany	RHEIN	2710080	\N
990	K�LN	RIVER	50.937	6.963	0101000020E61000007CF2B0506BDA1B405DFE43FAED774940	Wasser und Schifffahrsdirektion Germany	RHEIN	2730010	\N
991	D�SSELDORF	RIVER	51.226	6.770	0101000020E610000053E68B625E141B40BE9F1A2FDD9C4940	Wasser und Schifffahrsdirektion Germany	RHEIN	2750010	\N
992	RUHRORT	RIVER	51.455	6.728	0101000020E6100000738AE99D65E91A40D5B2B5BE48BA4940	Wasser und Schifffahrsdirektion Germany	RHEIN	2770010	\N
993	WESEL	RIVER	51.646	6.607	0101000020E6100000213CDA38626D1A4098512CB7B4D24940	Wasser und Schifffahrsdirektion Germany	RHEIN	2770040	\N
994	REES	RIVER	51.757	6.396	0101000020E6100000B81DBF5C30951940C74961DEE3E04940	Wasser und Schifffahrsdirektion Germany	RHEIN	2790010	\N
995	EMMERICH	RIVER	51.829	6.246	0101000020E6100000554FE61F7DFB1840A01A2FDD24EA4940	Wasser und Schifffahrsdirektion Germany	RHEIN	2790020	\N
996	WOLFSBRUCH OP	RIVER	53.182	12.905	0101000020E6100000897956D28ACF2940D8D64FFF59974A40	Wasser und Schifffahrsdirektion Germany	RHEINSBERGER GEW�SSER	589000	\N
997	WOLFSBRUCH UP	RIVER	53.182	12.903	0101000020E610000039ED293927CE2940956247E350974A40	Wasser und Schifffahrsdirektion Germany	RHEINSBERGER GEW�SSER	589010	\N
1046	ITZEHOE	RIVER	53.921	9.501	0101000020E61000007FC16ED8B600234012312592E8F54A40	Wasser und Schifffahrsdirektion Germany	ST�R	5970039	\N
998	SCHLEUSE ROTHENSEE UP	RIVER	52.221	11.674	0101000020E6100000E012807F4A5927407138F3AB391C4A40	Wasser und Schifffahrsdirektion Germany	ROTHENSEER-VERBINDUNGSKANAL	3101016	\N
999	HATTINGEN	RIVER	51.400	7.161	0101000020E61000001F2DCE18E6A41C40BA490C022BB34940	Wasser und Schifffahrsdirektion Germany	RUHR	2769510000100	\N
1000	RUTHENSTROM SPERRWERK	RIVER	53.665	5.334	0101000020E61000002FDD2406815515404B04AA7F10D54A40	Wasser und Schifffahrsdirektion Germany	RUTHENSTROM	126010	\N
1001	WOLTERSDORF UP	RIVER	52.442	13.764	0101000020E61000003D62F4DC42872B404D2D5BEB8B384A40	Wasser und Schifffahrsdirektion Germany	R�DERSDORFER GEW�SSER	586050	\N
1002	WOLTERSDORF OP	RIVER	52.443	13.765	0101000020E61000007427D87F9D872B40E63FA4DFBE384A40	Wasser und Schifffahrsdirektion Germany	R�DERSDORFER GEW�SSER	586040	\N
1003	CALBE GRIZEHNE	RIVER	51.916	11.812	0101000020E6100000EAB46E83DA9F2740BBD408FD4CF54940	Wasser und Schifffahrsdirektion Germany	SAALE	570940	\N
1004	CALBE UP	RIVER	51.906	11.789	0101000020E610000004FEF0F3DF9327406B82A8FB00F44940	Wasser und Schifffahrsdirektion Germany	SAALE	570930	\N
1005	CALBE OP	RIVER	51.901	11.789	0101000020E61000008FE4F21FD293274080272D5C56F34940	Wasser und Schifffahrsdirektion Germany	SAALE	570920	\N
1006	NIENBURG	RIVER	51.839	11.772	0101000020E610000083E0F1ED5D8B2740CAA99D616AEB4940	Wasser und Schifffahrsdirektion Germany	SAALE	579100	\N
1007	BERNBURG UP	RIVER	51.797	11.735	0101000020E6100000D2730B5D89782740D2E3F736FDE54940	Wasser und Schifffahrsdirektion Germany	SAALE	570910	\N
1008	BERNBURG OP	RIVER	51.796	11.734	0101000020E6100000BF620D17B9772740B2D7BB3FDEE54940	Wasser und Schifffahrsdirektion Germany	SAALE	570900	\N
1009	ALSLEBEN UP	RIVER	51.708	11.677	0101000020E610000001A60C1CD05A2740B613252191DA4940	Wasser und Schifffahrsdirektion Germany	SAALE	570880	\N
1010	ALSLEBEN OP	RIVER	51.706	11.679	0101000020E610000020F0C000C25B27403546EBA86ADA4940	Wasser und Schifffahrsdirektion Germany	SAALE	570870	\N
1011	ROTHENBURG UP	RIVER	51.655	11.751	0101000020E6100000D49AE61DA78027408D9944BDE0D34940	Wasser und Schifffahrsdirektion Germany	SAALE	570860	\N
1012	ROTHENBURG OP	RIVER	51.654	11.752	0101000020E6100000D9791B9B1D8127406F0C01C0B1D34940	Wasser und Schifffahrsdirektion Germany	SAALE	570850	\N
1013	WETTIN UP	RIVER	51.582	11.793	0101000020E61000001DE5603601962740CB82893F8ACA4940	Wasser und Schifffahrsdirektion Germany	SAALE	570840	\N
1014	WETTIN OP	RIVER	51.583	11.795	0101000020E6100000A92F4B3B35972740D9B5BDDD92CA4940	Wasser und Schifffahrsdirektion Germany	SAALE	570830	\N
1015	TROTHA UP	RIVER	51.514	11.955	0101000020E61000002F88484DBBE82740E7FBA9F1D2C14940	Wasser und Schifffahrsdirektion Germany	SAALE	570810	\N
1016	TROTHA OP	RIVER	51.514	11.955	0101000020E610000066D993C0E6E82740AFB0E07EC0C14940	Wasser und Schifffahrsdirektion Germany	SAALE	570800	\N
1017	R�PZIG	RIVER	51.435	11.945	0101000020E6100000B5334C6DA9E3274041BCAE5FB0B74940	Wasser und Schifffahrsdirektion Germany	SAALE	570710	\N
1018	RISCHM�HLE UP	RIVER	51.351	12.003	0101000020E61000001155F833BC0128404016A243E0AC4940	Wasser und Schifffahrsdirektion Germany	SAALE	570630	\N
1019	FREMERSDORF	RIVER	49.409	6.648	0101000020E61000005E83BEF4F6971A407FD93D7958B44840	Wasser und Schifffahrsdirektion Germany	SAAR	26400550	\N
1020	SANKT ARNUAL	RIVER	49.215	7.023	0101000020E61000007484679D4C171C401781B1BE819B4840	Wasser und Schifffahrsdirektion Germany	SAAR	26400220	\N
1021	SCHWEDT SCHLEUSE AP	RIVER	53.070	14.323	0101000020E61000009B012EC896A52C40E59CD843FB884A40	Wasser und Schifffahrsdirektion Germany	SCHWEDTER QUERFAHRT	603110	\N
1022	SCHWINGE SPERRWERK	RIVER	53.625	9.514	0101000020E61000007C9E3F6D54072340EB73B515FBCF4A40	Wasser und Schifffahrsdirektion Germany	SCHWINGE	59000106	\N
1023	BERLIN-CHARLOTTENBURG UP	RIVER	52.530	13.283	0101000020E6100000F14BFDBCA9902A40C1559E40D8434A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	582750	\N
1024	BERLIN-CHARLOTTENBURG OP	RIVER	52.531	13.292	0101000020E61000006D3656629E952A405C38109205444A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	582740	\N
1025	BERLIN-M�HLENDAMM UP	RIVER	52.515	13.409	0101000020E61000008C67D0D03FD12A40AD6BB41CE8414A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	582730	\N
1026	BERLIN-M�HLENDAMM OP	RIVER	52.514	13.411	0101000020E6100000AE282504ABD22A4031957EC2D9414A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	582720	\N
1027	BERLIN-K�PENICK	RIVER	52.430	13.574	0101000020E610000045B9347EE1252B4089B5F81400374A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	586290	\N
1028	WERNSDORF UP	RIVER	52.373	13.708	0101000020E6100000D74E9484446A2B40A54DD53DB22F4A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	585930	\N
1029	WERNSDORF OP	RIVER	52.371	13.711	0101000020E6100000A04E7974236C2B40527FBDC2822F4A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	585920	\N
1030	FUERSTENWALDE UP	RIVER	52.354	14.065	0101000020E6100000E48409A359212C406A334E43542D4A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	582650	\N
1031	FUERSTENWALDE OP	RIVER	52.354	14.067	0101000020E61000005D8940F50F222C40F6234564582D4A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	582640	\N
1032	KERSDORF UP	RIVER	52.305	14.239	0101000020E61000005F419AB1687A2C40ED6305BF0D274A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	585950	\N
1033	KERSDORF OP	RIVER	52.305	14.242	0101000020E6100000BE175FB4C77B2C40910E0F61FC264A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	585940	\N
1034	EISENHUETTENSTADT SCHL. OP	RIVER	52.132	14.652	0101000020E61000000F61FC34EE4D2D40F3C98AE1EA104A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	690050	\N
1035	EISENHUETTENSTADT SCHL. UP	RIVER	52.132	14.656	0101000020E61000006FD74B5304502D4077DCF0BBE9104A40	Wasser und Schifffahrsdirektion Germany	SPREE-ODER-WASSERSTRASSE	603020	\N
1036	BOLZUM	RIVER	52.301	9.958	0101000020E61000005C548B8862EA23407B15191D90264A40	Wasser und Schifffahrsdirektion Germany	STICHKANAL HILDESHEIM	31010072	\N
1037	KUMMERSDORF UP	RIVER	52.269	13.865	0101000020E6100000423EE8D9ACBA2B4090F9804067224A40	Wasser und Schifffahrsdirektion Germany	STORKOWER GEWAESSER	586360	\N
1038	KUMMERSDORF OP	RIVER	52.267	13.866	0101000020E6100000003CA24275BB2B40A779C7293A224A40	Wasser und Schifffahrsdirektion Germany	STORKOWER GEWAESSER	586350	\N
1039	STORKOW UP	RIVER	52.258	13.931	0101000020E610000044F7AC6BB4DC2B40EA93DC6113214A40	Wasser und Schifffahrsdirektion Germany	STORKOWER GEWAESSER	586340	\N
1040	STORKOW OP	RIVER	52.259	13.934	0101000020E61000002672C119FCDD2B4005DD5ED218214A40	Wasser und Schifffahrsdirektion Germany	STORKOWER GEWAESSER	586330	\N
1041	WENDISCH RIETZ UP	RIVER	52.214	14.003	0101000020E610000039EFFFE384012C409E7AA4C16D1B4A40	Wasser und Schifffahrsdirektion Germany	STORKOWER GEWAESSER	586320	\N
1042	WENDISCH RIETZ OP	RIVER	52.214	14.004	0101000020E61000008AC8B08A37022C400B992B836A1B4A40	Wasser und Schifffahrsdirektion Germany	STORKOWER GEWAESSER	586310	\N
1043	RENSING	RIVER	53.959	9.732	0101000020E61000003E97A949F07623406D567DAEB6FA4A40	Wasser und Schifffahrsdirektion Germany	ST�R	5970036	\N
1044	GR�NHUDE	RIVER	53.936	9.691	0101000020E610000000E48409A3612340A032FE7DC6F74A40	Wasser und Schifffahrsdirektion Germany	ST�R	5970037	\N
1045	BREITENBERG	RIVER	53.928	9.632	0101000020E6100000355F251FBB4323407BBDFBE3BDF64A40	Wasser und Schifffahrsdirektion Germany	ST�R	5970038	\N
1047	ST�R-SPERRWERK BP	RIVER	53.826	9.401	0101000020E610000082C98D226BCD2240E04BE141B3E94A40	Wasser und Schifffahrsdirektion Germany	ST�R	5970040	\N
1048	ST�R-SPERRWERK AP	RIVER	53.826	9.401	0101000020E610000082C98D226BCD2240691B7FA2B2E94A40	Wasser und Schifffahrsdirektion Germany	ST�R	5970041	\N
1049	BANZKOW UP	RIVER	53.523	11.522	0101000020E610000061FE0A992B0B2740221ADD41ECC24A40	Wasser und Schifffahrsdirektion Germany	ST�R-WASSERSTRASSE	596930	\N
1050	BANZKOW OP	RIVER	53.524	11.520	0101000020E6100000323CF6B3580A27401893FE5E0AC34A40	Wasser und Schifffahrsdirektion Germany	ST�R-WASSERSTRASSE	596920	\N
1051	SCHWERIN WERDERBR�CKE	RIVER	53.646	11.427	0101000020E6100000373811FDDADA26404C6DA983BCD24A40	Wasser und Schifffahrsdirektion Germany	ST�R-WASSERSTRASSE	596900	\N
1052	KLEINMACHNOW UP	RIVER	52.396	13.208	0101000020E6100000AFB48CD47B6A2A401F4B1FBAA0324A40	Wasser und Schifffahrsdirektion Germany	TELTOWKANAL	587030	\N
1053	KLEINMACHNOW OP	RIVER	52.397	13.211	0101000020E6100000DF8AC404356C2A409B8F6B43C5324A40	Wasser und Schifffahrsdirektion Germany	TELTOWKANAL	587020	\N
1054	KANNENBURG OP	RIVER	53.075	13.392	0101000020E6100000C0CDE2C5C2C82A4053D0ED258D894A40	Wasser und Schifffahrsdirektion Germany	TEMPLINER GEW�SSER	581220	\N
1055	KANNENBURG UP	RIVER	53.074	13.391	0101000020E6100000AAD4EC8156C82A401A6EC0E787894A40	Wasser und Schifffahrsdirektion Germany	TEMPLINER GEW�SSER	581230	\N
1056	TEMPLIN OP	RIVER	53.123	13.495	0101000020E61000007C80EECB99FD2A40594C6C3EAE8F4A40	Wasser und Schifffahrsdirektion Germany	TEMPLINER GEW�SSER	581200	\N
1057	TEMPLIN UP	RIVER	53.122	13.495	0101000020E61000001E32E54350FD2A40406B7EFCA58F4A40	Wasser und Schifffahrsdirektion Germany	TEMPLINER GEW�SSER	581210	\N
1058	L�BECK-BAUHOF	RIVER	53.893	10.703	0101000020E6100000D5E76A2BF66725401F80D4264EF24A40	Wasser und Schifffahrsdirektion Germany	TRAVE	9610090	\N
1059	TRAVEM�NDE	RIVER	53.958	10.872	0101000020E6100000C45DBD8A8CBE2540AED7F4A0A0FA4A40	Wasser und Schifffahrsdirektion Germany	TRAVE	9610085	\N
1060	FRIEDRICHSTADT TREENE	RIVER	54.374	9.084	0101000020E610000094F59B89E92A2240401361C3D32F4B40	Wasser und Schifffahrsdirektion Germany	TREENE	9520061	\N
1061	KETZIN	RIVER	52.463	12.857	0101000020E6100000DD787764ACB629407C8159A1483B4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580430	\N
1062	BRANDENBURG OP	RIVER	52.421	12.581	0101000020E6100000B1FCF9B6602929400BEF7211DF354A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580440	\N
1063	BRANDENBURG UP	RIVER	52.424	12.569	0101000020E6100000F71DC3633F2329400C3F389F3A364A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580450	\N
1064	PLAUE OP	RIVER	52.403	12.393	0101000020E61000008F37F92D3AC92840530438BD8B334A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	587560	\N
1065	PLAUE UP	RIVER	52.403	12.395	0101000020E610000008B0C8AF1FCA284031B3CF6394334A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580600	\N
1066	TIECKOW	RIVER	52.473	12.448	0101000020E610000049B9FB1C1FE5284046EBA86A823C4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580601	\N
1067	BAHNITZ OP	RIVER	52.501	12.419	0101000020E6100000B0E2546B61D6284001DC2C5E2C404A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580620	\N
1068	BAHNITZ UP	RIVER	52.501	12.415	0101000020E6100000A52DAEF199D428408E9257E718404A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580630	\N
1069	RATHENOW OP	RIVER	52.600	12.314	0101000020E6100000AC8C463EAFA028409BC937DBDC4C4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580640	\N
1070	RATHENOW UP	RIVER	52.607	12.321	0101000020E610000048FC8A355CA42840328FFCC1C04D4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580650	\N
1071	ALBERTSHEIM	RIVER	52.656	12.334	0101000020E610000083A10E2BDCAA2840C47C7901F6534A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580520	\N
1072	GR�TZ OP	RIVER	52.667	12.260	0101000020E61000007270E998F384284043AA285E65554A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580700	\N
1073	GR�TZ UP	RIVER	52.667	12.255	0101000020E610000024F25D4A5D822840CAA31B6151554A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580710	\N
1074	WARNAU POLDER	RIVER	52.731	12.194	0101000020E6100000BB253960576328404BC8073D9B5D4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	588321	\N
1075	G�LPE OP	RIVER	52.739	12.222	0101000020E6100000F8E28BF678712840B48EAA26885E4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580747	\N
1076	GARZ OP	RIVER	52.746	12.215	0101000020E6100000DFE2E13D076E2840AFCE31207B5F4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580750	\N
1077	GARZ UP	RIVER	52.749	12.213	0101000020E6100000D8800871E56C2840B2BAD573D25F4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580760	\N
1078	TRUEBENGRABEN POLDER	RIVER	52.811	12.097	0101000020E6100000B153AC1A843128404298DBBDDC674A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580795	\N
1079	HAVELBERG STADT	RIVER	52.824	12.078	0101000020E61000000B5D8940F5272840F1BDBF417B694A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580790	\N
1080	HAVELBERG UP	RIVER	52.831	12.057	0101000020E6100000FF76D9AF3B1D28400B96EA025E6A4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580800	\N
1081	HAVELBERG EP	RIVER	52.834	12.053	0101000020E6100000B0373124271B28403D9E961FB86A4A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	502475	\N
1082	QUITZ�BEL OP	RIVER	52.881	12.005	0101000020E610000037FE4465C3022840BF654E97C5704A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580820	\N
1083	QUITZ�BEL UP	RIVER	52.881	12.004	0101000020E61000000B630B410E0228406682E15CC3704A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580830	\N
1084	NEUWERBEN EP	RIVER	52.878	12.009	0101000020E610000012A452EC68042840D367075C57704A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	502470	\N
1085	GNEVSDORF OP	RIVER	52.908	11.887	0101000020E61000003C1405FA44C6274043CBBA7F2C744A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	580840	\N
1086	GNEVSDORF EP	RIVER	52.908	11.886	0101000020E610000068791EDC9DC527409BFF571D39744A40	Wasser und Schifffahrsdirektion Germany	UNTERE HAVEL-WASSERSTRASSE	503010	\N
1087	HOHENSAATEN OST AP	RIVER	52.874	14.151	0101000020E6100000742843554C4D2C4015527E52ED6F4A40	Wasser und Schifffahrsdirektion Germany	VERBINDUNGSKANAL HOHENSAATEN	603090	\N
1088	ROSTOCK M�HLENDAMM OW	RIVER	54.082	12.154	0101000020E6100000C64FE3DEFC4E2840EDF0D7648D0A4B40	Wasser und Schifffahrsdirektion Germany	WARNOW	9640002	\N
1089	ROSTOCK M�HLENDAMM UW	RIVER	54.083	12.155	0101000020E61000006AA164726A4F28409B38B9DFA10A4B40	Wasser und Schifffahrsdirektion Germany	WARNOW	9640018	\N
1090	EICHHORST OP	RIVER	52.891	13.639	0101000020E6100000950B957F2D472B40E62494BE10724A40	Wasser und Schifffahrsdirektion Germany	WERBELLINER GEW�SSER	693320	\N
1091	EICHHORST UP	RIVER	52.891	13.639	0101000020E61000000A664CC11A472B40AB77B81D1A724A40	Wasser und Schifffahrsdirektion Germany	WERBELLINER GEW�SSER	693330	\N
1092	LETZTER HELLER	RIVER	51.416	9.678	0101000020E6100000950B957F2D5B23408C4AEA0434B54940	Wasser und Schifffahrsdirektion Germany	WERRA	41900206	\N
1093	ALLENDORF	RIVER	51.277	9.966	0101000020E610000099107349D5EE2340274A42226DA34940	Wasser und Schifffahrsdirektion Germany	WERRA	41900104	\N
1094	HELDRA	RIVER	51.125	10.197	0101000020E61000007DB08C0DDD64244083DE1B4300904940	Wasser und Schifffahrsdirektion Germany	WERRA	41700105	\N
1095	GROSSE WESERBR�CKE	RIVER	53.073	8.804	0101000020E6100000C9C6832D769B2140C537143E5B894A40	Wasser und Schifffahrsdirektion Germany	WESER	4910050	\N
1096	HANN.MUENDEN	RIVER	51.426	9.641	0101000020E61000009FE6E445264823405F7B664980B64940	Wasser und Schifffahrsdirektion Germany	WESER	43100109	\N
1097	OSLEBSHAUSEN	RIVER	53.120	8.712	0101000020E6100000F870C971A76C214057941282558F4A40	Wasser und Schifffahrsdirektion Germany	WESER	4910060	\N
1098	VEGESACK	RIVER	53.169	8.620	0101000020E61000002785798F333D2140535BEA20AF954A40	Wasser und Schifffahrsdirektion Germany	WESER	4950010	\N
1099	FARGE	RIVER	53.205	8.510	0101000020E6100000D74B5304380521400395F1EF339A4A40	Wasser und Schifffahrsdirektion Germany	WESER	4950020	\N
1100	ELSFLETH	RIVER	53.264	8.481	0101000020E610000055698B6B7CF620404C70EA03C9A14A40	Wasser und Schifffahrsdirektion Germany	WESER	4970010	\N
1101	WAHMBECK	RIVER	51.626	9.520	0101000020E610000088A1D5C9190A2340BAF59A1E14D04940	Wasser und Schifffahrsdirektion Germany	WESER	43900105	\N
1102	BRAKE	RIVER	53.295	8.485	0101000020E6100000EEEA556474F82040A453573ECBA54A40	Wasser und Schifffahrsdirektion Germany	WESER	4970020	\N
1103	KARLSHAFEN	RIVER	51.648	9.439	0101000020E610000010B056ED9AE02240D89DEE3CF1D24940	Wasser und Schifffahrsdirektion Germany	WESER	45100100	\N
1104	RECHTENFLETH	RIVER	53.381	8.501	0101000020E610000093C3279D480021408D45D3D9C9B04A40	Wasser und Schifffahrsdirektion Germany	WESER	4970030	\N
1105	NORDENHAM	RIVER	53.464	8.488	0101000020E61000009F0436E7E0F92040C53D963E74BB4A40	Wasser und Schifffahrsdirektion Germany	WESER	4970040	\N
1106	BHV ALTER LEUCHTTURM	RIVER	53.545	8.568	0101000020E610000042CF66D5E722214026E1421EC1C54A40	Wasser und Schifffahrsdirektion Germany	WESER	4990010	\N
1107	H�XTER	RIVER	51.776	9.400	0101000020E6100000E90E62670ACD2240C19140834DE34940	Wasser und Schifffahrsdirektion Germany	WESER	45300109	\N
1108	ROBBENS�DSTEERT	RIVER	53.639	8.445	0101000020E6100000433A3C84F1E320408FE4F21FD2D14A40	Wasser und Schifffahrsdirektion Germany	WESER	9460010	\N
1109	DWARSGAT	RIVER	53.719	8.308	0101000020E6100000A18499B67F9D204037DDB243FCDB4A40	Wasser und Schifffahrsdirektion Germany	WESER	9460020	\N
1110	BODENWERDER	RIVER	51.974	9.516	0101000020E61000009FAC18AE0E0823402A91442FA3FC4940	Wasser und Schifffahrsdirektion Germany	WESER	45300200	\N
1111	LEUCHTTURM ALTE WESER	RIVER	53.863	8.128	0101000020E610000048C5FF1D5141204018CFA0A17FEE4A40	Wasser und Schifffahrsdirektion Germany	WESER	9460040	\N
1112	HAMELN WEHRBERGEN	RIVER	52.124	9.307	0101000020E6100000ADA23F34F39C22405DC47762D60F4A40	Wasser und Schifffahrsdirektion Germany	WESER	45700207	\N
1113	RINTELN	RIVER	52.190	9.082	0101000020E6100000E0D6DD3CD5292240CEC133A149184A40	Wasser und Schifffahrsdirektion Germany	WESER	45900109	\N
1114	VLOTHO	RIVER	52.176	8.862	0101000020E6100000D5AE09698DB92140C616821C94164A40	Wasser und Schifffahrsdirektion Germany	WESER	45900208	\N
1115	PORTA	RIVER	52.249	8.922	0101000020E61000006C2409C215D821401618B2BAD51F4A40	Wasser und Schifffahrsdirektion Germany	WESER	47100100	\N
1116	PETERSHAGEN	RIVER	52.382	8.971	0101000020E6100000A2629CBF09F12140F0F96184F0304A40	Wasser und Schifffahrsdirektion Germany	WESER	47300100	\N
1117	STOLZENAU	RIVER	52.518	9.078	0101000020E61000005682C5E1CC2722407593180456424A40	Wasser und Schifffahrsdirektion Germany	WESER	47500110	\N
1118	LIEBENAU	RIVER	52.594	9.113	0101000020E61000001CCF6740BD392240C382FB010F4C4A40	Wasser und Schifffahrsdirektion Germany	WESER	47500200	\N
1119	NIENBURG	RIVER	52.644	9.205	0101000020E610000004AA7F10C968224036CB65A373524A40	Wasser und Schifffahrsdirektion Germany	WESER	47900118	\N
1120	DRAKENBURG	RIVER	52.693	9.226	0101000020E6100000AD32535A7F732240C66D3480B7584A40	Wasser und Schifffahrsdirektion Germany	WESER	47900107	\N
1121	HOYA	RIVER	52.801	9.147	0101000020E6100000B9FE5D9F394B224074D3669C86664A40	Wasser und Schifffahrsdirektion Germany	WESER	47900129	\N
1122	D�RVERDEN	RIVER	52.852	9.210	0101000020E610000035423F53AF6B2240F4A5B73F176D4A40	Wasser und Schifffahrsdirektion Germany	WESER	47900209	\N
1123	INTSCHEDE	RIVER	52.964	9.126	0101000020E610000030BDFDB96840224065E42CEC697B4A40	Wasser und Schifffahrsdirektion Germany	WESER	49100101	\N
1124	DREYE	RIVER	53.014	8.891	0101000020E6100000DCF4673F52C821406F2F698CD6814A40	Wasser und Schifffahrsdirektion Germany	WESER	4910020	\N
1125	WESERWEHR OW	RIVER	53.059	8.869	0101000020E6100000E3344415FEBC214030116F9D7F874A40	Wasser und Schifffahrsdirektion Germany	WESER	4910030	\N
1126	WESERWEHR UW	RIVER	53.060	8.855	0101000020E61000009E0B23BDA8B521407FDB1324B6874A40	Wasser und Schifffahrsdirektion Germany	WESER	4910040	\N
1127	GARTZ	RIVER	53.206	14.395	0101000020E6100000EB1B98DC28CA2C40876C205D6C9A4A40	Wasser und Schifffahrsdirektion Germany	WESTODER	603510	\N
1128	MESCHERIN	RIVER	53.251	14.436	0101000020E61000007D5D86FF74DF2C404A07EBFF1CA04A40	Wasser und Schifffahrsdirektion Germany	WESTODER	603520	\N
1129	WISCHHAFEN SPERRWERK	RIVER	53.785	9.341	0101000020E61000008BDEA9807BAE224094BC3AC780E44A40	Wasser und Schifffahrsdirektion Germany	WISCHHAFENER S�DERELBE	59000107	\N
1130	BORGFELD	RIVER	53.134	8.894	0101000020E61000007AE3A430EFC92140344A97FE25914A40	Wasser und Schifffahrsdirektion Germany	W�MME	4940010	\N
1131	NIEDERBLOCKLAND	RIVER	53.162	8.827	0101000020E610000001F6D1A92BA721405B9A5B21AC944A40	Wasser und Schifffahrsdirektion Germany	W�MME	4940020	\N
\.




--
-- Name: gaugemeasurement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE gaugemeasurement (
    gaugeid integer NOT NULL,
    value numeric(4,2) NOT NULL,
    "time" timestamp without time zone NOT NULL
);


ALTER TABLE gaugemeasurement OWNER TO postgres;

--
-- Name: license; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE license (
    name character varying(255) NOT NULL,
    shortname character varying(16),
    text text,
    public boolean,
    id integer NOT NULL,
    user_name character varying(255)
);


ALTER TABLE license OWNER TO postgres;

--
-- Name: license_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE license_id_seq
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE license_id_seq OWNER TO postgres;

COPY license (name, shortname, text, public, id, user_name) FROM stdin;
Open Data Commons Public Domain Dedication and License	PDDL	Preamble The Open Data Commons – Public Domain Dedication & Licence is a document intended to allow you to freely share, modify, and use this work for any purpose and without any restrictions. This licence is intended for use on databases or their contents (“data”), either together or individually.\n\nMany databases are covered by copyright. Some jurisdictions, mainly in Europe, have specific special rights that cover databases called the “sui generis” database right. Both of these sets of rights, as well as other legal rights used to protect databases and data, can create uncertainty or practical difficulty for those wishing to share databases and their underlying data but retain a limited amount of rights under a “some rights reserved” approach to licensing as outlined in the Science Commons Protocol for Implementing Open Access Data. As a result, this waiver and licence tries to the fullest extent possible to eliminate or fully license any rights that cover this database and data. Any Community Norms or similar statements of use of the database or data do not form a part of this document, and do not act as a contract for access or other terms of use for the database or data.\n\nThe position of the recipient of the work\n\nBecause this document places the database and its contents in or as close as possible within the public domain, there are no restrictions or requirements placed on the recipient by this document. Recipients may use this work commercially, use technical protection measures, combine this data or database with other databases or data, and share their changes and additions or keep them secret. It is not a requirement that recipients provide further users with a copy of this licence or attribute the original creator of the data or database as a source. The goal is to eliminate restrictions held by the original creator of the data and database on the use of it by others.\n\nThe position of the dedicator of the work\n\nCopyright law, as with most other law under the banner of “intellectual property”, is inherently national law. This means that there exists several differences in how copyright and other IP rights can be relinquished, waived or licensed in the many legal jurisdictions of the world. This is despite much harmonisation of minimum levels of protection. The internet and other communication technologies span these many disparate legal jurisdictions and thus pose special difficulties for a document relinquishing and waiving intellectual property rights, including copyright and database rights, for use by the global community. Because of this feature of intellectual property law, this document first relinquishes the rights and waives the relevant rights and claims. It then goes on to license these same rights for jurisdictions or areas of law that may make it difficult to relinquish or waive rights or claims.\n\nThe purpose of this document is to enable rightsholders to place their work into the public domain. Unlike licences for free and open source software, free cultural works, or open content licences, rightsholders will not be able to “dual license” their work by releasing the same work under different licences. This is because they have allowed anyone to use the work in whatever way they choose. Rightsholders therefore can’t re-license it under copyright or database rights on different terms because they have nothing left to license. Doing so creates truly accessible data to build rich applications and advance the progress of science and the arts.\n\nThis document can cover either or both of the database and its contents (the data). Because databases can have a wide variety of content – not just factual data – rightsholders should use the Open Data Commons – Public Domain Dedication & Licence for an entire database and its contents only if everything can be placed under the terms of this document. Because even factual data can sometimes have intellectual property rights, rightsholders should use this licence to cover both the database and its factual data when making material available under this document, even if it is likely that the data would not be covered by copyright or database rights.\n\nRightsholders can also use this document to cover any copyright or database rights claims over only a database, and leave the contents to be covered by other licences or documents. They can do this because this document refers to the “Work”, which can be either – or both – the database and its contents. As a result, rightsholders need to clearly state what they are dedicating under this document when they dedicate it.\n\nJust like any licence or other document dealing with intellectual property, rightsholders should be aware that one can only license what one owns. Please ensure that the rights have been cleared to make this material available under this document.\n\nThis document permanently and irrevocably makes the Work available to the public for any use of any kind, and it should not be used unless the rightsholder is prepared for this to happen.\n\nPart I: Introduction\n\nThe Rightsholder (the Person holding rights or claims over the Work) agrees as follows:\n\n1.0 Definitions of Capitalised Words\n\n“Copyright” – Includes rights under copyright and under neighbouring rights and similarly related sets of rights under the law of the relevant jurisdiction under Section 6.4.\n\n“Data” – The contents of the Database, which includes the information, independent works, or other material collected into the Database offered under the terms of this Document.\n\n“Database” – A collection of Data arranged in a systematic or methodical way and individually accessible by electronic or other means offered under the terms of this Document.\n\n“Database Right” – Means rights over Data resulting from the Chapter III (“sui generis”) rights in the Database Directive (Directive 96/9/EC of the European Parliament and of the Council of 11 March 1996 on the legal protection of databases) and any future updates as well as any similar rights available in the relevant jurisdiction under Section 6.4.\n\n“Document” – means this relinquishment and waiver of rights and claims and back up licence agreement.\n\n“Person” – Means a natural or legal person or a body of persons corporate or incorporate.\n\n“Use” – As a verb, means doing any act that is restricted by Copyright or Database Rights whether in the original medium or any other, and includes modifying the Work as may be technically necessary to use it in a different mode or format. This includes the right to sublicense the Work.\n\n“Work” – Means either or both of the Database and Data offered under the terms of this Document.\n\n“You” – the Person acquiring rights under the licence elements of this Document.\n\nWords in the singular include the plural and vice versa.\n\n2.0 What this document covers\n\n2.1. Legal effect of this Document. This Document is:\n\na. A dedication to the public domain and waiver of Copyright and Database Rights over the Work, and\n\nb. A licence of Copyright and Database Rights over the Work in jurisdictions that do not allow for relinquishment or waiver.\n\n2.2. Legal rights covered.\n\na. Copyright. Any copyright or neighbouring rights in the Work. Copyright law varies between jurisdictions, but is likely to cover: the Database model or schema, which is the structure, arrangement, and organisation of the Database, and can also include the Database tables and table indexes, the data entry and output sheets, and the Field names of Data stored in the Database. Copyright may also cover the Data depending on the jurisdiction and type of Data, and\n\nb. Database Rights. Database Rights only extend to the extraction and re-utilisation of the whole or a substantial part of the Data. Database Rights can apply even when there is no copyright over the Database. Database Rights can also apply when the Data is removed from the Database and is selected and arranged in a way that would not infringe any applicable copyright.\n\n2.2 Rights not covered.\n\na. This Document does not apply to computer programs used in the making or operation of the Database,\n\nb. This Document does not cover any patents over the Data or the Database. Please see Section 4.2 later in this Document for further details, and\n\nc. This Document does not cover any trade marks associated with the Database. Please see Section 4.3 later in this Document for further details.\n\nUsers of this Database are cautioned that they may have to clear other rights or consult other licences.\n\n2.3 Facts are free. The Rightsholder takes the position that factual information is not covered by Copyright. This Document however covers the Work in jurisdictions that may protect the factual information in the Work by Copyright, and to cover any information protected by Copyright that is contained in the Work.\n\nPart II: Dedication to the public domain\n\n3.0 Dedication, waiver, and licence of Copyright and Database Rights\n\n3.1 Dedication of Copyright and Database Rights to the public domain. The Rightsholder by using this Document, dedicates the Work to the public domain for the benefit of the public and relinquishes all rights in Copyright and Database Rights over the Work.\n\na. The Rightsholder realises that once these rights are relinquished, that the Rightsholder has no further rights in Copyright and Database Rights over the Work, and that the Work is free and open for others to Use.\n\nb. The Rightsholder intends for their relinquishment to cover all present and future rights in the Work under Copyright and Database Rights, whether they are vested or contingent rights, and that this relinquishment of rights covers all their heirs and successors.\n\nThe above relinquishment of rights applies worldwide and includes media and formats now known or created in the future.\n\n3.2 Waiver of rights and claims in Copyright and Database Rights when Section 3.1 dedication inapplicable. If the dedication in Section 3.1 does not apply in the relevant jurisdiction under Section 6.4, the Rightsholder waives any rights and claims that the Rightsholder may have or acquire in the future over the Work in:\n\na. Copyright, and\n\nb. Database Rights.\n\nTo the extent possible in the relevant jurisdiction, the above waiver of rights and claims applies worldwide and includes media and formats now known or created in the future. The Rightsholder agrees not to assert the above rights and waives the right to enforce them over the Work.\n\n3.3 Licence of Copyright and Database Rights when Sections 3.1 and 3.2 inapplicable. If the dedication and waiver in Sections 3.1 and 3.2 does not apply in the relevant jurisdiction under Section 6.4, the Rightsholder and You agree as follows:\n\na. The Licensor grants to You a worldwide, royalty-free, non-exclusive, licence to Use the Work for the duration of any applicable Copyright and Database Rights. These rights explicitly include commercial use, and do not exclude any field of endeavour. To the extent possible in the relevant jurisdiction, these rights may be exercised in all media and formats whether now known or created in the future.\n\n3.4 Moral rights. This section covers moral rights, including the right to be identified as the author of the Work or to object to treatment that would otherwise prejudice the author’s honour and reputation, or any other derogatory treatment:\n\na. For jurisdictions allowing waiver of moral rights, Licensor waives all moral rights that Licensor may have in the Work to the fullest extent possible by the law of the relevant jurisdiction under Section 6.4,\n\nb. If waiver of moral rights under Section 3.4 a in the relevant jurisdiction is not possible, Licensor agrees not to assert any moral rights over the Work and waives all claims in moral rights to the fullest extent possible by the law of the relevant jurisdiction under Section 6.4, and\n\nc. For jurisdictions not allowing waiver or an agreement not to assert moral rights under Section 3.4 a and b, the author may retain their moral rights over the copyrighted aspects of the Work.\n\nPlease note that some jurisdictions do not allow for the waiver of moral rights, and so moral rights may still subsist over the work in some jurisdictions.\n\n4.0 Relationship to other rights\n\n4.1 No other contractual conditions. The Rightsholder makes this Work available to You without any other contractual obligations, either express or implied. Any Community Norms statement associated with the Work is not a contract and does not form part of this Document.\n\n4.2 Relationship to patents. This Document does not grant You a licence for any patents that the Rightsholder may own. Users of this Database are cautioned that they may have to clear other rights or consult other licences.\n\n4.3 Relationship to trade marks. This Document does not grant You a licence for any trade marks that the Rightsholder may own or that the Rightsholder may use to cover the Work. Users of this Database are cautioned that they may have to clear other rights or consult other licences. Part III: General provisions\n\n5.0 Warranties, disclaimer, and limitation of liability\n\n5.1 The Work is provided by the Rightsholder “as is” and without any warranty of any kind, either express or implied, whether of title, of accuracy or completeness, of the presence of absence of errors, of fitness for purpose, or otherwise. Some jurisdictions do not allow the exclusion of implied warranties, so this exclusion may not apply to You.\n\n5.2 Subject to any liability that may not be excluded or limited by law, the Rightsholder is not liable for, and expressly excludes, all liability for loss or damage however and whenever caused to anyone by any use under this Document, whether by You or by anyone else, and whether caused by any fault on the part of the Rightsholder or not. This exclusion of liability includes, but is not limited to, any special, incidental, consequential, punitive, or exemplary damages. This exclusion applies even if the Rightsholder has been advised of the possibility of such damages.\n\n5.3 If liability may not be excluded by law, it is limited to actual and direct financial loss to the extent it is caused by proved negligence on the part of the Rightsholder.\n\n6.0 General\n\n6.1 If any provision of this Document is held to be invalid or unenforceable, that must not affect the cvalidity or enforceability of the remainder of the terms of this Document.\n\n6.2 This Document is the entire agreement between the parties with respect to the Work covered here. It replaces any earlier understandings, agreements or representations with respect to the Work not specified here.\n\n6.3 This Document does not affect any rights that You or anyone else may independently have under any applicable law to make any use of this Work, including (for jurisdictions where this Document is a licence) fair dealing, fair use, database exceptions, or any other legally recognised limitation or exception to infringement of copyright or other applicable laws.\n\n6.4 This Document takes effect in the relevant jurisdiction in which the Document terms are sought to be enforced. If the rights waived or granted under applicable law in the relevant jurisdiction includes additional rights not waived or granted under this Document, these additional rights are included in this Document in order to meet the intent of this Document.\n	t	1	none
\.

--
-- Name: license_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE license_id_seq OWNED BY license.id;


--
-- Name: repl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE repl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE repl_id_seq OWNER TO postgres;

--
-- Name: rpl_journal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rpl_journal (
    id bigint DEFAULT nextval('repl_id_seq'::regclass) NOT NULL,
    table_name character varying(50) NOT NULL,
    row_id bigint NOT NULL,
    opcode character varying(1) NOT NULL,
    time_stamp timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE rpl_journal OWNER TO postgres;

--
-- Name: sbassensor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sbassensor_id_seq
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sbassensor_id_seq OWNER TO postgres;

--
-- Name: sbassensor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE sbassensor (
    vesselconfigid integer NOT NULL,
    x numeric(5,2),
    y numeric(5,2),
    z numeric(5,2),
    sensorid character varying,
    manufacturer character varying(100),
    model character varying(100),
    id bigint DEFAULT nextval('sbassensor_id_seq'::regclass) NOT NULL
);


ALTER TABLE sbassensor OWNER TO postgres;

--
-- Name: seq_tif; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE seq_tif
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seq_tif OWNER TO postgres;

--
-- Name: tmp_tg_user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tmp_tg_user_profiles (
    user_name character varying(256),
    password character varying(40),
    salt character varying(10),
    attempts smallint,
    last_attempt timestamp without time zone,
    forename character varying,
    surname character varying,
    country character varying,
    language character varying,
    organisation character varying,
    phone character varying,
    acceptedemailcontact boolean,
    num_tracks integer
);


ALTER TABLE tmp_tg_user_profiles OWNER TO postgres;

--
-- Name: tmp_tg_user_tracks_2018_12_03; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE tmp_tg_user_tracks_2018_12_03 (
    track_id bigint,
    user_name character varying(40),
    file_ref character varying(255),
    upload_state smallint,
    filetype character varying(80),
    compression character varying(80),
    containertrack integer,
    vesselconfigid integer,
    license integer,
    gauge_name character varying(100),
    gauge numeric(6,2),
    height_ref character varying(100),
    comment character varying,
    watertype character varying(20),
    uploaddate timestamp without time zone,
    bbox geometry
);


ALTER TABLE tmp_tg_user_tracks_2018_12_03 OWNER TO postgres;

--
-- Name: track_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE track_info (
    id bigint DEFAULT nextval('seq_tif'::regclass) NOT NULL,
    tra_id bigint NOT NULL,
    short_info character varying(20),
    long_info character varying,
    reprocess boolean,
    discard boolean,
    ignore boolean
);


ALTER TABLE track_info OWNER TO postgres;

--
-- Name: trackgauges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE trackgauges (
    id integer NOT NULL,
    trackid bigint,
    gaugeid integer,
    source integer
);


ALTER TABLE trackgauges OWNER TO postgres;

--
-- Name: trackgauges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE trackgauges_id_seq
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE trackgauges_id_seq OWNER TO postgres;

--
-- Name: trackgauges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE trackgauges_id_seq OWNED BY trackgauges.id;


--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_profiles_id_seq
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_profiles_id_seq OWNER TO postgres;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE user_profiles (
    user_name character varying(256) NOT NULL,
    password character varying(40),
    salt character varying(10),
    attempts smallint DEFAULT 0 NOT NULL,
    last_attempt timestamp without time zone,
    forename character varying,
    surname character varying,
    country character varying,
    language character varying,
    organisation character varying,
    phone character varying,
    acceptedemailcontact boolean DEFAULT false,
    id bigint DEFAULT nextval('user_profiles_id_seq'::regclass) NOT NULL
);


ALTER TABLE user_profiles OWNER TO postgres;

--
-- Name: user_tracks_track_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_tracks_track_id_seq
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE user_tracks_track_id_seq OWNER TO postgres;

--
-- Name: user_tracks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE user_tracks (
    track_id bigint DEFAULT nextval('user_tracks_track_id_seq'::regclass) NOT NULL,
    user_name character varying(40) NOT NULL,
    file_ref character varying(255),
    upload_state smallint DEFAULT 0,
    filetype character varying(80),
    compression character varying(80),
    containertrack integer,
    vesselconfigid integer,
    license integer,
    gauge_name character varying(100),
    gauge numeric(6,2),
    height_ref character varying(100),
    comment character varying,
    watertype character varying(20),
    uploaddate timestamp without time zone DEFAULT now(),
    bbox geometry,
    clusteruuid character varying,
    clusterseq bigint,
    upr_id bigint NOT NULL,
    num_points integer,
    is_container boolean,
    CONSTRAINT enforce_dims_bbox CHECK ((st_ndims(bbox) = 2)),
    CONSTRAINT enforce_geotype_bbox CHECK (((geometrytype(bbox) = 'POLYGON'::text) OR (bbox IS NULL))),
    CONSTRAINT enforce_srid_bbox CHECK ((st_srid(bbox) = 4326))
);


ALTER TABLE user_tracks OWNER TO postgres;

--
-- Name: userroles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE userroles (
    user_name character varying(250),
    role character varying(15)
);


ALTER TABLE userroles OWNER TO postgres;

--
-- Name: v_user_tracks; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW v_user_tracks AS
 SELECT user_tracks.track_id,
    user_tracks.user_name,
    user_tracks.file_ref,
    user_tracks.upload_state,
    user_tracks.filetype,
    user_tracks.compression,
    user_tracks.containertrack,
    user_tracks.vesselconfigid,
    user_tracks.license,
    user_tracks.gauge_name,
    user_tracks.gauge,
    user_tracks.height_ref,
    user_tracks.comment,
    user_tracks.watertype,
    user_tracks.uploaddate,
    user_tracks.bbox,
    user_tracks.clusteruuid,
    user_tracks.clusterseq,
    user_tracks.upr_id,
    user_tracks.num_points,
    user_tracks.is_container,
    ( SELECT string_agg((((track_info.short_info)::text || ': '::text) || (track_info.long_info)::text), '\n'::text) AS string_agg
           FROM track_info
          WHERE (track_info.tra_id = user_tracks.track_id)) AS track_info,
    st_xmin((user_tracks.bbox)::box3d) AS "left",
    st_xmax((user_tracks.bbox)::box3d) AS "right",
    st_ymax((user_tracks.bbox)::box3d) AS top,
    st_ymin((user_tracks.bbox)::box3d) AS bottom
   FROM user_tracks;


ALTER TABLE v_user_tracks OWNER TO postgres;

--
-- Name: vesselconfiguration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE vesselconfiguration (
    id integer NOT NULL,
    name character varying,
    description character varying,
    user_name character varying,
    mmsi character varying(20),
    manufacturer character varying(100),
    model character varying,
    loa numeric(7,2),
    breadth numeric(7,2),
    draft numeric(4,2),
    height numeric(4,2),
    displacement numeric(8,1),
    maximumspeed numeric(3,1),
    type integer DEFAULT 0,
    upr_id bigint NOT NULL
);


ALTER TABLE vesselconfiguration OWNER TO postgres;

--
-- Name: vesselconfiguration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vesselconfiguration_id_seq
    START WITH 1
    INCREMENT BY 2
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE vesselconfiguration_id_seq OWNER TO postgres;

--
-- Name: vesselconfiguration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vesselconfiguration_id_seq OWNED BY vesselconfiguration.id;


--
-- Name: license id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY license ALTER COLUMN id SET DEFAULT nextval('license_id_seq'::regclass);


--
-- Name: trackgauges id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trackgauges ALTER COLUMN id SET DEFAULT nextval('trackgauges_id_seq'::regclass);


--
-- Name: vesselconfiguration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vesselconfiguration ALTER COLUMN id SET DEFAULT nextval('vesselconfiguration_id_seq'::regclass);


SET search_path = depth_tables, pg_catalog;

--
-- Name: rpl_journal_shadow pk_rpl_j; Type: CONSTRAINT; Schema: depth_tables; Owner: postgres
--

ALTER TABLE ONLY rpl_journal_shadow
    ADD CONSTRAINT pk_rpl_j PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: depthsensor dse_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY depthsensor
    ADD CONSTRAINT dse_pk PRIMARY KEY (id);


--
-- Name: gauge gauge_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY gauge
    ADD CONSTRAINT gauge_pkey PRIMARY KEY (id);


--
-- Name: gaugemeasurement gaugemeasurement_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY gaugemeasurement
    ADD CONSTRAINT gaugemeasurement_unique UNIQUE (gaugeid, "time");


--
-- Name: license license_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY license
    ADD CONSTRAINT license_pkey PRIMARY KEY (id);


--
-- Name: rpl_journal pk_rpl_j; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rpl_journal
    ADD CONSTRAINT pk_rpl_j PRIMARY KEY (id);


--
-- Name: sbassensor sse_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sbassensor
    ADD CONSTRAINT sse_pk PRIMARY KEY (id);


--
-- Name: track_info tif_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY track_info
    ADD CONSTRAINT tif_pk PRIMARY KEY (id);


--
-- Name: trackgauges trackgauges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trackgauges
    ADD CONSTRAINT trackgauges_pkey PRIMARY KEY (id);


--
-- Name: user_profiles upr_name_uk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_profiles
    ADD CONSTRAINT upr_name_uk UNIQUE (user_name);


--
-- Name: user_profiles upr_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_profiles
    ADD CONSTRAINT upr_pk PRIMARY KEY (id);


--
-- Name: user_tracks user_tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_tracks
    ADD CONSTRAINT user_tracks_pkey PRIMARY KEY (track_id);


--
-- Name: vesselconfiguration vesselconfiguration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vesselconfiguration
    ADD CONSTRAINT vesselconfiguration_pkey PRIMARY KEY (id);


SET search_path = depth_tables, pg_catalog;

--
-- Name: rpl_j_s_id_new; Type: INDEX; Schema: depth_tables; Owner: postgres
--

CREATE INDEX rpl_j_s_id_new ON rpl_journal_shadow USING btree (id) WHERE (copied IS NULL);


SET search_path = public, pg_catalog;

--
-- Name: fki_gaugemeasurement_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_gaugemeasurement_fkey ON gaugemeasurement USING btree (gaugeid);


--
-- Name: tif_tra_fk_i; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tif_tra_fk_i ON track_info USING btree (tra_id);


--
-- Name: tmp_tg_user_tracks_2018_12_03_tid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tmp_tg_user_tracks_2018_12_03_tid ON tmp_tg_user_tracks_2018_12_03 USING btree (track_id);


--
-- Name: user_tracks_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_tracks_user ON user_tracks USING btree (user_name);


--
-- Name: utr_upr_fk_i; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX utr_upr_fk_i ON user_tracks USING btree (upr_id);


--
-- Name: utr_utr_fk_i; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX utr_utr_fk_i ON user_tracks USING btree (containertrack);


--
-- Name: utr_vcf_fk_i; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX utr_vcf_fk_i ON user_tracks USING btree (vesselconfigid);


--
-- Name: vcf_upr_fk_i; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX vcf_upr_fk_i ON vesselconfiguration USING btree (upr_id);


--
-- Name: depthsensor rpl_log_dse; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rpl_log_dse AFTER INSERT OR DELETE OR UPDATE ON depthsensor FOR EACH ROW EXECUTE PROCEDURE rpl_log();


--
-- Name: sbassensor rpl_log_sse; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rpl_log_sse AFTER INSERT OR DELETE OR UPDATE ON sbassensor FOR EACH ROW EXECUTE PROCEDURE rpl_log();


--
-- Name: user_profiles rpl_log_upr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rpl_log_upr AFTER INSERT OR DELETE OR UPDATE ON user_profiles FOR EACH ROW EXECUTE PROCEDURE rpl_log();


--
-- Name: user_tracks rpl_log_utr; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rpl_log_utr AFTER INSERT OR DELETE OR UPDATE ON user_tracks FOR EACH ROW EXECUTE PROCEDURE rpl_log();


--
-- Name: vesselconfiguration rpl_log_vcf; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rpl_log_vcf AFTER INSERT OR DELETE OR UPDATE ON vesselconfiguration FOR EACH ROW EXECUTE PROCEDURE rpl_log();


--
-- Name: user_tracks ti_utr_upr_integrity; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ti_utr_upr_integrity BEFORE INSERT ON user_tracks FOR EACH ROW EXECUTE PROCEDURE tif_upr_integrity();


--
-- Name: vesselconfiguration ti_vcf_upr_integrity; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ti_vcf_upr_integrity BEFORE INSERT ON vesselconfiguration FOR EACH ROW EXECUTE PROCEDURE tif_upr_integrity();


--
-- Name: depthsensor depthsoffset_vesselconfigid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY depthsensor
    ADD CONSTRAINT depthsoffset_vesselconfigid_fkey FOREIGN KEY (vesselconfigid) REFERENCES vesselconfiguration(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: trackgauges gauge_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trackgauges
    ADD CONSTRAINT gauge_fkey FOREIGN KEY (gaugeid) REFERENCES gauge(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: gaugemeasurement gaugemeasurement_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY gaugemeasurement
    ADD CONSTRAINT gaugemeasurement_fkey FOREIGN KEY (gaugeid) REFERENCES gauge(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sbassensor sbasoffset_vesselconfigid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sbassensor
    ADD CONSTRAINT sbasoffset_vesselconfigid_fkey FOREIGN KEY (vesselconfigid) REFERENCES vesselconfiguration(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: track_info tif_tra_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY track_info
    ADD CONSTRAINT tif_tra_fk FOREIGN KEY (tra_id) REFERENCES user_tracks(track_id);


--
-- Name: trackgauges trackgauges_trackid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trackgauges
    ADD CONSTRAINT trackgauges_trackid_fkey FOREIGN KEY (trackid) REFERENCES user_tracks(track_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_tracks utr_upr_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_tracks
    ADD CONSTRAINT utr_upr_fk FOREIGN KEY (upr_id) REFERENCES user_profiles(id) ON DELETE CASCADE;


--
-- Name: user_tracks utr_utr_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_tracks
    ADD CONSTRAINT utr_utr_fk FOREIGN KEY (containertrack) REFERENCES user_tracks(track_id);


--
-- Name: user_tracks utr_vcf_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_tracks
    ADD CONSTRAINT utr_vcf_fk FOREIGN KEY (vesselconfigid) REFERENCES vesselconfiguration(id);


--
-- Name: vesselconfiguration vcf_upr_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vesselconfiguration
    ADD CONSTRAINT vcf_upr_fk FOREIGN KEY (upr_id) REFERENCES user_profiles(id) ON DELETE CASCADE;


--
-- Name: depthsensor_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,UPDATE ON SEQUENCE depthsensor_id_seq TO PUBLIC;


--
-- Name: depthsensor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE depthsensor TO admin;


--
-- Name: gauge; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE gauge TO admin;


--
-- Name: gaugemeasurement; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE gaugemeasurement TO admin;


--
-- Name: geography_columns; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE geography_columns TO admin;


--
-- Name: geometry_columns; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE geometry_columns TO admin;


--
-- Name: license; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE license TO admin;


--
-- Name: raster_columns; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE raster_columns TO admin;


--
-- Name: raster_overviews; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE raster_overviews TO admin;


--
-- Name: repl_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,UPDATE ON SEQUENCE repl_id_seq TO admin;


--
-- Name: rpl_journal; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE rpl_journal TO admin;

--
-- Name: sbassensor_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,UPDATE ON SEQUENCE sbassensor_id_seq TO PUBLIC;


--
-- Name: sbassensor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE sbassensor TO admin;


--
-- Name: seq_tif; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,UPDATE ON SEQUENCE seq_tif TO admin;

--
-- Name: spatial_ref_sys; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE spatial_ref_sys TO admin;


--
-- Name: track_info; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE track_info TO admin;


--
-- Name: trackgauges; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE trackgauges TO admin;


--
-- Name: user_profiles_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE user_profiles_id_seq TO PUBLIC;


--
-- Name: user_profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE user_profiles TO admin;


--
-- Name: user_tracks_track_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE user_tracks_track_id_seq TO admin;

--
-- Name: user_tracks; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE user_tracks TO admin;


--
-- Name: userroles; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE userroles TO admin;


--
-- Name: v_user_tracks; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE v_user_tracks TO PUBLIC;


--
-- Name: vesselconfiguration; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE vesselconfiguration TO admin;


--
-- Name: vesselconfiguration_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,UPDATE ON SEQUENCE vesselconfiguration_id_seq TO admin;


--
-- PostgreSQL database dump complete
--
