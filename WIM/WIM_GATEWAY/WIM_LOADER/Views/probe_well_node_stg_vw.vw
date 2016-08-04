
  CREATE OR REPLACE FORCE VIEW "WIM_LOADER"."PROBE_WELL_NODE_STG_VW" ("UWI", "SOURCE", "NODE_ID", "NODE_OBS_NO", "ACQUISITION_ID", "ACTIVE_IND", "COUNTRY", "COUNTY", "EASTING", "EASTING_CUOM", "EASTING_OUOM", "EFFECTIVE_DATE", "ELEV", "ELEV_CUOM", "ELEV_OUOM", "EW_DIRECTION", "EXPIRY_DATE", "GEOG_COORD_SYSTEM_ID", "LATITUDE", "LEGAL_SURVEY", "LOCATION_QUALIFIER", "LOCATION_QUALITY", "LONGITUDE", "MAP_COORD_SYSTEM_ID", "MD", "MD_CUOM", "MD_OUOM", "MONUMENT_ID", "MONUMENT_SF_TYPE", "NODE_POSITION", "NORTHING", "NORTHING_CUOM", "NORTHING_OUOM", "NORTH_TYPE", "NS_DIRECTION", "POLAR_AZIMUTH", "POLAR_OFFSET", "POLAR_OFFSET_CUOM", "POLAR_OFFSET_OUOM", "PPDM_GUID", "PREFERRED_IND", "PROVINCE_STATE", "REMARK", "REPORTED_TVD", "REPORTED_TVD_CUOM", "REPORTED_TVD_OUOM", "VERSION_TYPE", "X_OFFSET", "X_OFFSET_CUOM", "X_OFFSET_OUOM", "Y_OFFSET", "Y_OFFSET_CUOM", "Y_OFFSET_OUOM", "IPL_XACTION_CODE", "ROW_CHANGED_BY", "ROW_CHANGED_DATE", "ROW_CREATED_BY", "ROW_CREATED_DATE", "IPL_UWI", "ROW_QUALITY") AS 
  SELECT wnv.ipl_uwi,
          wnv.SOURCE,
          wnv.node_id node_id,
          TO_NUMBER (wnv.node_obs_no) node_obs_no,
          wnv.acquisition_id acquisition_id,
          wnv.active_ind active_ind,
          wnv.country country,
          wnv.county county,
          wnv.easting easting,
          CAST ('M' AS VARCHAR (2)) easting_cuom,                        --NEW
          wnv.easting_ouom easting_ouom,
          wnv.effective_date effective_date,
          wnv.elev elev,
          CAST ('M' AS VARCHAR (2)) AS elev_cuom,
          --NEW
          wnv.elev_ouom elev_ouom,
          wnv.ew_direction ew_direction,
          wnv.expiry_date expiry_date,
		  -- QC# 1475 - this value is no longer converted int the MV.
          PPDM_ADMIN.TLM_UTIL.GET_COORD_SYSTEM_ID(wnv.geog_coord_system_id) geog_coord_system_id,
--          wnv.geog_coord_system_id,
          wnv.latitude latitude,
          wnv.legal_survey_type legal_survey,
          wnv.location_qualifier location_qualifier,
          wnv.location_quality location_quality,
          wnv.longitude longitude,
          wnv.map_coord_system_id map_coord_system_id,
          wnv.md md,
          CAST ('M' AS VARCHAR (2)) AS md_ouom,                          --NEW
          wnv.md_ouom md_ouom,
          wnv.monument_id monument_id,
          wnv.monument_sf_type monument_sf_type,
          wnv.node_position node_position,
          wnv.northing northing,
          CAST ('M' AS VARCHAR (2)) AS northing_cuom,                    --NEW
          wnv.northing_ouom northing_ouom,
          wnv.north_type north_type,
          wnv.ns_direction ns_direction,
          wnv.polar_azimuth polar_azimuth,
          wnv.polar_offset polar_offset,
          CAST ('M' AS VARCHAR (2)) AS polar_offset_cuom,                --NEW
          wnv.polar_offset_ouom polar_offset_ouom,
          wnv.ppdm_guid ppdm_guid,
          wnv.preferred_ind preferred_ind,
          wnv.province_state province_state,
          wnv.remark remark,
          wnv.reported_tvd reported_tvd,
          CAST ('M' AS VARCHAR (2)) AS reported_tvd_cuom,                --NEW
          wnv.reported_tvd_ouom reported_tvd_ouom,
          wnv.version_type version_type,
          wnv.x_offset x_offset,
          CAST ('M' AS VARCHAR (2)) AS x_offset_cuom,                    --NEW
          wnv.x_offset_ouom x_offset_ouom,
          wnv.y_offset y_offset,
          CAST ('M' AS VARCHAR (2)) AS y_offset_cuom,                    --NEW
          wnv.y_offset_ouom y_offset_ouom,
          wnv.ipl_xaction_code ipl_xaction_code,
          CAST (wnv.row_changed_by AS VARCHAR (30)) AS row_changed_by,
          wnv.row_changed_date row_changed_date,
          CAST (wnv.row_created_by AS VARCHAR (30)) AS row_created_by,
          wnv.row_created_date row_created_date,
          wnv.ipl_uwi ipl_uwi,
          wnv.row_quality row_quality
     FROM well_node_versionPRBSTG_MV wnv
 ;
