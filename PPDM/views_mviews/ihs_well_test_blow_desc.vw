/***************************************************************************************************
 ihs_well_test_blow_desc  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_test_blow_desc;

create or replace force view ppdm.ihs_well_test_blow_desc
(
  uwi,
  source,
  test_type,
  test_num,
  blow_obs_num,
  blow_description,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state,
  run_num,
  active_ind
)
as
  select /*+ use_nl(wtbd wv) */
         wv.uwi,
         wtbd.source,
         wtbd.test_type,
         wtbd.test_num,
         wtbd.blow_obs_num,
         wtbd.blow_description,
         wtbd.row_changed_by,
         wtbd.row_changed_date,
         wtbd.row_created_by,
         wtbd.row_created_date,
         wtbd.row_quality,
         wtbd.province_state,
         wtbd.run_num,
         wtbd.active_ind
    from well_test_blow_desc@c_talisman_ihsdata wtbd, well_version wv
   where     wv.ipl_uwi_local = wtbd.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_test_blow_desc to ppdm_ro;
