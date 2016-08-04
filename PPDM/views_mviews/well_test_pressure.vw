/*******************************************************************************************
  WELL_TEST_PRESSURE  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_pressure;


create or replace force view ppdm.well_test_pressure
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   period_type,
   period_obs_no,
   active_ind,
   effective_date,
   end_pressure,
   end_pressure_ouom,
   expiry_date,
   ppdm_guid,
   quality_code,
   recorder_id,
   remark,
   start_pressure,
   start_pressure_ouom,
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
          period_type,
          period_obs_no,
          active_ind,
          effective_date,
          end_pressure,
          end_pressure_ouom,
          expiry_date,
          ppdm_guid,
          quality_code,
          recorder_id,
          remark,
          start_pressure,
          start_pressure_ouom,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL    as province_state
     from tlm_well_test_pressure
   union all
   select wtpr.uwi,
          wtpr.source,
          wtpr.test_type,
          wtpr.run_num,
          wtpr.test_num,
          wtpr.period_type,
          wtpr.period_obs_no,
          wtpr.active_ind,
          wtpr.effective_date,
          wtpr.end_pressure,
          wtpr.end_pressure_ouom,
          wtpr.expiry_date,
          wtpr.ppdm_guid,
          wtpr.quality_code,
          wtpr.recorder_id,
          wtpr.remark,
          wtpr.start_pressure,
          wtpr.start_pressure_ouom,
          wtpr.row_changed_by,
          wtpr.row_changed_date,
          wtpr.row_created_by,
          wtpr.row_created_date,
          wtpr.row_quality,
          --IHS extension
          wtpr.province_state
     from ihs_cdn_well_test_pressure wtpr
   union all
   select wtpr.uwi,
          wtpr.source,
          wtpr.test_type,
          wtpr.run_num,
          wtpr.test_num,
          wtpr.period_type,
          wtpr.period_obs_no,
          wtpr.active_ind,
          wtpr.effective_date,
          wtpr.end_pressure,
          wtpr.end_pressure_ouom,
          wtpr.expiry_date,
          wtpr.ppdm_guid,
          wtpr.quality_code,
          wtpr.recorder_id,
          wtpr.remark,
          wtpr.start_pressure,
          wtpr.start_pressure_ouom,
          wtpr.row_changed_by,
          wtpr.row_changed_date,
          wtpr.row_created_by,
          wtpr.row_created_date,
          wtpr.row_quality,
          --IHS extension
          wtpr.province_state
     from ihs_us_well_test_pressure wtpr
;


grant select on ppdm.well_test_pressure to ppdm_ro;


--create or replace synonym data_finder.well_test_pressure for ppdm.well_test_pressure;
--create or replace synonym ppdm.wtpsr for ppdm.well_test_pressure;
