/***************************************************************************************************
 ihs_us_well_test_cushion  (view)

 20150812   cdong       Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_test_cushion;


create or replace force view ppdm.ihs_us_well_test_cushion
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
         wv.source,
         wtc.test_type,
         wtc.run_num,
         wtc.test_num,
         wtc.cushion_obs_no,
         wtc.active_ind,
         wtc.cushion_gas_pressure,
         wtc.cushion_gas_pressure_ouom,
         wtc.cushion_inhibitor_volume,
         wtc.cushion_inhibitor_vol_ouom,
         wtc.cushion_length*.3048       as cushion_length,
         'FT'                           as cushion_length_ouom,
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
    from well_test_cushion@c_talisman_us_ihsdataq wtc, ppdm.well_version wv
    where    wv.well_num = wtc.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_test_cushion to ppdm_ro;
