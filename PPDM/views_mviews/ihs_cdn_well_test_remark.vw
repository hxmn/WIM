/***************************************************************************************************
 ihs_cdn_well_test_remark  (view)

 20150817 copied from ihs_well_test_remark, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_remark;


create or replace force view ppdm.ihs_cdn_well_test_remark
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  remark_obs_no,
  active_ind,
  effective_date,
  expiry_date,
  ppdm_guid,
  remark,
  remark_type,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state
)
as
  select /*+ use_nl(wtrmk wv) */
         wv.uwi,
         wv.source,
         wtrmk.test_type,
         wtrmk.run_num,
         wtrmk.test_num,
         wtrmk.remark_obs_no,
         wtrmk.active_ind,
         wtrmk.effective_date,
         wtrmk.expiry_date,
         wtrmk.ppdm_guid,
         wtrmk.remark,
         wtrmk.remark_type,
         wtrmk.row_changed_by,
         wtrmk.row_changed_date,
         wtrmk.row_created_by,
         wtrmk.row_created_date,
         wtrmk.row_quality,
         wtrmk.province_state
    from well_test_remark@c_talisman_ihsdata wtrmk, ppdm.well_version wv
   where     wv.ipl_uwi_local = wtrmk.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_remark to ppdm_ro;
