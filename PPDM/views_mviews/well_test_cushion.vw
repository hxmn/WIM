/*******************************************************************************************
  WELL_TEST_CUSHION  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_cushion;


create or replace force view ppdm.well_test_cushion
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   cushion_obs_no,
   active_ind,
   cushion_gas_pressure,
   cushion_gas_pressure_ouom,
   cushion_inhibitor_volume,
   cushion_inhibitor_vol_ouom,
   cushion_length,
   cushion_length_ouom,
   cushion_type,
   cushion_volume,
   cushion_volume_ouom,
   effective_date,
   expiry_date,
   ppdm_guid,
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
          cushion_obs_no,
          active_ind,
          cushion_gas_pressure,
          cushion_gas_pressure_ouom,
          cushion_inhibitor_volume,
          cushion_inhibitor_vol_ouom,
          cushion_length,
          cushion_length_ouom,
          cushion_type,
          cushion_volume,
          cushion_volume_ouom,
          effective_date,
          expiry_date,
          ppdm_guid,
          remark,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL      as province_state
     from tlm_well_test_cushion
   union all
   select wtcc.uwi,
          wtcc.source,
          wtcc.test_type,
          wtcc.run_num,
          wtcc.test_num,
          wtcc.cushion_obs_no,
          wtcc.active_ind,
          wtcc.cushion_gas_pressure,
          wtcc.cushion_gas_pressure_ouom,
          wtcc.cushion_inhibitor_volume,
          wtcc.cushion_inhibitor_vol_ouom,
          wtcc.cushion_length,
          wtcc.cushion_length_ouom,
          wtcc.cushion_type,
          wtcc.cushion_volume,
          wtcc.cushion_volume_ouom,
          wtcc.effective_date,
          wtcc.expiry_date,
          wtcc.ppdm_guid,
          wtcc.remark,
          wtcc.row_changed_by,
          wtcc.row_changed_date,
          wtcc.row_created_by,
          wtcc.row_created_date,
          wtcc.row_quality,
          --IHS extension
          wtcc.province_state
     from ihs_cdn_well_test_cushion wtcc
   union all
   select wtcc.uwi,
          wtcc.source,
          wtcc.test_type,
          wtcc.run_num,
          wtcc.test_num,
          wtcc.cushion_obs_no,
          wtcc.active_ind,
          wtcc.cushion_gas_pressure,
          wtcc.cushion_gas_pressure_ouom,
          wtcc.cushion_inhibitor_volume,
          wtcc.cushion_inhibitor_vol_ouom,
          wtcc.cushion_length,
          wtcc.cushion_length_ouom,
          wtcc.cushion_type,
          wtcc.cushion_volume,
          wtcc.cushion_volume_ouom,
          wtcc.effective_date,
          wtcc.expiry_date,
          wtcc.ppdm_guid,
          wtcc.remark,
          wtcc.row_changed_by,
          wtcc.row_changed_date,
          wtcc.row_created_by,
          wtcc.row_created_date,
          wtcc.row_quality,
          --IHS extension
          wtcc.province_state
     from ihs_us_well_test_cushion wtcc
;


grant select on ppdm.well_test_cushion to ppdm_ro;


--create or replace synonym data_finder.well_test_cushion for ppdm.well_test_cushion;
--create or replace synonym ppdm.wtcu for ppdm.well_test_cushion;
