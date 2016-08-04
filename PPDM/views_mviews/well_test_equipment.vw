/*******************************************************************************************
  WELL_TEST_EQUIPMENT  (View)

  20150818  cdong   include IHS US data (tis task 1164), adapted code by vrajpoot

 *******************************************************************************************/

--drop view ppdm.well_test_equipment;


create or replace force view ppdm.well_test_equipment
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
   select uwi,
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
          --IHS extension
          NULL      as x_equip_grade,
          NULL      as province_state
     from tlm_well_test_equipment
   union all
   select wte.uwi,
          wte.source,
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
          --IHS extension
          wte.x_equip_grade,
          wte.province_state
     from ihs_cdn_well_test_equipment wte
   union all
   select wte.uwi,
          wte.source,
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
          --IHS extension
          wte.x_equip_grade,
          wte.province_state
     from ihs_us_well_test_equipment wte
;


grant select on ppdm.well_test_equipment to ppdm_ro;


--create or replace synonym data_finder.well_test_equipment for ppdm.well_test_equipment;
--create or replace synonym ppdm.wte for ppdm.well_test_equipment;
