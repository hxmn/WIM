/***************************************************************************************************

  Combo view to return directional survey station information from Talisman and IHS (Canada and US)

  History
   20141002 cdong       Modify to return only active directional surveys  (TIS Task 1529)
                        This will line up this view with the other dir srvy objects (inventory count, spatial)
   20141121 cdong       Modify to return ipl_uwi_local  (tis task 1547)
                          update tlm dir srvy section to join with well
                          update ihs us section to return ipl_uwi_local, instead of a single-space

 ***************************************************************************************************/

drop view ppdm.well_dir_srvy_station;


create or replace force view ppdm.well_dir_srvy_station
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
  select tlm.uwi,
         tlm.survey_id,
         tlm.source,
         tlm.depth_obs_no,
         tlm.active_ind,
         tlm.azimuth,
         tlm.azimuth_ouom,
         tlm.dog_leg_severity,
         tlm.effective_date,
         tlm.ew_direction,
         tlm.expiry_date,
         tlm.inclination,
         tlm.inclination_ouom,
         tlm.latitude,
         tlm.longitude,
         tlm.ns_direction,
         tlm.point_type,
         tlm.ppdm_guid,
         tlm.remark,
         tlm.station_id,
         tlm.station_md,
         tlm.station_md_ouom,
         tlm.station_tvd,
         tlm.station_tvd_ouom,
         tlm.vertical_section,
         tlm.vertical_section_ouom,
         tlm.x_offset,
         tlm.x_offset_ouom,
         tlm.y_offset,
         tlm.y_offset_ouom,
         tlm.row_changed_by,
         tlm.row_changed_date,
         tlm.row_created_by,
         tlm.row_created_date,
         tlm.row_quality,
         tlm.geog_coord_system_id,
         tlm.province_state,
         tlm.location_qualifier,
         w.ipl_uwi_local
    from ppdm.tlm_well_dir_srvy_station tlm
         inner join ppdm.well w on tlm.uwi = w.uwi
   where tlm.active_ind = 'Y'

  union all
  select uwi,
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
    from ihs_cdn_well_dir_srvy_stn ihsc
   where ihsc.active_ind = 'Y'

  union all
  select uwi,
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
    from ihs_us_well_dir_srvy_station ihsu
   where ihsu.active_ind = 'Y'
;


------------------------------------------------
-- Grants
grant select on ppdm.well_dir_srvy_station to ppdm_ro;
grant select on ppdm.well_dir_srvy_station to dir_srvy_ro;
grant delete, insert, select, update on ppdm.well_dir_srvy_station to dir_srvy_rw;
grant select on ppdm.well_dir_srvy_station to spatial;


------------------------------------------------
-- Synonyms: can be run via ppdm_admin schema
create or replace synonym ppdm.wdss                                 for ppdm.well_dir_srvy_station;
create or replace synonym geowiz.well_dir_srvy_station              for ppdm.well_dir_srvy_station;
create or replace synonym geowiz_survey.well_dir_srvy_station       for ppdm.well_dir_srvy_station;
create or replace synonym sdp.well_dir_srvy_station                 for ppdm.well_dir_srvy_station;
create or replace synonym sdp_appl.well_dir_srvy_station            for ppdm.well_dir_srvy_station;
create or replace synonym data_finder.well_dir_srvy_station         for ppdm.well_dir_srvy_station;
create or replace synonym geowiz_appl.well_dir_srvy_station         for ppdm.well_dir_srvy_station;
create or replace synonym geoframe_appl.well_dir_srvy_station       for ppdm.well_dir_srvy_station;
create or replace synonym geowiz_survey_appl.well_dir_srvy_station  for ppdm.well_dir_srvy_station;
create or replace synonym spatial_appl.well_dir_srvy_station        for ppdm.well_dir_srvy_station;


