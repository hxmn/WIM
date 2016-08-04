/*******************************************************************************************
  WELL_TEST_PERIOD  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_period;


create or replace force view ppdm.well_test_period
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   period_type,
   period_obs_no,
   active_ind,
   casing_pressure,
   casing_pressure_ouom,
   effective_date,
   expiry_date,
   period_duration,
   period_duration_ouom,
   ppdm_guid,
   remark,
   tubing_pressure,
   tubing_pressure_ouom,
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
          casing_pressure,
          casing_pressure_ouom,
          effective_date,
          expiry_date,
          period_duration,
          period_duration_ouom,
          ppdm_guid,
          remark,
          tubing_pressure,
          tubing_pressure_ouom,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL    as province_state
     from tlm_well_test_period
   union all
   select wtp.uwi,
          wtp.source,
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
          --IHS extension
          wtp.province_state
     from ihs_cdn_well_test_period wtp
   union all
   select wtp.uwi,
          wtp.source,
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
          --IHS extension
          wtp.province_state
     from ihs_us_well_test_period wtp
;


grant select on ppdm.well_test_period to ppdm_ro;


--create or replace synonym data_finder.well_test_period for ppdm.well_test_period;
--create or replace synonym ppdm.wtp for ppdm.well_test_period;
