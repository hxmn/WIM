/***************************************************************************************************
 ihs_us_well_core_sample_desc  (view)

 20150812   cdong       Task 1164 add IHS-US data to combo views
 20150814   cdong       adapted vrajpoot code

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_core_sample_desc;


create or replace force view ppdm.ihs_us_well_core_sample_desc
(
  uwi,
  source,
  core_id,
  analysis_obs_no,
  sample_num,
  sample_analysis_obs_no,
  sample_desc_obs_no,
  active_ind,
  base_depth,
  base_depth_ouom,
  description,
  dip_angle,
  effective_date,
  expiry_date,
  lithology_desc,
  porosity_length,
  porosity_length_ouom,
  porosity_quality,
  porosity_type,
  ppdm_guid,
  recovered_amount,
  recovered_amount_ouom,
  remark,
  sample_type,
  show_length,
  show_length_ouom,
  show_quality,
  show_type,
  strat_name_set_id,
  strat_unit_id,
  swc_recovery_type,
  top_depth,
  top_depth_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state,
  strat_unit_age
)
as
  select /*+ use_nl(wcsd wv) */
         wv.uwi,
         wv.source,
         wcsd.core_id,
         wcsd.analysis_obs_no,
         wcsd.sample_num,
         wcsd.sample_analysis_obs_no,
         wcsd.sample_desc_obs_no,
         wcsd.active_ind,
         wcsd.base_depth*.3048          as base_depth,
         'FT'                           as base_depth_ouom,
         wcsd.description,
         wcsd.dip_angle,
         wcsd.effective_date,
         wcsd.expiry_date,
         wcsd.lithology_desc,
         wcsd.porosity_length*.3048     as porosity_length,
         'FT'                           as porosity_length_ouom,
         wcsd.porosity_quality,
         wcsd.porosity_type,
         wcsd.ppdm_guid,
         wcsd.recovered_amount*.3048    as recovered_amount,
         'FT'                           as recovered_amount_ouom,
         wcsd.remark,
         wcsd.sample_type,
         wcsd.show_length*.3048         as show_length,
         'FT'                           as show_length_ouom,
         wcsd.show_quality,
         wcsd.show_type,
         wcsd.strat_name_set_id,
         wcsd.strat_unit_id,
         wcsd.swc_recovery_type,
         wcsd.top_depth*.3048           as top_depth,
         'FT'                           as top_depth_ouom,
         wcsd.row_changed_by,
         wcsd.row_changed_date,
         wcsd.row_created_by,
         wcsd.row_created_date,
         wcsd.row_quality,
         wcsd.province_state,
         wcsd.strat_unit_age
    from well_core_sample_desc@c_talisman_us_ihsdataq wcsd, ppdm.well_version wv
    where    wv.well_num = wcsd.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_core_sample_desc to ppdm_ro;
