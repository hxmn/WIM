/***************************************************************************************************
 ihs_well_test_recorder  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_test_recorder;

create or replace force view ppdm.ihs_well_test_recorder
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
  select /*+ use_nl(wtrec wv) */
         wv.uwi,
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
         wtrec.province_state
    from well_test_recorder@c_talisman_ihsdata wtrec, well_version wv
   where     wv.ipl_uwi_local = wtrec.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_test_recorder to ppdm_ro;
