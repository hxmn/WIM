DROP PROCEDURE CWS_PPDM_COMPARE_REPORT;

CREATE OR REPLACE PROCEDURE            "CWS_PPDM_COMPARE_REPORT" 
IS
    V_WELL_VERSION_DIFF NUMBER;
    V_WELL_B_NODE_DIFF NUMBER;
    V_WELL_S_NODE_DIFF NUMBER;
    V_WELL_LICENSE_DIFF NUMBER;
    V_WELL_STATUS_DIFF NUMBER;
    V_MESSAGE VARCHAR2(2000) := 'WIM_LOADER_CWS Differences: 0';

BEGIN

/*---------------------------------------------------------------------------------
Proocedure: CWS_PPDM_COMPARE_REPORT
Purpose:    To Report the differences between CWS and PPDM database.     


History:

Sep 15, 2011    V.Rajpoot   Initial Creation
May 25 2013     V.Rajpoot   Changed to use CWS_WELLS_STG_VW,.. views instead of 
                            using cws tables.
Mar 05, 2014    K.Edwards   Added defalut message to be dispalyed if no differences are found.                                   

---------------------------------------------------------------------------------*/

    -- WELL VERSION
    SELECT COUNT(1) INTO V_WELL_VERSION_DIFF FROM
    (
        
        SELECT  uwi,source, active_ind,  Well_Name, 
               round(Bottom_Hole_Latitude,7), round(Bottom_hole_Longitude,7), 
               Current_Status, CURRENT_STATUS_DATE, 
                DRILL_TD, KB_ELEV, PROVINCE_STATE, RIG_RELEASE_DATE,
                SPUD_DATE, round(SURFACE_LATITUDE,7),round(SURFACE_LONGITUDE,7) ,
                IPL_OFFSHORE_IND, IPL_ONPROD_DATE, IPL_UWI_LOCAL  
          FROM CWS_WELLS_STG_VW
          MINUS
      SELECT distinct  WV.UWI, WV.SOURCE, WV.ACTIVE_IND, WV.WELL_NAME, 
        WV.Bottom_Hole_Latitude, WV.Bottom_hole_Longitude,
        WV.Current_Status, WV.CURRENT_STATUS_DATE, 
        WV.DRILL_TD, WV.KB_ELEV, WV.PROVINCE_STATE, WV.RIG_RELEASE_DATE,
        WV.SPUD_DATE, WV.SURFACE_LATITUDE, WV.SURFACE_LONGITUDE,
        wv.IPL_OFFSHORE_IND, wv.IPL_ONPROD_DATE, IPL_UWI_LOCAL  --, wv.row_changed_date, wv.row_created_date 
          from WELL_VERSION WV 
        where wv.source = '100TLM'    
          and wv.ACTIVE_IND = 'Y'
  );
            
   


--Well Node Version - BottomHole Lat/Longs
    SELECT COUNT(1) into V_WELL_B_NODE_DIFF
    FROM (
         SELECT  uwi, source, activE_ind,  
                round(latitude,7),  round(longitude,7),
                 geog_coord_system_id, location_qualifier, node_position          
            FROM CWS_WELL_NODE_STG_VW 
            where Node_Position = 'B'
            MINUS 
        SELECT distinct  B.IPL_UWI, B.SOURCE, B.ACTIVE_IND,  
           B.Latitude BottomHole_Latitude, B.Longitude Bottomhole_Longitude,
            geog_coord_system_id, location_qualifier, node_position
         --  ,b.row_changed_date, b.row_created_date
          from well_version wv, well_node_Version B
         where wv.uwi = b.ipl_uwi
           and wv.source = '100TLM'
           and B.source = '100TLM'    
           and b.ACTIVE_IND = 'Y'
           and B.Node_Position = 'B'
      
       ) ;
          

-- Well Node Version - Surface Lat/Longs
    SELECT COUNT(1) into V_WELL_S_NODE_DIFF
    FROM (          
        SELECT  uwi, source, activE_ind,  
            round(latitude,7),  round(longitude,7),
           geog_coord_system_id, location_qualifier, node_position
          -- ,row_changed_date, row_created_date
    FROM CWS_WELL_NODE_STG_VW 
    where Node_Position = 'S' 
    MINUS
    SELECT distinct  S.IPL_UWI, S.SOURCE, S.ACTIVE_IND,  
           S.Latitude Surface_Latitude, S.Longitude Surface_Longitude,
            geog_coord_system_id, location_qualifier, node_position
           --, wv.row_changed_date, wv.row_created_Date
      from well_version wv,well_node_Version S
     where  wv.uwi = s.ipl_uwi
       and wv.source = '100TLM'
       and S.source = '100TLM'    
       and s.ACTIVE_IND = 'Y'
       and S.Node_Position = 'S'
           
       
        );   
    
     
--well_statuses
  SELECT COUNT(1) into V_WELL_STATUS_DIFF
    FROM ( 
       SELECT uwi, source, active_ind,          
         status, Status_date --, row_changed_date, row_created_date
     FROM CWS_WELL_STATUS_STG_VW    
     MINUS
     Select uwi, source, active_ind, current_status, current_Status_date 
    from well_Version
        where source = '100TLM' and active_ind = 'Y'
     
   );
     
    
    
 --Well License
SELECT COUNT(1) into V_WELL_LICENSE_DIFF
    FROM ( 
     SELECT  uwi, source, wl_activE_ind,  
           wl_license_id,  
           wl_License_num,           
           Wl_Projected_Depth --, WL_row_changed_date ,  WL_row_Created_Date    
    FROM  CWS_WELLS_STG_VW
    WHERE wl_license_num is not null
    Minus
    SELECT distinct WL.UWI, WL.SOURCE, WL.ACTIVE_IND, WL.LICENSE_ID,   WL.LICENSE_NUM, 
        WL.PROJECTED_DEPTH --, wl.row_changed_date, wl.row_created_date
    from well_license WL    , well_version wv     
    where wl.uwi = wv.uwi 
    and wv.source ='100TLM'
    and wl.source = '100TLM' 
      and wv.active_ind ='Y'
      and wl.ACTIVE_IND = 'Y'   
      and wl.license_num is not null      
      );
      

    IF V_WELL_VERSION_DIFF > 0 OR V_WELL_B_NODE_DIFF > 0 OR V_WELL_S_NODE_DIFF > 0 OR V_WELL_LICENSE_DIFF > 0 OR V_WELL_STATUS_DIFF > 0 THEN
        -- Add to Process Log,  for now add to temp table
        v_Message := 'WIM_LOADER_CWS Differences: ' || CHR(13) || CHR(10) || ' Well Version: ' || V_WELL_VERSION_DIFF;
        v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Base Node: ' || V_WELL_B_NODE_DIFF;
        v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Surface Node: ' || V_WELL_S_NODE_DIFF;
        v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well License: ' || V_WELL_LICENSE_DIFF;
        v_Message := v_Message ||  CHR(13) || CHR(10) || ' Well Status: ' || V_WELL_STATUS_DIFF;
        
    END IF;
    
     tlm_process_logger.info (v_Message);


END CWS_PPDM_COMPARE_REPORT;

/
