DROP PROCEDURE IPL_PPDM_COMPARE_REPORT;

CREATE OR REPLACE PROCEDURE            "IPL_PPDM_COMPARE_REPORT" 
IS
    V_WELL_VERSION_DIFF NUMBER;
    V_WELL_B_NODE_DIFF NUMBER;
    V_WELL_S_NODE_DIFF NUMBER;
    --V_WELL_LICENSE_DIFF NUMBER;
    V_WELL_STATUS_DIFF NUMBER;
    V_MESSAGE VARCHAR2(2000) := 'WIM_LOADER_IHS_CDN Differences: 0';

BEGIN
/*---------------------------------------------------------------------------------
Proocedure: IPL_PPDM_COMPARE_REPORT
Purpose:    To Report the differences between IHS@C_TALISMAN_IHSDATA and PPDM database.     


History:

Feb 07, 2012    V.Rajpoot   Initial Creation
May 25 2013     V.Rajpoot   Changed to use IPL_WELLS_STG_VW,.. views instead of 
                           using IHS tables. 
Mar 05, 2014    K.Edwards   Added defalut message to be dispalyed if no differences are found                                 

---------------------------------------------------------------------------------*/


    -- WELL VERSION
    SELECT COUNT(1) INTO V_WELL_VERSION_DIFF FROM
    (
        
        SELECT BASE_NODE_ID,  ABANDONMENT_DATE, ACTIVE_IND, ASSIGNED_FIELD, CASING_FLANGE_ELEV, CASING_FLANGE_ELEV_OUOM, Completion_Date, 
               CONFIDENTIAL_DATE, CONFIDENTIAL_DEPTH, CONFIDENTIAL_DEPTH_OUOM, CONFIDENTIAL_TYPE, CONFID_STRAT_NAME_SET_ID, 
               CONFID_STRAT_UNIT_ID, COUNTRY, COUNTY, Current_Class, Current_STATUS, CURRENT_STATUS_DATE, DEEPEST_DEPTH,
               DEEPEST_DEPTH_OUOM, Depth_Datum, Depth_Datum_Elev, Depth_Datum_Elev_OUOM, DERRICK_FLOOR_ELEV, DERRICK_FLOOR_ELEV_OUOM,
               DIFFERENCE_LAT_MSL, DISCOVERY_IND, DISTRICT, DRILL_TD,Drill_TD_OUOM, EFFECTIVE_DATE, ELEV_REF_DATUM, EXPIRY_DATE, 
               FAULTED_IND, FINAL_DRILL_DATE, FINAL_TD, FINAL_TD_OUOM, GEOGRAPHIC_REGION, GEOLOGIC_PROVINCE, Ground_Elev, 
               Ground_Elev_OUOM, GROUND_ELEV_TYPE, INITIAL_CLASS, KB_ELEV, KB_ELEV_OUOM, LEASE_NAME, LEASE_NUM, LEGAL_SURVEY_TYPE, 
               LOCATION_TYPE, LOG_TD, LOG_TD_OUOM, MAX_TVD, MAX_TVD_OUOM, NET_PAY, NET_PAY_OUOM, Cast(Oldest_Strat_Age as VARCHAR(20)), 
               OLDEST_STRAT_NAME_SET_AGE, OLDEST_STRAT_NAME_SET_ID, Oldest_Strat_Unit_Id, Operator, PARENT_RELATIONSHIP_TYPE,
               Parent_UWI, PLATFORM_ID, PLATFORM_SF_TYPE, Plot_Name, Plot_Symbol, PLUGBACK_DEPTH, PLUGBACK_DEPTH_OUOM, PPDM_GUID, 
               PROFILE_TYPE, PROVINCE_STATE, REGULATORY_AGENCY, REMARK, RIG_ON_SITE_DATE, RIG_RELEASE_DATE, ROTARY_TABLE_ELEV, 
               SOURCE_DOCUMENT, Spud_Date, STATUS_TYPE, SUBSEA_ELEV_REF_TYPE, TAX_CREDIT_CODE, Cast(TD_STRAT_AGE as varchar(20)) ,
               TD_STRAT_NAME_SET_AGE, TD_STRAT_NAME_SET_ID, TD_STRAT_UNIT_ID, WATER_ACOUSTIC_VEL, WATER_ACOUSTIC_VEL_OUOM, Water_Depth,
               WATER_DEPTH_DATUM, WATER_DEPTH_OUOM, WELL_EVENT_NUM, WELL_GOVERNMENT_ID, WELL_INTERSECT_MD,WELL_NAME,
               WELL_NUMERIC_ID, WHIPSTOCK_DEPTH,WHIPSTOCK_DEPTH_OUOM,  IPL_Licensee,IPL_OFFSHORE_IND,
               IPL_PRSTATUS, IPL_ORSTATUS, IPL_ONPROD_DATE,  IPL_ONINJECT_DATE,
               IPL_CONFIDENTIAL_STRAT_AGE,  IPL_POOL,IPL_UWI_Sort,
               IPL_UWI_DISPLAY,IPL_TD_TVD,  IPL_PLUGBACK_TVD, IPL_WHIPSTOCK_TVD
            from ipl_wells_stg_vw
         WHERE SOURCE = 'IHSE'       
                    MINUS
        SELECT WELL_NUM,ABANDONMENT_DATE,ACTIVE_IND,ASSIGNED_FIELD,CASING_FLANGE_ELEV,CASING_FLANGE_ELEV_OUOM,COMPLETION_DATE, 
               CONFIDENTIAL_DATE, CONFIDENTIAL_DEPTH, CONFIDENTIAL_DEPTH_OUOM, CONFIDENTIAL_TYPE,CONFID_STRAT_NAME_SET_ID,
               CONFID_STRAT_UNIT_ID, COUNTRY, COUNTY, CURRENT_CLASS, CURRENT_STATUS, CURRENT_STATUS_DATE, DEEPEST_DEPTH,
               DEEPEST_DEPTH_OUOM,   DEPTH_DATUM,  DEPTH_DATUM_ELEV,  DEPTH_DATUM_ELEV_OUOM, DERRICK_FLOOR_ELEV,  DERRICK_FLOOR_ELEV_OUOM,  
               DIFFERENCE_LAT_MSL,   DISCOVERY_IND,   DISTRICT,   DRILL_TD,   DRILL_TD_OUOM,EFFECTIVE_DATE,   ELEV_REF_DATUM,   EXPIRY_DATE,   
               FAULTED_IND,   FINAL_DRILL_DATE,   FINAL_TD,   FINAL_TD_OUOM,   GEOGRAPHIC_REGION, GEOLOGIC_PROVINCE,  GROUND_ELEV, 
               GROUND_ELEV_OUOM,  GROUND_ELEV_TYPE,  INITIAL_CLASS,  KB_ELEV,  KB_ELEV_OUOM,  LEASE_NAME, LEASE_NUM, LEGAL_SURVEY_TYPE, 
               LOCATION_TYPE,  LOG_TD,  LOG_TD_OUOM,  MAX_TVD,  MAX_TVD_OUOM,  NET_PAY,  NET_PAY_OUOM, OLDEST_STRAT_AGE,  
               OLDEST_STRAT_NAME_SET_AGE,  OLDEST_STRAT_NAME_SET_ID,  OLDEST_STRAT_UNIT_ID,   OPERATOR,   PARENT_RELATIONSHIP_TYPE,
               PARENT_UWI,  PLATFORM_ID,  PLATFORM_SF_TYPE,  PLOT_NAME,  PLOT_SYMBOL,  PLUGBACK_DEPTH,  PLUGBACK_DEPTH_OUOM,  PPDM_GUID,  
               PROFILE_TYPE, PROVINCE_STATE,  REGULATORY_AGENCY,  REMARK,  RIG_ON_SITE_DATE,  RIG_RELEASE_DATE,  ROTARY_TABLE_ELEV,  
               SOURCE_DOCUMENT, SPUD_DATE,  STATUS_TYPE,  SUBSEA_ELEV_REF_TYPE, TAX_CREDIT_CODE, TD_STRAT_AGE,
               TD_STRAT_NAME_SET_AGE,  TD_STRAT_NAME_SET_ID,  TD_STRAT_UNIT_ID,  WATER_ACOUSTIC_VEL,  WATER_ACOUSTIC_VEL_OUOM,  WATER_DEPTH,
               WATER_DEPTH_DATUM,  WATER_DEPTH_OUOM,  WELL_EVENT_NUM,  WELL_GOVERNMENT_ID,  WELL_INTERSECT_MD,  WELL_NAME,  
                             WELL_NUMERIC_ID,  WHIPSTOCK_DEPTH,  WHIPSTOCK_DEPTH_OUOM,  IPL_LICENSEE,  IPL_OFFSHORE_IND,  
               IPL_PRSTATUS, IPL_ORSTATUS,  IPL_ONPROD_DATE,  IPL_ONINJECT_DATE, 
               IPL_CONFIDENTIAL_STRAT_AGE,  IPL_POOL, IPL_UWI_SORT,  
               IPL_UWI_DISPLAY, IPL_TD_TVD, IPL_PLUGBACK_TVD,IPL_WHIPSTOCK_TVD
           FROM well_Version where source = '300IPL'
                  );
           
   


