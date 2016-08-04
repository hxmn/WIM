DROP VIEW PPDM.IHS_CDN_WELL_CORE_REMARK;

/* Formatted on 4/2/2013 9:10:26 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_CDN_WELL_CORE_REMARK
(
   UWI,
   SOURCE,
   CORE_ID,
   REMARK_OBS_NO,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT /*+ RULE */
         wv."UWI",
          wv."SOURCE",
          wcr."CORE_ID",
          wcr."REMARK_OBS_NO",
          wcr."ACTIVE_IND",
          wcr."EFFECTIVE_DATE",
          wcr."EXPIRY_DATE",
          wcr."PPDM_GUID",
          wcr."REMARK",
          wcr."ROW_CHANGED_BY",
          wcr."ROW_CHANGED_DATE",
          wcr."ROW_CREATED_BY",
          wcr."ROW_CREATED_DATE",
          wcr."ROW_QUALITY",
          wcr."PROVINCE_STATE"
     FROM well_core_remark@C_TALISMAN_IHSDATA wcr, well_version wv
    WHERE     wv.ipl_uwi_local = wcr.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_CDN_WELL_CORE_REMARK TO PPDM_RO;
