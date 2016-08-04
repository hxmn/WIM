DROP VIEW PPDM.WELL_LOG_new;

/* Formatted on 11/14/2012 8:07:01 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_LOG_new
(
   UWI,
   WELL_LOG_ID,
   SOURCE,
   ACQUIRED_FOR_BA_ID,
   ACTIVE_IND,
   BASE_DEPTH,
   BASE_DEPTH_OUOM,
   BYPASS_IND,
   CASED_HOLE_IND,
   COMPOSITE_IND,
   DEPTH_TYPE,
   DICTIONARY_ID,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   LOG_JOB_ID,
   LOG_JOB_SOURCE,
   LOG_REF_NUM,
   LOG_TITLE,
   LOG_TOOL_PASS_NO,
   MWD_IND,
   PPDM_GUID,
   REMARK,
   TOP_DEPTH,
   TOP_DEPTH_OUOM,
   TRIP_OBS_NO,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT TWL.UWI,
          TWL.WELL_LOG_ID,
          TWL.SOURCE,
          TWL.ACQUIRED_FOR_BA_ID,
          TWL.ACTIVE_IND,
          TWL.BASE_DEPTH,
          TWL.BASE_DEPTH_OUOM,
          TWL.BYPASS_IND,
          TWL.CASED_HOLE_IND,
          TWL.COMPOSITE_IND,
          TWL.DEPTH_TYPE,
          TWL.DICTIONARY_ID,
          TWL.EFFECTIVE_DATE,
          TWL.EXPIRY_DATE,
          TWL.LOG_JOB_ID,
          TWL.LOG_JOB_SOURCE,
          TWL.LOG_REF_NUM,
          TWL.LOG_TITLE,
          TWL.LOG_TOOL_PASS_NO,
          TWL.MWD_IND,
          TWL.PPDM_GUID,
          TWL.REMARK,
          TWL.TOP_DEPTH,
          TWL.TOP_DEPTH_OUOM,
          TWL.TRIP_OBS_NO,
          TWL.ROW_CHANGED_BY,
          TWL.ROW_CHANGED_DATE,
          TWL.ROW_CREATED_BY,
          TWL.ROW_CREATED_DATE,
          TWL.ROW_QUALITY,
          -- IHS Extensions 
          NULL AS "PROVINCE_STATE"
      FROM tlm_well_log twl
   UNION ALL
   SELECT icwl.UWI,
          icwl.WELL_LOG_ID,
          icwl.SOURCE,
          icwl.ACQUIRED_FOR_BA_ID,
          icwl.ACTIVE_IND,
          icwl.BASE_DEPTH,
          icwl.BASE_DEPTH_OUOM,
          icwl.BYPASS_IND,
          icwl.CASED_HOLE_IND,
          icwl.COMPOSITE_IND,
          icwl.DEPTH_TYPE,
          icwl.DICTIONARY_ID,
          icwl.EFFECTIVE_DATE,
          icwl.EXPIRY_DATE,
          icwl.LOG_JOB_ID,
          icwl.LOG_JOB_SOURCE,
          icwl.LOG_REF_NUM,
          icwl.LOG_TITLE,
          icwl.LOG_TOOL_PASS_NO,
          icwl.MWD_IND,
          icwl.PPDM_GUID,
          icwl.REMARK,
          icwl.TOP_DEPTH,
          icwl.TOP_DEPTH_OUOM,
          icwl.TRIP_OBS_NO,
          icwl.ROW_CHANGED_BY,
          icwl.ROW_CHANGED_DATE,
          icwl.ROW_CREATED_BY,
          icwl.ROW_CREATED_DATE,
          icwl.ROW_QUALITY,
          -- IHS Extensions 
          icwl.PROVINCE_STATE
     FROM IHS_CDN_WELL_LOG icwl
   UNION ALL
   SELECT iuwl.UWI,
          iuwl.WELL_LOG_ID,
          iuwl.SOURCE,
          iuwl.ACQUIRED_FOR_BA_ID,
          iuwl.ACTIVE_IND,
          iuwl.BASE_DEPTH,
          iuwl.BASE_DEPTH_OUOM,
          iuwl.BYPASS_IND,
          iuwl.CASED_HOLE_IND,
          iuwl.COMPOSITE_IND,
          iuwl.DEPTH_TYPE,
          iuwl.DICTIONARY_ID,
          iuwl.EFFECTIVE_DATE,
          iuwl.EXPIRY_DATE,
          iuwl.LOG_JOB_ID,
          iuwl.LOG_JOB_SOURCE,
          iuwl.LOG_REF_NUM,
          iuwl.LOG_TITLE,
          iuwl.LOG_TOOL_PASS_NO,
          iuwl.MWD_IND,
          iuwl.PPDM_GUID,
          iuwl.REMARK,
          iuwl.TOP_DEPTH,
          iuwl.TOP_DEPTH_OUOM,
          iuwl.TRIP_OBS_NO,
          iuwl.ROW_CHANGED_BY,
          iuwl.ROW_CHANGED_DATE,
          iuwl.ROW_CREATED_BY,
          iuwl.ROW_CREATED_DATE,
          iuwl.ROW_QUALITY,
          -- IHS Extensions 
          iuwl.PROVINCE_STATE
     FROM IHS_US_WELL_LOG iuwl;


DROP SYNONYM EDIOS_ADMIN.WELL_LOG_new;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_LOG_new FOR PPDM.WELL_LOG_new;


DROP SYNONYM SDP_APPL.WELL_LOG_new;

CREATE OR REPLACE SYNONYM SDP_APPL.WELL_LOG_new FOR PPDM.WELL_LOG_new;


DROP SYNONYM PPDM.WLV;

CREATE OR REPLACE SYNONYM PPDM.WLV FOR PPDM.WELL_LOG_new;


DROP SYNONYM DATA_FINDER.WELL_LOG_new;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_LOG_new FOR PPDM.WELL_LOG_new;


GRANT SELECT ON PPDM.WELL_LOG_new TO PPDM_RO;