--Well Node Version - BottomHole Lat/Longs
    SELECT COUNT(1) into V_WELL_B_NODE_DIFF
    FROM ( SELECT WV.BASE_NODE_ID, wnv.ACQUISITION_ID, wnv.COUNTRY, wnv.COUNTY, wnv.EASTING, wnv.EASTING_OUOM, wnv.EFFECTIVE_DATE, wnv.ELEV, wnv.ELEV_OUOM, 
                  wnv.EW_DIRECTION, wnv.EXPIRY_DATE,wnv.GEOG_COORD_SYSTEM_ID, wnv.Latitude, wnv.LEGAL_SURVEY, wnv.LOCATION_QUALIFIER, 
                  wnv.LOCATION_QUALITY, wnv.Longitude, wnv.MAP_COORD_SYSTEM_ID, wnv.MD, wnv.MD_OUOM,wnv.MONUMENT_ID, wnv.MONUMENT_SF_TYPE, 
                  wnv.NORTHING NORTHING, wnv.NORTHING_OUOM, wnv.NORTH_TYPE, wnv.NS_DIRECTION, wnv.POLAR_AZIMUTH,
                  wnv.POLAR_OFFSET, wnv.POLAR_OFFSET_OUOM, wnv.PPDM_GUID, wnv.PREFERRED_IND, wnv.PROVINCE_STATE, wnv.Remark, wnv.REPORTED_TVD, 
                  wnv.REPORTED_TVD_OUOM, wnv.VERSION_TYPE,wnv.X_OFFSET, wnv.X_OFFSET_OUOM, wnv.Y_OFFSET, wnv.Y_OFFSET_OUOM, 
                  CAST (wnv.ROW_CHANGED_BY AS VARCHAR (30)), wnv.ROW_CHANGED_DATE, --CAST (wnv.ROW_CREATED_BY AS VARCHAR (30)),
                  wnv.ROW_CREATED_DATE, wnv.ROW_QUALITY
             FROM ipl_wells_stg_vw WV,
                  ipl_well_Node_stg_vw WNV
            WHERE WV.UWI = WNV.UWI
              AND WV.SOURCE = 'IHSE'
              and NODE_POSITION = 'B'
              and WNV.ACTIVE_IND = 'Y'
                  MINUS
           SELECT WV.WELL_NUM, WNV.ACQUISITION_ID, WNV.COUNTRY, WNV.COUNTY, WNV.EASTING, WNV.EASTING_OUOM, WNV.EFFECTIVE_DATE,
                  WNV.ELEV, WNV.ELEV_OUOM, WNV.EW_DIRECTION, WNV.EXPIRY_DATE, WNV.GEOG_COORD_SYSTEM_ID, WNV.LATITUDE, WNV.LEGAL_SURVEY_type,
                  WNV.LOCATION_QUALIFIER, WNV.LOCATION_QUALITY, WNV.LONGITUDE, WNV.MAP_COORD_SYSTEM_ID, WNV.MD, WNV.MD_OUOM, WNV.mONUMENT_ID,
                  WNV.MONUMENT_SF_TYPE, WNV.NORTHING,WNV.NORTHING_OUOM, WNV.NORTH_TYPE, WNV.NS_DIRECTION, WNV.POLAR_AZIMUTH,
                  WNV.POLAR_OFFSET, WNV.POLAR_OFFSET_OUOM, WNV.PPDM_GUID, WNV.PREFERRED_IND, WNV.PROVINCE_STATE, WNV.REMARK, WNV.REPORTED_TVD,
                  WNV.REPORTED_TVD_OUOM, WNV.VERSION_TYPE, WNV.X_OFFSET, WNV.X_OFFSET_OUOM, WNV.Y_OFFSET,
                  WNV.Y_OFFSET_OUOM, WNV.ROW_CHANGED_BY, WNV.ROW_CHANGED_DATE, --WNV.ROW_CREATED_BY,
                  WNV.ROW_CREATED_DATE, WNV.ROW_QUALITY
             from ppdm.well_node_version wnv, ppdm.well_version wv
            where wv.uwi = wnv.ipl_uwi
              and  wv.source = '300IPL'
              and  wnv.source = '300IPL'
              and wnv.node_position = 'B'
              and WNV.ACTIVE_IND = 'Y'
        );
       

