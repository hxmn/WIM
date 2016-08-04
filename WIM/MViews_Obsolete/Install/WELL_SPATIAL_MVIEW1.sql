-- SCRIPT: Well_Spatial_MView_Install.sql
--
-- PURPOSE:
--   Creates an MVIEW for use by the spatial layer generation for WIM
--
--  Assumptions:
--   None
--
-- DEPENDENCIES
--   PPDM.WELL, WELL_NODE, TLM_R_WELL_STATUS, BUSINESS_ASSOCIATE tables
--
-- EXECUTION:
--   Run as PPDM users on the PET* databases - Usually run through TOAD
--
--   Syntax:
--    N/A
--
-- HISTORY:
--    4-May-10 R. Masterman      Initial version - extracted from the PETP PPDM schema
--    25-Aug-11 N. Grewal	 Added a last update timestamp to the WELL_SPATIAL_MVIEW1 
--				 so the spatial generation team can have the option to just do updates.
--    25-Nov-11 N. Grewal	Added following attributes:
--					a) WELL.WELL_NUM
--					b) WELL.TD_STRAT_*
--					c) WELL.COUNTY - need to link to R_COUNTY too

-- *************************************************************************************
-- Run as PPDM User
-- *************************************************************************************
DROP MATERIALIZED VIEW PPDM.WELL_SPATIAL_MVIEW1;
CREATE MATERIALIZED VIEW PPDM.WELL_SPATIAL_MVIEW1 
TABLESPACE PPDMDATA
PCTUSED    40
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
NOCACHE
NOLOGGING
NOPARALLEL
BUILD DEFERRED
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 8/10/2011 10:26:01 AM (QP5 v5.139.911.3011) */
SELECT w.uwi AS uwi,
       NVL (w.active_ind, 'Y') AS active_ind,
       bn.node_id AS base_node_id,
       NVL (bn.latitude, sn.latitude) AS bottom_hole_latitude,
       NVL (bn.longitude, sn.longitude) AS bottom_hole_longitude,
       w.country AS country,
       c.long_name AS country_name,
       bn.coord_system_id AS coord_system_id_orig,
       NVL (NVL (bn.coord_system_id, sn.coord_system_id),
            DECODE (SUBSTR (w.country, 1, 1), '7', '4267', '4326'))
          AS coord_system_id,
       w.status_type AS status_type,
       NVL (w.current_status, '00000000') AS current_status,
       NVL (tr_ws.short_name, 'UNDEF') AS status_name,
       w.drill_td AS drill_td,
       w.ground_elev AS ground_elev,
       w.kb_elev AS kb_elev,
       w.OPERATOR AS OPERATOR,
       NVL (ba1.ba_name, w.OPERATOR) AS operator_name,
       w.ipl_licensee AS licensee,
       NVL (ba2.ba_name, w.ipl_licensee) AS licensee_name,
       w.parent_uwi AS parent_uwi,
       w.plot_name AS plot_name,
       w.primary_source AS primary_source,
       w.province_state AS province_state,
       w.rig_release_date AS rig_release_date,
       w.spud_date AS spud_date,
       NVL (sn.latitude, bn.latitude) AS surface_latitude,
       NVL (sn.longitude, bn.longitude) AS surface_longitude,
       sn.node_id AS surface_node_id,
       w.well_name AS well_name,
       w.ipl_offshore_ind AS ipl_offshore_ind,
       w.ipl_uwi_local AS ipl_uwi_local,
       w.well_num, 
       w.td_strat_age, w.td_strat_name_set_age, w.td_strat_name_set_id, w.td_strat_unit_id,
       w.county, rc.long_name AS county_name, 
       GREATEST (
	  NVL (w.row_changed_date, NVL (w.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
          NVL (sn.row_changed_date, NVL (sn.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),  
	  NVL (bn.row_changed_date, NVL (bn.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
	  NVL (c.row_changed_date, NVL (c.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
	  NVL (tr_ws.row_changed_date, NVL (tr_ws.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
	  NVL (ba1.row_changed_date, NVL (ba1.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
	  NVL (ba2.row_changed_date, NVL (ba2.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
	  NVL (rc.row_changed_date, NVL (rc.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))))
          AS latest_date
  FROM well w
       INNER JOIN r_country c
          ON w.country = c.country
       LEFT OUTER JOIN well_node sn
          ON w.surface_node_id = sn.node_id
       LEFT OUTER JOIN well_node bn
          ON w.base_node_id = bn.node_id
       LEFT OUTER JOIN tlm_r_well_status tr_ws
          ON w.current_status = tr_ws.status
       LEFT OUTER JOIN business_associate ba1
          ON w.OPERATOR = ba1.business_associate
       LEFT OUTER JOIN business_associate ba2
          ON w.ipl_licensee = ba2.business_associate
       LEFT OUTER JOIN r_county rc
          ON (    w.country = rc.country
	      and w.province_state = rc.province_state
 	      and w.county = rc.county);


COMMENT ON TABLE PPDM.WELL_SPATIAL_MVIEW1 IS 'snapshot table for snapshot PPDM.WELL_SPATIAL_MVIEW1';


-- to refresh execute the following statement in sqlplus (took about 2 hours)
exec dbms_mview.refresh( 'WELL_SPATIAL_MVIEW1', 'C' );



CREATE INDEX PPDM.WSMV1_BA_IDX1 ON PPDM.WELL_SPATIAL_MVIEW1
(OPERATOR)
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

CREATE INDEX PPDM.WSMV1_BA_IDX2 ON PPDM.WELL_SPATIAL_MVIEW1
(LICENSEE)
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

CREATE INDEX PPDM.WSMV1_IDX01 ON PPDM.WELL_SPATIAL_MVIEW1
(STATUS_NAME)
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

CREATE UNIQUE INDEX PPDM.WSMV1_PK ON PPDM.WELL_SPATIAL_MVIEW1
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

CREATE INDEX PPDM.WSMV1_R_C1_IDX ON PPDM.WELL_SPATIAL_MVIEW1
(COUNTRY)
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

CREATE INDEX PPDM.WSMV1_R_PS3_IDX ON PPDM.WELL_SPATIAL_MVIEW1
(COUNTRY, PROVINCE_STATE)
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

CREATE INDEX PPDM.WSMV1_R_S_IDX ON PPDM.WELL_SPATIAL_MVIEW1
(PRIMARY_SOURCE)
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

CREATE INDEX PPDM.WSMV1_R_WS_IDX ON PPDM.WELL_SPATIAL_MVIEW1
(STATUS_TYPE, CURRENT_STATUS)
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


CREATE INDEX PPDM.WSMV1_LD_IDX ON PPDM.WELL_SPATIAL_MVIEW1
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



GRANT SELECT ON PPDM.WELL_SPATIAL_MVIEW1 TO PPDM_BROWSE;

GRANT SELECT ON PPDM.WELL_SPATIAL_MVIEW1 TO PPDM_CHANGE;

GRANT SELECT ON PPDM.WELL_SPATIAL_MVIEW1 TO PPDM_OW;

GRANT SELECT ON PPDM.WELL_SPATIAL_MVIEW1 TO PPDM_READ;

GRANT SELECT ON PPDM.WELL_SPATIAL_MVIEW1 TO PPDM_WRITE;

GRANT SELECT ON PPDM.WELL_SPATIAL_MVIEW1 TO SDP;

GRANT SELECT ON PPDM.WELL_SPATIAL_MVIEW1 TO SDP_PPDM;


--connect to ppdm_read@PETT;
DROP SYNONYM PPDM_READ.WELL_SPATIAL_MVIEW1;

CREATE SYNONYM PPDM_READ.WELL_SPATIAL_MVIEW1 FOR PPDM.WELL_SPATIAL_MVIEW1;

--connect to ppdm_WRITE@PETT;
DROP SYNONYM PPDM_WRITE.WELL_SPATIAL_MVIEW1;

CREATE SYNONYM PPDM_WRITE.WELL_SPATIAL_MVIEW1 FOR PPDM.WELL_SPATIAL_MVIEW1;

--connect to ppdm@PETT;
DROP SYNONYM PPDM.WSMV1;

CREATE SYNONYM PPDM.WSMV1 FOR PPDM.WELL_SPATIAL_MVIEW1;


===============================================================================================

EXEC DBMS_JOB.BROKEN(1081,FALSE);
commit;

execute dbms_job.next_date(1081,to_date('10/09/2011:08:00AM','dd/mm/yyyy:hh:miam'));
commit;


execute dbms_job.interval(1081,'SYSDATE+7');
commit;




--  Job List
select job, last_date, this_date, next_date, what, interval, broken, failures from all_jobs order by next_date;



