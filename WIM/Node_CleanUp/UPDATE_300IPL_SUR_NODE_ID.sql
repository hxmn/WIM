CREATE OR REPLACE PROCEDURE  WIM.UPDATE_300IPL_SUR_NODE_ID
IS

/*-------------------------------------------------------
Created By: vRajpoot
2011-08-05
To Update Surface_Node_ID ( from Null)

----------------------------------------------------------*/
 
--declare

--This sql will give uwis where surface and Base nodes are same
CURSOR wells_cur is
select uwi
  from ppdm.well_version
 where source = '300IPL'
   and surface_node_id is null
   and ipl_uwi_local = (select distinct uwi from well@ihsdata where base_node_id = surface_node_id and uwi = ipl_uwi_local );


  
--  select * from ppdm.well_version      where uwi  = '50024095000';
 -- select * from ppdm.well_node_version where ipl_uwi        = '50000010311';
                     
   
 v_uwi  VARCHAR2(20);
 v_node_obs_no NUMBER;
 v_b_node_obs_no NUMBER;
 v_count NUMBER;
 v_total number; 
 BEGIN
 
v_count := 0;        
    FOR wells IN wells_cur() 
    LOOP      
        -- get max node_obs_no
         select max(node_obs_no) into v_node_obs_no
           from ppdm.well_node_version
          where ipl_uwi = wells.uwi
            and source = '300IPL';
         
         --get node_obs_no for 'B' node position, it can be copied
         select max(node_obs_no) into v_b_node_obs_no
           from ppdm.well_node_version
          where ipl_uwi = wells.uwi
            and node_position  ='B'
            and source = '300IPL';
         
         INSERT INTO PPDM.WELL_NODE_VERSION
               (NODE_ID,SOURCE,NODE_OBS_NO,ACQUISITION_ID,ACTIVE_IND,COUNTRY,COUNTY, EASTING, EASTING_OUOM,EFFECTIVE_DATE, ELEV,ELEV_OUOM, EW_DIRECTION,
                EXPIRY_DATE, GEOG_COORD_SYSTEM_ID,LATITUDE,LEGAL_SURVEY_TYPE, LOCATION_QUALIFIER, LOCATION_QUALITY, LONGITUDE, MAP_COORD_SYSTEM_ID, MD,
                MD_OUOM,MONUMENT_ID,MONUMENT_SF_TYPE,NODE_POSITION, NORTHING, NORTHING_OUOM, NORTH_TYPE,NS_DIRECTION, POLAR_AZIMUTH, POLAR_OFFSET,
                POLAR_OFFSET_OUOM,PPDM_GUID, PREFERRED_IND, PROVINCE_STATE, REMARK, REPORTED_TVD, REPORTED_TVD_OUOM, VERSION_TYPE, X_OFFSET,
                X_OFFSET_OUOM, Y_OFFSET, Y_OFFSET_OUOM, IPL_XACTION_CODE, ROW_CHANGED_BY, ROW_CHANGED_DATE,  ROW_CREATED_BY,  ROW_CREATED_DATE,
                IPL_UWI,   ROW_QUALITY)
               ( Select ipl_uwi ||'1', SOURCE, v_node_obs_no+1, ACQUISITION_ID,ACTIVE_IND,COUNTRY,COUNTY, 
                 EASTING,EASTING_OUOM,EFFECTIVE_DATE,ELEV, ELEV_OUOM, EW_DIRECTION,EXPIRY_DATE, GEOG_COORD_SYSTEM_ID, LATITUDE, LEGAL_SURVEY_TYPE, 
                 LOCATION_QUALIFIER,LOCATION_QUALITY, LONGITUDE, MAP_COORD_SYSTEM_ID, MD, MD_OUOM, MONUMENT_ID, MONUMENT_SF_TYPE, 'S', NORTHING, 
                 NORTHING_OUOM,NORTH_TYPE, NS_DIRECTION, POLAR_AZIMUTH, POLAR_OFFSET,
                 POLAR_OFFSET_OUOM, PPDM_GUID, PREFERRED_IND, PROVINCE_STATE, REMARK, REPORTED_TVD, 
                 REPORTED_TVD_OUOM, VERSION_TYPE, X_OFFSET, X_OFFSET_OUOM, Y_OFFSET, Y_OFFSET_OUOM, IPL_XACTION_CODE, ROW_CHANGED_BY, ROW_CHANGED_DATE,  
                 ROW_CREATED_BY,  ROW_CREATED_DATE,IPL_UWI,   ROW_QUALITY from ppdm.well_node_version
                where ipl_uwi = wells.uwi and source = '300IPL'
                 and Node_Obs_no = v_node_obs_no);
               
               wim_rollup.well_rollup(wells.uwi);
               
              -- dbms_output.put_line(wells.uwi );
               
               v_count := v_count +1;
         --      v_total := v_total +1;
               
                        
               if v_count = 500 then
                COMMIT;
               v_count :=0;
               end if;

    END LOOP;
    
    COMMIT;
 
 END;




/*

  
 select w.uwi --, s.node_id, s.node_position, b.uwi, b.node_id, b.node_position 
   from well@ihsdata w
   where w.base_node_id = w.surface_node_id
   and w.uwi not in ( select ipl_uwi_local from ppdm.well_version wv, ppdm.well_node_version wnv
                   where wv.uwi = wnv.ipl_uwi                    
                     and wv.source = '300IPL'
                     and wnv.source = '300IPL'
                     and wnv.node_position = 'S');


*/