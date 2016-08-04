DROP VIEW PPDM.WELL_LOG_JOB_new;

/* Formatted on 11/14/2012 8:07:01 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_LOG_JOB_new
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
   SELECT  UWI,
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
         -- ihs extensions
           NULL AS PROVINCE_STATE  
      FROM tlm_well_log_job
   UNION ALL
    SELECT  UWI,
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
         -- ihs extensions
           PROVINCE_STATE  
     FROM IHS_CDN_WELL_LOG_JOB
   UNION ALL
   SELECT  UWI,
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
         -- ihs extensions
           NULL AS PROVINCE_STATE  
     FROM IHS_US_WELL_LOG_JOB;


DROP SYNONYM EDIOS_ADMIN.WELL_LOG_JOB_new;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_LOG_JOB_new FOR PPDM.WELL_LOG_JOB_new;


DROP SYNONYM SDP_APPL.WELL_LOG_JOB_new;

CREATE OR REPLACE SYNONYM SDP_APPL.WELL_LOG_JOB_new FOR PPDM.WELL_LOG_JOB_new;


DROP SYNONYM PPDM.WlJv;

CREATE OR REPLACE SYNONYM PPDM.WlJv FOR PPDM.WELL_LOG_JOB_new;


DROP SYNONYM DATA_FINDER.WELL_LOG_CURVE_new;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_LOG_CURVE_new FOR PPDM.WELL_LOG_CURVE_new;


GRANT SELECT ON PPDM.WELL_LOG_CURVE_new TO PPDM_RO;
