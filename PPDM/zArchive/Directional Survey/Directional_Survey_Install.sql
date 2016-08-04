-- SCRIPT: Direction_Survey_Install.sql
--
-- PURPOSE:
--   Installs the components for the new Directional Survey approach.
--   The public directional survey data is provided through IHS in the C_TALISMAN
--   schema. TLM proprietary diractional survey data is loaded using the GeoWIZ
--   tool into a local table in the PPDM schema on PETP. The approach is to take
--   the public Directional Survey data from IHS and merge it with the local TLM
--   data to provide a combined view of all available DIR SRVY data.
--
--   This is implemented as:
--   1) Local tables TLM_DIR_SRVY and TLM_WELL_DIR_SRVY_STATION in PETP are used
--      to store the TLM directional surveys
--   2) Materialized views, updated nightly, store a copy of the public data
--      in PETP to improve performance for accessing the public data
--   3) Views in PETP merge the TLM and public data to offer a combined view
--       of all directional surveys.
--
-- DEPENDENCIES
--   None
--
--
-- EXECUTION:
--   Can be executed from SQLPLUS or Toad
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   15-Apr-10 R. Masterman  Initial version
--   23-Apr-10 R. Masterman  Converted over to all VIEWS to try as speed seems OK
--   10-May-10 R. Masterman  Re-instate the local table creation as we don't need to preserve old loaded data
--   14-May-10 R. Masterman  Added GEOWIZ to the grants
--   23-Aug-10 R. Masterman  Made GEOG_COORD_SYSTEM_ID and LOCATION_QUALIFIER non-null fields
--   20-Sep-10 R. Masterman  Converted IHS_* views to MVIEWs for performance on multiple well selects. Added HINT to views.
--   20-May-11 R. Masterman  Switch to a views on IHS server as MVIEWs failing too often

-----------------------------------
--  Create as VIEWS  - TALISMAN37
----------------------------------

--  Create the views to represent the Public data. These are built as separate views
--  to allow them to be easily replaced by Mviews if performance becomes an issue.
--    The DB Link C_TALISMAN.IHS.INTERNAL.CORP points to the C_TALISMAN schema on IHSDATA hub.
--    The view converts the IHS UWI to a TLM_ID to provide a common key in the UWI column

--  Add an index to WELL_VERSION to support faster view
--  NOTE: May already be created as part of the WELL_COMPLETION, WELL_STRAT or PRODUCTION Installs
--drop index PPDM.WV_AI_IDX;

CREATE INDEX PPDM.WV_AI_IDX ON PPDM.WELL_VERSION
(UWI, SOURCE, ACTIVE_IND, IPL_UWI_LOCAL)
NOLOGGING;

-- Create the views
CREATE OR REPLACE FORCE VIEW TALISMAN37.IHS_WELL_DIR_SRVY
AS
SELECT /*+ RULE */ 
       WV.UWI,
       WDS.survey_id,
       WDS.SOURCE,
       WDS.active_ind,
       WDS.azimuth_north_type,
       WDS.base_depth,
       WDS.base_depth_ouom,
       WDS.compute_method,
       WDS.coord_system_id,
       WDS.dir_survey_class,
       WDS.effective_date,
       WDS.ew_direction,
       WDS.expiry_date,
       WDS.magnetic_declination,
       WDS.offset_north_type,
       WDS.plane_of_proposal,
       WDS.ppdm_guid,
       WDS.record_mode,
       WDS.remark,
       WDS.report_apd,
       WDS.report_log_datum,
       WDS.report_log_datum_elev,
       WDS.report_log_datum_elev_ouom,
       WDS.report_perm_datum,
       WDS.report_perm_datum_elev,
       WDS.report_perm_datum_elev_ouom,
       WDS.source_document,
       WDS.survey_company,
       WDS.survey_date,
       WDS.survey_numeric_id,
       WDS.survey_quality,
       WDS.survey_type,
       WDS.top_depth,
       WDS.top_depth_ouom,
       WDS.row_changed_by,
       WDS.row_changed_date,
       WDS.row_created_by,
       WDS.row_created_date,
       WDS.row_quality,
       WDS.province_state,
       ' ' as X_ORIG_DOCUMENT
