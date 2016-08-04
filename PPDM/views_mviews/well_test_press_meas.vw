/*******************************************************************************************
  WELL_TEST_PRESS_MEAS  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot
                    ** NOTE: at IHS-US, there is NO object  well_test_press_meas **

 *******************************************************************************************/

--drop view ppdm.well_test_press_meas;


create or replace force view ppdm.well_test_press_meas
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   measurement_obs_no,
   active_ind,
   effective_date,
   expiry_date,
   measurement_pressure,
   measurement_pressure_ouom,
   measurement_temperature,
   measurement_temp_ouom,
   measurement_time,
   measurement_time_ouom,
   period_obs_no,
   period_type,
   ppdm_guid,
   recorder_id,
   remark,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   province_state
)
as
   select uwi,
          source,
          test_type,
          run_num,
          test_num,
          measurement_obs_no,
          active_ind,
          effective_date,
          expiry_date,
          measurement_pressure,
          measurement_pressure_ouom,
          measurement_temperature,
          measurement_temp_ouom,
          measurement_time,
          measurement_time_ouom,
          period_obs_no,
          period_type,
          ppdm_guid,
          recorder_id,
          remark,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL    as province_state
     from tlm_well_test_press_meas
   union all
   select wtpm.uwi,
          wtpm.source,
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
          --IHS extension
          wtpm.province_state
     from ihs_cdn_well_test_press_meas wtpm
--   union all
--   select wtpm.uwi,
--          wtpm.source,
--          wtpm.test_type,
--          wtpm.run_num,
--          wtpm.test_num,
--          wtpm.measurement_obs_no,
--          wtpm.active_ind,
--          wtpm.effective_date,
--          wtpm.expiry_date,
--          wtpm.measurement_pressure,
--          wtpm.measurement_pressure_ouom,
--          wtpm.measurement_temperature,
--          wtpm.measurement_temp_ouom,
--          wtpm.measurement_time,
--          wtpm.measurement_time_ouom,
--          wtpm.period_obs_no,
--          wtpm.period_type,
--          wtpm.ppdm_guid,
--          wtpm.recorder_id,
--          wtpm.remark,
--          wtpm.row_changed_by,
--          wtpm.row_changed_date,
--          wtpm.row_created_by,
--          wtpm.row_created_date,
--          wtpm.row_quality,
--          --IHS extension
--          wtpm.province_state
--     from ihs_us_well_test_press_meas wtpm
;


grant select on ppdm.well_test_press_meas to ppdm_ro;


--create or replace synonym data_finder.well_test_press_meas for ppdm.well_test_press_meas;
--create or replace synonym ppdm.wtpm for ppdm.well_test_press_meas;
