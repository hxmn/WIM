DROP VIEW PPDM.IHS_US_WELL_CORE_ANAL_METHOD;

/* Formatted on 4/2/2013 9:10:30 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_CORE_ANAL_METHOD
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
   SELECT wv."UWI",
          wv."SOURCE",
          wuam."CORE_ID",
          wuam."ANALYSIS_OBS_NO",
          wuam."ACTIVE_IND",
          wuam."CORE_SOLVENT",
          wuam."CUTTING_FLUID",
          wuam."DENSITY_ANALYSIS",
          wuam."DRYING_METHOD",
          wuam."DRYING_TEMPERATURE",
          wuam."DRYING_TEMPERATURE_OUOM",
          wuam."DRYING_TIME",
          wuam."DRYING_TIME_OUOM",
          wuam."EFFECTIVE_DATE",
          wuam."EXPIRY_DATE",
          wuam."EXTRACT_METHOD",
          wuam."EXTRACT_TIME",
          wuam."EXTRACT_TIME_OUOM",
          wuam."FLUID_SAT_ANALYSIS",
          wuam."PERMEABILITY_ANALYSIS",
          wuam."POROSITY_ANALYSIS",
          wuam."PPDM_GUID",
          wuam."REMARK",
          wuam."ROW_CHANGED_BY",
          wuam."ROW_CHANGED_DATE",
          wuam."ROW_CREATED_BY",
          wuam."ROW_CREATED_DATE",
          wuam."ROW_QUALITY",
          wuam."PROVINCE_STATE"
     FROM well_core_anal_method@C_TALISMAN_US_IHSDATAQ wuam, well_version wv
    WHERE     wv.well_num = wuam.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_CORE_ANAL_METHOD TO PPDM_RO;
