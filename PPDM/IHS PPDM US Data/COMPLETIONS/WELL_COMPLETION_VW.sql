DROP VIEW WELL_COMPLETION;

/* Formatted on 12/06/2013 11:05:51 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW WELL_COMPLETION
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
   TOP_STRAT_AGE,
   BASE_STRAT_AGE,
   PROVINCE_STATE,
   X_PERF_SHOTS,
   X_PERF_STATUS,
   TLM_PERFORATION_PER_UOM
)
AS
   SELECT twc."UWI",
          twc."SOURCE",
          twc."COMPLETION_OBS_NO",
          twc."ACTIVE_IND",
          twc."BASE_DEPTH",
          twc."BASE_DEPTH_OUOM",
          twc."BASE_STRAT_UNIT_ID",
          twc."COMPLETION_DATE",
          twc."COMPLETION_METHOD",
          twc."COMPLETION_STRAT_UNIT_ID",
          twc."COMPLETION_TYPE",
          twc."EFFECTIVE_DATE",
          twc."EXPIRY_DATE",
          twc."PPDM_GUID",
          twc."REMARK",
          twc."STRAT_NAME_SET_ID",
          twc."TOP_DEPTH",
          twc."TOP_DEPTH_OUOM",
          twc."TOP_STRAT_UNIT_ID",
          twc."ROW_CHANGED_BY",
          twc."ROW_CHANGED_DATE",
          twc."ROW_CREATED_BY",
          twc."ROW_CREATED_DATE",
          twc."ROW_QUALITY",
          --  Extensions - Initially all NULL, but once we start to load the data may need to join this to other tables
          NULL AS top_strat_age,
          NULL AS base_strat_age,
          NULL AS province_state,
          NULL AS x_perf_shots,
          NULL AS x_perf_status,
          NULL AS tlm_perforation_per_uom
     FROM ppdm.tlm_well_completion twc
   UNION ALL
   SELECT iwc."UWI",
          iwc."SOURCE",
          iwc."COMPLETION_OBS_NO",
          iwc."ACTIVE_IND",
          iwc."BASE_DEPTH",
          iwc."BASE_DEPTH_OUOM",
          iwc."BASE_STRAT_UNIT_ID",
          iwc."COMPLETION_DATE",
          iwc."COMPLETION_METHOD",
          iwc."COMPLETION_STRAT_UNIT_ID",
          iwc."COMPLETION_TYPE",
          iwc."EFFECTIVE_DATE",
          iwc."EXPIRY_DATE",
          iwc."PPDM_GUID",
          iwc."REMARK",
          iwc."STRAT_NAME_SET_ID",
          iwc."TOP_DEPTH",
          iwc."TOP_DEPTH_OUOM",
          iwc."TOP_STRAT_UNIT_ID",
          iwc."ROW_CHANGED_BY",
          iwc."ROW_CHANGED_DATE",
          iwc."ROW_CREATED_BY",
          iwc."ROW_CREATED_DATE",
          iwc."ROW_QUALITY",
          --  IHS Extentions
          iwc."TOP_STRAT_AGE",
          iwc."BASE_STRAT_AGE",
          iwc."PROVINCE_STATE",
          iwc."X_PERF_SHOTS",
          iwc."X_PERF_STATUS",
          --  Extension for DataFinder - Assuming IHS data defaults to Metres
          'M' AS TLM_PERFORATION_PER_UOM
     FROM IHS_CDN_WELL_COMPLETION IWC
     UNION ALL
      SELECT iwc."UWI",
          iwc."SOURCE",
          iwc."COMPLETION_OBS_NO",
          iwc."ACTIVE_IND",
          iwc."BASE_DEPTH",
          iwc."BASE_DEPTH_OUOM",
          iwc."BASE_STRAT_UNIT_ID",
          iwc."COMPLETION_DATE",
          iwc."COMPLETION_METHOD",
          iwc."COMPLETION_STRAT_UNIT_ID",
          iwc."COMPLETION_TYPE",
          iwc."EFFECTIVE_DATE",
          iwc."EXPIRY_DATE",
          iwc."PPDM_GUID",
          iwc."REMARK",
          iwc."STRAT_NAME_SET_ID",
          iwc."TOP_DEPTH",
          iwc."TOP_DEPTH_OUOM",
          iwc."TOP_STRAT_UNIT_ID",
          iwc."ROW_CHANGED_BY",
          iwc."ROW_CHANGED_DATE",
          iwc."ROW_CREATED_BY",
          iwc."ROW_CREATED_DATE",
          iwc."ROW_QUALITY",
          --  IHS Extentions
          iwc."TOP_STRAT_AGE",
          iwc."BASE_STRAT_AGE",
          iwc."PROVINCE_STATE",
          iwc."X_PERF_SHOTS",
          iwc."X_PERF_STATUS",
          --  Extension for DataFinder - Assuming IHS data defaults to Metres
          'M' AS TLM_PERFORATION_PER_UOM
     FROM IHS_US_WELL_COMPLETION IWC;



CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_COMPLETION FOR WELL_COMPLETION;


CREATE OR REPLACE SYNONYM WCO FOR WELL_COMPLETION;


CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_COMPLETION FOR WELL_COMPLETION;


GRANT SELECT ON WELL_COMPLETION TO PPDM_RO;
