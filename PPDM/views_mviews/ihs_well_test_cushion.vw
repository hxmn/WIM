/***************************************************************************************************
 ihs_well_test_cushion  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_test_cushion;

create or replace force view ppdm.ihs_well_test_cushion
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
  select /*+ use_nl(wtcc wv) */
         wv.uwi,
         wtcc.SOURCE,
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
         wtcc.province_state
    from well_test_cushion@c_talisman_ihsdata wtcc, well_version wv
   where     wv.ipl_uwi_local = wtcc.uwi
         and wv.SOURCE = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_test_cushion to ppdm_ro;
