/***************************************************************************************************
 ihs_cdn_well_dir_srvy  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_cdn_well_dir_srvy;

create or replace force view ppdm.ihs_cdn_well_dir_srvy
(
  uwi,
  survey_id,
  source,
  active_ind,
  azimuth_north_type,
  base_depth,
  base_depth_ouom,
  compute_method,
  coord_system_id,
  dir_survey_class,
  effective_date,
  ew_direction,
  expiry_date,
  magnetic_declination,
  offset_north_type,
  plane_of_proposal,
  ppdm_guid,
  record_mode,
  remark,
  report_apd,
  report_log_datum,
  report_log_datum_elev,
  report_log_datum_elev_ouom,
  report_perm_datum,
  report_perm_datum_elev,
  report_perm_datum_elev_ouom,
  source_document,
  survey_company,
  survey_date,
  survey_numeric_id,
  survey_quality,
  survey_type,
  top_depth,
  top_depth_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state,
  x_orig_document
)
as
  select /*+ use_nl(wds wv) */
         wv.uwi,
         wds.survey_id,
         wv.source,
         wds.active_ind,
         wds.azimuth_north_type,
         wds.base_depth,
         wds.base_depth_ouom,
         wds.compute_method,
         ppdm_admin.tlm_util.Get_coord_System_ID (wds.coord_system_id),
         wds.dir_survey_class,
         wds.effective_date,
         wds.ew_direction,
         wds.expiry_date,
         wds.magnetic_declination,
         wds.offset_north_type,
         wds.plane_of_proposal,
         wds.ppdm_guid,
         wds.record_mode,
         wds.remark,
         wds.report_apd,
         wds.report_log_datum,
         wds.report_log_datum_elev,
         wds.report_log_datum_elev_ouom,
         wds.report_perm_datum,
         wds.report_perm_datum_elev,
         wds.report_perm_datum_elev_ouom,
         wds.source_document,
         wds.survey_company,
         wds.survey_date,
         wds.survey_numeric_id,
         wds.survey_quality,
         wds.survey_type,
         wds.top_depth,
         wds.top_depth_ouom,
         wds.row_changed_by,
         wds.row_changed_date,
         wds.row_created_by,
         wds.row_created_date,
         wds.row_quality,
         wds.province_state,
         ' ' as x_orig_document
    from well_dir_srvy@c_talisman_ihsdata wds, well_version wv
   where     wv.ipl_uwi_local = wds.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_dir_srvy to data_finder;

grant select on ppdm.ihs_cdn_well_dir_srvy to dir_srvy_ro;

grant select on ppdm.ihs_cdn_well_dir_srvy to ppdm_ro;

grant select on ppdm.ihs_cdn_well_dir_srvy to spatial;
