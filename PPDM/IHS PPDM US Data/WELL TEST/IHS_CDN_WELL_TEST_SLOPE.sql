DROP VIEW IHS_CDN_WELL_TEST_SLOPE;

/* Formatted on 11/06/2013 8:31:40 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW IHS_CDN_WELL_TEST_SLOPE
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   PERIOD_NUM,
   SEG_ID,
   SEG_QC,
   SLOPE_LIQ,
   EXTRAP_PRESS_LIQ,
   SLOPE_GAS,
   EXTRAP_PRESS_GAS,
   IHP,
   FHP,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE,
   ACTIVE_IND,
   PERIOD_TYPE,
   RECORDER_ID
)
AS
   SELECT /*+ RULE */
         wv.uwi,
          '300IPL',
          wtsl.test_type,
          wtsl.run_num,
          wtsl.test_num,
          wtsl.period_num,
          wtsl.seg_id,
          wtsl.seg_qc,
          wtsl.slope_liq,
          wtsl.extrap_press_liq,
          wtsl.slope_gas,
          wtsl.extrap_press_gas,
          wtsl.ihp,
          wtsl.fhp,
          wtsl.row_changed_by,
          wtsl.row_changed_date,
          wtsl.row_created_by,
          wtsl.row_created_date,
          wtsl.row_quality,
          wtsl.province_state,
          wtsl.active_ind,
          wtsl.period_type,
          wtsl.recorder_id
     FROM well_test_slope@c_talisman_ihsdata wtsl, well_version wv
    WHERE     wv.ipl_uwi_local = wtsl.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';


GRANT SELECT ON IHS_CDN_WELL_TEST_SLOPE TO PPDM_RO;
