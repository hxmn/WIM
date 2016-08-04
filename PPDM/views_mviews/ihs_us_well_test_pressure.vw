/***************************************************************************************************
 ihs_us_well_test_pressure  (view)

 20150812   cdong       Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_test_pressure;


create or replace force view ppdm.ihs_us_well_test_pressure
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
  select /*+ use_nl(wtp wv) */
         wv.uwi,
         wv.source,
         wtp.test_type,
         wtp.run_num,
         wtp.test_num,
         wtp.period_type,
         wtp.period_obs_no,
         wtp.active_ind,
         wtp.effective_date,
         wtp.end_pressure,
         wtp.end_pressure_ouom,
         wtp.expiry_date,
         wtp.ppdm_guid,
         wtp.quality_code,
         wtp.recorder_id,
         wtp.remark,
         wtp.start_pressure,
         wtp.start_pressure_ouom,
         wtp.row_changed_by,
         wtp.row_changed_date,
         wtp.row_created_by,
         wtp.row_created_date,
         wtp.row_quality,
         wtp.province_state
    from well_test_pressure@c_talisman_us_ihsdataq wtp, ppdm.well_version wv
   where     wv.well_num = wtp.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_test_pressure to ppdm_ro;
