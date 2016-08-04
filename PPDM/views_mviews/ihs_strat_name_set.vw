/*******************************************************************************************
   IHS_STRAT_NAME_SET  (View)

 *******************************************************************************************/

--drop view PPDM.IHS_STRAT_NAME_SET;


create or replace force view PPDM.IHS_STRAT_NAME_SET
(
   STRAT_NAME_SET_ID,
   ACTIVE_IND,
   AREA_ID,
   AREA_TYPE,
   BUSINESS_ASSOCIATE,
   CERTIFIED_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   PREFERRED_IND,
   REMARK,
   SOURCE,
   STRAT_NAME_SET_NAME,
   STRAT_NAME_SET_TYPE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY
)
AS
   SELECT STRAT_NAME_SET_ID,
          ACTIVE_IND,
          AREA_ID,
          AREA_TYPE,
          BUSINESS_ASSOCIATE,
          CERTIFIED_IND,
          EFFECTIVE_DATE,
          EXPIRY_DATE,
          PPDM_GUID,
          PREFERRED_IND,
          REMARK,
          SOURCE,
          STRAT_NAME_SET_NAME,
          STRAT_NAME_SET_TYPE,
          ROW_CHANGED_BY,
          ROW_CHANGED_DATE,
          ROW_CREATED_BY,
          ROW_CREATED_DATE,
          ROW_QUALITY
     FROM STRAT_NAME_SET@C_TALISMAN_IHSDATA
;


GRANT SELECT ON PPDM.IHS_STRAT_NAME_SET TO PPDM_RO;
