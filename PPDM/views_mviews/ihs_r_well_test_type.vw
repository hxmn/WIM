/*******************************************************************************************
   IHS_R_WELL_TEST_TYPE  (View)

 *******************************************************************************************/

--drop view PPDM.IHS_R_WELL_TEST_TYPE;


create or replace force view PPDM.IHS_R_WELL_TEST_TYPE
(
   WELL_TEST_TYPE,
   ABBREVIATION,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   LONG_NAME,
   PPDM_GUID,
   REMARK,
   SHORT_NAME,
   SOURCE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY
)
AS
   SELECT WTT.WELL_TEST_TYPE,
          WTT.ABBREVIATION,
          WTT.ACTIVE_IND,
          WTT.EFFECTIVE_DATE,
          WTT.EXPIRY_DATE,
          WTT.LONG_NAME,
          WTT.PPDM_GUID,
          WTT.REMARK,
          WTT.SHORT_NAME,
          WTT.SOURCE,
          WTT.ROW_CHANGED_BY,
          WTT.ROW_CHANGED_DATE,
          WTT.ROW_CREATED_BY,
          WTT.ROW_CREATED_DATE,
          WTT.ROW_QUALITY
     FROM R_WELL_TEST_TYPE@C_TALISMAN_IHSDATA WTT
;


GRANT SELECT ON PPDM.IHS_R_WELL_TEST_TYPE TO PPDM_RO;
