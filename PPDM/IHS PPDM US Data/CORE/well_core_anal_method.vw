DROP VIEW PPDM.WELL_CORE_ANAL_METHOD;

DROP TABLE WELL_CORE_ANAL_METHOD CASCADE CONSTRAINTS;

/* Formatted on 4/2/2013 9:10:38 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_CORE_ANAL_METHOD
(
   UWI,
   SOURCE,
   CORE_ID,
   ANALYSIS_OBS_NO,
   ACTIVE_IND,
   CORE_SOLVENT,
   CUTTING_FLUID,
   DENSITY_ANALYSIS,
   DRYING_METHOD,
   DRYING_TEMPERATURE,
   DRYING_TEMPERATURE_OUOM,
   DRYING_TIME,
   DRYING_TIME_OUOM,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   EXTRACT_METHOD,
   EXTRACT_TIME,
   EXTRACT_TIME_OUOM,
   FLUID_SAT_ANALYSIS,
   PERMEABILITY_ANALYSIS,
   POROSITY_ANALYSIS,
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
   SELECT twcam."UWI",
          twcam."SOURCE",
          twcam."CORE_ID",
          twcam."ANALYSIS_OBS_NO",
          twcam."ACTIVE_IND",
          twcam."CORE_SOLVENT",
          twcam."CUTTING_FLUID",
          twcam."DENSITY_ANALYSIS",
          twcam."DRYING_METHOD",
          twcam."DRYING_TEMPERATURE",
          twcam."DRYING_TEMPERATURE_OUOM",
          twcam."DRYING_TIME",
          twcam."DRYING_TIME_OUOM",
          twcam."EFFECTIVE_DATE",
          twcam."EXPIRY_DATE",
          twcam."EXTRACT_METHOD",
          twcam."EXTRACT_TIME",
          twcam."EXTRACT_TIME_OUOM",
          twcam."FLUID_SAT_ANALYSIS",
          twcam."PERMEABILITY_ANALYSIS",
          twcam."POROSITY_ANALYSIS",
          twcam."PPDM_GUID",
          twcam."REMARK",
          twcam."ROW_CHANGED_BY",
          twcam."ROW_CHANGED_DATE",
          twcam."ROW_CREATED_BY",
          twcam."ROW_CREATED_DATE",
          twcam."ROW_QUALITY",
          --  IHS extensions
          NULL AS "PROVINCE_STATE"
     FROM ppdm.tlm_well_core_anal_method twcam
   UNION ALL
   SELECT icwcam."UWI",
          icwcam."SOURCE",
          icwcam."CORE_ID",
          icwcam."ANALYSIS_OBS_NO",
          icwcam."ACTIVE_IND",
          icwcam."CORE_SOLVENT",
          icwcam."CUTTING_FLUID",
          icwcam."DENSITY_ANALYSIS",
          icwcam."DRYING_METHOD",
          icwcam."DRYING_TEMPERATURE",
          icwcam."DRYING_TEMPERATURE_OUOM",
          icwcam."DRYING_TIME",
          icwcam."DRYING_TIME_OUOM",
          icwcam."EFFECTIVE_DATE",
          icwcam."EXPIRY_DATE",
          icwcam."EXTRACT_METHOD",
          icwcam."EXTRACT_TIME",
          icwcam."EXTRACT_TIME_OUOM",
          icwcam."FLUID_SAT_ANALYSIS",
          icwcam."PERMEABILITY_ANALYSIS",
          icwcam."POROSITY_ANALYSIS",
          icwcam."PPDM_GUID",
          icwcam."REMARK",
          icwcam."ROW_CHANGED_BY",
          icwcam."ROW_CHANGED_DATE",
          icwcam."ROW_CREATED_BY",
          icwcam."ROW_CREATED_DATE",
          icwcam."ROW_QUALITY",
          --  IHS extensions
          icwcam."PROVINCE_STATE"
     FROM ihs_cdn_well_core_anal_method icwcam
   UNION ALL
   SELECT iuwcam."UWI",
          iuwcam."SOURCE",
          iuwcam."CORE_ID",
          iuwcam."ANALYSIS_OBS_NO",
          iuwcam."ACTIVE_IND",
          iuwcam."CORE_SOLVENT",
          iuwcam."CUTTING_FLUID",
          iuwcam."DENSITY_ANALYSIS",
          iuwcam."DRYING_METHOD",
          iuwcam."DRYING_TEMPERATURE",
          iuwcam."DRYING_TEMPERATURE_OUOM",
          iuwcam."DRYING_TIME",
          iuwcam."DRYING_TIME_OUOM",
          iuwcam."EFFECTIVE_DATE",
          iuwcam."EXPIRY_DATE",
          iuwcam."EXTRACT_METHOD",
          iuwcam."EXTRACT_TIME",
          iuwcam."EXTRACT_TIME_OUOM",
          iuwcam."FLUID_SAT_ANALYSIS",
          iuwcam."PERMEABILITY_ANALYSIS",
          iuwcam."POROSITY_ANALYSIS",
          iuwcam."PPDM_GUID",
          iuwcam."REMARK",
          iuwcam."ROW_CHANGED_BY",
          iuwcam."ROW_CHANGED_DATE",
          iuwcam."ROW_CREATED_BY",
          iuwcam."ROW_CREATED_DATE",
          iuwcam."ROW_QUALITY",
          --  IHS extensions
          iuwcam."PROVINCE_STATE"
     FROM ihs_us_well_core_anal_method iuwcam;


DROP SYNONYM DATA_FINDER.WELL_CORE_ANAL_METHOD;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_CORE_ANAL_METHOD FOR PPDM.WELL_CORE_ANAL_METHOD;


DROP SYNONYM EDIOS_ADMIN.WELL_CORE_ANAL_METHOD;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_CORE_ANAL_METHOD FOR PPDM.WELL_CORE_ANAL_METHOD;


DROP SYNONYM PPDM.WCAM;

CREATE OR REPLACE SYNONYM PPDM.WCAM FOR PPDM.WELL_CORE_ANAL_METHOD;


DROP SYNONYM PPDM.WCRAM;

CREATE OR REPLACE SYNONYM PPDM.WCRAM FOR PPDM.WELL_CORE_ANAL_METHOD;


GRANT SELECT ON PPDM.WELL_CORE_ANAL_METHOD TO PPDM_RO;
