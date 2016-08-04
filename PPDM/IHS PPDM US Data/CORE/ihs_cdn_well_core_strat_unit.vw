DROP VIEW PPDM.IHS_CDN_WELL_CORE_STRAT_UNIT;

/* Formatted on 4/2/2013 9:10:28 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_CDN_WELL_CORE_STRAT_UNIT
(
   UWI,
   SOURCE,
   CORE_ID,
   DESCRIPTION_OBS_NO,
   CORE_STRAT_UNIT_ID,
   STRAT_NAME_SET_ID,
   ACTIVE_IND,
   CORE_STRAT_UNIT_MD,
   CORE_STRAT_UNIT_MD_OUOM,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE,
   STRAT_UNIT_AGE
)
AS
   SELECT /*+ RULE */
         wv."UWI",
          wv."SOURCE",
          wcsu."CORE_ID",
          wcsu."DESCRIPTION_OBS_NO",
          wcsu."CORE_STRAT_UNIT_ID",
          wcsu."STRAT_NAME_SET_ID",
          wcsu."ACTIVE_IND",
          wcsu."CORE_STRAT_UNIT_MD",
          wcsu."CORE_STRAT_UNIT_MD_OUOM",
          wcsu."EFFECTIVE_DATE",
          wcsu."EXPIRY_DATE",
          wcsu."PPDM_GUID",
          wcsu."REMARK",
          wcsu."ROW_CHANGED_BY",
          wcsu."ROW_CHANGED_DATE",
          wcsu."ROW_CREATED_BY",
          wcsu."ROW_CREATED_DATE",
          wcsu."ROW_QUALITY",
          wcsu."PROVINCE_STATE",
          wcsu."STRAT_UNIT_AGE"
     FROM well_core_strat_unit@C_TALISMAN_IHSDATA wcsu, well_version wv
    WHERE     wv.ipl_uwi_local = wcsu.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_CDN_WELL_CORE_STRAT_UNIT TO PPDM_RO;


