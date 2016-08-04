DROP VIEW PPDM.IHS_CDN_WELL_TEST_PRESSURE;

/* Formatted on 4/2/2013 11:36:11 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_CDN_WELL_TEST_PRESSURE
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   PERIOD_TYPE,
   PERIOD_OBS_NO,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   END_PRESSURE,
   END_PRESSURE_OUOM,
   EXPIRY_DATE,
   PPDM_GUID,
   QUALITY_CODE,
   RECORDER_ID,
   REMARK,
   START_PRESSURE,
   START_PRESSURE_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT /*+ RULE */
         wv.uwi,
          wv.SOURCE,
          wtp.TEST_TYPE,
          wtp.RUN_NUM,
          wtp.TEST_NUM,
          wtp.PERIOD_TYPE,
          wtp.PERIOD_OBS_NO,
          wtp.ACTIVE_IND,
          wtp.EFFECTIVE_DATE,
          wtp.END_PRESSURE,
          wtp.END_PRESSURE_OUOM,
          wtp.EXPIRY_DATE,
          wtp.PPDM_GUID,
          wtp.QUALITY_CODE,
          wtp.RECORDER_ID,
          wtp.REMARK,
          wtp.START_PRESSURE,
          wtp.START_PRESSURE_OUOM,
          wtp.ROW_CHANGED_BY,
          wtp.ROW_CHANGED_DATE,
          wtp.ROW_CREATED_BY,
          wtp.ROW_CREATED_DATE,
          wtp.ROW_QUALITY,
          wtp.PROVINCE_STATE
     FROM well_test_pressure@c_talisman_ihsdata wtp, well_version wv
    WHERE     wv.ipl_uwi_local = wtp.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';

GRANT SELECT ON PPDM.IHS_CDN_WELL_TEST_PRESSURE TO PPDM_RO;
