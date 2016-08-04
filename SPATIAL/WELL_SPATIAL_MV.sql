/*--------------------------------------------------------------------------------------------------
Script: SPATIAL.Well_Spatial_MV

History:
    March 8, 2013         Updated to show well_name as plot_name if Plot_name is Null

    2014-01-10 cdong      TIS Tasks 1031, 1273, and 1357  
         Modify materialized view SPATIAL.WELL_SPATIAL_MV to include additional columns
          talisman_interest_fg
          location_population
          base_coord_system_id (replacing coord_system_id_orig)
          surface_coord_system_id (replacing coord_system_id)
          surface_location_accuracy
          bottom_hole_location_accuracy
          location_qa_document
  

  Run this from the SPATIAL schema

----------------------------------------------------------------------------------------------------*/

TRUNCATE TABLE SPATIAL.WELL_SPATIAL_MV;
DROP MATERIALIZED VIEW SPATIAL.WELL_SPATIAL_MV;


CREATE MATERIALIZED VIEW SPATIAL.WELL_SPATIAL_MV (UWI,ACTIVE_IND,TALISMAN_INTEREST_FG,LOCATION_POPULATION,BASE_NODE_ID,BOTTOM_HOLE_LATITUDE,BOTTOM_HOLE_LONGITUDE,COUNTRY,COUNTRY_NAME,BASE_COORD_SYSTEM_ID,SURFACE_COORD_SYSTEM_ID,STATUS_TYPE,CURRENT_STATUS,STATUS_NAME,DRILL_TD,GROUND_ELEV,KB_ELEV,OPERATOR,OPERATOR_NAME,LICENSEE,LICENSEE_NAME,PARENT_UWI,PLOT_NAME,PRIMARY_SOURCE,PROVINCE_STATE,RIG_RELEASE_DATE,SPUD_DATE,SURFACE_LATITUDE,SURFACE_LONGITUDE,SURFACE_NODE_ID,WELL_NAME,IPL_OFFSHORE_IND,IPL_UWI_LOCAL,WELL_NUM,TD_STRAT_AGE,TD_STRAT_NAME_SET_AGE,TD_STRAT_NAME_SET_ID,TD_STRAT_UNIT_ID,COUNTY,COUNTY_NAME,LATEST_DATE,SURFACE_LOCATION_ACCURACY,BOTTOM_HOLE_LOCATION_ACCURACY,LOCATION_QA_DOCUMENT)
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

