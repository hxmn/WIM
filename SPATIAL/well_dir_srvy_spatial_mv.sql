DROP SYNONYM SPATIAL_APPL.WELL_DIR_SRVY_SPATIAL_MV;

CREATE SYNONYM SPATIAL_APPL.WELL_DIR_SRVY_SPATIAL_MV FOR WELL_DIR_SRVY_SPATIAL_MV;


DROP MATERIALIZED VIEW WELL_DIR_SRVY_SPATIAL_MV;
CREATE MATERIALIZED VIEW WELL_DIR_SRVY_SPATIAL_MV 
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
/* Formatted on 2013/03/08 10:08 (Formatter Plus v4.8.8) */
SELECT w.uwi, wdss.latitude, wdss.longitude, wdss.station_tvd,
       wdss.station_md, w.depth_datum_elev, wdss.geog_coord_system_id,
       wdss.survey_id, wdss.SOURCE, w.kb_elev,
       GREATEST (NVL (w.row_created_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
                 NVL (w.row_changed_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
                 NVL (wdss.row_created_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')
                     ),
                 NVL (wdss.row_changed_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')
                     )
                ) AS latest_date
  FROM tlm_well_dir_srvy_station wdss JOIN well w ON w.uwi = wdss.uwi
UNION ALL
SELECT w.uwi, wdss.latitude, wdss.longitude, wdss.station_tvd,
       wdss.station_md, w.depth_datum_elev, wdss.geog_coord_system_id,
       wdss.survey_id, wdss.SOURCE, w.kb_elev,
       GREATEST (NVL (w.row_created_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
                 NVL (w.row_changed_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')),
                 NVL (wdss.row_created_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')
                     ),
                 NVL (wdss.row_changed_date,
                      TO_DATE ('0001-01-01', 'yyyy-mm-dd')
                     )
                ) AS latest_date
  FROM well_dir_srvy_station@c_talisman_ihsdata wdss JOIN well w
       ON w.ipl_uwi_local = wdss.uwi;

COMMENT ON MATERIALIZED VIEW WELL_DIR_SRVY_SPATIAL_MV IS 'snapshot table for snapshot SPATIAL.WELL_DIR_SRVY_SPATIAL_MV';

CREATE INDEX WDSSMV1_LD_IDX ON WELL_DIR_SRVY_SPATIAL_MV
(LATEST_DATE)
NOLOGGING
TABLESPACE APP_INDEXES
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
NOPARALLEL;

CREATE INDEX WDSSMV1_SID_IDX ON WELL_DIR_SRVY_SPATIAL_MV
(SURVEY_ID)
NOLOGGING
TABLESPACE APP_INDEXES
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
NOPARALLEL;

CREATE INDEX WDSSMV1_S_IDX ON WELL_DIR_SRVY_SPATIAL_MV
(SOURCE)
NOLOGGING
TABLESPACE APP_INDEXES
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
NOPARALLEL;

CREATE INDEX WDSSMV1_UWI_IDX ON WELL_DIR_SRVY_SPATIAL_MV
(UWI)
NOLOGGING
TABLESPACE APP_INDEXES
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
NOPARALLEL;

GRANT SELECT ON WELL_DIR_SRVY_SPATIAL_MV TO R_SPATIAL;

