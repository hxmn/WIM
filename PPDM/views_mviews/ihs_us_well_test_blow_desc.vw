/***************************************************************************************************
 ihs_us_well_test_blow_desc  (view)

 20150812   cdong       Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_test_blow_desc;


create or replace force view ppdm.ihs_us_well_test_blow_desc
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
         wv.source,
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
    from well_test_blow_desc@c_talisman_us_ihsdataq wtbd, ppdm.well_version wv
   where     wv.well_num = wtbd.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_test_blow_desc to ppdm_ro;
