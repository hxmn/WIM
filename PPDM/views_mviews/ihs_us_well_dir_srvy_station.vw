/***************************************************************************************************
 ihs_us_well_dir_srvy_station  (view)

 History
 20141121 cdong     tis task 1547: get ipl_uwi_local from well_version
                    add hint for nested-loop join (just-in-case, to be like the ihs canada dir srvy stn view
 20160614 cdong     QC1838
                    Change conversion to use hard-coded value of 0.3048 (ft to m), which is faster
                      than using the wim.wim_util.uom_conversion function.
                    Use lpad to set survey_id to three characters, instead of ppdm_admin.tlm_util.prefix_zeros.
                      This would then make the survey_id consistent with code for the DF US dir srvy mv.
                      Data at IHS is '1', '2', '3', '4', '5', '101'.
                    Use case-stmt to resolve EPSG code for geog_coord_system_id, instead of utility
                      function ppdm_admin.tlm_util.prefix_zeros.
                      Data at IHS is 'NAD27' or 'NAD83'.

 **************************************************************************************************/

--drop view ppdm.ihs_us_well_dir_srvy_station;

create or replace force view ppdm.ihs_us_well_dir_srvy_station
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
         lpad(wdss.survey_id, 3, '0')     as survey_id,
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
         wdss.station_md * 0.3048         as station_md,
         wdss.station_md_ouom,
         wdss.station_tvd * 0.3048        as station_tvd,
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
         case upper(nvl(wdss.geog_coord_system_id, 'foo'))
             when 'NAD83' then '4269'
             when 'NAD27' then '4267'
             when 'FOO'   then NULL
             else '9999'
           end                            as geog_coord_system_id,
         wdss.province_state,
         wdss.location_qualifier,
         wv.ipl_uwi_local
    from well_dir_srvy_station@c_talisman_us_ihsdataq wdss, well_version wv
   where     wv.well_num = wdss.uwi
         and wv.source = '450PID'
         and wv.active_ind = 'Y'
;


------------------------------------------------
-- Grants
grant select on ppdm.ihs_us_well_dir_srvy_station to data_finder;
grant select on ppdm.ihs_us_well_dir_srvy_station to dir_srvy_ro;
grant select on ppdm.ihs_us_well_dir_srvy_station to ppdm_ro;
grant select on ppdm.ihs_us_well_dir_srvy_station to spatial;
grant select on ppdm.ihs_us_well_dir_srvy_station to wim_ro;