FROM WELL_DIR_SRVY@C_TALISMAN.IHS.INTERNAL.CORP WDS, Well_Version WV
WHERE WV.IPL_UWI_LOCAL = WDS.UWI
  AND WV.source = '300IPL'
  AND wv.active_ind = 'Y';

--  Survey Station View

CREATE OR REPLACE VIEW TALISMAN37.IHS_WELL_DIR_SRVY_STN
AS
SELECT /*+ RULE */
       WV.UWI,
       WDSS.survey_id,
       WDSS.SOURCE,
       WDSS.depth_obs_no,
       WDSS.active_ind,
       WDSS.azimuth,
       WDSS.azimuth_ouom,
       WDSS.dog_leg_severity,
       WDSS.effective_date,
       WDSS.ew_direction,
       WDSS.expiry_date,
       WDSS.inclination,
       WDSS.inclination_ouom,
       WDSS.latitude,
       WDSS.longitude,
       WDSS.ns_direction,
       WDSS.point_type,
       WDSS.ppdm_guid,
       WDSS.remark,
       WDSS.station_id,
       WDSS.station_md,
       WDSS.station_md_ouom,
       WDSS.station_tvd,
       WDSS.station_tvd_ouom,
       WDSS.vertical_section,
       WDSS.vertical_section_ouom,
       WDSS.x_offset,
       WDSS.x_offset_ouom,
       WDSS.y_offset,
       WDSS.y_offset_ouom,
       WDSS.row_changed_by,
       WDSS.row_changed_date,
       WDSS.row_created_by,
       WDSS.row_created_date,
       WDSS.row_quality,
       WDSS.geog_coord_system_id,
       WDSS.province_state,
       WDSS.location_qualifier
FROM WELL_DIR_SRVY_STATION@C_TALISMAN.IHS.INTERNAL.CORP WDSS, Well_Version WV
WHERE WDSS.UWI = WV.IPL_UWI_LOCAL
  AND WV.source = '300IPL'
  AND wv.active_ind = 'Y';


--  Test the new views - compare the new view and the source table
select * from IHS_WELL_DIR_SRVY;
select * from WELL_DIR_SRVY@C_TALISMAN.IHS.INTERNAL.CORP; 

select * from IHS_WELL_DIR_SRVY_STN;
select * from WELL_DIR_SRVY_STATION@C_TALISMAN.IHS.INTERNAL.CORP; 

--  Create the local tables

-- Remove existing table - commented out to avoid accidental dropping of tables
--DROP TABLE PPDM.TLM_WELL_DIR_SRVY CASCADE CONSTRAINTS;

