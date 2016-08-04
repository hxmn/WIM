/*******************************************************************************************
  WELL_TEST_SLOPE  (View)

  20150818  cdong   include IHS US data (tis task 1164)

 *******************************************************************************************/

--drop view ppdm.well_test_slope;

 
create or replace force view ppdm.well_test_slope
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   period_num,
   seg_id,
   seg_qc,
   slope_liq,
   extrap_press_liq,
   slope_gas,
   extrap_press_gas,
   ihp,
   fhp,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   province_state,
   active_ind,
   period_type,
   recorder_id
)
as
   select uwi,
          source,
          test_type,
          run_num,
          test_num,
          period_num,
          seg_id,
          seg_qc,
          slope_liq,
          extrap_press_liq,
          slope_gas,
          extrap_press_gas,
          ihp,
          fhp,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          province_state,
          active_ind,
          period_type,
          recorder_id
     from tlm_well_test_slope
   union all
   select wtsl.uwi,
          wtsl.source,
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
     from ihs_cdn_well_test_slope wtsl
   union all
   select wtsl.uwi,
          wtsl.source,
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
     from ihs_us_well_test_slope wtsl
;


grant select on ppdm.well_test_slope to ppdm_ro;


--create or replace synonym data_finder.well_test_slope for ppdm.well_test_slope;
