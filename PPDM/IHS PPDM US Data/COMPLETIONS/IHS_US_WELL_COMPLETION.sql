DROP VIEW IHS_US_WELL_COMPLETION;

/* Formatted on 12/06/2013 11:07:55 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW IHS_US_WELL_COMPLETION
(
   UWI,
   SOURCE,
   COMPLETION_OBS_NO,
   ACTIVE_IND,
   BASE_DEPTH,
   BASE_DEPTH_OUOM,
   BASE_STRAT_UNIT_ID,
   COMPLETION_DATE,
   COMPLETION_METHOD,
   COMPLETION_STRAT_UNIT_ID,
   COMPLETION_TYPE,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   STRAT_NAME_SET_ID,
   TOP_DEPTH,
   TOP_DEPTH_OUOM,
   TOP_STRAT_UNIT_ID,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   X_PERF_STATUS,
   X_PERF_SHOTS,
   PROVINCE_STATE,
   TOP_STRAT_AGE,
   BASE_STRAT_AGE
)
AS
 --SELECT  /*+ RULE */
     select    wv."UWI",
          wv."SOURCE",
          wc."COMPLETION_OBS_NO",
          wc."ACTIVE_IND",
          
          wc.BASE_DEPTH * .3048 AS "BASE_DEPTH",
          'FT' as "BASE_DEPTH_OUOM",
          wc."BASE_STRAT_UNIT_ID",
          wc."COMPLETION_DATE",
          wc."COMPLETION_METHOD",
          wc."COMPLETION_STRAT_UNIT_ID",
          wc."COMPLETION_TYPE",
          wc."EFFECTIVE_DATE",
          wc."EXPIRY_DATE",
          wc."PPDM_GUID",
          wc."REMARK",
          wc."STRAT_NAME_SET_ID",
          wc.TOP_DEPTH * .3048 AS "TOP_DEPTH",
          'FT' AS "TOP_DEPTH_OUOM",
          wc."TOP_STRAT_UNIT_ID",
          wc."ROW_CHANGED_BY",
          wc."ROW_CHANGED_DATE",
          wc."ROW_CREATED_BY",
          wc."ROW_CREATED_DATE",
          wc."ROW_QUALITY",
          wc."X_PERF_STATUS",
          wc."X_PERF_SHOTS",
          wc."PROVINCE_STATE",
          wc."TOP_STRAT_AGE",
          wc."BASE_STRAT_AGE"
    
 from well_completion@c_talisman_us_ihsdataq wc, well_version wv
    WHERE     wv.ipl_uwi_local = wc.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON IHS_US_WELL_COMPLETION TO PPDM_RO;