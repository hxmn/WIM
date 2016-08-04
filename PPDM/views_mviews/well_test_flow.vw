/*******************************************************************************************
  WELL_TEST_FLOW  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_flow;


create or replace force view ppdm.well_test_flow
(
   uwi,
   source,
   test_type,
   run_num,
   test_num,
   period_type,
   period_obs_no,
   fluid_type,
   active_ind,
   basic_sediment_ind,
   blow_desc,
   effective_date,
   expiry_date,
   gas_riser_diameter,
   gas_riser_diameter_ouom,
   max_fluid_rate,
   max_fluid_rate_ouom,
   max_fluid_rate_uom,
   max_surface_pressure,
   max_surface_pressure_ouom,
   measurement_technique,
   ppdm_guid,
   remark,
   shakeout_percent,
   tts_elapsed_time,
   tts_elapsed_time_ouom,
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
          fluid_type,
          active_ind,
          basic_sediment_ind,
          blow_desc,
          effective_date,
          expiry_date,
          gas_riser_diameter,
          gas_riser_diameter_ouom,
          max_fluid_rate,
          max_fluid_rate_ouom,
          max_fluid_rate_uom,
          max_surface_pressure,
          max_surface_pressure_ouom,
          measurement_technique,
          ppdm_guid,
          remark,
          shakeout_percent,
          tts_elapsed_time,
          tts_elapsed_time_ouom,
          row_changed_by,
          row_changed_date,
          row_created_by,
          row_created_date,
          row_quality,
          --IHS extension
          NULL    as province_state
     from tlm_well_test_flow
   union all
   select wtf.uwi,
          wtf.source,
          wtf.test_type,
          wtf.run_num,
          wtf.test_num,
          wtf.period_type,
          wtf.period_obs_no,
          wtf.fluid_type,
          wtf.active_ind,
          wtf.basic_sediment_ind,
          wtf.blow_desc,
          wtf.effective_date,
          wtf.expiry_date,
          wtf.gas_riser_diameter,
          wtf.gas_riser_diameter_ouom,
          wtf.max_fluid_rate,
          wtf.max_fluid_rate_ouom,
          wtf.max_fluid_rate_uom,
          wtf.max_surface_pressure,
          wtf.max_surface_pressure_ouom,
          wtf.measurement_technique,
          wtf.ppdm_guid,
          wtf.remark,
          wtf.shakeout_percent,
          wtf.tts_elapsed_time,
          wtf.tts_elapsed_time_ouom,
          wtf.row_changed_by,
          wtf.row_changed_date,
          wtf.row_created_by,
          wtf.row_created_date,
          wtf.row_quality,
          --IHS extension
          wtf.province_state
     from ihs_cdn_well_test_flow wtf
   union all
   select wtf.uwi,
          wtf.source,
          wtf.test_type,
          wtf.run_num,
          wtf.test_num,
          wtf.period_type,
          wtf.period_obs_no,
          wtf.fluid_type,
          wtf.active_ind,
          wtf.basic_sediment_ind,
          wtf.blow_desc,
          wtf.effective_date,
          wtf.expiry_date,
          wtf.gas_riser_diameter,
          wtf.gas_riser_diameter_ouom,
          wtf.max_fluid_rate,
          wtf.max_fluid_rate_ouom,
          wtf.max_fluid_rate_uom,
          wtf.max_surface_pressure,
          wtf.max_surface_pressure_ouom,
          wtf.measurement_technique,
          wtf.ppdm_guid,
          wtf.remark,
          wtf.shakeout_percent,
          wtf.tts_elapsed_time,
          wtf.tts_elapsed_time_ouom,
          wtf.row_changed_by,
          wtf.row_changed_date,
          wtf.row_created_by,
          wtf.row_created_date,
          wtf.row_quality,
          --IHS extension
          wtf.province_state
     from ihs_us_well_test_flow wtf
;


grant select on ppdm.well_test_flow to ppdm_ro;


--create or replace synonym data_finder.well_test_flow for ppdm.well_test_flow;
--create or replace synonym ppdm.wtf for ppdm.well_test_flow;
