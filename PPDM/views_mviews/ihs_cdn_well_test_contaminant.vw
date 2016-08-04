/***************************************************************************************************
 ihs_cdn_well_test_contaminant  (view)

 20150817 copied from ihs_well_test_contaminant, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_contaminant;


create or replace force view ppdm.ihs_cdn_well_test_contaminant
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  recovery_obs_no,
  contaminant_seq_no,
  active_ind,
  contaminant_type,
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
  select /*+ use_nl(wc wv) */
         wv.uwi,
         wv.source,
         wc.test_type,
         wc.run_num,
         wc.test_num,
         wc.recovery_obs_no,
         wc.contaminant_seq_no,
         wc.active_ind,
         wc.contaminant_type,
         wc.effective_date,
         wc.expiry_date,
         wc.ppdm_guid,
         wc.remark,
         wc.row_changed_by,
         wc.row_changed_date,
         wc.row_created_by,
         wc.row_created_date,
         wc.row_quality,
         wc.province_state
    from c_talisman.well_test_contaminant@c_talisman_ihsdata wc, ppdm.well_version wv
   where     wv.ipl_uwi_local = wc.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_contaminant to ppdm_ro;
