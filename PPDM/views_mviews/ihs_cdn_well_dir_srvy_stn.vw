/***************************************************************************************************
 ihs_cdn_well_dir_srvy_stn  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_cdn_well_dir_srvy_stn;

create or replace force view ppdm.ihs_cdn_well_dir_srvy_stn
(
  uwi,
  survey_id,
  source,
  depth_obs_no,
  active_ind,
  azimuth,
  azimuth_ouom,
  dog_leg_severity,
  effective_date,
  ew_direction,
  expiry_date,
  inclination,
  inclination_ouom,
  latitude,
  longitude,
  ns_direction,
  point_type,
  ppdm_guid,
  remark,
  station_id,
  station_md,
  station_md_ouom,
  station_tvd,
  station_tvd_ouom,
  vertical_section,
  vertical_section_ouom,
  x_offset,
  x_offset_ouom,
  y_offset,
  y_offset_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  geog_coord_system_id,
  province_state,
  location_qualifier,
  ipl_uwi_local
)
as
  select /*+ use_nl(wdss wv) */
         wv.uwi,
         wdss.survey_id,
         wv.source,
         wdss.depth_obs_no,
         wdss.active_ind,
         wdss.azimuth,
         wdss.azimuth_ouom,
         wdss.dog_leg_severity,
         wdss.effective_date,
         wdss.ew_direction,
         wdss.expiry_date,
         wdss.inclination,
         wdss.inclination_ouom,
         wdss.latitude,
         wdss.longitude,
         wdss.ns_direction,
         wdss.point_type,
         wdss.ppdm_guid,
         wdss.remark,
         wdss.station_id,
         wdss.station_md,
         wdss.station_md_ouom,
         wdss.station_tvd,
         wdss.station_tvd_ouom,
         wdss.vertical_section,
         wdss.vertical_section_ouom,
         wdss.x_offset,
         wdss.x_offset_ouom,
         wdss.y_offset,
         wdss.y_offset_ouom,
         wdss.row_changed_by,
         wdss.row_changed_date,
         wdss.row_created_by,
         wdss.row_created_date,
         wdss.row_quality,
         --wdss.geog_coord_system_id,
         ppdm_admin.tlm_util.Get_coord_System_ID (wdss.geog_coord_system_id),
         wdss.province_state,
         wdss.location_qualifier,
         wv.ipl_uwi_local
    from well_dir_srvy_station@c_talisman_ihsdata wdss, well_version wv
   where     wdss.uwi = wv.ipl_uwi_local
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_cdn_well_dir_srvy_stn to data_finder;

grant select on ppdm.ihs_cdn_well_dir_srvy_stn to dir_srvy_ro;

grant select on ppdm.ihs_cdn_well_dir_srvy_stn to ppdm_ro;

grant select on ppdm.ihs_cdn_well_dir_srvy_stn to spatial;
