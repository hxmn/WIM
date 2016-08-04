DROP VIEW PPDM.PDEN_VOL_BY_MONTH;

/* Formatted on 10/30/2012 2:56:52 PM (QP5 v5.185.11230.41888) */
DROP VIEW PPDM.PDEN_VOL_BY_MONTH;

/* Formatted on 4/2/2013 7:28:59 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.PDEN_VOL_BY_MONTH
(
   PDEN_ID,
   PDEN_TYPE,
   PDEN_SOURCE,
   VOLUME_METHOD,
   ACTIVITY_TYPE,
   PRODUCT_TYPE,
   YEAR,
   AMENDMENT_SEQ_NO,
   ACTIVE_IND,
   AMEND_REASON,
   APR_VOLUME,
   APR_VOLUME_QUAL,
   AUG_VOLUME,
   AUG_VOLUME_QUAL,
   CUM_VOLUME,
   DEC_VOLUME,
   DEC_VOLUME_QUAL,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   FEB_VOLUME,
   FEB_VOLUME_QUAL,
   JAN_VOLUME,
   JAN_VOLUME_QUAL,
   JUL_VOLUME,
   JUL_VOLUME_QUAL,
   JUN_VOLUME,
   JUN_VOLUME_QUAL,
   MAR_VOLUME,
   MAR_VOLUME_QUAL,
   MAY_VOLUME,
   MAY_VOLUME_QUAL,
   NOV_VOLUME,
   NOV_VOLUME_QUAL,
   OCT_VOLUME,
   OCT_VOLUME_QUAL,
   POSTED_DATE,
   PPDM_GUID,
   REMARK,
   SEP_VOLUME,
   SEP_VOLUME_QUAL,
   VOLUME_END_DATE,
   VOLUME_OUOM,
   VOLUME_QUALITY_OUOM,
   VOLUME_START_DATE,
   VOLUME_UOM,
   YTD_VOLUME,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE,
   POOL_ID,
   X_STRAT_UNIT_ID,
   TOP_STRAT_AGE,
   BASE_STRAT_AGE,
   STRAT_NAME_SET_ID
)
AS
   SELECT "PDEN_ID",
          "PDEN_TYPE",
          "PDEN_SOURCE",
          "VOLUME_METHOD",
          "ACTIVITY_TYPE",
          "PRODUCT_TYPE",
          "YEAR",
          "AMENDMENT_SEQ_NO",
          "ACTIVE_IND",
          "AMEND_REASON",
          "APR_VOLUME",
          "APR_VOLUME_QUAL",
          "AUG_VOLUME",
          "AUG_VOLUME_QUAL",
          "CUM_VOLUME",
          "DEC_VOLUME",
          "DEC_VOLUME_QUAL",
          "EFFECTIVE_DATE",
          "EXPIRY_DATE",
          "FEB_VOLUME",
          "FEB_VOLUME_QUAL",
          "JAN_VOLUME",
          "JAN_VOLUME_QUAL",
          "JUL_VOLUME",
          "JUL_VOLUME_QUAL",
          "JUN_VOLUME",
          "JUN_VOLUME_QUAL",
          "MAR_VOLUME",
          "MAR_VOLUME_QUAL",
          "MAY_VOLUME",
          "MAY_VOLUME_QUAL",
          "NOV_VOLUME",
          "NOV_VOLUME_QUAL",
          "OCT_VOLUME",
          "OCT_VOLUME_QUAL",
          "POSTED_DATE",
          "PPDM_GUID",
          "REMARK",
          "SEP_VOLUME",
          "SEP_VOLUME_QUAL",
          "VOLUME_END_DATE",
          "VOLUME_OUOM",
          "VOLUME_QUALITY_OUOM",
          "VOLUME_START_DATE",
          "VOLUME_UOM",
          "YTD_VOLUME",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY",
          -- IHS Extensions
          NULL AS "PROVINCE_STATE",
          NULL AS "POOL_ID",
          NULL AS "X_STRAT_UNIT_ID",
          NULL AS "TOP_STRAT_AGE",
          NULL AS "BASE_STRAT_AGE",
          NULL AS "STRAT_NAME_SET_ID"
     FROM TLM_PDEN_VOL_BY_MONTH
   UNION ALL
   SELECT "PDEN_ID",
          "PDEN_TYPE",
          "PDEN_SOURCE",
          "VOLUME_METHOD",
          "ACTIVITY_TYPE",
          "PRODUCT_TYPE",
          "YEAR",
          "AMENDMENT_SEQ_NO",
          "ACTIVE_IND",
          "AMEND_REASON",
          "APR_VOLUME",
          "APR_VOLUME_QUAL",
          "AUG_VOLUME",
          "AUG_VOLUME_QUAL",
          "CUM_VOLUME",
          "DEC_VOLUME",
          "DEC_VOLUME_QUAL",
          "EFFECTIVE_DATE",
          "EXPIRY_DATE",
          "FEB_VOLUME",
          "FEB_VOLUME_QUAL",
          "JAN_VOLUME",
          "JAN_VOLUME_QUAL",
          "JUL_VOLUME",
          "JUL_VOLUME_QUAL",
          "JUN_VOLUME",
          "JUN_VOLUME_QUAL",
          "MAR_VOLUME",
          "MAR_VOLUME_QUAL",
          "MAY_VOLUME",
          "MAY_VOLUME_QUAL",
          "NOV_VOLUME",
          "NOV_VOLUME_QUAL",
          "OCT_VOLUME",
          "OCT_VOLUME_QUAL",
          "POSTED_DATE",
          "PPDM_GUID",
          "REMARK",
          "SEP_VOLUME",
          "SEP_VOLUME_QUAL",
          "VOLUME_END_DATE",
          "VOLUME_OUOM",
          "VOLUME_QUALITY_OUOM",
          "VOLUME_START_DATE",
          "VOLUME_UOM",
          "YTD_VOLUME",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY",
          -- IHS Extensions
          "PROVINCE_STATE",
          "POOL_ID",
          "X_STRAT_UNIT_ID",
          "TOP_STRAT_AGE",
          "BASE_STRAT_AGE",
          "STRAT_NAME_SET_ID"
     FROM IHS_CDN_PDEN_VOL_BY_MONTH
   UNION ALL
   SELECT "PDEN_ID",
          "PDEN_TYPE",
          "PDEN_SOURCE",
          "VOLUME_METHOD",
          "ACTIVITY_TYPE",
          "PRODUCT_TYPE",
          "YEAR",
          "AMENDMENT_SEQ_NO",
          "ACTIVE_IND",
          "AMEND_REASON",
          "APR_VOLUME",
          "APR_VOLUME_QUAL",
          "AUG_VOLUME",
          "AUG_VOLUME_QUAL",
          "CUM_VOLUME",
          "DEC_VOLUME",
          "DEC_VOLUME_QUAL",
          "EFFECTIVE_DATE",
          "EXPIRY_DATE",
          "FEB_VOLUME",
          "FEB_VOLUME_QUAL",
          "JAN_VOLUME",
          "JAN_VOLUME_QUAL",
          "JUL_VOLUME",
          "JUL_VOLUME_QUAL",
          "JUN_VOLUME",
          "JUN_VOLUME_QUAL",
          "MAR_VOLUME",
          "MAR_VOLUME_QUAL",
          "MAY_VOLUME",
          "MAY_VOLUME_QUAL",
          "NOV_VOLUME",
          "NOV_VOLUME_QUAL",
          "OCT_VOLUME",
          "OCT_VOLUME_QUAL",
          "POSTED_DATE",
          "PPDM_GUID",
          "REMARK",
          "SEP_VOLUME",
          "SEP_VOLUME_QUAL",
          "VOLUME_END_DATE",
          "VOLUME_OUOM",
          "VOLUME_QUALITY_OUOM",
          "VOLUME_START_DATE",
          "VOLUME_UOM",
          "YTD_VOLUME",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY",
          "PROVINCE_STATE",
          "POOL_ID",
          "X_STRAT_UNIT_ID",
          "TOP_STRAT_AGE",
          "BASE_STRAT_AGE",
          "STRAT_NAME_SET_ID"
     FROM IHS_US_PDEN_VOL_BY_MONTH;


DROP SYNONYM DATA_FINDER.PDEN_VOL_BY_MONTH;
CREATE OR REPLACE SYNONYM DATA_FINDER.PDEN_VOL_BY_MONTH FOR PPDM.PDEN_VOL_BY_MONTH;


DROP SYNONYM EDIOS_ADMIN.PDEN_VOL_BY_MONTH;
CREATE OR REPLACE SYNONYM EDIOS_ADMIN.PDEN_VOL_BY_MONTH FOR PPDM.PDEN_VOL_BY_MONTH;


DROP SYNONYM PPDM.PDENVBM;
CREATE OR REPLACE SYNONYM PPDM.PDENVBM FOR PPDM.PDEN_VOL_BY_MONTH;

GRANT SELECT ON PPDM.PDEN_VOL_BY_MONTH TO PPDM_RO;

GRANT SELECT ON PPDM.PDEN_VOL_BY_MONTH TO PPDM_RO;

GRANT SELECT ON PPDM.PDEN_VOL_BY_MONTH TO VALNAV WITH GRANT OPTION;