CREATE TABLE TLM_WELL_DIR_SRVY
(
  UWI                          VARCHAR2(20 BYTE) NOT NULL,
  SURVEY_ID                    VARCHAR2(20 BYTE) NOT NULL,
  SOURCE                       VARCHAR2(20 BYTE) NOT NULL,
  ACTIVE_IND                   VARCHAR2(1 BYTE),
  AZIMUTH_NORTH_TYPE           VARCHAR2(20 BYTE),
  BASE_DEPTH                   NUMBER(10,5),
  BASE_DEPTH_OUOM              VARCHAR2(20 BYTE),
  COMPUTE_METHOD               VARCHAR2(20 BYTE),
  COORD_SYSTEM_ID              VARCHAR2(20 BYTE),
  DIR_SURVEY_CLASS             VARCHAR2(20 BYTE),
  EFFECTIVE_DATE               DATE,
  EW_DIRECTION                 VARCHAR2(20 BYTE),
  EXPIRY_DATE                  DATE,
  MAGNETIC_DECLINATION         NUMBER(4,2),
  OFFSET_NORTH_TYPE            VARCHAR2(20 BYTE),
  PLANE_OF_PROPOSAL            NUMBER(10,6),
  PPDM_GUID                    VARCHAR2(38 BYTE),
  RECORD_MODE                  VARCHAR2(20 BYTE),
  REMARK                       VARCHAR2(2000 BYTE),
  REPORT_APD                   NUMBER(10,5),
  REPORT_LOG_DATUM             VARCHAR2(20 BYTE),
  REPORT_LOG_DATUM_ELEV        NUMBER(10,5),
  REPORT_LOG_DATUM_ELEV_OUOM   VARCHAR2(20 BYTE),
  REPORT_PERM_DATUM            VARCHAR2(20 BYTE),
  REPORT_PERM_DATUM_ELEV       NUMBER(10,5),
  REPORT_PERM_DATUM_ELEV_OUOM  VARCHAR2(20 BYTE),
  SOURCE_DOCUMENT              VARCHAR2(20 BYTE),
  SURVEY_COMPANY               VARCHAR2(20 BYTE),
  SURVEY_DATE                  DATE,
  SURVEY_NUMERIC_ID            NUMBER(12),
  SURVEY_QUALITY               VARCHAR2(20 BYTE),
  SURVEY_TYPE                  VARCHAR2(20 BYTE),
  TOP_DEPTH                    NUMBER(10,5),
  TOP_DEPTH_OUOM               VARCHAR2(20 BYTE),
  ROW_CHANGED_BY               VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE             DATE,
  ROW_CREATED_BY               VARCHAR2(30 BYTE),
  ROW_CREATED_DATE             DATE,
  ROW_QUALITY                  VARCHAR2(20 BYTE),
  PROVINCE_STATE               VARCHAR2(20 BYTE),
  X_ORIG_DOCUMENT              VARCHAR2(1024 BYTE)
);

COMMENT ON TABLE TLM_WELL_DIR_SRVY IS 'WELL DIRECTIONAL SURVEY: Talisman proprietary Well Directional Survey table contains header information about directional surveys which have   been performed on a wellbore. This downhole survey charts the   degree of departure of the wellbore from vertical and  the direction  of departure.  Since many directional surveys can be conducted on   a wellbore, the survey number is included as part of the primary key  to uniquely identify the survey.      ';

CREATE UNIQUE INDEX TWDS_PK ON TLM_WELL_DIR_SRVY
(UWI, SURVEY_ID, SOURCE);

CREATE UNIQUE INDEX TWDS_UK ON TLM_WELL_DIR_SRVY
(SURVEY_NUMERIC_ID, UWI, SURVEY_ID, SOURCE);

ALTER TABLE TLM_WELL_DIR_SRVY
  ADD (CONSTRAINT TWDS_PK
          PRIMARY KEY (UWI, SURVEY_ID, SOURCE)
          USING INDEX,
       CONSTRAINT TWDS_UK
          UNIQUE (SURVEY_NUMERIC_ID, UWI, SURVEY_ID, SOURCE)
          USING INDEX 
      );

--CREATE TABLE TLM_WELL_DIR_SRVY_STATION;
--DROP TABLE PPDM.TLM_WELL_DIR_SRVY_STATION CASCADE CONSTRAINTS;

