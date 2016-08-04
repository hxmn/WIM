
DROP VIEW PPDM.IHS_CDN_PDEN;

/* Formatted on 4/2/2013 7:35:21 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_CDN_PDEN
(
   PDEN_ID,
   PDEN_TYPE,
   SOURCE,
   ACTIVE_IND,
   COUNTRY,
   CURRENT_OPERATOR,
   CURRENT_PROD_STR_NAME,
   CURRENT_STATUS_DATE,
   CURRENT_WELL_STR_NUMBER,
   DISTRICT,
   EFFECTIVE_DATE,
   ENHANCED_RECOVERY_TYPE,
   EXPIRY_DATE,
   FIELD_ID,
   GEOGRAPHIC_REGION,
   GEOLOGIC_PROVINCE,
   LAST_INJECTION_DATE,
   LAST_PRODUCTION_DATE,
   LAST_REPORTED_DATE,
   LOCATION_DESC,
   LOCATION_DESC_TYPE,
   ON_INJECTION_DATE,
   ON_PRODUCTION_DATE,
   PDEN_NAME,
   PDEN_SHORT_NAME,
   PDEN_STATUS,
   PLOT_NAME,
   PLOT_SYMBOL,
   POOL_ID,
   PPDM_GUID,
   PRIMARY_PRODUCT,
   PRODUCTION_METHOD,
   PROPRIETARY_IND,
   PROVINCE_STATE,
   REMARK,
   STATE_OR_FEDERAL_WATERS,
   STRAT_NAME_SET_ID,
   STRAT_UNIT_ID,
   STRING_SERIAL_NUMBER,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   X_TOP_DEPTH,
   X_BASE_DEPTH,
   X_UNIT_ID,
   X_ALLOW_TYPE,
   X_BLOCK_ID,
   X_PSU_SURPLUS_IND,
   X_PROJECT_ID,
   X_PROD_FREQ,
   X_PROD_SPACING_UNIT,
   X_UNIT_OIL_INTEREST,
   X_UNIT_GAS_INTEREST,
   X_SPECIAL_PSU_SURPLUS,
   X_SPECIAL_PENALTY_RELIEF,
   X_PENALTY_RELIEF,
   X_SET_GOR_DATE,
   X_SET_GOR,
   X_PEND_S4_IND,
   X_FACILITY_ID,
   X_CONTROL_WELL_IND,
   X_OIL_DENSITY,
   X_OFF_TARGET,
   X_DISP_INJ_APPROVAL,
   X_DISP_INJ_APPROVAL_NUMBER,
   X_WELLHEAD_PRESS,
   X_BATTERY_ID,
   X_COMMINGLED,
   TOP_STRAT_AGE,
   BASE_STRAT_AGE,
   X_ONPROD_OIL,
   X_ONPROD_GAS,
   X_ONPROD_WATER,
   FACILITY_TYPE
)
AS
   SELECT 
         WV.UWI AS "PDEN_ID",
          P."PDEN_TYPE",
          wv.source AS "SOURCE",
          P."ACTIVE_IND",
          P."COUNTRY",
          BA.business_associate,
          P."CURRENT_PROD_STR_NAME",
          P."CURRENT_STATUS_DATE",
          P."CURRENT_WELL_STR_NUMBER",
          P."DISTRICT",
          P."EFFECTIVE_DATE",
          P."ENHANCED_RECOVERY_TYPE",
          P."EXPIRY_DATE",
          P."FIELD_ID",
          P."GEOGRAPHIC_REGION",
          P."GEOLOGIC_PROVINCE",
          P."LAST_INJECTION_DATE",
          P."LAST_PRODUCTION_DATE",
          P."LAST_REPORTED_DATE",
          P."LOCATION_DESC",
          P."LOCATION_DESC_TYPE",
          P."ON_INJECTION_DATE",
          P."ON_PRODUCTION_DATE",
          P."PDEN_NAME",
          P."PDEN_SHORT_NAME",
          S."STATUS",
          P."PLOT_NAME",
          P."PLOT_SYMBOL",
          P."POOL_ID",
          P."PPDM_GUID",
          P."PRIMARY_PRODUCT",
          P."PRODUCTION_METHOD",
          P."PROPRIETARY_IND",
          PS."PROVINCE_STATE",
          P."REMARK",
          P."STATE_OR_FEDERAL_WATERS",
          P."STRAT_NAME_SET_ID",
          P."STRAT_UNIT_ID",
          P."STRING_SERIAL_NUMBER",
          P."ROW_CHANGED_BY",
          P."ROW_CHANGED_DATE",
          P."ROW_CREATED_BY",
          P."ROW_CREATED_DATE",
          P."ROW_QUALITY",
          P."X_TOP_DEPTH",
          P."X_BASE_DEPTH",
          P."X_UNIT_ID",
          P."X_ALLOW_TYPE",
          P."X_BLOCK_ID",
          P."X_PSU_SURPLUS_IND",
          P."X_PROJECT_ID",
          P."X_PROD_FREQ",
          P."X_PROD_SPACING_UNIT",
          P."X_UNIT_OIL_INTEREST",
          P."X_UNIT_GAS_INTEREST",
          P."X_SPECIAL_PSU_SURPLUS",
          P."X_SPECIAL_PENALTY_RELIEF",
          P."X_PENALTY_RELIEF",
          P."X_SET_GOR_DATE",
          P."X_SET_GOR",
          P."X_PEND_S4_IND",
          P."X_FACILITY_ID",
          P."X_CONTROL_WELL_IND",
          P."X_OIL_DENSITY",
          P."X_OFF_TARGET",
          P."X_DISP_INJ_APPROVAL",
          P."X_DISP_INJ_APPROVAL_NUMBER",
          P."X_WELLHEAD_PRESS",
          P."X_BATTERY_ID",
          P."X_COMMINGLED",
          P."TOP_STRAT_AGE",
          P."BASE_STRAT_AGE",
          P."X_ONPROD_OIL",
          P."X_ONPROD_GAS",
          P."X_ONPROD_WATER",
          P."FACILITY_TYPE"
     FROM PDEN@C_TALISMAN_IHSDATA P, WELL_VERSION WV,   BUSINESS_ASSOCIATE BA,
          R_WELL_STATUS S, R_PROVINCE_STATE PS
    WHERE WV.IPL_UWI_LOCAL = P.PDEN_ID
       AND P.PDEN_TYPE = 'PDEN_WELL'
       AND WV.SOURCE = '300IPL'
       AND WV.ACTIVE_IND = 'Y'
       AND p.current_operator = ba.business_associate(+) and ba.active_ind(+) ='Y'
       AND p.pden_Status = s.status(+) and s.active_ind(+) ='Y'
       AND p.PROVINCE_STATE = PS.PROVINCE_STATE(+) and ps.active_ind(+) ='Y';


GRANT SELECT ON PPDM.IHS_CDN_PDEN TO PPDM_RO;


--
select* from PPDM.IHS_CDN_PDEN
 where geologic_province is not null;

select  PDEN_ID,   PDEN_TYPE,   wv.SOURCE, p.ACTIVE_IND,ps.province_State, p.geologic_province, ba.business_associate,  p.COUNTRY,  ba.ba_name, p.CURRENT_OPERATOR, p.field_id, p.pden_status   
   FROM PDEN@C_TALISMAN_IHSDATA P, 
        WELL_VERSION WV,
        BUSINESS_ASSOCIATE BA,
        R_WELL_STATUS S,
        R_PROVINCE_STATE PS
  WHERE WV.IPL_UWI_LOCAL = P.PDEN_ID
    AND P.PDEN_TYPE = 'PDEN_WELL'
    AND WV.SOURCE = '300IPL'
    AND WV.ACTIVE_IND = 'Y'
    AND p.current_operator = ba.business_associate(+) and ba.active_ind(+) ='Y'
    AND p.pden_Status = s.status(+) and s.active_ind(+) ='Y'
    AND p.PROVINCE_STATE = PS.PROVINCE_STATE(+) and ps.active_ind(+) ='Y'
    and pden_id in ('1AD102806403W400','1AD103405104W400');
    
    select * from r_well_status
    where status in ('17021000','01010000');
    
    select * from r_geologic_province ppdm, r_geologic_province@C_TALISMAN_IHSDATA ihs
    where ppdm.long_name = ihs.abbreviation;
    
    select * from r_geologic_province@C_TALISMAN_IHSDATA;
    
    select * from field;
    select * from field@C_TALISMAN_IHSDATA;
    
    --Load Field from IHS to TLM Field table???
    
    