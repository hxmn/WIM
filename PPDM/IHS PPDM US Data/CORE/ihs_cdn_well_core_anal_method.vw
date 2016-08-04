DROP VIEW PPDM.IHS_CDN_WELL_CORE_ANAL_METHOD;

/* Formatted on 4/2/2013 9:10:23 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_CDN_WELL_CORE_ANAL_METHOD
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
   SELECT /*+ RULE */
         wv."UWI",
          wv."SOURCE",
          wcam."CORE_ID",
          wcam."ANALYSIS_OBS_NO",
          wcam."ACTIVE_IND",
          wcam."CORE_SOLVENT",
          wcam."CUTTING_FLUID",
          wcam."DENSITY_ANALYSIS",
          wcam."DRYING_METHOD",
          wcam."DRYING_TEMPERATURE",
          wcam."DRYING_TEMPERATURE_OUOM",
          wcam."DRYING_TIME",
          wcam."DRYING_TIME_OUOM",
          wcam."EFFECTIVE_DATE",
          wcam."EXPIRY_DATE",
          wcam."EXTRACT_METHOD",
          wcam."EXTRACT_TIME",
          wcam."EXTRACT_TIME_OUOM",
          wcam."FLUID_SAT_ANALYSIS",
          wcam."PERMEABILITY_ANALYSIS",
          wcam."POROSITY_ANALYSIS",
          wcam."PPDM_GUID",
          wcam."REMARK",
          wcam."ROW_CHANGED_BY",
          wcam."ROW_CHANGED_DATE",
          wcam."ROW_CREATED_BY",
          wcam."ROW_CREATED_DATE",
          wcam."ROW_QUALITY",
          wcam."PROVINCE_STATE"
     FROM well_core_anal_method@C_TALISMAN_IHSDATA wcam, well_version wv
    WHERE     wv.ipl_uwi_local = wcam.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_CDN_WELL_CORE_ANAL_METHOD TO PPDM_RO;
