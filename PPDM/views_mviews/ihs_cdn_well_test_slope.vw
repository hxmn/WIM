/***************************************************************************************************
 ihs_cdn_well_test_slope  (view)

 20150817 copied from ihs_well_test_slope, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_slope;


create or replace force view ppdm.ihs_cdn_well_test_slope
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
  select /*+ use_nl(wtsl wv) */
         wv.uwi,
         wv.source,
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
    from well_test_slope@c_talisman_ihsdata wtsl, ppdm.well_version wv
   where     wv.ipl_uwi_local = wtsl.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_slope to ppdm_ro;
