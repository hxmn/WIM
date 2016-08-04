DROP PROCEDURE PID_PPDM_COMPARE_REPORT;

CREATE OR REPLACE PROCEDURE            "PID_PPDM_COMPARE_REPORT" 
IS
    V_WELL_VERSION_DIFF     NUMBER;
    V_WELL_B_NODE_DIFF      NUMBER;
    V_WELL_S_NODE_DIFF      NUMBER;
    V_WELL_LICENSE_DIFF     NUMBER;
    V_WELL_STATUS_DIFF      NUMBER;
    V_MESSAGE               VARCHAR2(2000) := 'WIM_LOADER_IHS_US Differences: 0';

BEGIN
/*---------------------------------------------------------------------------------
Proocedure: PID_PPDM_COMPARE_REPORT
Purpose:    To Report the differences between IHS@C_TALISMAN_US and PPDM database.     


History:

Feb 07, 2012     V.Rajpoot   Initial Creation
May 17, 2013     V.Rajpoot  Changed to use PID_WELLS_STG_VW,.. views instead of 
                           using IHS tables.
Mar 05, 2014    K.Edwards   Added defalut message to be dispalyed if no differences are found        

---------------------------------------------------------------------------------*/

    Select count(1) INTO V_WELL_VERSION_DIFF FROM
    (
     Select  uwi as WELL_NUM, abandonment_date, assigned_field, completion_date, confidential_date, confidential_type, confid_strat_name_set_id,
            confid_strat_unit_id, country, county, current_class, current_Status, current_status_date,
            difference_lat_msl, discovery_ind, district, effective_date, elev_ref_datum, expiry_date, faulted_ind, final_drill_date,
            Geographic_region, geologic_province, ground_elev_type,Initial_class,LeasE_Name, LeasE_Num, Legal_Survey_type, Location_Type,
            CAST(oldest_strat_age as VARCHAR(12)), oldest_strat_name_set_age, oldest_strat_name_set_id, oldest_strat_unit_id, 
            operator, parent_relationship_type,
            parent_uwi, platform_id, platform_sf_type, plot_name, plot_symbol, 
            ppdm_guid, profile_type, province_state, regulatory_agency, remark, rig_on_site_date, rig_Release_date, rotary_table_elev,
            source_document, spud_date, status_type, subsea_elev_ref_type, tax_credit_code, td_Strat_age, td_strat_name_set_age, td_strat_unit_id,
            water_acoustic_vel, water_acoustic_vel_ouom, well_event_num, well_government_id, well_intersect_md, well_name, well_numeric_id, ipl_licensee,
            ipl_offshore_ind, ipl_pidstatus, ipl_orstatus,ipl_prstatus, ipl_onprod_date, ipl_confidential_strat_age, ipl_pool, ipl_last_update, ipl_uwi_sort,
            ipl_uwi_display, ipl_td_tvd, ipl_plugback_tvd, ipl_whipstock_tvd, ipl_water_tvd, ipl_alt_source, ipl_basin, ipl_block, ipl_area,
            ipl_twp, ipl_tract, ipl_lot, ipl_conc, ipl_uwi_local, 
            depth_datum,
            ROUND(casing_flange_elev*.3048/1,5), casing_flange_elev_ouom, 
            ROUND(confidential_depth*.3048/1,5), confidential_depth_ouom, 
            ROUND(deepest_depth*.3048/1,5), deepest_depth_ouom,
            --cast(wim_util.uom_conversion ('FT','M',depth_datum_elev) as number(10,5)), 
            depth_datum_elev_ouom, 
            ROUND(derrick_floor_elev*.3048/1,5), derrick_floor_elev_ouom,
            ROUND(drill_Td*.3048/1,5), drill_td_ouom, 
            ROUND(Final_td*.3048/1,5), final_td_ouom, 
            ROUND(ground_elev*.3048/1,5), ground_elev_ouom,
            ROUND(kb_elev*.3048/1,5), kb_elev_ouom,
            ROUND(Log_Td*.3048/1,5), log_td_ouom, 
            ROUND(max_tvd*.3048/1,5), max_tvd_ouom,
            net_pay*.3048/1, net_pay_ouom, 
            ROUND(plugback_depth*.3048/1,5), plugback_depth_ouom, 
            ROUND(water_depth*.3048/1,5), water_depth_ouom,
            ROUND(whipstock_depth*.3048/1,5), whipstock_depth_ouom
          --  row_changed_date, row_created_date
            from PID_WELLS_STG_VW --well@c_talisman_us 
            where active_ind = 'Y'
              and well_name is not null          
            minus
            Select well_num, abandonment_date, assigned_field, completion_date, confidential_date, confidential_type, confid_strat_name_set_id,
                    confid_strat_unit_id, country, county, current_class, current_Status, current_status_date,
                    difference_lat_msl, discovery_ind, district, effective_date, elev_ref_datum, expiry_date, faulted_ind, final_drill_date,
                    Geographic_region, geologic_province, ground_elev_type,Initial_class,LeasE_Name, LeasE_Num, Legal_Survey_type, Location_Type,
                    oldest_strat_age, oldest_strat_name_set_age, oldest_strat_name_set_id, oldest_strat_unit_id, operator, parent_relationship_type,
                    parent_uwi, platform_id, platform_sf_type, plot_name, plot_symbol,ppdm_guid, profile_type, province_state, regulatory_agency, remark, rig_on_site_date, rig_Release_date, rotary_table_elev,
                    source_document, spud_date, status_type, subsea_elev_ref_type, tax_credit_code, td_Strat_age, td_strat_name_set_age, td_strat_unit_id,
                    water_acoustic_vel, water_acoustic_vel_ouom, well_event_num, well_government_id, well_intersect_md, well_name, well_numeric_id, ipl_licensee,
                    ipl_offshore_ind, ipl_pidstatus, ipl_orstatus,ipl_prstatus, ipl_onprod_date, ipl_confidential_strat_age, ipl_pool, ipl_last_update, ipl_uwi_sort,
                    ipl_uwi_display, ipl_td_tvd, ipl_plugback_tvd, ipl_whipstock_tvd, ipl_water_tvd, ipl_alt_source, ipl_basin, ipl_block, ipl_area,
                    ipl_twp, ipl_tract, ipl_lot, ipl_conc, ipl_uwi_local, depth_datum,
                    casing_flange_elev, casing_flange_elev_ouom, confidential_depth, confidential_depth_ouom, deepest_depth, deepest_depth_ouom,
                    --depth_datum_elev, 
                    depth_datum_elev_ouom, derrick_floor_elev, derrick_floor_elev_ouom,
                    drill_Td, drill_td_ouom, final_td, final_td_ouom, ground_elev, ground_elev_ouom,kb_elev, kb_elev_ouom,Log_Td, log_td_ouom, max_tvd, max_tvd_ouom,
                    net_pay, net_pay_ouom, plugback_depth, plugback_depth_ouom, water_depth, water_depth_ouom,whipstock_depth, whipstock_depth_ouom
                 --   row_changed_date, row_created_date
            
            from well_Version
            where source = '450PID' and active_ind = 'Y'
             
             );
             
             
            --NODES
        SELECT COUNT(1) into V_WELL_B_NODE_DIFF
        FROM (     
          Select  wnv.uwi as WELL_NUM, WNV.NODE_OBS_NO, WNV.ACQUISITION_ID, WNV.ACTIVE_IND, WNV.COUNTRY, WNV.COUNTY, 
                ROUND(WNV.EASTING*.3048/1,5) as Easting, WNV.EASTING_OUOM, 
                WNV.EFFECTIVE_DATE, 
                ROUND(WNV.ELEV*.3048/1,5), WNV.ELEV_OUOM, 
                WNV.EW_DIRECTION, WNV.EXPIRY_DATE, WNV.GEOG_COORD_SYSTEM_ID,  
                WNV.LATITUDE, WNV.LEGAL_SURVEY_TYPE, WNV.LOCATION_QUALIFIER, WNV.LOCATION_QUALITY, WNV.LONGITUDE, WNV.MAP_COORD_SYSTEM_ID, 
                ROUND(WNV.MD*.3048/1,5), WNV.MD_OUOM, WNV.MONUMENT_ID, WNV.MONUMENT_SF_TYPE, WNV.NODE_POSITION, 
                WNV.NORTH_TYPE, 
                ROUND(WNV.NORTHING*.3048/1,5),  WNV.NORTHING_OUOM, 
                WNV.NS_DIRECTION, WNV.POLAR_AZIMUTH, 
                ROUND(WNV.POLAR_OFFSET*.3048/1,2), WNV.POLAR_OFFSET_OUOM,WNV.PPDM_GUID, WNV.PREFERRED_IND, 
                WNV.PROVINCE_STATE, WNV.REMARK, 
                ROUND(WNV.REPORTED_TVD*.3048/1 ,5), WNV.REPORTED_TVD_OUOM, wnv.version_type, 
                ROUND(X_OFFSET*.3048/1,2) , WNV.X_OFFSET_OUOM, 
                ROUND(Y_OFFSET*.3048/1,2) , WNV.Y_OFFSET_OUOM 
                from pid_well_node_stg_vw wnv , pid_wells_Stg_Vw w       
            where wnv.node_position = 'B'  
             and w.uwi = wnv.uwi
             and w.well_name is not null
          MINUS
     Select wv.well_num, WNV.NODE_OBS_NO,WNV.ACQUISITION_ID, WNV.ACTIVE_IND, WNV.COUNTRY, WNV.COUNTY, 
            WNV.EASTING, WNV.EASTING_OUOM, 
            WNV.EFFECTIVE_DATE, 
            WNV.ELEV, WNV.ELEV_OUOM, WNV.EW_DIRECTION, WNV.EXPIRY_DATE, WNV.GEOG_COORD_SYSTEM_ID,  
            WNV.LATITUDE, WNV.LEGAL_SURVEY_TYPE, WNV.LOCATION_QUALIFIER, WNV.LOCATION_QUALITY, WNV.LONGITUDE, WNV.MAP_COORD_SYSTEM_ID, 
            WNV.MD, WNV.MD_OUOM, WNV.MONUMENT_ID, WNV.MONUMENT_SF_TYPE, WNV.NODE_POSITION, 
            WNV.NORTH_TYPE, 
            WNV.NORTHING,WNV.NORTHING_OUOM, 
            WNV.NS_DIRECTION, WNV.POLAR_AZIMUTH, 
            WNV.POLAR_OFFSET, WNV.POLAR_OFFSET_OUOM,WNV.PPDM_GUID, WNV.PREFERRED_IND, 
            WNV.PROVINCE_STATE, WNV.REMARK, 
            WNV.REPORTED_TVD, WNV.REPORTED_TVD_OUOM,  wnv.version_type,
            WNV.X_OFFSET, WNV.X_OFFSET_OUOM, 
            WNV.Y_OFFSET, WNV.Y_OFFSET_OUOM --, wnv.row_changed_by, wnv.row_changed_Date, wnv.row_created_by,wnv.row_Created_date
             from ppdm.well_node_version wnv, ppdm.well_version wv
            where wv.uwi = wnv.ipl_uwi
              and  wv.source = '450PID' and wnv.source = '450PID'
              and wnv.node_position = 'B'
              and wnv.active_ind = 'Y' 
              and wnv.location_qualifier = 'IH'
            );
        
             --Node ('S)
       SELECT COUNT(1) into V_WELL_S_NODE_DIFF
       FROM (        
        Select  wnv.uwi as WELL_NUM, WNV.NODE_OBS_NO, WNV.ACQUISITION_ID, WNV.ACTIVE_IND, WNV.COUNTRY, WNV.COUNTY, 
                ROUND(WNV.EASTING*.3048/1,5) as Easting, WNV.EASTING_OUOM, 
                WNV.EFFECTIVE_DATE, 
                ROUND(WNV.ELEV*.3048/1,5), WNV.ELEV_OUOM, 
                WNV.EW_DIRECTION, WNV.EXPIRY_DATE, WNV.GEOG_COORD_SYSTEM_ID,  
                WNV.LATITUDE, WNV.LEGAL_SURVEY_TYPE, WNV.LOCATION_QUALIFIER, WNV.LOCATION_QUALITY, WNV.LONGITUDE, WNV.MAP_COORD_SYSTEM_ID, 
                ROUND(WNV.MD*.3048/1,5), WNV.MD_OUOM, WNV.MONUMENT_ID, WNV.MONUMENT_SF_TYPE, WNV.NODE_POSITION, 
                WNV.NORTH_TYPE, 
                ROUND(WNV.NORTHING*.3048/1,5),  WNV.NORTHING_OUOM, 
                WNV.NS_DIRECTION, WNV.POLAR_AZIMUTH, 
                ROUND(WNV.POLAR_OFFSET*.3048/1,2), WNV.POLAR_OFFSET_OUOM,WNV.PPDM_GUID, WNV.PREFERRED_IND, 
                WNV.PROVINCE_STATE, WNV.REMARK, 
                ROUND(WNV.REPORTED_TVD*.3048/1 ,5), WNV.REPORTED_TVD_OUOM, wnv.version_type, 
                ROUND(X_OFFSET*.3048/1,2) , WNV.X_OFFSET_OUOM, 
                ROUND(Y_OFFSET*.3048/1,2) , WNV.Y_OFFSET_OUOM 
           from pid_well_node_stg_vw wnv, pid_wells_stg_Vw w    
          where wnv.node_position = 'S'  
           and w.uwi = wnv.uwi
           and w.well_name is not null
         MINUS
         Select wv.well_num, WNV.NODE_OBS_NO,WNV.ACQUISITION_ID, WNV.ACTIVE_IND, WNV.COUNTRY, WNV.COUNTY, 
                WNV.EASTING, WNV.EASTING_OUOM, 
                WNV.EFFECTIVE_DATE, 
                WNV.ELEV, WNV.ELEV_OUOM, WNV.EW_DIRECTION, WNV.EXPIRY_DATE, WNV.GEOG_COORD_SYSTEM_ID,  
                WNV.LATITUDE, WNV.LEGAL_SURVEY_TYPE, WNV.LOCATION_QUALIFIER, WNV.LOCATION_QUALITY, WNV.LONGITUDE, WNV.MAP_COORD_SYSTEM_ID, 
                WNV.MD, WNV.MD_OUOM, WNV.MONUMENT_ID, WNV.MONUMENT_SF_TYPE, WNV.NODE_POSITION, 
                WNV.NORTH_TYPE, 
                WNV.NORTHING,WNV.NORTHING_OUOM, 
                WNV.NS_DIRECTION, WNV.POLAR_AZIMUTH, 
                WNV.POLAR_OFFSET, WNV.POLAR_OFFSET_OUOM,WNV.PPDM_GUID, WNV.PREFERRED_IND, 
                WNV.PROVINCE_STATE, WNV.REMARK, 
                WNV.REPORTED_TVD, WNV.REPORTED_TVD_OUOM,  wnv.version_type,
                WNV.X_OFFSET, WNV.X_OFFSET_OUOM, 
                WNV.Y_OFFSET, WNV.Y_OFFSET_OUOM --, wnv.row_changed_by, wnv.row_changed_Date, wnv.row_created_by,wnv.row_Created_date
           from ppdm.well_node_version wnv, ppdm.well_version wv
          where wv.uwi = wnv.ipl_uwi
            and wv.source = '450PID' and wnv.source = '450PID'
            and wnv.node_position = 'S'
            and wnv.active_ind = 'Y' 
            and wnv.location_qualifier = 'IH'
         
            );
      
              
              
              --STATUSES
                           
            SELECT COUNT(1) into V_WELL_STATUS_DIFF
            FROM ( 
                select ws.UWI as well_num, ws.status_id, ws.effective_date, ws.expiry_date, ws.ppdm_guid, ws.remark, ws.status, ws.status_date, 
                ws.status_Depth, ws.status_depth_ouom,
                ws.ipl_xaction_code, ws.status_type
                from pid_well_status_stg_vw ws, pid_wells_stg_Vw w
                where ws.active_ind = 'Y'
                and ws.uwi = w.well_num
                and w.well_name is not null
                    minus
                    
                select wv.well_num, status_id, ws.effective_date, ws.expiry_date, ws.ppdm_guid, ws.remark, status, status_date, status_Depth, status_depth_ouom,
                ws.ipl_xaction_code, ws.status_type
                from well_Status ws, well_version wv
                where ws.source = '450PID'
                  and wv.uwi = ws.uwi
                  and wv.source = '450PID'          
                  and ws.active_ind = 'Y'                
               
                 );
                 
            --LICENSES
            SELECT COUNT(1) into V_WELL_LICENSE_DIFF
                FROM (      
            select well_num,  WL.WL_AGENT, WL.WL_APPLICATION_ID, WL.WL_AUTHORIZED_STRAT_UNIT_ID, WL.WL_BIDDING_ROUND_NUM, WL.WL_CONTRACTOR, 
                    ROUND(WL.WL_DIRECTION_TO_LOC*1609.344/1,2),
                   -- wim.wim_util.uom_conversion (wl_direction_to_loc_cuom,'M',WL.WL_DIRECTION_TO_LOC),
                     
                    WL.WL_DIRECTION_TO_LOC_OUOM, WL.WL_DISTANCE_REF_POINT, 
                    ROUND(WL.WL_DISTANCE_TO_LOC*1609.344/1,2),
                    --wim.wim_util.uom_conversion (wl_distance_to_loc_cuom,'M',WL.WL_DISTANCE_TO_LOC),
                       
                    WL.WL_DISTANCE_TO_LOC_OUOM, WL.WL_DRILL_RIG_NUM, WL.WL_DRILL_SLOT_NO, WL.WL_DRILL_TOOL, WL.WL_EFFECTIVE_DATE, WL.WL_EXCEPTION_GRANTED, 
                    WL.WL_EXCEPTION_REQUESTED, WL.WL_EXPIRED_IND, WL.WL_EXPIRY_DATE, WL.WL_FEES_PAID_IND, WL.WL_IPL_ALT_SOURCE, WL.WL_IPL_PROJECTED_STRAT_AGE, 
                    WL.WL_IPL_WELL_OBJECTIVE, WL.WL_IPL_XACTION_CODE, WL.WL_LICENSE_DATE, WL.WL_LICENSE_NUM, WL.WL_LICENSEE, 
                    WL.WL_LICENSEE_CONTACT_ID, WL.WL_NO_OF_WELLS, WL.WL_OFFSHORE_COMPLETION_TYPE, WL.WL_PERMIT_REFERENCE_NUM, WL.WL_PERMIT_REISSUE_DATE, 
                    WL.WL_PERMIT_TYPE, WL.WL_PLATFORM_NAME, WL.WL_PPDM_GUID, 
                    ROUND(WL.WL_PROJECTED_DEPTH*.3048/1 ,5) ,  
                    
                   -- wim.wim_util.uom_conversion (wl_projected_depth_cuom,'M',WL.WL_PROJECTED_DEPTH),
                    WL.WL_PROJECTED_DEPTH_OUOM,  
                    WL.WL_PROJECTED_STRAT_UNIT_ID, 
                    ROUND(WL.WL_PROJECTED_TVD* .3048/1,5),
                    -- wim.wim_util.uom_conversion (WL_PROJECTED_TVD_cuom,'M',WL.WL_PROJECTED_TVD),
                       
                    WL.WL_PROJECTED_TVD_OUOM, WL.WL_PROPOSED_SPUD_DATE, 
                    WL.WL_PURPOSE, WL.WL_RATE_SCHEDULE_ID, WL.WL_REGULATION, WL.WL_REGULATORY_AGENCY, WL.WL_REGULATORY_CONTACT_ID, WL.WL_REMARK, 
                    WL.WL_RIG_CODE, 
                    ROUND(WL.WL_RIG_SUBSTR_HEIGHT* .3048/1,2) , 
                   -- wim.wim_util.uom_conversion (WL_RIG_SUBSTR_HEIGHT_cuom,'M',WL.WL_RIG_SUBSTR_HEIGHT),
                    WL.WL_RIG_SUBSTR_HEIGHT_OUOM, WL.WL_RIG_TYPE,
                    WL.WL_ROW_QUALITY, WL.WL_SECTION_OF_REGULATION, WL.WL_STRAT_NAME_SET_ID, WL.WL_SURVEYOR, WL.WL_TARGET_OBJECTIVE_FLUID
               from pid_wells_stg_vw wl
               where wl_license_num is not null
                and  well_name is not null
                minus
             select WV.WELL_NUM, WL.AGENT, WL.APPLICATION_ID, WL.AUTHORIZED_STRAT_UNIT_ID, WL.BIDDING_ROUND_NUM, WL.CONTRACTOR, WL.DIRECTION_TO_LOC, 
                    WL.DIRECTION_TO_LOC_OUOM, WL.DISTANCE_REF_POINT, WL.DISTANCE_TO_LOC,  
                    WL.DISTANCE_TO_LOC_OUOM, WL.DRILL_RIG_NUM, WL.DRILL_SLOT_NO, WL.DRILL_TOOL, WL.EFFECTIVE_DATE, WL.EXCEPTION_GRANTED, 
                    WL.EXCEPTION_REQUESTED, WL.EXPIRED_IND, WL.EXPIRY_DATE, WL.FEES_PAID_IND, WL.IPL_ALT_SOURCE, WL.IPL_PROJECTED_STRAT_AGE, 
                    WL.IPL_WELL_OBJECTIVE, WL.IPL_XACTION_CODE, WL.LICENSE_DATE, WL.LICENSE_NUM, WL.LICENSEE, 
                    WL.LICENSEE_CONTACT_ID, WL.NO_OF_WELLS, WL.OFFSHORE_COMPLETION_TYPE, WL.PERMIT_REFERENCE_NUM, WL.PERMIT_REISSUE_DATE, 
                    WL.PERMIT_TYPE, WL.PLATFORM_NAME, WL.PPDM_GUID, WL.PROJECTED_DEPTH, WL.PROJECTED_DEPTH_OUOM, 
                    WL.PROJECTED_STRAT_UNIT_ID, WL.PROJECTED_TVD, WL.PROJECTED_TVD_OUOM, WL.PROPOSED_SPUD_DATE, 
                    WL.PURPOSE, WL.RATE_SCHEDULE_ID, WL.REGULATION, WL.REGULATORY_AGENCY, WL.REGULATORY_CONTACT_ID, WL.REMARK, 
                    WL.RIG_CODE, WL.RIG_SUBSTR_HEIGHT,  WL.RIG_SUBSTR_HEIGHT_OUOM, WL.RIG_TYPE,
                    WL.ROW_QUALITY, WL.SECTION_OF_REGULATION, WL.STRAT_NAME_SET_ID, WL.SURVEYOR, WL.TARGET_OBJECTIVE_FLUID
               from ppdm.well_license wl,
                    well_version wv
              where wl.active_ind = 'Y'
                and wl.uwi = wv.uwi
                and wl.source = '450PID'
                and wv.source = '450PID'         
          );
        
        IF V_WELL_VERSION_DIFF > 0 OR V_WELL_B_NODE_DIFF > 0 OR V_WELL_S_NODE_DIFF > 0 THEN
            v_Message := 'WIM_LOADER_IHS_US Differences: ' || CHR(13) || CHR(10) || ' Well Version: ' || V_WELL_VERSION_DIFF;
            v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Base Node: ' || V_WELL_B_NODE_DIFF;
            v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Surface Node: ' || V_WELL_S_NODE_DIFF;
            v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Status: ' || V_WELL_S_NODE_DIFF;
            v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well License: ' || V_WELL_S_NODE_DIFF;
        END IF;
        
        tlm_process_logger.info (v_Message);  
          
  

END PID_PPDM_COMPARE_REPORT;

/
