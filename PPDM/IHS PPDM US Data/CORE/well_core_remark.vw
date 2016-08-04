DROP VIEW PPDM.WELL_CORE_REMARK;

DROP TABLE WELL_CORE_REMARK CASCADE CONSTRAINTS;

/* Formatted on 4/2/2013 9:10:40 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_CORE_REMARK
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
   SELECT twcr."UWI",
          twcr."SOURCE",
          twcr."CORE_ID",
          twcr."REMARK_OBS_NO",
          twcr."ACTIVE_IND",
          twcr."EFFECTIVE_DATE",
          twcr."EXPIRY_DATE",
          twcr."PPDM_GUID",
          twcr."REMARK",
          twcr."ROW_CHANGED_BY",
          twcr."ROW_CHANGED_DATE",
          twcr."ROW_CREATED_BY",
          twcr."ROW_CREATED_DATE",
          twcr."ROW_QUALITY",
          --  IHS extensions
          NULL AS "PROVINCE_STATE"
     FROM ppdm.tlm_well_core_remark twcr
   UNION ALL
   SELECT icwcr."UWI",
          icwcr."SOURCE",
          icwcr."CORE_ID",
          icwcr."REMARK_OBS_NO",
          icwcr."ACTIVE_IND",
          icwcr."EFFECTIVE_DATE",
          icwcr."EXPIRY_DATE",
          icwcr."PPDM_GUID",
          icwcr."REMARK",
          icwcr."ROW_CHANGED_BY",
          icwcr."ROW_CHANGED_DATE",
          icwcr."ROW_CREATED_BY",
          icwcr."ROW_CREATED_DATE",
          icwcr."ROW_QUALITY",
          --  IHS extensions
          icwcr."PROVINCE_STATE"
     FROM ihs_cdn_well_core_remark icwcr
   UNION ALL
   SELECT iuwcr."UWI",
          iuwcr."SOURCE",
          iuwcr."CORE_ID",
          iuwcr."REMARK_OBS_NO",
          iuwcr."ACTIVE_IND",
          iuwcr."EFFECTIVE_DATE",
          iuwcr."EXPIRY_DATE",
          iuwcr."PPDM_GUID",
          iuwcr."REMARK",
          iuwcr."ROW_CHANGED_BY",
          iuwcr."ROW_CHANGED_DATE",
          iuwcr."ROW_CREATED_BY",
          iuwcr."ROW_CREATED_DATE",
          iuwcr."ROW_QUALITY",
          --  IHS extensions
          iuwcr."PROVINCE_STATE"
     FROM ihs_us_well_core_remark iuwcr;


DROP SYNONYM DATA_FINDER.WELL_CORE_REMARK;
CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_CORE_REMARK FOR PPDM.WELL_CORE_REMARK;


DROP SYNONYM EDIOS_ADMIN.WELL_CORE_REMARK;
CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_CORE_REMARK FOR PPDM.WELL_CORE_REMARK;


DROP SYNONYM PPDM.WCR;
CREATE OR REPLACE SYNONYM PPDM.WCR FOR PPDM.WELL_CORE_REMARK;


DROP SYNONYM PPDM.WCRM;
CREATE OR REPLACE SYNONYM PPDM.WCRM FOR PPDM.WELL_CORE_REMARK;

GRANT SELECT ON PPDM.WELL_CORE_REMARK TO PPDM_RO;