-- Well Node Version - Surface Lat/Longs
    SELECT COUNT(1) into V_WELL_S_NODE_DIFF
     FROM (( SELECT WV.BASE_NODE_ID, wnv.ACQUISITION_ID, wnv.COUNTRY, wnv.COUNTY, wnv.EASTING, wnv.EASTING_OUOM, wnv.EFFECTIVE_DATE, wnv.ELEV, wnv.ELEV_OUOM, 
                  wnv.EW_DIRECTION, wnv.EXPIRY_DATE, wnv.GEOG_COORD_SYSTEM_ID, wnv.Latitude, wnv.LEGAL_SURVEY, wnv.LOCATION_QUALIFIER, 
                  wnv.LOCATION_QUALITY, wnv.Longitude, wnv.MAP_COORD_SYSTEM_ID, wnv.MD, wnv.MD_OUOM,wnv.MONUMENT_ID, wnv.MONUMENT_SF_TYPE, 
                  wnv.NORTHING NORTHING, wnv.NORTHING_OUOM, wnv.NORTH_TYPE, wnv.NS_DIRECTION, wnv.POLAR_AZIMUTH,
                  wnv.POLAR_OFFSET, wnv.POLAR_OFFSET_OUOM, wnv.PPDM_GUID, wnv.PREFERRED_IND, wnv.PROVINCE_STATE, wnv.Remark, wnv.REPORTED_TVD, 
                  wnv.REPORTED_TVD_OUOM, wnv.VERSION_TYPE,wnv.X_OFFSET, wnv.X_OFFSET_OUOM, wnv.Y_OFFSET, wnv.Y_OFFSET_OUOM, 
                   wnv.ROW_CHANGED_DATE, --CAST (wnv.ROW_CREATED_BY AS VARCHAR (30)),
                  wnv.ROW_CREATED_DATE, wnv.ROW_QUALITY
              FROM ipl_wells_stg_vw WV,
                   ipl_well_Node_stg_vw WNV
             WHERE WV.UWI = WNV.UWI
              AND WV.SOURCE = 'IHSE'              
              and NODE_POSITION = 'S'
              and wv.base_node_id != wv.surface_node_id
              and WNV.ACTIVE_IND = 'Y'
              UNION
              SELECT WV.BASE_NODE_ID, wnv.ACQUISITION_ID, wnv.COUNTRY, wnv.COUNTY, wnv.EASTING, wnv.EASTING_OUOM, wnv.EFFECTIVE_DATE, wnv.ELEV, wnv.ELEV_OUOM, 
                  wnv.EW_DIRECTION, wnv.EXPIRY_DATE, wnv.GEOG_COORD_SYSTEM_ID, wnv.Latitude, wnv.LEGAL_SURVEY, wnv.LOCATION_QUALIFIER, 
                  wnv.LOCATION_QUALITY, wnv.Longitude, wnv.MAP_COORD_SYSTEM_ID, wnv.MD, wnv.MD_OUOM,wnv.MONUMENT_ID, wnv.MONUMENT_SF_TYPE, 
                  wnv.NORTHING NORTHING, wnv.NORTHING_OUOM, wnv.NORTH_TYPE, wnv.NS_DIRECTION, wnv.POLAR_AZIMUTH,
                  wnv.POLAR_OFFSET, wnv.POLAR_OFFSET_OUOM, wnv.PPDM_GUID, wnv.PREFERRED_IND, wnv.PROVINCE_STATE, wnv.Remark, wnv.REPORTED_TVD, 
                  wnv.REPORTED_TVD_OUOM, wnv.VERSION_TYPE,wnv.X_OFFSET, wnv.X_OFFSET_OUOM, wnv.Y_OFFSET, wnv.Y_OFFSET_OUOM, 
                   wnv.ROW_CHANGED_DATE, --CAST (wnv.ROW_CREATED_BY AS VARCHAR (30)),
                  wnv.ROW_CREATED_DATE, wnv.ROW_QUALITY
             FROM ipl_wells_stg_vw WV,
                  ipl_well_Node_stg_vw WNV
            WHERE WV.UWI = WNV.UWI
              AND WV.SOURCE = 'IHSE'              
              and NODE_POSITION = 'B'
              and wv.base_node_id = wv.surface_node_id
              and WNV.ACTIVE_IND = 'Y')          
            MINUS
           SELECT WV.WELL_NUM, WNV.ACQUISITION_ID, WNV.COUNTRY, WNV.COUNTY, WNV.EASTING, WNV.EASTING_OUOM, WNV.EFFECTIVE_DATE,
                  WNV.ELEV, WNV.ELEV_OUOM, WNV.EW_DIRECTION, WNV.EXPIRY_DATE, WNV.GEOG_COORD_SYSTEM_ID, WNV.LATITUDE, WNV.LEGAL_SURVEY_type,
                  WNV.LOCATION_QUALIFIER, WNV.LOCATION_QUALITY, WNV.LONGITUDE, WNV.MAP_COORD_SYSTEM_ID, WNV.MD, WNV.MD_OUOM, WNV.mONUMENT_ID,
                  WNV.MONUMENT_SF_TYPE, WNV.NORTHING,WNV.NORTHING_OUOM, WNV.NORTH_TYPE, WNV.NS_DIRECTION, WNV.POLAR_AZIMUTH,
                  WNV.POLAR_OFFSET, WNV.POLAR_OFFSET_OUOM, WNV.PPDM_GUID, WNV.PREFERRED_IND, WNV.PROVINCE_STATE, WNV.REMARK, WNV.REPORTED_TVD,
                  WNV.REPORTED_TVD_OUOM, WNV.VERSION_TYPE, WNV.X_OFFSET, WNV.X_OFFSET_OUOM, WNV.Y_OFFSET,
                  WNV.Y_OFFSET_OUOM, WNV.ROW_CHANGED_DATE, --WNV.ROW_CREATED_BY,
                  WNV.ROW_CREATED_DATE,   WNV.ROW_QUALITY
             from ppdm.well_node_version wnv, ppdm.well_version wv
            where wv.uwi = wnv.ipl_uwi
              and  wv.source = '300IPL'
              and  wnv.source = '300IPL'
              and wnv.node_position = 'S'
              and WNV.ACTIVE_IND = 'Y'
                  );  
   

