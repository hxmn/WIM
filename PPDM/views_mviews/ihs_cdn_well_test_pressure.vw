/***************************************************************************************************
 ihs_cdn_well_test_pressure  (view)

 20150817 copied from ihs_well_test_pressure, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_pressure;


create or replace force view ppdm.ihs_cdn_well_test_pressure
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  period_type,
  period_obs_no,
  active_ind,
  effective_date,
  end_pressure,
  end_pressure_ouom,
  expiry_date,
  ppdm_guid,
  quality_code,
  recorder_id,
  remark,
  start_pressure,
  start_pressure_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state
)
as
  select /*+ use_nl(wtpr wv) */
         wv.uwi,
         wv.source,
         wtpr.test_type,
         wtpr.run_num,
         wtpr.test_num,
         wtpr.period_type,
         wtpr.period_obs_no,
         wtpr.active_ind,
         wtpr.effective_date,
         wtpr.end_pressure,
         wtpr.end_pressure_ouom,
         wtpr.expiry_date,
         wtpr.ppdm_guid,
         wtpr.quality_code,
         wtpr.recorder_id,
         wtpr.remark,
         wtpr.start_pressure,
         wtpr.start_pressure_ouom,
         wtpr.row_changed_by,
         wtpr.row_changed_date,
         wtpr.row_created_by,
         wtpr.row_created_date,
         wtpr.row_quality,
         wtpr.province_state
    from well_test_pressure@c_talisman_ihsdata wtpr, ppdm.well_version wv
   where     wv.ipl_uwi_local = wtpr.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_pressure to ppdm_ro;
