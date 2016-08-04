DROP VIEW PPDM.IHS_US_WELL_LOG_JOB;

/* Formatted on 11/7/2012 2:41:33 PM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_LOG_JOB
(
   UWI,
   SOURCE,
   JOB_ID,
   ACTIVE_IND,
   CASING_SHOE_DEPTH,
   CASING_SHOE_DEPTH_OUOM,
   DRILLING_MD,
   DRILLING_MD_OUOM,
   EFFECTIVE_DATE,
   END_DATE,
   ENGINEER,
   EXPIRY_DATE,
   LOGGING_COMPANY,
   LOGGING_UNIT,
   LOGGING_UNIT_BASE,
   OBSERVER,
   PPDM_GUID,
   REMARK,
   START_DATE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT WV.UWI,
             WV.SOURCE,
             WLJ.JOB_ID,
             WLJ.ACTIVE_IND,
             WLJ.CASING_SHOE_DEPTH,
             WLJ.CASING_SHOE_DEPTH_OUOM,
             WLJ.DRILLING_MD,
             WLJ.DRILLING_MD_OUOM,
             WLJ.EFFECTIVE_DATE,
             WLJ.END_DATE,
             WLJ.ENGINEER,
             WLJ.EXPIRY_DATE,
             WLJ.LOGGING_COMPANY,
             WLJ.LOGGING_UNIT,
             WLJ.LOGGING_UNIT_BASE,
             WLJ.OBSERVER,
             WLJ.PPDM_GUID,
             WLJ.REMARK,
             WLJ.START_DATE,
             WLJ.ROW_CHANGED_BY,
             WLJ.ROW_CHANGED_DATE,
             WLJ.ROW_CREATED_BY,
             WLJ.ROW_CREATED_DATE,
             WLJ.ROW_QUALITY,
             WLJ.PROVINCE_STATE
     FROM well_log_job@C_TALISMAN_US_IHSDATAQ wlj, well_version wv
    WHERE     wv.well_num = wlj.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_LOG_JOB TO PPDM_RO;
