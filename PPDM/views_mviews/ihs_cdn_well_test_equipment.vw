/***************************************************************************************************
 ihs_cdn_well_test_equipment  (view)

 20150817 copied from ihs_well_test_equipment, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_equipment;


create or replace force view ppdm.ihs_cdn_well_test_equipment
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  equipment_type,
  equip_obs_no,
  active_ind,
  effective_date,
  equip_length,
  equip_length_ouom,
  equip_weight,
  equip_weight_ouom,
  expiry_date,
  inside_diameter,
  inside_diameter_ouom,
  outside_diameter,
  outside_diameter_ouom,
  ppdm_guid,
  remark,
  top_depth,
  top_depth_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  x_equip_grade,
  province_state
)
as
  select /*+ use_nl(wte wv) */
         wv.uwi,
         wv.source,
         wte.test_type,
         wte.run_num,
         wte.test_num,
         wte.equipment_type,
         wte.equip_obs_no,
         wte.active_ind,
         wte.effective_date,
         wte.equip_length,
         wte.equip_length_ouom,
         wte.equip_weight,
         wte.equip_weight_ouom,
         wte.expiry_date,
         wte.inside_diameter,
         wte.inside_diameter_ouom,
         wte.outside_diameter,
         wte.outside_diameter_ouom,
         wte.ppdm_guid,
         wte.remark,
         wte.top_depth,
         wte.top_depth_ouom,
         wte.row_changed_by,
         wte.row_changed_date,
         wte.row_created_by,
         wte.row_created_date,
         wte.row_quality,
         wte.x_equip_grade,
         wte.province_state
    from well_test_equipment@c_talisman_ihsdata wte, ppdm.well_version wv
   where     wv.ipl_uwi_local = wte.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_equipment to ppdm_ro;
