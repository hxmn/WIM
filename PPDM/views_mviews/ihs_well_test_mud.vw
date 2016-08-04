/***************************************************************************************************
 ihs_well_test_mud  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_test_mud;

create or replace force view ppdm.ihs_well_test_mud
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  mud_type,
  active_ind,
  effective_date,
  expiry_date,
  filtrate_resistivity,
  filtrate_resistivity_ouom,
  filtrate_salinity,
  filtrate_salinity_ouom,
  filtrate_salinity_uom,
  filtrate_temperature,
  filtrate_temperature_ouom,
  mud_ph,
  mud_resistivity,
  mud_resistivity_ouom,
  mud_salinity,
  mud_salinity_ouom,
  mud_salinity_uom,
  mud_sample_type,
  mud_temperature,
  mud_temperature_ouom,
  mud_viscosity,
  mud_viscosity_ouom,
  mud_weight,
  mud_weight_ouom,
  mud_weight_uom,
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
  select /*+ use_nl(wtmud wv) */
         wv.uwi,
         wtmud.source,
         wtmud.test_type,
         wtmud.run_num,
         wtmud.test_num,
         wtmud.mud_type,
         wtmud.active_ind,
         wtmud.effective_date,
         wtmud.expiry_date,
         wtmud.filtrate_resistivity,
         wtmud.filtrate_resistivity_ouom,
         wtmud.filtrate_salinity,
         wtmud.filtrate_salinity_ouom,
         wtmud.filtrate_salinity_uom,
         wtmud.filtrate_temperature,
         wtmud.filtrate_temperature_ouom,
         wtmud.mud_ph,
         wtmud.mud_resistivity,
         wtmud.mud_resistivity_ouom,
         wtmud.mud_salinity,
         wtmud.mud_salinity_ouom,
         wtmud.mud_salinity_uom,
         wtmud.mud_sample_type,
         wtmud.mud_temperature,
         wtmud.mud_temperature_ouom,
         wtmud.mud_viscosity,
         wtmud.mud_viscosity_ouom,
         wtmud.mud_weight,
         wtmud.mud_weight_ouom,
         wtmud.mud_weight_uom,
         wtmud.ppdm_guid,
         wtmud.remark,
         wtmud.row_changed_by,
         wtmud.row_changed_date,
         wtmud.row_created_by,
         wtmud.row_created_date,
         wtmud.row_quality,
         wtmud.province_state
    from well_test_mud@c_talisman_ihsdata wtmud, well_version wv
   where     wv.ipl_uwi_local = wtmud.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_test_mud to ppdm_ro;
