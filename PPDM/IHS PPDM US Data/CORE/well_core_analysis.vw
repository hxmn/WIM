DROP VIEW PPDM.WELL_CORE_ANALYSIS;
DROP TABLE WELL_CORE_ANALYSIS CASCADE CONSTRAINTS;

/* Formatted on 4/2/2013 9:10:39 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_CORE_ANALYSIS
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
   SELECT twca."UWI",
          twca."SOURCE",
          twca."CORE_ID",
          twca."ANALYSIS_OBS_NO",
          twca."ACTIVE_IND",
          twca."ANALYSIS_DATE",
          twca."ANALYZING_COMPANY",
          twca."ANALYZING_COMPANY_LOC",
          twca."ANALYZING_FILE_NUM",
          twca."CORE_ANALYST_NAME",
          twca."EFFECTIVE_DATE",
          twca."EXPIRY_DATE",
          twca."PPDM_GUID",
          twca."PRIMARY_SAMPLE_TYPE",
          twca."REMARK",
          twca."SAMPLE_DIAMETER",
          twca."SAMPLE_DIAMETER_OUOM",
          twca."SAMPLE_LENGTH",
          twca."SAMPLE_LENGTH_OUOM",
          twca."SAMPLE_SHAPE",
          twca."SECOND_SAMPLE_TYPE",
          twca."ROW_CHANGED_BY",
          twca."ROW_CHANGED_DATE",
          twca."ROW_CREATED_BY",
          twca."ROW_CREATED_DATE",
          twca."ROW_QUALITY",
          --  IHS extensions
          NULL AS "PROVINCE_STATE"
     FROM ppdm.tlm_well_core_analysis twca
   UNION ALL
   SELECT icwca."UWI",
          icwca."SOURCE",
          icwca."CORE_ID",
          icwca."ANALYSIS_OBS_NO",
          icwca."ACTIVE_IND",
          icwca."ANALYSIS_DATE",
          icwca."ANALYZING_COMPANY",
          icwca."ANALYZING_COMPANY_LOC",
          icwca."ANALYZING_FILE_NUM",
          icwca."CORE_ANALYST_NAME",
          icwca."EFFECTIVE_DATE",
          icwca."EXPIRY_DATE",
          icwca."PPDM_GUID",
          icwca."PRIMARY_SAMPLE_TYPE",
          icwca."REMARK",
          icwca."SAMPLE_DIAMETER",
          icwca."SAMPLE_DIAMETER_OUOM",
          icwca."SAMPLE_LENGTH",
          icwca."SAMPLE_LENGTH_OUOM",
          icwca."SAMPLE_SHAPE",
          icwca."SECOND_SAMPLE_TYPE",
          icwca."ROW_CHANGED_BY",
          icwca."ROW_CHANGED_DATE",
          icwca."ROW_CREATED_BY",
          icwca."ROW_CREATED_DATE",
          icwca."ROW_QUALITY",
          --  IHS extensions
          icwca."PROVINCE_STATE"
     FROM ihs_cdn_well_core_analysis icwca
   UNION ALL
   SELECT iuwca."UWI",
          iuwca."SOURCE",
          iuwca."CORE_ID",
          iuwca."ANALYSIS_OBS_NO",
          iuwca."ACTIVE_IND",
          iuwca."ANALYSIS_DATE",
          iuwca."ANALYZING_COMPANY",
          iuwca."ANALYZING_COMPANY_LOC",
          iuwca."ANALYZING_FILE_NUM",
          iuwca."CORE_ANALYST_NAME",
          iuwca."EFFECTIVE_DATE",
          iuwca."EXPIRY_DATE",
          iuwca."PPDM_GUID",
          iuwca."PRIMARY_SAMPLE_TYPE",
          iuwca."REMARK",
          iuwca."SAMPLE_DIAMETER",
          iuwca."SAMPLE_DIAMETER_OUOM",
          iuwca."SAMPLE_LENGTH",
          iuwca."SAMPLE_LENGTH_OUOM",
          iuwca."SAMPLE_SHAPE",
          iuwca."SECOND_SAMPLE_TYPE",
          iuwca."ROW_CHANGED_BY",
          iuwca."ROW_CHANGED_DATE",
          iuwca."ROW_CREATED_BY",
          iuwca."ROW_CREATED_DATE",
          iuwca."ROW_QUALITY",
          iuwca."PROVINCE_STATE"
     FROM ihs_us_well_core_analysis iuwca;


DROP SYNONYM DATA_FINDER.WELL_CORE_ANALYSIS;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_CORE_ANALYSIS FOR PPDM.WELL_CORE_ANALYSIS;


DROP SYNONYM EDIOS_ADMIN.WELL_CORE_ANALYSIS;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_CORE_ANALYSIS FOR PPDM.WELL_CORE_ANALYSIS;


DROP SYNONYM PPDM.WCA;

CREATE OR REPLACE SYNONYM PPDM.WCA FOR PPDM.WELL_CORE_ANALYSIS;


DROP SYNONYM PPDM.WCRA;

CREATE OR REPLACE SYNONYM PPDM.WCRA FOR PPDM.WELL_CORE_ANALYSIS;


DROP SYNONYM PPDM_ADMIN.WELL_CORE_ANALYSIS;

CREATE OR REPLACE SYNONYM PPDM_ADMIN.WELL_CORE_ANALYSIS FOR PPDM.WELL_CORE_ANALYSIS;

DROP SYNONYM WIM.WELL_CORE_ANALYSIS;

CREATE OR REPLACE SYNONYM WIM.WELL_CORE_ANALYSIS FOR PPDM.WELL_CORE_ANALYSIS;


GRANT SELECT ON PPDM.WELL_CORE_ANALYSIS TO PPDM_RO;

GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_CORE_ANALYSIS TO WIM;
