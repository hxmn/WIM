DROP VIEW PPDM.IHS_US_WELL_TEST_PERIOD;

/* Formatted on 4/2/2013 11:40:32 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_TEST_PERIOD
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   PERIOD_TYPE,
   PERIOD_OBS_NO,
   ACTIVE_IND,
   CASING_PRESSURE,
   CASING_PRESSURE_OUOM,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PERIOD_DURATION,
   PERIOD_DURATION_OUOM,
   PPDM_GUID,
   REMARK,
   TUBING_PRESSURE,
   TUBING_PRESSURE_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT WV.UWI,
          wv.SOURCE,
          wtp.test_type,
          wtp.run_num,
          wtp.test_num,
          wtp.period_type,
          wtp.period_obs_no,
          wtp.active_ind,
          wtp.casing_pressure,
          wtp.casing_pressure_ouom,
          wtp.effective_date,
          wtp.expiry_date,
          wtp.period_duration,
          wtp.period_duration_ouom,
          wtp.ppdm_guid,
          wtp.remark,
          wtp.tubing_pressure,
          wtp.tubing_pressure_ouom,
          wtp.row_changed_by,
          wtp.row_changed_date,
          wtp.row_created_by,
          wtp.row_created_date,
          wtp.row_quality,
          wtp.province_state
     FROM well_test_period@C_TALISMAN_US_IHSDATAQ wtp, well_version wv
    WHERE     wv.well_num = wtp.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_TEST_PERIOD TO PPDM_RO;
