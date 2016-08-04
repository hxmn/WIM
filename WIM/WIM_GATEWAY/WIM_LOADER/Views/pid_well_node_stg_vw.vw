
  CREATE OR REPLACE FORCE VIEW "WIM_LOADER"."PID_WELL_NODE_STG_VW" ("UWI", "SOURCE", "NODE_ID", "NODE_OBS_NO", "ACQUISITION_ID", "ACTIVE_IND", "COUNTRY", "COUNTY", "EASTING", "EASTING_CUOM", "EASTING_OUOM", "EFFECTIVE_DATE", "ELEV", "ELEV_CUOM", "ELEV_OUOM", "EW_DIRECTION", "EXPIRY_DATE", "GEOG_COORD_SYSTEM_ID", "LATITUDE", "LEGAL_SURVEY_TYPE", "LOCATION_QUALIFIER", "LOCATION_QUALITY", "LONGITUDE", "MAP_COORD_SYSTEM_ID", "MD", "MD_CUOM", "MD_OUOM", "MONUMENT_ID", "MONUMENT_SF_TYPE", "NODE_POSITION", "NORTHING", "NORTHING_CUOM", "NORTHING_OUOM", "NORTH_TYPE", "NS_DIRECTION", "POLAR_AZIMUTH", "POLAR_OFFSET", "POLAR_OFFSET_CUOM", "POLAR_OFFSET_OUOM", "PPDM_GUID", "PREFERRED_IND", "PROVINCE_STATE", "REMARK", "REPORTED_TVD", "REPORTED_TVD_CUOM", "REPORTED_TVD_OUOM", "VERSION_TYPE", "X_OFFSET", "X_OFFSET_CUOM", "X_OFFSET_OUOM", "Y_OFFSET", "Y_OFFSET_CUOM", "Y_OFFSET_OUOM", "IPL_XACTION_CODE", "ROW_CHANGED_BY", "ROW_CHANGED_DATE", "ROW_CREATED_BY", "ROW_CREATED_DATE", "IPL_UWI", "ROW_QUALITY") AS 
  (SELECT wnv.uwi as ipl_uwi, wnv.SOURCE, wnv.node_id node_id,
          TO_NUMBER (wnv.node_obs_no) node_obs_no,
          wnv.acquisition_id acquisition_id, wnv.active_ind active_ind,
          wnv.country country, Substr(wnv.county,3) county, wnv.easting easting,
         /* Cast((select ABREV
            from r_unit_of_measure@c_talisman_us
            where table_name = 'WELL_NODE_VERSION'
              and UOM_SYSTEM_ID = 'IMPERIAL'
              and COLUMN_NAME= 'EASTING') as varchar(2)) AS easting_cuom,*/  
              Cast('FT' as varchar(2)) AS easting_cuom,
             wnv.easting_ouom easting_ouom,
          wnv.effective_date effective_date, wnv.elev elev, 
          
          /*CAST((select ABREV
             from r_unit_of_measure@c_talisman_us
            where table_name = 'WELL_NODE_VERSION'
              and UOM_SYSTEM_ID = 'IMPERIAL'
              and COLUMN_NAME= 'ELEV') as varchar(2)) ,
            */
              
              Cast('FT' as varchar(2)) AS elev_cuom,
          
          --NEW
          wnv.elev_ouom elev_ouom, wnv.ew_direction ew_direction,
          wnv.expiry_date expiry_date,
		  -- QC# 1475
          PPDM_ADMIN.TLM_UTIL.GET_COORD_SYSTEM_ID(wnv.geog_coord_system_id) as geog_coord_system_id,
--          wnv.geog_coord_system_id    ,
          wnv.latitude latitude, wnv.legal_survey_type legal_survey,
          wnv.location_qualifier location_qualifier,
          wnv.location_quality location_quality, wnv.longitude longitude,
          wnv.map_coord_system_id map_coord_system_id, wnv.md md,
        /*  cast( (select ABREV
            from r_unit_of_measure@c_talisman_us
           where table_name = 'WELL_NODE_VERSION'
             and UOM_SYSTEM_ID = 'IMPERIAL'
             and COLUMN_NAME= 'MD') as varchar(2)) AS , */
             
              Cast('FT' as varchar(2)) as md_ouom,                                                --NEW
          
          wnv.md_ouom md_ouom, wnv.monument_id monument_id,
          cast(wnv.monument_sf_type as varchar(30)) monument_sf_type,
          cast(wnv.node_position as varchar(1)) node_position, wnv.northing northing,
          
         /* cast((select ABREV
            from r_unit_of_measure@c_talisman_us
            where table_name = 'WELL_NODE_VERSION'
            and UOM_SYSTEM_ID = 'IMPERIAL'
            and COLUMN_NAME= 'NORTHING') as varchar(2)) */
            
             Cast('FT' as varchar(2)) AS northing_cuom,                                          --NEW
             
          wnv.northing_ouom northing_ouom,
          wnv.north_type north_type, wnv.ns_direction ns_direction,
          wnv.polar_azimuth polar_azimuth, wnv.polar_offset polar_offset,
        /*  Cast((select ABREV
            from r_unit_of_measure@c_talisman_us
            where table_name = 'WELL_NODE_VERSION'
            and UOM_SYSTEM_ID = 'IMPERIAL'
            and COLUMN_NAME= 'POLAR_OFFSET') as varchar(2)) */
            
             Cast('FT' as varchar(2)) AS polar_offset_cuom,      
            
                                            --NEW
          wnv.polar_offset_ouom polar_offset_ouom,
          wnv.ppdm_guid ppdm_guid, wnv.preferred_ind preferred_ind,
          wnv.province_state province_state, wnv.remark remark,
          wnv.reported_tvd reported_tvd, 
        /*  cast((select ABREV
            from r_unit_of_measure@c_talisman_us
            where table_name = 'WELL_NODE_VERSION'
            and UOM_SYSTEM_ID = 'IMPERIAL'
            and COLUMN_NAME= 'REPORTED_TVD')  as varchar(2)) */ 
            
             Cast('FT' as varchar(2)) AS reported_tvd_cuom,       --NEW
             
          wnv.reported_tvd_ouom reported_tvd_ouom,
          wnv.version_type version_type, wnv.x_offset x_offset,
        /*  Cast((select ABREV
            from r_unit_of_measure@c_talisman_us
            where table_name = 'WELL_NODE_VERSION'
            and UOM_SYSTEM_ID = 'IMPERIAL'
            and COLUMN_NAME= 'X_OFFSET') as varchar(2)) */
                         
           Cast('FT' as varchar(2)) AS x_offset_cuom,                                          --NEW
          wnv.x_offset_ouom x_offset_ouom,
          wnv.y_offset y_offset, 
         /* Cast((select ABREV
            from r_unit_of_measure@c_talisman_us
            where table_name = 'WELL_NODE_VERSION'
            and UOM_SYSTEM_ID = 'IMPERIAL'
            and COLUMN_NAME= 'Y_OFFSET') as varchar(2)) */
             Cast('FT' as varchar(2)) AS y_offset_cuom,                   --NEW
            
          wnv.y_offset_ouom y_offset_ouom,
          CAST('' as VARCHAR(1)) AS ipl_xaction_code,
          CAST (wnv.row_changed_by AS VARCHAR (30)) AS row_changed_by,
          wnv.row_changed_date,
          CAST (wnv.row_created_by AS VARCHAR (30)) AS row_created_by,
          wnv.row_created_date, 
          wnv.uwi ipl_uwi,
          wnv.row_quality row_quality
     FROM well_node_versionpidstg_mv wnv
    WHERE LOCATION_QUALIFIER = 'IH'
      AND active_ind = 'Y')
 ;
