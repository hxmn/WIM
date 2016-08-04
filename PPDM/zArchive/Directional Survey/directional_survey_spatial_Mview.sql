-- SCRIPT: Direction_Survey_Spatial_MView_Install.sql
--
-- PURPOSE:
--   Installs a summary Mview for use in generating the spatial layers which show
--   the Directional Survey data.
--
-- DEPENDENCIES
--   None
--
-- EXECUTION:
--   Run as PPDM users on the PET* databases - Usually run through TOAD
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   09-Jun-10 	R. Masterman  	Initial version
--   16-Nov-10 	R. Masterman  	New query for the view now GeoWiz loadds coord system into station table
--   18-Nov-10 	R. Masterman  	Dropped Loc Qual and added filter for IHS Loc Quals
--   10-Jan-11 	R. Masterman  	Converted to just TLM DIR SRVYS (OPTION 3) for now for performance. Keep structure so we can revert back if required.
--   23-Feb-11 	R. Masterman  	Added KB to the view
--   23-Sept-11	N. Grewal 	Full TLM & IHS merged view with timestamp
--   29-Sept-11 N. Grewal	convert from view to Mview for better performance.


-- *************************************************************************************
-- Run as PPDM User
-- Create the Mview
- Full TLM & IHS merged Mview
-- *************************************************************************************

DROP MATERIALIZED VIEW PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW;
CREATE MATERIALIZED VIEW PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 9/30/2011 1:13:55 PM (QP5 v5.139.911.3011) */
SELECT w.uwi,
       wdss.latitude,
       wdss.longitude,
       wdss.station_tvd,
       wdss.station_md,
       w.depth_datum_elev,
       wdss.geog_coord_system_id,
       wdss.survey_id,
       wdss.SOURCE,
       w.kb_elev,
       GREATEST (
          NVL (w.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
          NVL (w.row_changed_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
          NVL (wdss.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
          NVL (wdss.row_changed_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')))
          AS latest_date
  FROM tlm_well_dir_srvy_station wdss JOIN Well W ON w.uwi = wdss.uwi
UNION ALL
SELECT w.uwi,
       wdss.latitude,
       wdss.longitude,
       wdss.station_tvd,
       wdss.station_md,
       w.depth_datum_elev,
       wdss.geog_coord_system_id,
       wdss.survey_id,
       wdss.SOURCE,
       w.kb_elev,
       GREATEST (
          NVL (w.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
          NVL (w.row_changed_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
          NVL (wdss.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
          NVL (wdss.row_changed_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')))
          AS latest_date
  FROM    well_dir_srvy_station@ihsdata.world wdss
       JOIN
          Well W
       ON w.ipl_uwi_local = wdss.uwi;

COMMENT ON TABLE PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW IS 'snapshot table for snapshot PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW';


CREATE INDEX PPDM.WDSSMV1_UWI_IDX ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW
(UWI)
NOLOGGING
TABLESPACE PPDMDATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;

CREATE INDEX PPDM.WDSSMV1_S_IDX ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW
(SOURCE)
NOLOGGING
TABLESPACE PPDMDATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX PPDM.WDSSMV1_SID_IDX ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW
(SURVEY_ID)
NOLOGGING
TABLESPACE PPDMDATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX PPDM.WDSSMV1_LD_IDX ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW
(LATEST_DATE)
NOLOGGING
TABLESPACE PPDMDATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


-- Set up Access
GRANT SELECT ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW TO PPDM_BROWSE;
GRANT SELECT ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW TO PPDM_READ;