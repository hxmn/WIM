DROP VIEW PPDM.IHS_US_WELL_CORE_ANALYSIS;

/* Formatted on 4/2/2013 9:10:30 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_CORE_ANALYSIS
(
   UWI,
   SOURCE,
   CORE_ID,
   ANALYSIS_OBS_NO,
   ACTIVE_IND,
   ANALYSIS_DATE,
   ANALYZING_COMPANY,
   ANALYZING_COMPANY_LOC,
   ANALYZING_FILE_NUM,
   CORE_ANALYST_NAME,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   PRIMARY_SAMPLE_TYPE,
   REMARK,
   SAMPLE_DIAMETER,
   SAMPLE_DIAMETER_OUOM,
   SAMPLE_LENGTH,
   SAMPLE_LENGTH_OUOM,
   SAMPLE_SHAPE,
   SECOND_SAMPLE_TYPE,
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
          wca."CORE_ID",
          wca."ANALYSIS_OBS_NO",
          wca."ACTIVE_IND",
          wca."ANALYSIS_DATE",
          wca."ANALYZING_COMPANY",
          wca."ANALYZING_COMPANY_LOC",
          wca."ANALYZING_FILE_NUM",
          wca."CORE_ANALYST_NAME",
          wca."EFFECTIVE_DATE",
          wca."EXPIRY_DATE",
          wca."PPDM_GUID",
          wca."PRIMARY_SAMPLE_TYPE",
          wca."REMARK",
          wca."SAMPLE_DIAMETER",
          wca."SAMPLE_DIAMETER_OUOM",
          SAMPLE_LENGTH*.3048 as "SAMPLE_LENGTH",
          'FT' as "SAMPLE_LENGTH_OUOM",
          wca."SAMPLE_SHAPE",
          wca."SECOND_SAMPLE_TYPE",
          wca."ROW_CHANGED_BY",
          wca."ROW_CHANGED_DATE",
          wca."ROW_CREATED_BY",
          wca."ROW_CREATED_DATE",
          wca."ROW_QUALITY",
          wca."PROVINCE_STATE"
     FROM well_core_analysis@C_TALISMAN_US_IHSDATAQ wca, well_version wv
    WHERE     wv.well_num = wca.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_CORE_ANALYSIS TO PPDM_RO;
