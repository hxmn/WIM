/***************************************************************************************************
 ihs_well_test_recovery  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_test_recovery;

create or replace force view ppdm.ihs_well_test_recovery
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  recovery_obs_no,
  active_ind,
  effective_date,
  expiry_date,
  multiple_test_ind,
  period_obs_no,
  period_type,
  ppdm_guid,
  recovery_amount,
  recovery_amount_ouom,
  recovery_amount_percent,
  recovery_amount_uom,
  recovery_desc,
  recovery_method,
  recovery_show_type,
  recovery_type,
  remark,
  reverse_circulation_ind,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state
)
as
  select /*+ use_nl(wtrv wv) */ 
         wv.uwi,
         wtrv.source,
         wtrv.test_type,
         wtrv.run_num,
         wtrv.test_num,
         wtrv.recovery_obs_no,
         wtrv.active_ind,
         wtrv.effective_date,
         wtrv.expiry_date,
         wtrv.multiple_test_ind,
         wtrv.period_obs_no,
         wtrv.period_type,
         wtrv.ppdm_guid,
         wtrv.recovery_amount,
         wtrv.recovery_amount_ouom,
         wtrv.recovery_amount_percent,
         wtrv.recovery_amount_uom,
         wtrv.recovery_desc,
         wtrv.recovery_method,
         wtrv.recovery_show_type,
         wtrv.recovery_type,
         wtrv.remark,
         wtrv.reverse_circulation_ind,
         wtrv.row_changed_by,
         wtrv.row_changed_date,
         wtrv.row_created_by,
         wtrv.row_created_date,
         wtrv.row_quality,
         wtrv.province_state
    from well_test_recovery@c_talisman_ihsdata wtrv, well_version wv
   where     wv.ipl_uwi_local = wtrv.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_test_recovery to ppdm_ro;