CREATE TABLE TLM_WELL_DIR_SRVY_STATION
(
  UWI                    VARCHAR2(20 BYTE)      NOT NULL,
  SURVEY_ID              VARCHAR2(20 BYTE)      NOT NULL,
  SOURCE                 VARCHAR2(20 BYTE)      NOT NULL,
  DEPTH_OBS_NO           NUMBER(8),
  ACTIVE_IND             VARCHAR2(1 BYTE),
  AZIMUTH                NUMBER(5,2),
  AZIMUTH_OUOM           VARCHAR2(20 BYTE),
  DOG_LEG_SEVERITY       NUMBER(5,2),
  EFFECTIVE_DATE         DATE,
  EW_DIRECTION           VARCHAR2(20 BYTE),
  EXPIRY_DATE            DATE,
  INCLINATION            NUMBER(5,2),
  INCLINATION_OUOM       VARCHAR2(20 BYTE),
  LATITUDE               NUMBER(12,7),
  LONGITUDE              NUMBER(12,7),
  NS_DIRECTION           VARCHAR2(20 BYTE),
  POINT_TYPE             VARCHAR2(20 BYTE),
  PPDM_GUID              VARCHAR2(38 BYTE),
  REMARK                 VARCHAR2(2000 BYTE),
  STATION_ID             VARCHAR2(20 BYTE),
  STATION_MD             NUMBER(10,5),
  STATION_MD_OUOM        VARCHAR2(20 BYTE),
  STATION_TVD            NUMBER(10,5),
  STATION_TVD_OUOM       VARCHAR2(20 BYTE),
  VERTICAL_SECTION       NUMBER(15,2),
  VERTICAL_SECTION_OUOM  VARCHAR2(20 BYTE),
  X_OFFSET               NUMBER(7,2),
  X_OFFSET_OUOM          VARCHAR2(20 BYTE),
  Y_OFFSET               NUMBER(7,2),
  Y_OFFSET_OUOM          VARCHAR2(20 BYTE),
  ROW_CHANGED_BY         VARCHAR2(30 BYTE),
  ROW_CHANGED_DATE       DATE,
  ROW_CREATED_BY         VARCHAR2(30 BYTE),
  ROW_CREATED_DATE       DATE,
  ROW_QUALITY            VARCHAR2(20 BYTE),
  GEOG_COORD_SYSTEM_ID   VARCHAR2(20 BYTE),
  PROVINCE_STATE         VARCHAR2(20 BYTE),
  LOCATION_QUALIFIER     VARCHAR2(20 BYTE)
);

COMMENT ON TABLE TLM_WELL_DIR_SRVY_STATION IS 'WELL DIRECTIONAL SURVEY STATION: The Talisman proprietary Well Directional Survey table records the individual directional survey points along the wellbore during a downhole survey. The measurements at the survey points record the inclination from the vertical   axis that the wellbore trends and the clockwise departure of the survey point from the north reference used in the directional survey. This table allows for multiple survey points or stations. Included as part of the primary keys are dire  ctional survey number and measured depth from the elevation reference datum to the specific survey point.      ';


CREATE UNIQUE INDEX TWDSS_PK ON TLM_WELL_DIR_SRVY_STATION
(UWI, SURVEY_ID, SOURCE, DEPTH_OBS_NO);

ALTER TABLE TLM_WELL_DIR_SRVY_STATION
 ADD (CONSTRAINT TWDSS_PK
         PRIMARY KEY (UWI, SURVEY_ID, SOURCE, DEPTH_OBS_NO)
         USING INDEX 
     );


--  New Constraints added after the main install
alter table TLM_WELL_DIR_SRVY_STATION modify LOCATION_QUALIFIER not null;
alter table TLM_WELL_DIR_SRVY_STATION modify GEOG_COORD_SYSTEM_ID not null;


-------------------------------------
--  Create the combined views in PET*
-------------------------------------


--  Create the local views to combine the public and TLM data
--  This assumes we no longer have a WELL_DIR_SRVY table as this would cause a name clash 
create or replace view PPDM.WELL_DIR_SRVY AS
select * from tlm_well_dir_srvy
  union all
select * from TALISMAN37.IHS_WELL_DIR_SRVY@TLM37.WORLD;

--  Create the local view to combine the public and TLM data
create or replace view PPDM.WELL_DIR_SRVY_STATION AS
select * from PPDM.tlm_well_dir_srvy_station
union all
select * from TALISMAN37.IHS_WELL_DIR_SRVY_STN@TLM37.WORLD;


-- *********************************
-- GRANT ACCESS to the new objects
-- *********************************

--  Grant Access to the other users - this list needs to be reviewed but they are the
--   current users with access to re-create for now

