/*******************************************************************************************
  WELL_TEST_RECORDER  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_recorder;

 
create or replace force view ppdm.well_test_recorder
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   recorder_id,
   active_ind,
   effective_date,
   expiry_date,
   max_capacity_pressure,
   max_capacity_pressure_ouom,
   max_capacity_temp,
   max_capacity_temp_ouom,
   performance_quality,
   ppdm_guid,
   recorder_depth,
   recorder_depth_ouom,
   recorder_inside_ind,
   recorder_max_temp,
   recorder_max_temp_ouom,
   recorder_min_temp,
   recorder_min_temp_ouom,
   recorder_position,
   recorder_resolution,
   recorder_resolution_ouom,
   recorder_type,
   recorder_used_ind,
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
          recorder_id,
          active_ind,
          effective_date,
          expiry_date,
          max_capacity_pressure,
          max_capacity_pressure_ouom,
          max_capacity_temp,
          max_capacity_temp_ouom,
          performance_quality,
          ppdm_guid,
          recorder_depth,
          recorder_depth_ouom,
          recorder_inside_ind,
          recorder_max_temp,
          recorder_max_temp_ouom,
          recorder_min_temp,
          recorder_min_temp_ouom,
          recorder_position,
          recorder_resolution,
          recorder_resolution_ouom,
          recorder_type,
          recorder_used_ind,
          remark,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL    as province_state
     from tlm_well_test_recorder
   union all
   select wtrec.uwi,
          wtrec.source,
          wtrec.test_type,
          wtrec.run_num,
          wtrec.test_num,
          wtrec.recorder_id,
          wtrec.active_ind,
          wtrec.effective_date,
          wtrec.expiry_date,
          wtrec.max_capacity_pressure,
          wtrec.max_capacity_pressure_ouom,
          wtrec.max_capacity_temp,
          wtrec.max_capacity_temp_ouom,
          wtrec.performance_quality,
          wtrec.ppdm_guid,
          wtrec.recorder_depth,
          wtrec.recorder_depth_ouom,
          wtrec.recorder_inside_ind,
          wtrec.recorder_max_temp,
          wtrec.recorder_max_temp_ouom,
          wtrec.recorder_min_temp,
          wtrec.recorder_min_temp_ouom,
          wtrec.recorder_position,
          wtrec.recorder_resolution,
          wtrec.recorder_resolution_ouom,
          wtrec.recorder_type,
          wtrec.recorder_used_ind,
          wtrec.remark,
          wtrec.row_changed_by,
          wtrec.row_changed_date,
          wtrec.row_created_by,
          wtrec.row_created_date,
          wtrec.row_quality,
          --IHS extension
          wtrec.province_state
     from ihs_cdn_well_test_recorder wtrec
   union all
   select wtrec.uwi,
          wtrec.source,
          wtrec.test_type,
          wtrec.run_num,
          wtrec.test_num,
          wtrec.recorder_id,
          wtrec.active_ind,
          wtrec.effective_date,
          wtrec.expiry_date,
          wtrec.max_capacity_pressure,
          wtrec.max_capacity_pressure_ouom,
          wtrec.max_capacity_temp,
          wtrec.max_capacity_temp_ouom,
          wtrec.performance_quality,
          wtrec.ppdm_guid,
          wtrec.recorder_depth,
          wtrec.recorder_depth_ouom,
          wtrec.recorder_inside_ind,
          wtrec.recorder_max_temp,
          wtrec.recorder_max_temp_ouom,
          wtrec.recorder_min_temp,
          wtrec.recorder_min_temp_ouom,
          wtrec.recorder_position,
          wtrec.recorder_resolution,
          wtrec.recorder_resolution_ouom,
          wtrec.recorder_type,
          wtrec.recorder_used_ind,
          wtrec.remark,
          wtrec.row_changed_by,
          wtrec.row_changed_date,
          wtrec.row_created_by,
          wtrec.row_created_date,
          wtrec.row_quality,
          --IHS extension
          wtrec.province_state
     from ihs_us_well_test_recorder wtrec
;


grant select on ppdm.well_test_recorder to ppdm_ro;

--create or replace synonym data_finder.well_test_recorder for ppdm.well_test_recorder;
--create or replace synonym ppdm.wtr for ppdm.well_test_recorder;
