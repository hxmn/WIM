DROP MATERIALIZED VIEW PPDM.CWS_WIM_COMPARE_MV;
CREATE MATERIALIZED VIEW PPDM.CWS_WIM_COMPARE_MV 
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
LOGGING
NOPARALLEL
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 2012/02/03 07:18 (Formatter Plus v4.8.8) */
SELECT wv.uwi, cwcd.country_cd AS country, 'SURF_LAT' AS difference,
       TO_CHAR (cwn.well_node_latitude) cws_value,
       TO_CHAR (wv.surface_latitude) wim_value
  FROM well_current_data@cws.world cwcd,
       well_node@cws.world cwn,
       well_version wv
 WHERE wv.country = '7US'
   AND wv.SOURCE = '450PID'
   AND cwcd.well_id = wv.uwi
   AND cwcd.country_cd = 'US'
   AND cwn.well_node_id = cwcd.surface_node_id
   AND NVL (TO_CHAR (cwn.well_node_latitude), 'NULL') !=
                                   NVL (TO_CHAR (wv.surface_latitude), 'NULL')
UNION ALL
SELECT wv.uwi, cwcd.country_cd AS country, 'SURF_LON' AS difference,
       TO_CHAR (cwn.well_node_longitude), TO_CHAR (wv.surface_longitude)
  FROM well_current_data@cws.world cwcd,
       well_node@cws.world cwn,
       well_version wv
 WHERE wv.country = '7US'
   AND wv.SOURCE = '450PID'
   AND cwcd.well_id = wv.uwi
   AND cwcd.country_cd = 'US'
   AND cwn.well_node_id = cwcd.base_node_id
   AND NVL (TO_CHAR (cwn.well_node_longitude), 'NULL') !=
                                  NVL (TO_CHAR (wv.surface_longitude), 'NULL')
UNION ALL
SELECT wv.uwi, cwcd.country_cd AS country, 'BH_LAT' AS difference,
       TO_CHAR (cwn.well_node_latitude), TO_CHAR (wv.bottom_hole_latitude)
  FROM well_current_data@cws.world cwcd,
       well_node@cws.world cwn,
       well_version wv
 WHERE wv.country = '7US'
   AND wv.SOURCE = '450PID'
   AND cwcd.well_id = wv.uwi
   AND cwcd.country_cd = 'US'
   AND cwn.well_node_id = cwcd.base_node_id
   AND NVL (TO_CHAR (cwn.well_node_latitude), 'NULL') !=
                               NVL (TO_CHAR (wv.bottom_hole_latitude), 'NULL')
UNION ALL
SELECT wv.uwi, cwcd.country_cd AS country, 'BH_LON' AS difference,
       TO_CHAR (cwn.well_node_longitude), TO_CHAR (wv.bottom_hole_longitude)
  FROM well_current_data@cws.world cwcd,
       well_node@cws.world cwn,
       well_version wv
 WHERE wv.country = '7US'
   AND wv.SOURCE = '450PID'
   AND cwcd.well_id = wv.uwi
   AND cwcd.country_cd = 'US'
   AND cwn.well_node_id = cwcd.base_node_id
   AND NVL (TO_CHAR (cwn.well_node_longitude), 'NULL') !=
                              NVL (TO_CHAR (wv.bottom_hole_longitude), 'NULL')
UNION ALL
SELECT wv.uwi, cwcd.country_cd AS country, 'SPUD' AS difference,
       TO_CHAR (cw.well_spud_dt), TO_CHAR (wv.spud_date)
  FROM well_current_data@cws.world cwcd,
       well_version wv,
       well@cws.world cw
 WHERE wv.country = '7US'
   AND wv.SOURCE = '450PID'
   AND cwcd.well_id = wv.uwi
   AND cwcd.well_id = cw.well_id
   AND cwcd.country_cd = 'US'
   AND NVL (TO_CHAR (cw.well_spud_dt), 'NULL') !=
                                          NVL (TO_CHAR (wv.spud_date), 'NULL')
UNION ALL
SELECT wv.uwi, cwcd.country_cd AS country, 'RIGREL' AS difference,
       TO_CHAR (cw.well_rig_release_dt), TO_CHAR (wv.rig_release_date)
  FROM well_current_data@cws.world cwcd,
       well_version wv,
       well@cws.world cw
 WHERE wv.country = '7US'
   AND wv.SOURCE = '450PID'
   AND cwcd.well_id = wv.uwi
   AND cwcd.well_id = cw.well_id
   AND cwcd.country_cd = 'US'
   AND NVL (TO_CHAR (cw.well_rig_release_dt), 'NULL') !=
                                   NVL (TO_CHAR (wv.rig_release_date), 'NULL');

COMMENT ON TABLE PPDM.CWS_WIM_COMPARE_MV IS 'snapshot table for snapshot PPDM.CWS_WIM_COMPARE_MV';

CREATE INDEX PPDM.CWC_UWI ON PPDM.CWS_WIM_COMPARE_MV
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

GRANT SELECT ON PPDM.CWS_WIM_COMPARE_MV TO PPDM_READ;
