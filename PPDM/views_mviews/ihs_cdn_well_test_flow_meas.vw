/***************************************************************************************************
 ihs_cdn_well_test_flow_meas  (view)

 20150817 copied from ihs_well_test_flow_meas, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_flow_meas;


create or replace force view ppdm.ihs_cdn_well_test_flow_meas
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
  flow_duration,
  flow_duration_ouom,
  fluid_type,
  measurement_pressure,
  measurement_pressure_ouom,
  measurement_time,
  measurement_time_ouom,
  measurement_volume,
  measurement_volume_ouom,
  measurement_volume_uom,
  period_obs_no,
  period_type,
  ppdm_guid,
  remark,
  surface_choke_diameter,
  surface_choke_diameter_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state
)
as
  select /*+ use_nl(wtfm wv) */
         wv.uwi,
         wv.source,
         wtfm.test_type,
         wtfm.run_num,
         wtfm.test_num,
         wtfm.measurement_obs_no,
         wtfm.active_ind,
         wtfm.effective_date,
         wtfm.expiry_date,
         wtfm.flow_duration,
         wtfm.flow_duration_ouom,
         wtfm.fluid_type,
         wtfm.measurement_pressure,
         wtfm.measurement_pressure_ouom,
         wtfm.measurement_time,
         wtfm.measurement_time_ouom,
         wtfm.measurement_volume,
         wtfm.measurement_volume_ouom,
         wtfm.measurement_volume_uom,
         wtfm.period_obs_no,
         wtfm.period_type,
         wtfm.ppdm_guid,
         wtfm.remark,
         wtfm.surface_choke_diameter,
         wtfm.surface_choke_diameter_ouom,
         wtfm.row_changed_by,
         wtfm.row_changed_date,
         wtfm.row_created_by,
         wtfm.row_created_date,
         wtfm.row_quality,
         wtfm.province_state
    from well_test_flow_meas@c_talisman_ihsdata wtfm, ppdm.well_version wv
   where     wv.ipl_uwi_local = wtfm.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_flow_meas to ppdm_ro;
