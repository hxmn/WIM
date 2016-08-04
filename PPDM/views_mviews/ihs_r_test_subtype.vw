/*******************************************************************************************
   IHS_R_TEST_SUBTYPE  (View)

 *******************************************************************************************/

--drop view PPDM.IHS_R_TEST_SUBTYPE;


create or replace force view PPDM.IHS_R_TEST_SUBTYPE
(
   TEST_SUBTYPE,
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
   SELECT TST.TEST_SUBTYPE,
          TST.ABBREVIATION,
          TST.ACTIVE_IND,
          TST.EFFECTIVE_DATE,
          TST.EXPIRY_DATE,
          TST.LONG_NAME,
          TST.PPDM_GUID,
          TST.REMARK,
          TST.SHORT_NAME,
          TST.SOURCE,
          TST.ROW_CHANGED_BY,
          TST.ROW_CHANGED_DATE,
          TST.ROW_CREATED_BY,
          TST.ROW_CREATED_DATE,
          TST.ROW_QUALITY
     FROM R_TEST_SUBTYPE@C_TALISMAN_IHSDATA TST
;


GRANT SELECT ON PPDM.IHS_R_TEST_SUBTYPE TO PPDM_RO;
