/*******************************************************************************************
   WELL_DIR_SRVY_STATION  (View)

 *******************************************************************************************/

--drop view PPDM.WELL_DIR_SRVY_STATION;


create or replace force view PPDM.WELL_DIR_SRVY_STATION
(
   UWI,
   SURVEY_ID,
   SOURCE,
   DEPTH_OBS_NO,
   ACTIVE_IND,
   AZIMUTH,
   AZIMUTH_OUOM,
   DOG_LEG_SEVERITY,
   EFFECTIVE_DATE,
   EW_DIRECTION,
   EXPIRY_DATE,
   INCLINATION,
   INCLINATION_OUOM,
   LATITUDE,
   LONGITUDE,
   NS_DIRECTION,
   POINT_TYPE,
   PPDM_GUID,
   REMARK,
   STATION_ID,
   STATION_MD,
   STATION_MD_OUOM,
   STATION_TVD,
   STATION_TVD_OUOM,
   VERTICAL_SECTION,
   VERTICAL_SECTION_OUOM,
   X_OFFSET,
   X_OFFSET_OUOM,
   Y_OFFSET,
   Y_OFFSET_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   GEOG_COORD_SYSTEM_ID,
   PROVINCE_STATE,
   LOCATION_QUALIFIER,
   IPL_UWI_LOCAL
)
AS
   SELECT tlm.uwi,
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
     FROM ppdm.tlm_well_dir_srvy_station tlm
          INNER JOIN ppdm.well w ON tlm.uwi = w.uwi
    WHERE tlm.active_ind = 'Y'
   UNION ALL
   SELECT uwi,
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
     FROM ihs_cdn_well_dir_srvy_stn ihsc
    WHERE ihsc.active_ind = 'Y'
   UNION ALL
   SELECT uwi,
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
     FROM ihs_us_well_dir_srvy_station ihsu
    WHERE ihsu.active_ind = 'Y'
;


GRANT SELECT ON PPDM.WELL_DIR_SRVY_STATION TO DIR_SRVY_RO;
GRANT DELETE, INSERT, SELECT, UPDATE ON PPDM.WELL_DIR_SRVY_STATION TO DIR_SRVY_RW;
GRANT SELECT ON PPDM.WELL_DIR_SRVY_STATION TO PPDM_RO;
GRANT SELECT ON PPDM.WELL_DIR_SRVY_STATION TO SPATIAL;


--CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_DIR_SRVY_STATION FOR PPDM.WELL_DIR_SRVY_STATION;
--CREATE OR REPLACE SYNONYM GEOFRAME_APPL.WELL_DIR_SRVY_STATION FOR PPDM.WELL_DIR_SRVY_STATION;
--CREATE OR REPLACE SYNONYM GEOWIZ.WELL_DIR_SRVY_STATION FOR PPDM.WELL_DIR_SRVY_STATION;
--CREATE OR REPLACE SYNONYM GEOWIZ_APPL.WELL_DIR_SRVY_STATION FOR PPDM.WELL_DIR_SRVY_STATION;
--CREATE OR REPLACE SYNONYM GEOWIZ_SURVEY_APPL.WELL_DIR_SRVY_STATION FOR PPDM.WELL_DIR_SRVY_STATION;
--CREATE OR REPLACE SYNONYM OPENSPIRIT_APPL.WELL_DIR_SRVY_STATION FOR PPDM.WELL_DIR_SRVY_STATION;
--CREATE OR REPLACE SYNONYM PPDM.WDSS FOR PPDM.WELL_DIR_SRVY_STATION;
--CREATE OR REPLACE SYNONYM SPATIAL_APPL.WELL_DIR_SRVY_STATION FOR PPDM.WELL_DIR_SRVY_STATION;
