/***************************************************************************************************
 ihs_cdn_well_test_analysis  (view)

 20150817 copied from ihs_well_test_analysis, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_test_analysis;


create or replace force view ppdm.ihs_cdn_well_test_analysis
(
  uwi,
  source,
  test_type,
  run_num,
  test_num,
  period_type,
  period_obs_no,
  analysis_obs_no,
  active_ind,
  bsw,
  completion_obs_no,
  condensate_gravity,
  condensate_ratio,
  condensate_ratio_ouom,
  condensate_temperature,
  condensate_temperature_ouom,
  effective_date,
  expiry_date,
  fluid_type,
  gas_content,
  gas_gravity,
  gor,
  gor_ouom,
  gwr,
  gwr_ouom,
  h2s_percent,
  lgr,
  lgr_ouom,
  oil_density,
  oil_density_ouom,
  oil_gravity,
  oil_temperature,
  oil_temperature_ouom,
  ppdm_guid,
  remark,
  salinity_type,
  sulphur_percent,
  water_cut,
  water_resistivity,
  water_resistivity_ouom,
  water_salinity,
  water_salinity_ouom,
  water_temperature,
  water_temperature_ouom,
  wor,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state
)
as
  select /*+ use_nl(wta wv) */
         wv.uwi,
         wv.source,
         wta.test_type,
         wta.run_num,
         wta.test_num,
         wta.period_type,
         wta.period_obs_no,
         wta.analysis_obs_no,
         wta.active_ind,
         wta.bsw,
         wta.completion_obs_no,
         wta.condensate_gravity,
         wta.condensate_ratio,
         wta.condensate_ratio_ouom,
         wta.condensate_temperature,
         wta.condensate_temperature_ouom,
         wta.effective_date,
         wta.expiry_date,
         wta.fluid_type,
         wta.gas_content,
         wta.gas_gravity,
         wta.gor,
         wta.gor_ouom,
         wta.gwr,
         wta.gwr_ouom,
         wta.h2s_percent,
         wta.lgr,
         wta.lgr_ouom,
         wta.oil_density,
         wta.oil_density_ouom,
         wta.oil_gravity,
         wta.oil_temperature,
         wta.oil_temperature_ouom,
         wta.ppdm_guid,
         wta.remark,
         wta.salinity_type,
         wta.sulphur_percent,
         wta.water_cut,
         wta.water_resistivity,
         wta.water_resistivity_ouom,
         wta.water_salinity,
         wta.water_salinity_ouom,
         wta.water_temperature,
         wta.water_temperature_ouom,
         wta.wor,
         wta.row_changed_by,
         wta.row_changed_date,
         wta.row_created_by,
         wta.row_created_date,
         wta.row_quality,
         wta.province_state
    from well_test_analysis@c_talisman_ihsdata wta, well_version wv
   where     wv.ipl_uwi_local = wta.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_test_analysis to ppdm_ro;
