DROP VIEW CWS_WELL_NODE_STG_VW;

/* Formatted on 30/09/2013 9:18:13 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW CWS_WELL_NODE_STG_VW
(
   UWI,
   SOURCE,
   NODE_ID,
   NODE_OBS_NO,
   ACQUISITION_ID,
   ACTIVE_IND,
   COUNTRY,
   COUNTY,
   EASTING,
   EASTING_CUOM,
   EASTING_OUOM,
   EFFECTIVE_DATE,
   ELEV,
   ELEV_CUOM,
   ELEV_OUOM,
   EW_DIRECTION,
   EXPIRY_DATE,
   GEOG_COORD_SYSTEM_ID,
   LATITUDE,
   LEGAL_SURVEY,
   LOCATION_QUALIFIER,
   LOCATION_QUALITY,
   LONGITUDE,
   MAP_COORD_SYSTEM_ID,
   MD,
   MD_CUOM,
   MD_OUOM,
   MONUMENT_ID,
   MONUMENT_SF_TYPE,
   NODE_POSITION,
   NORTHING,
   NORTHING_CUOM,
   NORTHING_OUOM,
   NORTH_TYPE,
   NS_DIRECTION,
   POLAR_AZIMUTH,
   POLAR_OFFSET,
   POLAR_OFFSET_CUOM,
   POLAR_OFFSET_OUOM,
   PPDM_GUID,
   PREFERRED_IND,
   PROVINCE_STATE,
   REMARK,
   REPORTED_TVD,
   REPORTED_TVD_CUOM,
   REPORTED_TVD_OUOM,
   VERSION_TYPE,
   X_OFFSET,
   X_OFFSET_CUOM,
   X_OFFSET_OUOM,
   Y_OFFSET,
   Y_OFFSET_CUOM,
   Y_OFFSET_OUOM,
   IPL_XACTION_CODE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   IPL_UWI,
   ROW_QUALITY
)
AS
   SELECT CAST (w.well_id AS VARCHAR (20)) uwi,
          CAST ('100TLM' AS VARCHAR (20)) SOURCE,
          CAST (c.well_id || '0' AS VARCHAR (20)) node_id,
          1 node_obs_no,
          CAST (NULL AS VARCHAR (20)) acquisition_id,
          'Y' active_ind,
          CASE country_cd
             WHEN 'CA' THEN '7CN'
             WHEN 'CO' THEN '2CO'
             WHEN 'CU' THEN '2CU'
             WHEN 'DZ' THEN '1AL'
             WHEN 'GA' THEN '1GA'
             WHEN 'GB' THEN '5UK'
             WHEN 'ID' THEN '3ID'
             WHEN 'MY' THEN '3MA'
             WHEN 'NA' THEN '1NA'
             WHEN 'NL' THEN '5NT'
             WHEN 'PER' THEN '2PE'
             WHEN 'QA' THEN '6QA'
             WHEN 'SDN' THEN '1SU'
             WHEN 'TT' THEN '2TT'
             WHEN 'TU' THEN '1TU'
             WHEN 'US' THEN '7US'
             WHEN 'VN' THEN '3VI'
             WHEN 'AU' THEN '4AU'
             WHEN 'KU' THEN '6IA'
             WHEN 'IQ' THEN '6IA'
             ELSE NULL
          END
             AS country,
          CAST (NULL AS VARCHAR (18)) county,
          CAST (NULL AS NUMBER) easting,
          CAST ('M' AS VARCHAR (2)) AS easting_cuom,
          CAST (NULL AS VARCHAR (20)) easting_ouom,
          CAST (NULL AS DATE) effective_date,
          CAST (NULL AS NUMBER) elev,
          CAST ('M' AS VARCHAR (2)) AS elev_cuom,
          CAST (NULL AS VARCHAR (20)) elev_ouom,
          CAST (NULL AS VARCHAR (20)) ew_direction,
          CAST (NULL AS DATE) expiry_date,
          CAST (
             DECODE (country_cd,  'US', '4267',  'CA', '4267',  '4326') AS VARCHAR (20))
             geog_coord_system_id,
          base.well_node_latitude latitude,
          CAST (base.legal_survey_type_cd AS VARCHAR (20)) legal_survey,
          CAST ('N/A' AS VARCHAR (20)) location_qualifier,
          CAST (NULL AS VARCHAR (20)) location_quality,
          base.well_node_longitude longitude,
          CAST (NULL AS VARCHAR (20)) map_coord_system_id,
          CAST (NULL AS NUMBER) md,
          CAST ('M' AS VARCHAR (2)) AS md_cuom,
          CAST (NULL AS VARCHAR (20)) md_ouom,
          CAST (NULL AS VARCHAR (20)) monument_id,
          CAST (NULL AS VARCHAR (30)) monument_sf_type,
          'B' node_position,
          CAST (NULL AS NUMBER) northing,
          CAST ('M' AS VARCHAR (2)) AS northing_cuom,
          CAST (NULL AS VARCHAR (20)) northing_ouom,
          CAST (NULL AS VARCHAR (20)) north_type,
          CAST (NULL AS VARCHAR (20)) ns_direction,
          CAST (NULL AS NUMBER) polar_azimuth,
          CAST (NULL AS NUMBER) polar_offset,
          CAST ('M' AS VARCHAR (2)) AS b_polar_offset_cuom,
          CAST (NULL AS VARCHAR (20)) polar_offset_ouom,
          CAST (NULL AS VARCHAR (38)) ppdm_guid,
          CAST (NULL AS VARCHAR (1)) preferred_ind,
          c.province_state_cd province_state,
          CAST (base.well_node_rem AS VARCHAR (2000)) AS remark,
          CAST (NULL AS NUMBER) reported_tvd,
          CAST ('M' AS VARCHAR (2)) AS reported_tvd_cuom,
          CAST (NULL AS VARCHAR (20)) reported_tvd_ouom,
          CAST (NULL AS VARCHAR (20)) version_type,
          CAST (NULL AS NUMBER) x_offset,
          CAST ('M' AS VARCHAR (2)) AS x_offset_cuom,
          CAST (NULL AS VARCHAR (20)) x_offset_ouom,
          CAST (NULL AS NUMBER) y_offset,
          CAST ('M' AS VARCHAR (2)) AS y_offset_cuom,
          CAST (NULL AS VARCHAR (20)) y_offset_ouom,
          CAST (NULL AS VARCHAR (1)) ipl_xaction_code,
          base.last_update_userid row_changed_by,
          base.last_update_dt row_changed_date,
          base.create_userid row_created_by,
          base.create_dt row_created_date,
          CAST (w.well_id AS VARCHAR (20)) ipl_uwi,
          CAST (NULL AS VARCHAR (20)) row_quality
     FROM well_current_data@cws.world c,
          well@cws.world w,
          well_node@cws.world base
    WHERE     w.well_id = c.well_id
          AND base.well_node_id = c.base_node_id
          AND (NVL (c.well_status_cd, 'z') != 'CANCEL')
          AND (    well_node_longitude IS NOT NULL
               AND well_node_latitude IS NOT NULL)
   UNION
   SELECT CAST (w.well_id AS VARCHAR (20)) uwi,
          CAST ('100TLM' AS VARCHAR (20)) SOURCE,
          CAST (c.well_id || '1' AS VARCHAR (20)) node_id,
          1 node_obs_no,
          CAST (NULL AS VARCHAR (20)) acquisition_id,
          'Y' active_ind,
          CASE country_cd
             WHEN 'CA' THEN '7CN'
             WHEN 'CO' THEN '2CO'
             WHEN 'CU' THEN '2CU'
             WHEN 'DZ' THEN '1AL'
             WHEN 'GA' THEN '1GA'
             WHEN 'GB' THEN '5UK'
             WHEN 'ID' THEN '3ID'
             WHEN 'MY' THEN '3MA'
             WHEN 'NA' THEN '1NA'
             WHEN 'NL' THEN '5NT'
             WHEN 'PER' THEN '2PE'
             WHEN 'QA' THEN '6QA'
             WHEN 'SDN' THEN '1SU'
             WHEN 'TT' THEN '2TT'
             WHEN 'TU' THEN '1TU'
             WHEN 'US' THEN '7US'
             WHEN 'VN' THEN '3VI'
             WHEN 'AU' THEN '4AU'
             WHEN 'KU' THEN '6IA'
             WHEN 'IQ' THEN '6IA'
             ELSE NULL
          END
             AS country,
          CAST (NULL AS VARCHAR (18)) county,
          CAST (NULL AS NUMBER) easting,
          CAST ('M' AS VARCHAR (2)) AS easting_cuom,
          CAST (NULL AS VARCHAR (20)) easting_ouom,
          CAST (NULL AS DATE) effective_date,
          CAST (NULL AS NUMBER) elev,
          CAST ('M' AS VARCHAR (2)) AS elev_cuom,
          CAST (NULL AS VARCHAR (20)) elev_ouom,
          CAST (NULL AS VARCHAR (20)) ew_direction,
          CAST (NULL AS DATE) expiry_date,
          CAST (
             DECODE (country_cd,  'US', '4267',  'CA', '4267',  '4326') AS VARCHAR (20))
             geog_coord_system_id,
          surface.well_node_latitude latitude,
          CAST (surface.legal_survey_type_cd AS VARCHAR (20)) legal_survey,
          CAST ('N/A' AS VARCHAR (20)) location_qualifier,
          CAST (NULL AS VARCHAR (20)) location_quality,
          surface.well_node_longitude longitude,
          CAST (NULL AS VARCHAR (20)) map_coord_system_id,
          CAST (NULL AS NUMBER) md,
          CAST ('M' AS VARCHAR (2)) AS md_cuom,
          CAST (NULL AS VARCHAR (20)) md_ouom,
          CAST (NULL AS VARCHAR (20)) monument_id,
          CAST (NULL AS VARCHAR (30)) monument_sf_type,
          'S' node_position,
          CAST (NULL AS NUMBER) northing,
          CAST ('M' AS VARCHAR (2)) AS northing_cuom,
          CAST (NULL AS VARCHAR (20)) northing_ouom,
          CAST (NULL AS VARCHAR (20)) north_type,
          CAST (NULL AS VARCHAR (20)) ns_direction,
          CAST (NULL AS NUMBER) polar_azimuth,
          CAST (NULL AS NUMBER) polar_offset,
          CAST ('M' AS VARCHAR (2)) AS b_polar_offset_cuom,
          CAST (NULL AS VARCHAR (20)) polar_offset_ouom,
          CAST (NULL AS VARCHAR (38)) ppdm_guid,
          CAST (NULL AS VARCHAR (1)) preferred_ind,
          c.province_state_cd province_state,
          CAST (surface.well_node_rem AS VARCHAR (2000)) AS remark,
          CAST (NULL AS NUMBER) reported_tvd,
          CAST ('M' AS VARCHAR (2)) AS reported_tvd_cuom,
          CAST (NULL AS VARCHAR (20)) reported_tvd_ouom,
          CAST (NULL AS VARCHAR (20)) version_type,
          CAST (NULL AS NUMBER) x_offset,
          CAST ('M' AS VARCHAR (2)) AS x_offset_cuom,
          CAST (NULL AS VARCHAR (20)) x_offset_ouom,
          CAST (NULL AS NUMBER) y_offset,
          CAST ('M' AS VARCHAR (2)) AS y_offset_cuom,
          CAST (NULL AS VARCHAR (20)) y_offset_ouom,
          CAST (NULL AS VARCHAR (1)) ipl_xaction_code,
          surface.last_update_userid row_changed_by,
          surface.last_update_dt row_changed_date,
          surface.create_userid row_created_by,
          surface.create_dt row_created_date,
          CAST (w.well_id AS VARCHAR (20)) ipl_uwi,
          CAST (NULL AS VARCHAR (20)) row_quality
     FROM well_current_data@cws.world c,
          well@cws.world w,
          well_node@cws.world surface
    WHERE     w.well_id = c.well_id
          AND surface.well_node_id = c.surface_node_id
          AND (NVL (c.well_status_cd, 'z') != 'CANCEL')
          AND (    well_node_longitude IS NOT NULL
               AND well_node_latitude IS NOT NULL);


GRANT SELECT ON CWS_WELL_NODE_STG_VW TO VRAJPOOT;
