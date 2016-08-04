DROP VIEW PPDM.WELL_CORE_DESCRIPTION;

DROP TABLE WELL_CORE_DESCRIPTION CASCADE CONSTRAINTS;
/* Formatted on 4/2/2013 9:10:39 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_CORE_DESCRIPTION
(
   UWI,
   SOURCE,
   CORE_ID,
   DESCRIPTION_OBS_NO,
   ACTIVE_IND,
   BASE_DEPTH,
   BASE_DEPTH_OUOM,
   CORE_DESCRIPTION_COMPANY,
   DESCRIPTION_DATE,
   DIP_ANGLE,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   INTERVAL_THICKNESS,
   INTERVAL_THICKNESS_OUOM,
   LITHOLOGY_DESC,
   POROSITY_LENGTH,
   POROSITY_LENGTH_OUOM,
   POROSITY_QUALITY,
   POROSITY_TYPE,
   PPDM_GUID,
   REMARK,
   SHOW_LENGTH,
   SHOW_LENGTH_OUOM,
   SHOW_TYPE,
   TOP_DEPTH,
   TOP_DEPTH_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE,
   X_TOP_STRAT_UNIT_ID,
   X_BASE_STRAT_UNIT_ID,
   X_PRIMARY_STRAT_UNIT_ID,
   TOP_STRAT_AGE,
   BASE_STRAT_AGE,
   PRIMARY_STRAT_AGE,
   STRAT_NAME_SET_ID
)
AS
   SELECT twcd."UWI",
          twcd."SOURCE",
          twcd."CORE_ID",
          twcd."DESCRIPTION_OBS_NO",
          twcd."ACTIVE_IND",
          twcd."BASE_DEPTH",
          twcd."BASE_DEPTH_OUOM",
          twcd."CORE_DESCRIPTION_COMPANY",
          twcd."DESCRIPTION_DATE",
          twcd."DIP_ANGLE",
          twcd."EFFECTIVE_DATE",
          twcd."EXPIRY_DATE",
          twcd."INTERVAL_THICKNESS",
          twcd."INTERVAL_THICKNESS_OUOM",
          twcd."LITHOLOGY_DESC",
          twcd."POROSITY_LENGTH",
          twcd."POROSITY_LENGTH_OUOM",
          twcd."POROSITY_QUALITY",
          twcd."POROSITY_TYPE",
          twcd."PPDM_GUID",
          twcd."REMARK",
          twcd."SHOW_LENGTH",
          twcd."SHOW_LENGTH_OUOM",
          twcd."SHOW_TYPE",
          twcd."TOP_DEPTH",
          twcd."TOP_DEPTH_OUOM",
          twcd."ROW_CHANGED_BY",
          twcd."ROW_CHANGED_DATE",
          twcd."ROW_CREATED_BY",
          twcd."ROW_CREATED_DATE",
          twcd."ROW_QUALITY",
          --  IHS extensions
          NULL AS "PROVINCE_STATE",
          NULL AS "X_TOP_STRAT_UNIT_ID",
          NULL AS "X_BASE_STRAT_UNIT_ID",
          NULL AS "X_PRIMARY_STRAT_UNIT_ID",
          NULL AS "TOP_STRAT_AGE",
          NULL AS "BASE_STRAT_AGE",
          NULL AS "PRIMARY_STRAT_AGE",
          NULL AS "STRAT_NAME_SET_ID"
     FROM ppdm.tlm_well_core_description twcd
   UNION ALL
   SELECT icwcd."UWI",
          icwcd."SOURCE",
          icwcd."CORE_ID",
          icwcd."DESCRIPTION_OBS_NO",
          icwcd."ACTIVE_IND",
          icwcd."BASE_DEPTH",
          icwcd."BASE_DEPTH_OUOM",
          icwcd."CORE_DESCRIPTION_COMPANY",
          icwcd."DESCRIPTION_DATE",
          icwcd."DIP_ANGLE",
          icwcd."EFFECTIVE_DATE",
          icwcd."EXPIRY_DATE",
          icwcd."INTERVAL_THICKNESS",
          icwcd."INTERVAL_THICKNESS_OUOM",
          icwcd."LITHOLOGY_DESC",
          icwcd."POROSITY_LENGTH",
          icwcd."POROSITY_LENGTH_OUOM",
          icwcd."POROSITY_QUALITY",
          icwcd."POROSITY_TYPE",
          icwcd."PPDM_GUID",
          icwcd."REMARK",
          icwcd."SHOW_LENGTH",
          icwcd."SHOW_LENGTH_OUOM",
          icwcd."SHOW_TYPE",
          icwcd."TOP_DEPTH",
          icwcd."TOP_DEPTH_OUOM",
          icwcd."ROW_CHANGED_BY",
          icwcd."ROW_CHANGED_DATE",
          icwcd."ROW_CREATED_BY",
          icwcd."ROW_CREATED_DATE",
          icwcd."ROW_QUALITY",
          --  IHS extensions
          icwcd."PROVINCE_STATE",
          icwcd."X_TOP_STRAT_UNIT_ID",
          icwcd."X_BASE_STRAT_UNIT_ID",
          icwcd."X_PRIMARY_STRAT_UNIT_ID",
          icwcd."TOP_STRAT_AGE",
          icwcd."BASE_STRAT_AGE",
          icwcd."PRIMARY_STRAT_AGE",
          icwcd."STRAT_NAME_SET_ID"
     FROM ihs_cdn_well_core_description icwcd
   UNION ALL
   SELECT iuwcd."UWI",
          iuwcd."SOURCE",
          iuwcd."CORE_ID",
          iuwcd."DESCRIPTION_OBS_NO",
          iuwcd."ACTIVE_IND",
          iuwcd."BASE_DEPTH",
          iuwcd."BASE_DEPTH_OUOM",
          iuwcd."CORE_DESCRIPTION_COMPANY",
          iuwcd."DESCRIPTION_DATE",
          iuwcd."DIP_ANGLE",
          iuwcd."EFFECTIVE_DATE",
          iuwcd."EXPIRY_DATE",
          iuwcd."INTERVAL_THICKNESS",
          iuwcd."INTERVAL_THICKNESS_OUOM",
          iuwcd."LITHOLOGY_DESC",
          iuwcd."POROSITY_LENGTH",
          iuwcd."POROSITY_LENGTH_OUOM",
          iuwcd."POROSITY_QUALITY",
          iuwcd."POROSITY_TYPE",
          iuwcd."PPDM_GUID",
          iuwcd."REMARK",
          iuwcd."SHOW_LENGTH",
          iuwcd."SHOW_LENGTH_OUOM",
          iuwcd."SHOW_TYPE",
          iuwcd."TOP_DEPTH",
          iuwcd."TOP_DEPTH_OUOM",
          iuwcd."ROW_CHANGED_BY",
          iuwcd."ROW_CHANGED_DATE",
          iuwcd."ROW_CREATED_BY",
          iuwcd."ROW_CREATED_DATE",
          iuwcd."ROW_QUALITY",
          --  IHS extensions
          iuwcd."PROVINCE_STATE",
          iuwcd."X_TOP_STRAT_UNIT_ID",
          iuwcd."X_BASE_STRAT_UNIT_ID",
          iuwcd."X_PRIMARY_STRAT_UNIT_ID",
          iuwcd."TOP_STRAT_AGE",
          iuwcd."BASE_STRAT_AGE",
          iuwcd."PRIMARY_STRAT_AGE",
          NULL AS "STRAT_NAME_SET_ID"
     FROM ihs_us_well_core_description iuwcd;


DROP SYNONYM DATA_FINDER.WELL_CORE_DESCRIPTION;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_CORE_DESCRIPTION FOR PPDM.WELL_CORE_DESCRIPTION;


DROP SYNONYM EDIOS_ADMIN.WELL_CORE_DESCRIPTION;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_CORE_DESCRIPTION FOR PPDM.WELL_CORE_DESCRIPTION;


DROP SYNONYM PPDM.WCD;

CREATE OR REPLACE SYNONYM PPDM.WCD FOR PPDM.WELL_CORE_DESCRIPTION;


DROP SYNONYM PPDM.WCRD;

CREATE OR REPLACE SYNONYM PPDM.WCRD FOR PPDM.WELL_CORE_DESCRIPTION;

GRANT SELECT ON PPDM.WELL_CORE_DESCRIPTION TO PPDM_RO;
