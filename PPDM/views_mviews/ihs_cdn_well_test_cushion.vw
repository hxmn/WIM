/***************************************************************************************************
 ihs_cdn_well_test_cushion  (view)

 20150817 copied from ihs_well_test_cushion, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_cushion;


create or replace force view ppdm.ihs_cdn_well_test_cushion
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
  select /*+ use_nl(wtc wv) */
         wv.uwi,
         wv.SOURCE,
         wtc.test_type,
         wtc.run_num,
         wtc.test_num,
         wtc.cushion_obs_no,
         wtc.active_ind,
         wtc.cushion_gas_pressure,
         wtc.cushion_gas_pressure_ouom,
         wtc.cushion_inhibitor_volume,
         wtc.cushion_inhibitor_vol_ouom,
         wtc.cushion_length,
         wtc.cushion_length_ouom,
         wtc.cushion_type,
         wtc.cushion_volume,
         wtc.cushion_volume_ouom,
         wtc.effective_date,
         wtc.expiry_date,
         wtc.ppdm_guid,
         wtc.remark,
         wtc.row_changed_by,
         wtc.row_changed_date,
         wtc.row_created_by,
         wtc.row_created_date,
         wtc.row_quality,
         wtc.province_state
    from well_test_cushion@c_talisman_ihsdata wtc, ppdm.well_version wv
   where     wv.ipl_uwi_local = wtc.uwi
         and wv.SOURCE = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_cushion to ppdm_ro;
