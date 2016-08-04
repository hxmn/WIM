/***************************************************************************************************
 ihs_us_well_test_equipment  (view)

 20150812   cdong       Task 1164 add IHS-US data to combo views, adapted code by vrajpoot

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_test_equipment;


create or replace force view ppdm.ihs_us_well_test_equipment
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
         wte.equip_length*.3048         as equip_length,
         'FT'                           as equip_length_ouom,
         wte.equip_weight,
         wte.equip_weight_ouom,
         wte.expiry_date,
         wte.inside_diameter,
         wte.inside_diameter_ouom,
         wte.outside_diameter,
         wte.outside_diameter_ouom,
         wte.ppdm_guid,
         wte.remark,
         wte.top_depth*.3048            as top_depth,
         'FT'                           as top_depth_ouom,
         wte.row_changed_by,
         wte.row_changed_date,
         wte.row_created_by,
         wte.row_created_date,
         wte.row_quality,
         wte.x_equip_grade,
         wte.province_state
    from well_test_equipment@c_talisman_us_ihsdataq wte, ppdm.well_version wv
    where    wv.well_num = wte.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_test_equipment to ppdm_ro;
