DROP VIEW PPDM.WELL_TEST_SLOPE;

/* Formatted on 4/2/2013 11:41:14 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_TEST_SLOPE
(
   UWI,
   SOURCE,
   ACTIVE_IND,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   PERIOD_NUM,
   SEG_ID,
   SEG_QC,
   EXTRAP_PRESS_LIQ,
   SLOPE_GAS,
   EXTRAP_PRESS_GAS,
   IHP,
   FHP,
   PROVINCE_STATE,
   PERIOD_TYPE,
   RECORDER_ID,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY
)
AS
   SELECT "UWI",
          "SOURCE",
          "ACTIVE_IND",
          "TEST_TYPE",
          "RUN_NUM",
          "TEST_NUM",
          "PERIOD_NUM",
          "SEG_ID",
          "SEG_QC",
          "EXTRAP_PRESS_LIQ",
          "SLOPE_GAS",
          "EXTRAP_PRESS_GAS",
          "IHP",
          "FHP",
          "PROVINCE_STATE",
          "PERIOD_TYPE",
          "RECORDER_ID",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY"          
     FROM tlm_well_test_slope
   UNION ALL
   SELECT wtrmk.uwi,
          wtrmk.SOURCE,
          wtrmk.active_ind,
          wtrmk.test_type,
          wtrmk.run_num,
          wtrmk.test_num,
          wtrmk.PERIOD_NUM,          
          wtrmk.SEG_ID,
          wtrmk.SEG_QC,
          wtrmk.EXTRAP_PRESS_LIQ,
          wtrmk.SLOPE_GAS,
          wtrmk.EXTRAP_PRESS_GAS,
          wtrmk.IHP,
          wtrmk.FHP,
          wtrmk.province_state,
          wtrmk.period_type,
          wtrmk.recorder_id,
          wtrmk.row_changed_by,
          wtrmk.row_changed_date,
          wtrmk.row_created_by,
          wtrmk.row_created_date,
          wtrmk.row_quality          
     FROM IHS_CDN_WELL_TEST_slope wtrmk;


DROP SYNONYM DATA_FINDER.WELL_TEST_SLOPE;
CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_SLOPE FOR PPDM.WELL_TEST_SLOPE;


DROP SYNONYM EDIOS_ADMIN.WELL_TEST_SLOPE;
CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_SLOPE FOR PPDM.WELL_TEST_SLOPE;


DROP SYNONYM PPDM.WTRM;
CREATE OR REPLACE SYNONYM PPDM.WTRM FOR PPDM.WELL_TEST_SLOPE;


GRANT SELECT ON PPDM.WELL_TEST_SLOPE TO PPDM_RO;
