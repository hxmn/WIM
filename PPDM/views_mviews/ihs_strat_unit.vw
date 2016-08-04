/*******************************************************************************************
   IHS_STRAT_UNIT  (View)

 *******************************************************************************************/

--drop view PPDM.IHS_STRAT_UNIT;


create or replace force view PPDM.IHS_STRAT_UNIT
(
   STRAT_NAME_SET_ID,
   STRAT_UNIT_ID,
   ABBREVIATION,
   ACTIVE_IND,
   AREA_ID,
   AREA_TYPE,
   BUSINESS_ASSOCIATE,
   CONFIDENCE_ID,
   CURRENT_STATUS_DATE,
   DESCRIPTION,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   FAULT_TYPE,
   FORM_CODE,
   GROUP_CODE,
   LONG_NAME,
   ORDINAL_AGE_CODE,
   PPDM_GUID,
   PREFERRED_IND,
   REMARK,
   SHORT_NAME,
   SOURCE,
   STRAT_INTERPRET_METHOD,
   STRAT_STATUS,
   STRAT_TYPE,
   STRAT_UNIT_TYPE,
   X_STRAT_UNIT_ID_NUM,
   BASE_STRAT_AGE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   X_LITHOLOGY,
   X_RESOURCE
)
AS
   SELECT STRAT_NAME_SET_ID,
          STRAT_UNIT_ID,
          ABBREVIATION,
          ACTIVE_IND,
          AREA_ID,
          AREA_TYPE,
          BUSINESS_ASSOCIATE,
          CONFIDENCE_ID,
          CURRENT_STATUS_DATE,
          DESCRIPTION,
          EFFECTIVE_DATE,
          EXPIRY_DATE,
          FAULT_TYPE,
          FORM_CODE,
          GROUP_CODE,
          LONG_NAME,
          ORDINAL_AGE_CODE,
          PPDM_GUID,
          PREFERRED_IND,
          REMARK,
          SHORT_NAME,
          SOURCE,
          STRAT_INTERPRET_METHOD,
          STRAT_STATUS,
          STRAT_TYPE,
          STRAT_UNIT_TYPE,
          X_STRAT_UNIT_ID_NUM,
          BASE_STRAT_AGE,
          ROW_CHANGED_BY,
          ROW_CHANGED_DATE,
          ROW_CREATED_BY,
          ROW_CREATED_DATE,
          ROW_QUALITY,
          X_LITHOLOGY,
          X_RESOURCE
     FROM strat_unit@c_talisman_ihsdata
    WHERE strat_name_set_id <> 'V80C'
;


GRANT SELECT ON PPDM.IHS_STRAT_UNIT TO PPDM_RO;
