/***************************************************************************************************
 ihs_cdn_well_core_sample_desc  (view)

 20150813 copied from ihs_well_core_sample_desc, adapted code by vrajpoot  (task 1164)

 **************************************************************************************************/

--drop view ppdm.ihs_cdn_well_core_sample_desc;


create or replace force view ppdm.ihs_cdn_well_core_sample_desc
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
          wcsd.base_depth,
          wcsd.base_depth_ouom,
          wcsd.description,
          wcsd.dip_angle,
          wcsd.effective_date,
          wcsd.expiry_date,
          wcsd.lithology_desc,
          wcsd.porosity_length,
          wcsd.porosity_length_ouom,
          wcsd.porosity_quality,
          wcsd.porosity_type,
          wcsd.ppdm_guid,
          wcsd.recovered_amount,
          wcsd.recovered_amount_ouom,
          wcsd.remark,
          wcsd.sample_type,
          wcsd.show_length,
          wcsd.show_length_ouom,
          wcsd.show_quality,
          wcsd.show_type,
          wcsd.strat_name_set_id,
          wcsd.strat_unit_id,
          wcsd.swc_recovery_type,
          wcsd.top_depth,
          wcsd.top_depth_ouom,
          wcsd.row_changed_by,
          wcsd.row_changed_date,
          wcsd.row_created_by,
          wcsd.row_created_date,
          wcsd.row_quality,
          wcsd.province_state,
          wcsd.strat_unit_age
     from well_core_sample_desc@c_talisman_ihsdata wcsd, ppdm.well_version wv
    where     wv.ipl_uwi_local = wcsd.uwi
          and wv.source = '300IPL'
          and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_core_sample_desc to ppdm_ro;

