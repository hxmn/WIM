DROP SYNONYM PPDM_READ.WELL_DIR_SRVY_SPATIAL_MVIEW;

CREATE SYNONYM PPDM_READ.WELL_DIR_SRVY_SPATIAL_MVIEW FOR PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW;


DROP MATERIALIZED VIEW PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW;
CREATE MATERIALIZED VIEW PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW 
TABLESPACE PPDMDATA
PCTUSED    40
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
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
/* Formatted on 1/25/2012 8:42:21 AM (QP5 v5.139.911.3011) */
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
  FROM tlm_well_dir_srvy_station wdss JOIN ppdm.Well W ON w.uwi = wdss.uwi;

COMMENT ON TABLE PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW IS 'snapshot table for snapshot PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW';

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

GRANT SELECT ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW TO PPDM_BROWSE;

GRANT SELECT ON PPDM.WELL_DIR_SRVY_SPATIAL_MVIEW TO PPDM_READ;


--  Add a new job
DECLARE
  JOBNO BINARY_INTEGER;
BEGIN
 DBMS_JOB.SUBMIT (JOB=>JOBNO,
                    WHAT=> 'dbms_mview.refresh( ' || '''WELL_DIR_SRVY_SPATIAL_MVIEW''' || ',' || '''C''' || ');' ,
                    NEXT_DATE => to_date('26/01/2012:01:00AM','dd/mm/yyyy:hh:miam'),
                    INTERVAL => 'TRUNC(SYSDATE+1)+1/24');
 commit;
END;
