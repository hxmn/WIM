/***************************************************************************************************
 ihs_us_well_test_contaminant  (view)

 20150812   cdong       Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_test_contaminant;


create or replace force view ppdm.ihs_us_well_test_contaminant
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
    from well_test_contaminant@c_talisman_us_ihsdataq wc, ppdm.well_version wv
    where    wv.well_num = wc.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_test_contaminant to ppdm_ro;
