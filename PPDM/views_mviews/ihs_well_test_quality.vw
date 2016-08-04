/***************************************************************************************************
 ihs_well_test_quality  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_test_quality;

create or replace force view ppdm.ihs_well_test_quality
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  quality_obs_no,
  test_result_code,
  quality_misrun_code,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  province_state,
  active_ind
)
as
  select /*+ use_nl(wtq wv) */
         wv.uwi,
         wtq.source,
         wtq.test_type,
         wtq.run_num,
         wtq.test_num,
         wtq.quality_obs_no,
         wtq.test_result_code,
         wtq.quality_misrun_code,
         wtq.row_changed_by,
         wtq.row_changed_date,
         wtq.row_created_by,
         wtq.row_created_date,
         wtq.province_state,
         wtq.active_ind
    from well_test_quality@c_talisman_ihsdata wtq, well_version wv
   where     wv.ipl_uwi_local = wtq.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_test_quality to ppdm_ro;
