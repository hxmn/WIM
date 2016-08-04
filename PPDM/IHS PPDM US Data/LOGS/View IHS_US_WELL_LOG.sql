DROP VIEW PPDM.IHS_US_WELL_LOG;

/* Formatted on 11/7/2012 2:41:33 PM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_LOG
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
   SELECT WV.UWI,
          WL.WELL_LOG_ID,
          WV.SOURCE,
          WL.ACQUIRED_FOR_BA_ID,
          WL.ACTIVE_IND,
          WL.BASE_DEPTH,
          WL.BASE_DEPTH_OUOM,
          WL.BYPASS_IND,
          WL.CASED_HOLE_IND,
          WL.COMPOSITE_IND,
          WL.DEPTH_TYPE,
          WL.DICTIONARY_ID,
          WL.EFFECTIVE_DATE,
          WL.EXPIRY_DATE,
          WL.LOG_JOB_ID,
          WL.LOG_JOB_SOURCE,
          WL.LOG_REF_NUM,
          WL.LOG_TITLE,
          WL.LOG_TOOL_PASS_NO,
          WL.MWD_IND,
          WL.PPDM_GUID,
          WL.REMARK,
          WL.TOP_DEPTH,
          WL.TOP_DEPTH_OUOM,
          WL.TRIP_OBS_NO,
          WL.ROW_CHANGED_BY,
          WL.ROW_CHANGED_DATE,
          WL.ROW_CREATED_BY,
          WL.ROW_CREATED_DATE,
          WL.ROW_QUALITY,
          WL.PROVINCE_STATE
     FROM well_LOG@C_TALISMAN_US_IHSDATAQ wl, well_version wv
    WHERE     wv.well_num = wl.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_LOG TO PPDM_RO;