SELECT w.uwi AS uwi,
       NVL (w.active_ind, 'Y') AS ACTIVE_IND,
       DECODE (wv.uwi, NULL, 'N', 'Y') AS TALISMAN_INTEREST_FG,
       DECODE (bn.node_id,
               NULL, 'SURFACE',
               DECODE (sn.node_id, NULL, 'BASE', 'BOTH')) AS LOCATION_POPULATION,
       --if bottom hole location doesn't exist, get surface node
       NVL (bn.node_id, sn.node_id) AS BASE_NODE_ID,
       NVL (bn.latitude, sn.latitude) AS BOTTOM_HOLE_LATITUDE,
       NVL (bn.longitude, sn.longitude) AS BOTTOM_HOLE_LONGITUDE,
       w.country AS country,
       c.long_name AS country_name,
       --if no bottom hole coord sys, get surface coord sys
       NVL (bn.coord_system_id, sn.coord_system_id) AS BASE_COORD_SYSTEM_ID,
       --if no surface coord sys, get bottom hole coord sys 
       NVL (sn.coord_system_id, bn.coord_system_id) AS SURFACE_COORD_SYSTEM_ID,
       w.status_type AS STATUS_TYPE,
       NVL (w.current_status, '00000000') AS CURRENT_STATUS,
       NVL (r_ws.short_name, 'UNDEF') AS STATUS_NAME,
       w.drill_td AS DRILL_TD,
       w.ground_elev AS GROUND_ELEV,
       w.kb_elev AS KB_ELEV,
       w.OPERATOR AS OPERATOR,
       NVL (ba1.ba_name, w.OPERATOR) AS OPERATOR_NAME,
       w.ipl_licensee AS LICENSEE,
       NVL (ba2.ba_name, w.ipl_licensee) AS LICENSEE_NAME,
       w.parent_uwi AS PARENT_UWI,
       NVL (w.plot_name, w.well_name) AS PLOT_NAME,
       w.primary_source AS PRIMARY_SOURCE,
       w.province_state AS PROVINCE_STATE,
       w.rig_release_date AS RIG_RELEASE_DATE,
       w.spud_date AS SPUD_DATE,
       --if surface location doesn't exist, get bottom hole
       NVL (sn.latitude, bn.latitude) AS SURFACE_LATITUDE,
       NVL (sn.longitude, bn.longitude) AS SURFACE_LONGITUDE,
       NVL (sn.node_id, bn.node_id) AS SURFACE_NODE_ID,
       w.well_name AS WELL_NAME,
       w.ipl_offshore_ind AS IPL_OFFSHORE_IND,
       w.ipl_uwi_local AS IPL_UWI_LOCAL,
       w.well_num,
       w.td_strat_age,
       w.td_strat_name_set_age,
       w.td_strat_name_set_id,
       w.td_strat_unit_id,
       w.county,
       rc.long_name AS COUNTY_NAME,
       GREATEST (
           NVL (
               w.row_changed_date,
               NVL (w.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
           NVL (
               sn.row_changed_date,
               NVL (sn.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
           NVL (
               bn.row_changed_date,
               NVL (bn.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
           NVL (
               c.row_changed_date,
               NVL (c.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
           NVL (
               r_ws.row_changed_date,
               NVL (r_ws.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
           NVL (
               ba1.row_changed_date,
               NVL (ba1.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
           NVL (
               ba2.row_changed_date,
               NVL (ba2.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd'))),
           NVL (
               rc.row_changed_date,
               NVL (rc.row_created_date, TO_DATE ('0001-01-01', 'yyyy-mm-dd')))
       ) AS LATEST_DATE,
       w.SURFACE_LOCATION_ACCURACY,
       w.BOTTOM_HOLE_LOCATION_ACCURACY,
       DM.DOCNUMBER AS LOCATION_QA_DOCUMENT
  FROM well w
       INNER JOIN r_country c ON w.country = c.country
       LEFT OUTER JOIN well_node sn
          ON (    w.surface_node_id = sn.node_id
              --ensure that coord sys is not undefined or null
              AND NVL (sn.geog_coord_system_id, '9999') <> '9999')
       LEFT OUTER JOIN well_node bn
          ON (    w.base_node_id = bn.node_id
              --ensure that coord sys is not undefined or null
              AND NVL (bn.geog_coord_system_id, '9999') <> '9999')
       LEFT OUTER JOIN (  SELECT status,
                                 MAX (short_name) AS short_name,
                                 MAX (row_created_date) AS row_created_date,
                                 MAX (row_changed_date) AS row_changed_date
                            FROM r_well_status
                        GROUP BY status) r_ws ON w.current_status = r_ws.status
       LEFT OUTER JOIN business_associate ba1 ON w.OPERATOR = ba1.business_associate
       LEFT OUTER JOIN business_associate ba2 ON w.ipl_licensee = ba2.business_associate
       LEFT OUTER JOIN r_county rc 
          ON (    w.country = rc.country
              AND w.province_state = rc.province_state
              AND w.county = rc.county)
       --to determine if well is of talisman interest (set talisman_interest_fg)
       LEFT OUTER JOIN ppdm.well_version wv 
          ON (    w.uwi = wv.uwi 
              AND wv.source = '100TLM' 
              AND wv.active_ind = 'Y')
       --to get the QA document number from DM
       --  note: need to create db link for spatial schema to edxp db
       LEFT OUTER JOIN 
           (SELECT P.DOCNUMBER, P.DOCNAME, P.DM_WELLS_MV AS TLM_WELL_ID
              FROM DOCSADM.PROFILE@EDXP P
                   INNER JOIN DOCSADM.DOCUMENTTYPES@EDXP DT ON P.DOCUMENTTYPE = DT.SYSTEM_ID
                   INNER JOIN DOCSADM.FORMS@EDXP F ON P.FORM = F.SYSTEM_ID
             WHERE     UPPER (DOCNAME) LIKE '%GEODETIC QA REPORT%'
                   AND UPPER (DT.TYPE_ID) = 'TECHNICAL'
                   AND F.FORM_NAME = 'WELLFILE_P') DM  ON w.uwi = DM.TLM_WELL_ID
  WHERE ( --ensure that some kind of location exists
              NVL (bn.latitude, sn.latitude) IS NOT NULL 
          AND NVL (sn.longitude, bn.longitude) IS NOT NULL)
        --ensure the well is active
        AND w.active_ind = 'Y'
        --and w.uwi in ('11682','50383060007','50211992200','50385324006', '144600', '143410', '1000000691', '300000174642')  --for testing
;


COMMENT ON MATERIALIZED VIEW SPATIAL.WELL_SPATIAL_MV IS 'snapshot table for snapshot SPATIAL.WELL_SPATIAL_MV';


CREATE INDEX SPATIAL.WSMV1_BA_IDX1 ON SPATIAL.WELL_SPATIAL_MV
(OPERATOR)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_BA_IDX2 ON SPATIAL.WELL_SPATIAL_MV
(LICENSEE)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_IDX01 ON SPATIAL.WELL_SPATIAL_MV
(STATUS_NAME)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_LD_IDX ON SPATIAL.WELL_SPATIAL_MV
(LATEST_DATE)
LOGGING
TABLESPACE APP_DATA
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

CREATE UNIQUE INDEX SPATIAL.WSMV1_PK ON SPATIAL.WELL_SPATIAL_MV
(UWI)
NOLOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_R_C1_IDX ON SPATIAL.WELL_SPATIAL_MV
(COUNTRY)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_R_PS3_IDX ON SPATIAL.WELL_SPATIAL_MV
(COUNTRY, PROVINCE_STATE)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_R_S_IDX ON SPATIAL.WELL_SPATIAL_MV
(PRIMARY_SOURCE)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_R_WS_IDX ON SPATIAL.WELL_SPATIAL_MV
(STATUS_TYPE, CURRENT_STATUS)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_LOCPOP_IDX ON SPATIAL.WELL_SPATIAL_MV
(LOCATION_POPULATION)
LOGGING
TABLESPACE APP_DATA
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

CREATE INDEX SPATIAL.WSMV1_TLMFG_IDX ON SPATIAL.WELL_SPATIAL_MV
(TALISMAN_INTEREST_FG)
LOGGING
TABLESPACE APP_DATA
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


/*--GRANTS---*/

GRANT SELECT ON SPATIAL.WELL_SPATIAL_MV TO PPDM;

GRANT SELECT ON SPATIAL.WELL_SPATIAL_MV TO PPDM_ADMIN;

GRANT SELECT ON SPATIAL.WELL_SPATIAL_MV TO R_SPATIAL;


----------------------------------------------------------------
/*--SYNONYMS---*/
--this has to be done via each individual schema.

DROP SYNONYM PPDM.WELL_SPATIAL_MV;
CREATE OR REPLACE SYNONYM PPDM.WELL_SPATIAL_MV FOR SPATIAL.WELL_SPATIAL_MV;

DROP SYNONYM PPDM_ADMIN.WELL_SPATIAL_MV;
CREATE OR REPLACE SYNONYM PPDM_ADMIN.WELL_SPATIAL_MV FOR SPATIAL.WELL_SPATIAL_MV;

DROP SYNONYM SPATIAL_APPL.WELL_SPATIAL_MV;
CREATE OR REPLACE SYNONYM SPATIAL_APPL.WELL_SPATIAL_MV FOR SPATIAL.WELL_SPATIAL_MV;