--well_statuses
  SELECT COUNT(1) into V_WELL_STATUS_DIFF
    FROM ( 
     select W.BASE_NODE_ID, WS.Status_ID, WS.ACTIVE_IND,WS.EFFECTIVE_DATE,WS.EXPIRY_DATE,WS.PPDM_GUID,
               WS.REMARK, WS.Status,WS.Status_Date, WS.STATUS_DEPTH,WS.STATUS_DEPTH_OUOM,
               WS.STATUS_TYPE,  WS.ROW_QUALITY , WS.ROW_CHANGED_DATE, WS.ROW_CREATED_DATE    
          FROM ipl_wells_stg_vw W, 
               ipl_well_status_stg_vw WS
         WHERE WS.UWI = W.UWI  
           and ws.status is not null           
                MINUS
        select W.WELL_NUM, WS.Status_ID, WS.ACTIVE_IND,WS.EFFECTIVE_DATE,WS.EXPIRY_DATE,WS.PPDM_GUID,
               WS.REMARK, WS.Status,WS.Status_Date, WS.STATUS_DEPTH,WS.STATUS_DEPTH_OUOM,
               WS.STATUS_TYPE, WS.ROW_QUALITY ,WS.ROW_CHANGED_DATE, WS.ROW_CREATED_DATE        
          FROM well_VERSION W, well_status WS
         WHERE WS.UWI = W.UWI
           and w.source = '300IPL'
           AND WS.SOURCE = '300IPL'
           AND WS.Active_IND ='Y'
        );
     
    
    
 --Well License
--Cant check

    --IF V_WELL_VERSION_DIFF > 0 OR V_WELL_B_NODE_DIFF > 0 OR V_WELL_S_NODE_DIFF > 0 OR V_WELL_LICENSE_DIFF > 0 OR V_WELL_STATUS_DIFF > 0 THEN
        -- Add to Process Log,  for now add to temp table
        v_Message := 'WIM_LOADER_IHS_CDN Differences: ' || CHR(13) || CHR(10) || ' Well Version: ' || V_WELL_VERSION_DIFF;
        v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Base Node: ' || V_WELL_B_NODE_DIFF;
        v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Surface Node: ' || V_WELL_S_NODE_DIFF;
        --v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well License: ' || V_WELL_LICENSE_DIFF;
        v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Status: ' || V_WELL_STATUS_DIFF;
        
   -- END IF;
    
     tlm_process_logger.info (v_Message);
  

END IPL_PPDM_COMPARE_REPORT;

/
