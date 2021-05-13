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
