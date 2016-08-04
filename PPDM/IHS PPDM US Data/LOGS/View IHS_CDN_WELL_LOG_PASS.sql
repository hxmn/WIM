DROP VIEW PPDM.IHS_CDN_WELL_LOG_PASS;

/* Formatted on 11/14/2012 7:11:00 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_CDN_WELL_LOG_PASS
(
   UWI,
   SOURCE,
   JOB_ID,
   TRIP_OBS_NO,
   LOG_TOOL_PASS_NO,
   ACTIVE_IND,
   BASE_DEPTH,
   BASE_DEPTH_OUOM,
   BASE_LOG_IND,
   EFFECTIVE_DATE,
   END_TIME,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   START_TIME,
   TOP_DEPTH,
   TOP_DEPTH_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT /*+ RULE */
           wv.UWI,
           wv.SOURCE,
           wlp.JOB_ID,
           wlp.TRIP_OBS_NO,
           wlp.LOG_TOOL_PASS_NO,
           wlp.ACTIVE_IND,
           wlp.BASE_DEPTH,
           wlp.BASE_DEPTH_OUOM,
           wlp.BASE_LOG_IND,
           wlp.EFFECTIVE_DATE,
           wlp.END_TIME,
           wlp.EXPIRY_DATE,
           wlp.PPDM_GUID,
           wlp.REMARK,
           wlp.START_TIME,
           wlp.TOP_DEPTH,
           wlp.TOP_DEPTH_OUOM,
           wlp.ROW_CHANGED_BY,
           wlp.ROW_CHANGED_DATE,
           wlp.ROW_CREATED_BY,
           wlp.ROW_CREATED_DATE,
           wlp.ROW_QUALITY,
           wlp.PROVINCE_STATE
     FROM well_log_pass@c_talisman_ihsdata wlp, well_version wv
    WHERE     wv.ipl_uwi_local = wlp.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_CDN_WELL_LOG_PASS TO PPDM_RO;
