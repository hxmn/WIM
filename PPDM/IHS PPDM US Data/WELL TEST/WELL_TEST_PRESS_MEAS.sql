DROP VIEW WELL_TEST_PRESS_MEAS;

/* Formatted on 11/06/2013 8:31:02 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW WELL_TEST_PRESS_MEAS
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   MEASUREMENT_OBS_NO,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   MEASUREMENT_PRESSURE,
   MEASUREMENT_PRESSURE_OUOM,
   MEASUREMENT_TEMPERATURE,
   MEASUREMENT_TEMP_OUOM,
   MEASUREMENT_TIME,
   MEASUREMENT_TIME_OUOM,
   PERIOD_OBS_NO,
   PERIOD_TYPE,
   PPDM_GUID,
   RECORDER_ID,
   REMARK,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT 
          uwi,
          wtpm.SOURCE,
          wtpm.test_type,
          wtpm.run_num,
          wtpm.test_num,
          wtpm.measurement_obs_no,
          wtpm.active_ind,
          wtpm.effective_date,
          wtpm.expiry_date,
          wtpm.measurement_pressure,
          wtpm.measurement_pressure_ouom,
          wtpm.measurement_temperature,
          wtpm.measurement_temp_ouom,
          wtpm.measurement_time,
          wtpm.measurement_time_ouom,
          wtpm.period_obs_no,
          wtpm.period_type,
          wtpm.ppdm_guid,
          wtpm.recorder_id,
          wtpm.remark,
          wtpm.row_changed_by,
          wtpm.row_changed_date,
          wtpm.row_created_by,
          wtpm.row_created_date,
          wtpm.row_quality,
          null as province_state
     FROM tlm_well_test_press_meas wtpm
    WHERE active_ind = 'Y'
   
   union all
   SELECT /*+ RULE */
         uwi,
          wtpm.SOURCE,
          wtpm.test_type,
          wtpm.run_num,
          wtpm.test_num,
          wtpm.measurement_obs_no,
          wtpm.active_ind,
          wtpm.effective_date,
          wtpm.expiry_date,
          wtpm.measurement_pressure,
          wtpm.measurement_pressure_ouom,
          wtpm.measurement_temperature,
          wtpm.measurement_temp_ouom,
          wtpm.measurement_time,
          wtpm.measurement_time_ouom,
          wtpm.period_obs_no,
          wtpm.period_type,
          wtpm.ppdm_guid,
          wtpm.recorder_id,
          wtpm.remark,
          wtpm.row_changed_by,
          wtpm.row_changed_date,
          wtpm.row_created_by,
          wtpm.row_created_date,
          wtpm.row_quality,
          wtpm.province_state
     FROM IHS_CDN_WELL_TEST_PRESS_MEAS wtpm;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_PRESS_MEAS FOR WELL_TEST_PRESS_MEAS;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_PRESS_MEAS FOR WELL_TEST_PRESS_MEAS;

CREATE OR REPLACE SYNONYM WTPM FOR WELL_TEST_PRESS_MEAS;


GRANT SELECT ON WELL_TEST_PRESS_MEAS TO PPDM_RO;