-- Read Access
GRANT SELECT ON WELL_DIR_SRVY TO SDP_PPDM, PPDM_BROWSE, PPDM_WRITE, EDIOS_ADMIN, GEOWIZ, GEOWIZ_SURVEY;
GRANT SELECT ON WELL_DIR_SRVY_STATION TO SDP_PPDM, PPDM_BROWSE, PPDM_WRITE, EDIOS_ADMIN, GEOWIZ, GEOWIZ_SURVEY,;
GRANT SELECT ON TLM_WELL_DIR_SRVY TO SDP_PPDM, PPDM_BROWSE, PPDM_WRITE, EDIOS_ADMIN, GEOWIZ, GEOWIZ_SURVEY;
GRANT SELECT ON TLM_WELL_DIR_SRVY_STATION TO SDP_PPDM, PPDM_BROWSE, PPDM_WRITE, EDIOS_ADMIN, GEOWIZ, GEOWIZ_SURVEY;

-- Write Access
GRANT INSERT,UPDATE,DELETE ON PPDM.TLM_WELL_DIR_SRVY TO GEOWIZ_SURVEY;
GRANT INSERT,UPDATE,DELETE ON PPDM.TLM_WELL_DIR_SRVY_STATION TO GEOWIZ_SURVEY;

-- ************************
-- TESTING
-- ************************

--  Test the new views - some of these take a long time to run
select count(1) from IHS_WELL_DIR_SRVY;
select count(1) from TLM_WELL_DIR_SRVY;
select count(1) from WELL_DIR_SRVY; -- should total sum of above

select * from WELL_DIR_SRVY;
select * from IHS_WELL_DIR_SRVY@tlm37.world;
select * from C_TALISMAN.WELL_DIR_SRVY@ihsdata.world;


--  test a sample - TLMID 132612 = UWI 100050305219W500
select * from TLM_WELL_DIR_SRVY  where uwi = '132612';   -- Local
select * from WELL_DIR_SRVY@ihsdata.world where uwi = '100050305219W500';  -- Remote
select * from TALISMAN37.IHS_WELL_DIR_SRVY@TLM37.WORLD where uwi = '132612';  -- View of remote
select * from WELL_DIR_SRVY where uwi = '132612'; -- Combined view
select * from WELL_DIR_SRVY@tlm37.world where uwi = '132612';   -- Old dataset

--  Test typical DF type inventory list creation - 7.5 minutes on PETT/PETD
select uwi, count(1)
  from WELL_DIR_SRVY
 group by uwi;

--  Test the new SRVY Station view - very slow, not representative and not recommended to try these
--select count(1) from WELL_DIR_SRVY_STATION;
--select count(1) from WELL_DIR_SRVY_STATION@tlm37.world;
--select count(1) from WELL_DIR_SRVY_STATION@ihsdata.world;

select * from WELL_DIR_SRVY_STATION;
select * from IHS_WELL_DIR_SRVY_STN@TLM37.WORLD;

select * from IHS_WELL_DIR_SRVY_STN@TLM37.WORLD where uwi = '132612';
select * from TLM_WELL_DIR_SRVY_STATION where uwi = '132612';
select * from WELL_DIR_SRVY_STATION where uwi = '132612';

select * from WELL_DIR_SRVY_STATION@tlm37.world where uwi = '132612';  -- OLD Dataset
select * from WELL_DIR_SRVY_STATION@ihsdata.world where uwi = '100050305219W500';


-------------------------------------------------------------------------------------
-- Performance Test
-------------------------------------------------------------------------------------

select count(1) from well_dir_srvy;  -- 1-2s
select count(1) from well_dir_srvy_station; -- 5 mins

select * from well_dir_srvy where uwi in ('70241','70242','70242','70243','70244','70245','70246','70247','142673' );  -- 1s
select * from well_dir_srvy_station where uwi in ('70241','70242','70243','70244','70245','70246','70247', '142673');  -- 1s

select UWI, count(1) COUNT from well_dir_srvy group by UWI;  -- 1s


--  End of Main Script
