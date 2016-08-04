/***************************************************************************************************
 ihs_well_test_period  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_test_period;

create or replace force view ppdm.ihs_well_test_period
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  period_type,
  period_obs_no,
  active_ind,
  casing_pressure,
  casing_pressure_ouom,
  effective_date,
  expiry_date,
  period_duration,
  period_duration_ouom,
  ppdm_guid,
  remark,
  tubing_pressure,
  tubing_pressure_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state
)
as
  select /*+ use_nl(wtp wv) */
         wv.uwi,
         wtp.source,
         wtp.test_type,
         wtp.run_num,
         wtp.test_num,
         wtp.period_type,
         wtp.period_obs_no,
         wtp.active_ind,
         wtp.casing_pressure,
         wtp.casing_pressure_ouom,
         wtp.effective_date,
         wtp.expiry_date,
         wtp.period_duration,
         wtp.period_duration_ouom,
         wtp.ppdm_guid,
         wtp.remark,
         wtp.tubing_pressure,
         wtp.tubing_pressure_ouom,
         wtp.row_changed_by,
         wtp.row_changed_date,
         wtp.row_created_by,
         wtp.row_created_date,
         wtp.row_quality,
         wtp.province_state
    from well_test_period@c_talisman_ihsdata wtp, well_version wv
   where     wv.ipl_uwi_local = wtp.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_test_period to ppdm_ro;
