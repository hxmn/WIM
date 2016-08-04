DROP MATERIALIZED VIEW SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV;
CREATE MATERIALIZED VIEW SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV (UWI,LATITUDE,LONGITUDE,STATION_TVD,STATION_MD,DEPTH_DATUM_ELEV,GEOG_COORD_SYSTEM_ID,SURVEY_ID,SOURCE,KB_ELEV,LATEST_DATE)
TABLESPACE APP_DATA
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 30/04/2013 10:42:45 AM (QP5 v5.227.12220.39754) */
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
          NVL (
             w.row_changed_date,
             NVL (w.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
          NVL (
             wdss.row_changed_date,
             NVL (wdss.row_created_date,
                  TO_DATE ('0001-01-01', 'yyyy-mm-dd'))))
          AS latest_date
  FROM tlm_well_dir_srvy_station wdss JOIN Well W ON w.uwi = wdss.uwi;


COMMENT ON MATERIALIZED VIEW SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV IS 'snapshot table for snapshot SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV';

CREATE OR REPLACE SYNONYM SPATIAL_APPL.TLM_WELL_DIR_SRVY_SPATIAL_MV FOR SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV;

GRANT SELECT ON SPATIAL.TLM_WELL_DIR_SRVY_SPATIAL_MV TO R_SPATIAL;
