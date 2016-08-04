create or replace PACKAGE BODY            WIM_LOADER
AS
/*----------------------------------------------------------------------------------------------------------
  SCRIPT: WIM.WIM_LOADER.pkb

 PURPOSE:
   Package body for the WIM WIM_LOADER functionality, to load CWS(100TLM), 300IPL, 500PRB, 450PID source wells to PPDM
   using WIM GATEWAY

 DEPENDENCIES
   See Package Specification


 HISTORY:
   0.1     June 14, 2011   V.Rajpoot   Initial version
   0.2     Nov, 2011       V.Rajpoot   Added loader for 300, 450 and 500 sources
   0.3     April 2012      V.Rajpoot   Change PID_LOADER to use MVs instead of going to IHS
   0.4     May 2012        V.Rajpoot   Changed logic to Create surface nodes when well is pointing to the same node.
                                       This only applies to 300 source. @C_TALISMAN_IHSDATA, when there is vertical
                                       well, there is only a base node, but when we load to WIM database, we need
                                       to load Surface node as well ( same as base_node)  
  1.0.0    June 22 2012    V.Rajpoot   changed FIND_WELL, passed findByAlias fg when calling Find_Wells_Extended.

  1.1.0    July 2012       V.Rajpoot   Modified to use new WIM Search 2.0.0
                                       Some of Wim_Serach logic moved to WIM_LOADER package, logic to determine if 
                                       Action_Cd is 'C', 'U', or 'A'
  1.2.0    Dec 2012        V.Rajpoot   Modified to use new PID source C_Talisman_US. 
  1.2.1    Jan 2013        V.Rajpoot    Modifed CheckWellStatus function. Created a new function PrefixZeros to add
                                        zeros infront of StatusID. For 450 source, zeros are not there.
 1.2.2     April 18, 2013  V.Rajpoot   Modifed CWS_WELL_NODE_STG_VW to filter out nodes wothout LAT/LONGS.
 1.2.3     May 24, 2013    V.Rajpoot   Added a new procedure called BlackList_Wells and added a to call to it 
                                        after each Loader to inactivate wells in BlackList_Wells table.Sometimes 
 1.2.4    June 7, 2013     V.Rajpoot   Replaced loaders name with new names:
                                       IPLLOADER with WIM_LOADER_IHS_CDN
                                       PRBLOADER with WIM_LOADER_IHS_INT
                                       PIDLOADER with WIM_LOADER_IHS_US
                                       CWSLOADER with WIM_LOADER_CWS 
                                       Update CONFIG_Settings table with the new names
1.2.5    July 23, 2013     V.Rajpoot   Create Mviews for IHS CDN loader. Changed Views to use Mviews instead.
                                       Update log messages: if running loader manually ( after being stopped)
                                       Update FIND_Well to log "matched with.." msg as actual action cd, instead of 'I' 
1.2.6    August 08, 2014   K.Edwards   Updated Exception handling blocks to klass error where a failure arises
                                        Updated INACTIVATION code (exception blocks) to log when too_many_rows errors
                                        so duplicate wells found when inactivating do not stop the loader and
                                        hang the other records from being processed.
1.2.7    August 11, 2014   	K.Edwards   Updated error message to standard prefixes.                                        
1.2.8    May 17, 2016   	K.Edwards   replaced tlm_id from the license_id field and load the IHS license_id into the license_id field.
1.2.9    June 02, 2016      K.EDWARDS   Updated the logging of blacklisted wells
1.3.0    June 27, 2016      K.EDWARDS   Automerge warnings, License_ID Inactivation 
1.3.1    July 11, 2016      K.EDWARDS   Fixed license inactivation
-----------------------------------------------------------------------------------------------------------*/                                       
                                       
/*----------------------------------------------------------------------------------------------------------
FUNCTION: Version
Detail:   This function returns version # of the package          

Created On: August. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
 FUNCTION Version
 RETURN VARCHAR2
 IS

 -- Format: nn.mm.ll (kk)
 -- nn - Major version (Numeric)
 -- mm - Functional change (Numeric)
 -- ll - Bug fix revision (Numeric)
 -- k - Optional - Test version (letters) 
 
 BEGIN
 RETURN '1.3.0';
 END Version; 
 
 /*----------------------------------------------------------------------------------------------------------
FUNCTION: Start_Loader
Detail:   This function checks if loader is not running already. If it is then loader will stop.        

Created On: Dec. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
 FUNCTION Start_Loader( P_LOADER VARCHAR2)
 RETURN VARCHAR2
 IS
 v_count NUMBER;
 
 BEGIN
     select count(1) into v_count
       from wim.wim_stg_Request
       where status_cd ='R'
       and row_created_by = P_LOADER;
     
     if v_count > 0 THEN -- means there are still some pending request or loader is still running
        RETURN 'N';
     else
        RETURN 'Y';
     end if;
 
 
 END Start_Loader;
 
/*----------------------------------------------------------------------------------------------------------
FUNCTION: Commit_Value
Detail:   This function get commit value from Config_Settings table          

Created On: Feb. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/
FUNCTION commit_value(p_process varchar2)
RETURN NUMBER
IS

V_COMMIT NUMBER;

BEGIN
    SELECT KEY_VALUE INTO V_COMMIT
      FROM CONFIG_SETTINGS
     WHERE PROCESS = P_PROCESS
       AND KEY_NAME = 'COMMIT';
    
    RETURN V_COMMIT;

END;

/*------------------------------------------------------------------------------------------
PROCEDURE: BlackList_Wells
Detail:    Procedure to inactivate wells in Black_List_Wells table.

HISTORY:
   0.1      May 25, 2013    V.Rajpoot       Initial Creation
--------------------------------------------------------------------------------------------*/
 
PROCEDURE BlackList_Wells (P_SOURCE WELL_VERSION.SOURCE%TYPE DEFAULT NULL)
IS
  
      
    V_WIM_STG_ID NUMBER;        
    v_count      NUMBER;
    ptlm_id      VARCHAR2(20);
    pStatus      VARCHAR2(200);
    pAudit_No    NUMBER;
    v_Warning_UWIs  VARCHAR2(2000);
    v_total     NUMBER;
    v_uwi       well_Version.uwi%type;
    
    BEGIN
   v_total :=0;
    ppdm.tlm_process_logger.info ( 'BlackList Wells Started');
           
    FOR wells IN (select * from BLACK_LIST_WELLS where P_SOURCE is null or Source = p_SOURCE)
    LOOP
            --Check if they exist in well_Version
           SELECT count(1) into v_count
             FROM PPDM.WELL_VERSION
            WHERE source = wells.source
              and ACTIVE_IND = 'Y'
              and uwi = wells.tlm_id;                            
        
        if v_count =1 then
              
           SELECT wim.WIM_STG_ID_SEQ.nextval INTO V_WIM_STG_ID   FROM DUAL;
                             
           INSERT INTO wim.wim_stg_request (WIM_STG_ID, STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
           VALUES (V_WIM_STG_ID, 'R', 'BLACKLIST', SYSDATE);
            
           INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, SOURCE)
           VALUES(V_WIM_STG_ID,'I','Y',wells.tlm_id, wells.SOURCE);
           
           WIM.wim_gateway.well_action(V_WIM_STG_ID, ptlm_id, pStatus, paudit_No);
           v_total := v_total+1;            
         end if;
    END LOOP;
    
    
    --Check if there are any warnings 
    
    --If timeout_date is before the current date then create a warning message.
    for rec in (select * from BLACK_LIST_WELLS where source = P_SOURCE and TimeOut_date < Sysdate)
    loop
        v_Warning_UWIs := v_Warning_UWIs || ',' || rec.tlm_id;
    
    end loop;
    
       ppdm.tlm_process_logger.info ( 'BlackList Wells Completed: Total Updated: ' || v_total);
     
    if Length(v_Warning_UWIs) > 0 then
         --Remove the last comma
        v_Warning_UWIs := ltrim(v_Warning_UWIs, ',');   
        ppdm.tlm_process_logger.warning ( 'BlackList Wells: TimeOut Date has been passed for UWIs (' ||  v_Warning_UWIs  || ')' );
    end if;
    
 EXCEPTION
    WHEN OTHERS
      THEN        
        ppdm.tlm_process_logger.error ( 'BlackList Wells FAILED: Oracle Error - ' || SQLERRM);                                                        
          
        ROLLBACK;
    
    
    
 END;
 
/*----------------------------------------------------------------------------------------------------------
Procedure: InActivate_100_Source
Detail:    This Procedure inactivated 100TLM source wells, by populated staging tables and calling 
           Wim_Gateway to process it.     

          This is called from Load_Cws_WElls, Load_Pid_Wells, Load_Probe_WElls, Load_IPL_Wells.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
PROCEDURE INACTIVATE_100_SOURCE
IS

CURSOR Well_Cur Is
  SELECT UWI 
    FROM WELL_VERSION
   WHERE (ACTIVE_IND != 'N' OR ACTIVE_IND is NULL)
     AND SOURCE = '100TLM'
     AND country in ('7US', '7CN')
     MINUS
     SELECT UWI FROM CWS_WELLS_STG_VW;
  
    CURSOR Nodes_Cur IS
    Select wv.UWI, wnv.node_id, wnv.Node_Obs_No,  wnv.Node_Position,  wnv.Geog_coord_System_Id, wnv.Location_Qualifier
    from  Well_Version wv,
          well_node_Version wnv
    Where wv.uwi = wnv.ipl_uwi
    and wv.source = '100TLM'
    and wv.source =  wnv.source
    and wv.country =  wnv.country
    and wnv.ACTIVE_IND = 'Y' and wv.ACTIVE_IND = 'N'
    AND wv.country in ('7US', '7CN')
    MINUS
    Select uwi, nodE_id, Node_Obs_no, Node_Position, Geog_Coord_System_Id, Location_Qualifier
     From cws_well_node_stg_vw;
     
    cursor license_cur
    is
        select uwi, license_id--, license_num
        from ppdm.well_license
        where source = '100TLM'
            and active_ind = 'Y'
        minus
        select uwi, wl_license_id as license_id--, wl_license_num
        from wim_loader.cws_wells_stg_vw
    ;
    
   v_uwi                    WELL_VERSION.UWI%TYPE;
   V_WIM_STG_ID             NUMBER;
   V_COMMIT                 NUMBER;
   V_TOTAL                  NUMBER;
   v_Node_Obs_No            well_node_Version.node_obs_no%type;
   v_Node_Position          WELL_NODE_VERSION.NODE_POSITION%TYPE;
   v_Node_id                WELL_NODE_VERSION.NODE_ID%TYPE;
   v_Geog_Coord_System_Id   WELL_NODE_VERSION.Geog_Coord_System_ID%TYPE;
   v_Location_Qualifier     WELL_NODE_VERSION.Location_Qualifier%TYPE;
	v_license_id            ppdm.well_license.license_id%type;
BEGIN
    --Get commit value
    V_COMMIT := Commit_Value('WIM_LOADER_CWS');
  
    ppdm_admin.tlm_process_logger.info('WIM_LOADER_CWS' || ' INACTIVATING - WELLS' );
  
   v_total := 0;
    -- Inactivating Well_Version. Simple populate wim_stg_well_version with 'I' action code
    -- Wim_Gateway Inactivates well_Version and its nodes, status, license
    OPEN well_cur;         
        loop
            FETCH well_cur into v_uwi;
            exit when well_cur%NotFound;            

           INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_CWS', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
            
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID,'I','Y',v_uwi, '100TLM', SYSDATE, 'WIM_LOADER_CWS');
          
         
            v_total := v_total+1;
                 
            if v_total = v_commit then
               COMMIT;
               v_commit := 0;
            END IF;     
        
        commit;
    end loop;
    close well_cur;
    
    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_CWS', 'INACTIVATION');
    
   -- tlm_process_logger.info ('CWSLOADER' || ' INACTIVATING - NODES' );  
  
    ppdm_admin.tlm_process_logger.info('WIM_LOADER_CWS' || ' INACTIVATING - NODES');
    
	v_total := 0;
	
	Open Nodes_Cur;
    Loop
        FETCH Nodes_Cur into  v_UWI, v_node_id,v_Node_Obs_No, v_Node_Position,  v_Geog_coord_System_Id, v_Location_Qualifier;
            exit when Nodes_Cur%NotFound;
                    
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ( 'R', 'WIM_LOADER_CWS', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
            
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, WELL_NUM, SOURCE )
            VALUES(V_WIM_STG_ID,'X','Y',v_uwi,null, '100TLM');
         
           INSERT INTO wim.wim_stg_well_node_version (WIM_STG_ID, WIM_SEQ,WIM_ACTION_CD, ACTIVE_IND, IPL_UWI, GEOG_COORD_SYSTEM_ID, 
                                                       LOCATION_QUALIFIER, NODE_OBS_NO, NODE_ID,NODE_POSITION,  SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID, 1, 'I','Y',v_uwi, v_geog_coord_system_id, v_location_qualifier, v_node_obs_no, v_node_id, v_node_Position, '100TLM', sysdate, 'PIDLOADER');
         
            v_total := v_total+1;
          
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;     
        
        commit;
    End Loop;
    close Nodes_Cur;
    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_CWS', 'INACTIVATION');
    
    ppdm_admin.tlm_process_logger.info('WIM_LOADER_CWS' || ' INACTIVATING - LICENSES');
    
    v_total := 0;   
    
	open license_cur;         
    loop
        fetch license_cur into v_uwi, v_license_id;
        exit when license_cur%notfound;            
        
        insert into wim.wim_stg_request(status_cd, row_created_by, row_created_date)
        values ('R', 'WIM_LOADER_CWS', sysdate)
        returning wim_stg_id into v_wim_stg_id;
    
        insert into wim.wim_stg_well_version(wim_stg_id, wim_action_cd, active_ind, uwi, source, row_changed_date, row_changed_by)
        values(v_wim_stg_id, 'X', 'Y', v_uwi, '100TLM', sysdate, 'WIM_LOADER_CWS');
        
        insert into wim.wim_stg_well_license(wim_stg_id, wim_action_cd, active_ind, uwi, license_id, source, row_changed_date, row_changed_by)
        values(v_wim_stg_id, 'I', 'Y', v_uwi, v_license_id, '100TLM', sysdate, 'WIM_LOADER_CWS');
    
        v_total := v_total + 1;
         
        if v_total = v_commit then
            commit;
            v_commit := 0;
        end if;
        commit;
    end loop;
    close license_cur;
    
    -- call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    wellaction('R', 'WIM_LOADER_CWS', 'INACTIVATION');
END INACTIVATE_100_SOURCE;

/*----------------------------------------------------------------------------------------------------------
Procedure: InActivate_450_Source
Detail:    This Procedure inactivated 450PID source wells, by populated staging tables and calling 
           Wim_Gateway to process it.     

          This is called from Load_Cws_WElls, Load_Pid_Wells, Load_Probe_WElls, Load_IPL_Wells.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/

PROCEDURE INACTIVATE_450_SOURCE
IS

CURSOR Well_Cur IS
  SELECT WELL_NUM 
    FROM WELL_VERSION
   WHERE (ACTIVE_IND != 'N' OR ACTIVE_IND is NULL)
     AND SOURCE = '450PID'    
     MINUS
     SELECT WELL_NUM FROM PID_WELLS_STG_VW; 
  
  --Nodes
  CURSOR Nodes_Cur IS
    Select wv.Well_Num, wnv.Node_Obs_No,  wnv.Node_Position,  wnv.Geog_coord_System_Id, wnv.Location_Qualifier
    from  Well_Version wv,
          well_node_Version wnv
    Where wv.uwi = wnv.ipl_uwi
    and wv.source = '450PID'
    and wv.source =  wnv.source
    and wnv.ACTIVE_IND = 'Y'
    and wnv.location_qualifier not like 'zTIS:%'
   
    MINUS   
    
         ( -- This is for all Base nodes where surface_node_Id = base_node_id
       Select w.Well_Num, wnv.Node_Obs_No,Node_Position, wnv.Geog_Coord_System_id, wnv.Location_Qualifier 
        From PID_wells_STG_VW w,
             PID_WELL_NODE_STG_VW wnv
       WHere w.uwi = wnv.uwi     
         and w.base_node_id = w.surface_node_id
         and wnv.location_qualifier = 'IH'
      
   
           union
         -- This is for all Surface nodes where surface_node_Id = base_node_id, IHS only has the base nodes, in this case
         -- copying Base Nodes and replacing Node_Position = 'S'  
        Select w.Well_Num, wnv.Node_Obs_No,'S', wnv.Geog_Coord_System_id, wnv.Location_Qualifier 
          From PID_wells_STG_VW w,
             PID_WELL_NODE_STG_VW wnv
         WHere w.uwi = wnv.uwi      
           and w.base_node_id = w.surface_node_id
           and wnv.location_qualifier = 'IH'            
         
              union
          --This of for rest of the nodes where Base_Node_Id <> Surface_Node_Id
        Select w.Well_Num, wnv.Node_Obs_No,Node_Position, wnv.Geog_Coord_System_id, wnv.Location_Qualifier 
          From PID_wells_STG_VW w,
             PID_WELL_NODE_STG_VW wnv
         WHere w.uwi = wnv.uwi         
          and wnv.location_qualifier = 'IH'
          and base_node_id <> surface_node_id 
        );
 
   Cursor Status_cur IS
   Select wv.WELL_NUM, ws.status_id 
     From well_version wv,
          well_status ws
    WHere wv.uwi = ws.uwi
      and wv.source = '450PID'
      and ws.source = '450PID'
      and ws.Active_ind = 'Y'      
     
    MINUS
    Select w.uwi, ws.status_id 
      From PID_Well_Status_stg_vw ws, 
           PID_wells_STG_VW w
     where ws.uwi = w.uwi
    
     ;    
     
    cursor license_cur
    is
        select v.well_num, l.license_id
        from ppdm.well_license l
        join ppdm.well_version v on v.uwi = l.uwi and v.source = l.source and v.active_ind = l.active_ind
        where l.source = '450PID'
            and l.active_ind = 'Y'
        minus
        select uwi, wl_license_id as license_id
        from wim_loader.pid_wells_stg_vw
    ;
   
  v_uwi                     WELL_VERSION.UWI%TYPE;  
  V_WIM_STG_ID              NUMBER;
  v_Well_Num                WELL_VERSION.WELL_NUM%TYPE;
  v_Node_Obs_No             WELL_NODE_VERSION.NODE_OBS_NO%TYPE;
  v_Node_Position           WELL_NODE_VERSION.NODE_POSITION%TYPE;
  v_Geog_Coord_System_Id    WELL_NODE_VERSION.Geog_Coord_System_ID%TYPE;
  v_Location_Qualifier      WELL_NODE_VERSION.Location_Qualifier%TYPE;
  v_node_id                 WELL_NODE_VERSION.Node_Id%TYPE;  
  v_Total                   NUMBER;
  v_COMMIT                  NUMBER;
  v_status_id               WELL_STATUS.STATUS_ID%TYPE;
  v_license_id              ppdm.well_license.license_id%type;
  v_ipl_uwi_local           ppdm.well_version.ipl_uwi_local%type;
  
BEGIN
    
    v_TOTAL := 0;
   
    --Get commit value
    V_COMMIT := Commit_Value('WIM_LOADER_IHS_US');
 
    tlm_process_logger.info ('WIM_LOADER_IHS_US' || ' INACTIVATING - WELLS' );
    
    -- Inactivating Well_version 
    --Populate wim_stg_well_version with 'I' action code  
    -- Wim_Gateway Inactivates well_Version and its nodes, status and licenses
     
    OPEN well_cur;         
        loop
            FETCH well_cur into v_well_num;
            exit when well_cur%NotFound;
            --Get UWI from well_version using well_num
        BEGIN
             SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '450PID'
                AND ACTIVE_IND = 'Y'
                AND well_num = v_well_num;
             
                  
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_IHS_US', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
            
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID,'I','Y',v_uwi, '450PID', SYSDATE, 'WIM_LOADER_IHS_US');
          
         
            v_total := v_total+1;
                 
            if v_total = V_COMMIT then
               COMMIT;
               v_total := 0;
            END IF;     
         Exception 
         when TOO_MANY_ROWS then
              tlm_process_logger.warning('WIM_LOADER_IHS_US - INACTIVATING WELLS: duplicate rows for WELL_NUM: ' || v_well_num);
               when NO_DATA_FOUND then
                     NULL;
  
       END;           
        commit;
    end loop;

    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_IHS_US', 'INACTIVATION');
    
    Close well_Cur;
 
  tlm_process_logger.info ('WIM_LOADER_IHS_US' || ' INACTIVATING - NODES' );  
  
  v_Total := 0;
  -- Inactivating Well_Nodes only. 
    --Populate wim_stg_well_node_version with 'I' action code
    --and populate wim_stg_Well_Version with 'X' action code so it wont be updated.
    -- Wim_Gateway Inactivates well_Node_Version only.   
    Open Nodes_Cur;
    Loop
        FETCH Nodes_Cur into  v_Well_Num, v_Node_Obs_No, v_Node_Position,  v_Geog_coord_System_Id, v_Location_Qualifier;
            exit when Nodes_Cur%NotFound;
      
            BEGIN
            --Get Uwi from well_Version table using well_num
              SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '450PID'
                AND ACTIVE_IND = 'Y'
                AND well_num = v_well_num;
                
             -- DBMS_OUTPUT.PUT_LINE ('uwi ' || v_uwi); 
            --Get Node_Id from well_Node_Version table using uwi, geog_coord_system, location_qualifier            
                SELECT node_id into v_node_id
                  FROM well_node_version 
                 WHERE source = '450PID'
                   AND ACTIVE_IND = 'Y'
                   AND ipl_uwi = v_uwi
                   AND node_obs_no = v_node_obs_no
                   AND node_position = v_node_Position
                   AND location_qualifier = v_location_qualifier
                   AND geog_coord_system_id = v_geog_coord_system_id;               
                
                  
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_IHS_US', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
        
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, WELL_NUM, SOURCE )
            VALUES(V_WIM_STG_ID,'X','Y',v_uwi,v_well_num, '450PID');
         
           INSERT INTO wim.wim_stg_well_node_version (WIM_STG_ID, WIM_SEQ,WIM_ACTION_CD, ACTIVE_IND, IPL_UWI, GEOG_COORD_SYSTEM_ID, 
                                                       LOCATION_QUALIFIER, NODE_OBS_NO, NODE_ID,NODE_POSITION,  SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID, 1, 'I','Y',v_uwi, v_geog_coord_system_id, v_location_qualifier, v_node_obs_no, v_node_id, v_node_Position, '450PID', sysdate, 'WIM_LOADER_IHS_US');
         
            v_total := v_total+1;
                 
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;     
            commit;
            
      Exception 
         when TOO_MANY_ROWS then
              tlm_process_logger.warning('WIM_LOADER_IHS_US - INACTIVATING NODES: duplicate rows for WELL_NUM: ' || v_well_num);
               when NO_DATA_FOUND then
                     NULL;
  
       END;             
    End Loop;
     Close NodEs_Cur;
     
    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_IHS_US', 'INACTIVATION');

    -- Inactivating Well_Status only. 
    --Populate wim_stg_well_Status with 'I' action code
    --and populate wim_stg_Well_Version with 'X' action code so it wont be updated.
    -- Wim_Gateway Inactivates well_Status only.
 
    tlm_process_logger.info ('WIM_LOADER_IHS_US' || ' INACTIVATING - STATUSES' );
  
  v_total := 0;
  Open Status_Cur;
    Loop
        FETCH Status_Cur into  v_well_num, v_status_id; --, v_status, v_status_date, v_status_type ;
            exit when Status_Cur%NotFound;
         
        begin  
            --Get Uwi from well_Version table using v_ipl_uwi_local
             SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '450PID'
                AND well_num = v_well_num;
                  
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_IHS_US', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;

            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, WELL_NUM, SOURCE )
            VALUES(V_WIM_STG_ID,'X','Y',v_uwi, v_well_num, '450PID');
          
            INSERT INTO wim.wim_stg_well_status (WIM_STG_ID, WIM_SEQ, WIM_ACTION_CD, ACTIVE_IND, UWI, STATUS_ID,   
                                                  SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID, 1, 'I','Y',v_uwi, v_status_id, '450PID', SYSDATE, 'WIM_LOADER_IHS_US');
          
            v_total := v_total+1;
                 
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;   
                      
        Exception 
         when TOO_MANY_ROWS then
              tlm_process_logger.warning('WIM_LOADER_IHS_US - INACTIVATING STATUSES: duplicate rows for WELL_NUM: ' || v_well_num);
           when NO_DATA_FOUND then
                NULL;
  
       END;               
    END loop;
     Close Status_Cur;
    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_IHS_US', 'INACTIVATION');
    
    ppdm_admin.tlm_process_logger.info('WIM_LOADER_IHS_US' || ' INACTIVATING - LICENSES' );
    
    v_total := 0;   
    open license_cur;         
    loop
        fetch license_cur into v_ipl_uwi_local, v_license_id;
        exit when license_cur%notfound;            
        
        --Get Uwi from well_Version table using v_ipl_uwi_local
        SELECT uwi into v_uwi
        FROM ppdm.well_version 
        WHERE source = '450PID'
            AND ipl_uwi_local = v_ipl_uwi_local
        ;
        
        insert into wim.wim_stg_request(status_cd, row_created_by, row_created_date)
        values ('R', 'WIM_LOADER_IHS_US', sysdate)
        returning wim_stg_id into v_wim_stg_id;
    
        insert into wim.wim_stg_well_version(wim_stg_id, wim_action_cd, active_ind, uwi, source, row_created_by, row_created_date)
        values(v_wim_stg_id, 'X', 'Y', v_uwi, '450PID', 'WIM_LOADER_IHS_US', sysdate);
        
        insert into wim.wim_stg_well_license(wim_stg_id, wim_action_cd, active_ind, uwi, license_id, source, row_created_by, row_created_date)
        values(v_wim_stg_id, 'I', 'Y', v_uwi, v_license_id, '450PID', 'WIM_LOADER_IHS_US', sysdate);
    
        v_total := v_total + 1;
         
        if v_total = v_commit then
            commit;
            v_commit := 0;
        end if;
        commit;
    end loop;
    close license_cur;
    
    -- call WIM_GATEWAY.WELL_ACTION
    wellaction('R', 'WIM_LOADER_IHS_US', 'INACTIVATION');
   
END INACTIVATE_450_SOURCE;

/*----------------------------------------------------------------------------------------------------------
Procedure: InActivate_500_Source
Detail:    This Procedure inactivated 500PRB source wells, by populated staging tables and calling 
           Wim_Gateway to process it.     

          This is called from Load_Cws_WElls, Load_Pid_Wells, Load_Probe_WElls, Load_IPL_Wells.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
PROCEDURE INACTIVATE_500_SOURCE
IS

CURSOR Well_Cur Is
  SELECT WELL_NUM 
    FROM WELL_VERSION
   WHERE (ACTIVE_IND != 'N' OR ACTIVE_IND is NULL)
     AND SOURCE = '500PRB'
     MINUS
     SELECT WELL_NUM FROM PROBE_WELLS_STG_VW;
  
  
  --Nodes
  CURSOR Nodes_Cur IS
    Select wv.Well_Num, wnv.Node_Obs_No, wnv.Node_Position, wnv.Geog_coord_System_Id, wnv.Location_Qualifier
    from  Well_Version wv,
          well_node_Version wnv
    Where wv.uwi = wnv.ipl_uwi
    and wv.source = '500PRB'
    and wv.source =  wnv.source
    and wnv.ACTIVE_IND = 'Y'
    MINUS
    Select wv.Well_Num, wnv.Node_Obs_no,  wnv.Node_Position, wnv.Geog_Coord_System_Id, wnv.Location_Qualifier
     From PROBE_WELLS_STG_VW wv,
          PROBE_WELL_NODE_STG_VW wnv
    Where wv.uwi = wnv.ipl_uwi;
     
  v_uwi                     WELL_VERSION.UWI%TYPE;  
  V_WIM_STG_ID              NUMBER;
  v_Well_Num                WELL_VERSION.WELL_NUM%TYPE;
  v_Node_Obs_No             WELL_NODE_VERSION.NODE_OBS_NO%TYPE;
  v_Node_Position           WELL_NODE_VERSION.NODE_POSITION%TYPE;
  v_Geog_Coord_System_Id    WELL_NODE_VERSION.Geog_Coord_System_ID%TYPE;
  v_Location_Qualifier      WELL_NODE_VERSION.Location_Qualifier%TYPE;
  v_Total                   NUMBER;
  v_COMMIT                  NUMBER;
  v_node_id                 WELL_NODE_VERSION.NODE_ID%TYPE;
BEGIN
    
    v_Total := 0;
    
    --Get commit value
    V_COMMIT := Commit_Value('WIM_LOADER_IHS_INT');
 
   
     tlm_process_logger.info ('WIM_LOADER_IHS_INT' || ' INACTIVATING - WELLS' );
  
    -- Inactivating Well_Nversion 
    --Populate wim_stg_well_version with 'I' action code    
    -- Wim_Gateway Inactivates well_Version  and its well_nodes, status, licenses
       
    OPEN well_cur;        
        loop
            FETCH well_cur into v_well_num;
            exit when well_cur%NotFound;
        
            BEGIN
            --Get UWI from well_version using well_num            
             SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '500PRB'
                AND ACTIVE_IND = 'Y'
                AND well_num = v_well_num;
             
                    
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_IHS_INT', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
            
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID,'I','Y',v_uwi, '500PRB', SYSDATE, 'WIM_LOADER_IHS_INT');
          
         
            v_total := v_total+1;
              
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;     
        
        commit;
          Exception 
         when TOO_MANY_ROWS then
              tlm_process_logger.warning('WIM_LOADER_IHS_INT - INACTIVATING WELLS: duplicate rows for WELL_NUM: ' || v_well_num);
               NULL;
               when NO_DATA_FOUND then
                     NULL;
  
       END;             

    end loop;
    
    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_IHS_INT', 'INACTIVATION');
    
     tlm_process_logger.info ('WIM_LOADER_IHS_INT' || ' INACTIVATING - NODES' );
  
    -- Inactivating Well_Nodes only. 
    --Populate wim_stg_well_node_version with 'I' action code
    --and populate wim_stg_Well_Version with 'X' action code so it wont be updated.
    -- Wim_Gateway Inactivates well_Node_Version only.
    
   v_total := 0;
    Open Nodes_Cur;
    Loop
        FETCH Nodes_Cur into  v_Well_Num, v_Node_Obs_No,  v_Node_Position, v_Geog_coord_System_Id, v_Location_Qualifier;
            exit when Nodes_Cur%NotFound;
       
         BEGIN
            --Get Uwi from well_Version table using well_num
             SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '500PRB'
                AND ACTIVE_IND = 'Y'
                AND well_num = v_well_num;
                                
            --Get Node_Id from well_Node_Version table using uwi, geog_coord_system, location_qualifier            
                
                --DBMS_OUTPUT.PUT_LINE(v_node_obs_no || '-' || v_location_qualifier || '-' || v_location_qualifier || '-' ||v_geog_coord_system_id);
                SELECT node_id into v_node_id
                  FROM well_node_version 
                 WHERE source = '500PRB'
                   AND ACTIVE_IND = 'Y'
                   AND ipl_uwi = v_uwi
                   AND node_obs_no = v_node_obs_no
                   AND location_qualifier = v_location_qualifier
                   AND geog_coord_system_id = v_geog_coord_system_id
                   AND node_position = v_Node_Position;   
                                   
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ( 'R', 'WIM_LOADER_IHS_INT', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
        
           INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, WELL_NUM, SOURCE )
            VALUES(V_WIM_STG_ID,'X','Y',v_uwi, v_well_num, '300IPL');
          
            INSERT INTO wim.wim_stg_well_node_version (WIM_STG_ID, WIM_SEQ,WIM_ACTION_CD, ACTIVE_IND, IPL_UWI, GEOG_COORD_SYSTEM_ID, 
                                                       LOCATION_QUALIFIER, NODE_OBS_NO, NODE_ID,NODE_POSITION,  SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID, 1, 'I','Y',v_uwi, v_geog_coord_system_id, v_location_qualifier, v_node_obs_no, v_node_id, v_node_Position, '500PRB', sysdate, 'WIM_LOADER_IHS_INT');
       
    
            v_total := v_total+1;                
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;     
            commit;
         Exception 
         when TOO_MANY_ROWS then
              tlm_process_logger.warning('WIM_LOADER_IHS_INT - INACTIVATING NODES: duplicate rows for WELL_NUM: ' || v_well_num);
               NULL;
               when NO_DATA_FOUND then
                     NULL;
  
       END;             

    End Loop;
    
    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_IHS_INT', 'INACTIVATION');
    
END INACTIVATE_500_SOURCE;

/*----------------------------------------------------------------------------------------------------------
Procedure: InActivate_300_Source
Detail:    This Procedure inactivated 300IPL source wells, by populated staging tables and calling 
           Wim_Gateway to process it.     

          This is called from Load_Cws_WElls, Load_Pid_Wells, Load_Probe_WElls, Load_IPL_Wells.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
PROCEDURE INACTIVATE_300_SOURCE
IS

--Well Version
CURSOR Well_Cur Is
  SELECT WELL_NUM 
    FROM WELL_VERSION
   WHERE ACTIVE_IND ='Y'
     AND SOURCE = '300IPL'
     MINUS
     SELECT BASE_NODE_ID
       FROM IPL_WELLS_STG_VW;

  
  -- Nodes
    CURSOR Nodes_Cur IS
     Select wv.WELL_NUM, wnv.Node_Obs_No, wnv.Node_Position, wnv.Geog_coord_System_Id, wnv.Location_Qualifier
       from Well_Version wv,
            Well_node_Version wnv
      Where wv.uwi = wnv.ipl_uwi
        and wv.source = '300IPL'
        and wv.source =  wnv.source
        AND wnv.ACTIVE_IND = 'Y'
        and wnv.Geog_coord_System_Id = '4269'
        and wnv.location_qualifier not like 'zTIS:%'
            MINUS
     ( -- This is for all Base nodes where surface_node_Id = base_node_id
       Select w.BASE_NODE_ID, wnv.Node_Obs_No,Node_Position, wnv.Geog_Coord_System_id, wnv.Location_Qualifier 
        From ipl_wells_stg_vw w,
             ipl_well_node_stg_vw wnv
       WHere w.uwi = wnv.uwi     
        and w.base_node_id = w.surface_node_id 
           union
         -- This is for all Surface nodes where surface_node_Id = base_node_id, IHS only has the base nodes, in this case
         -- copying Base Nodes and replacing Node_Position = 'S'  
        Select w.BASE_NODE_ID, wnv.Node_Obs_No,'S', wnv.Geog_Coord_System_id, wnv.Location_Qualifier 
          From ipl_wells_stg_vw w,
               ipl_well_node_stg_vw wnv
         WHere w.uwi = wnv.uwi      
           and w.base_node_id = w.surface_node_id  
              union
          --This of for rest of the nodes where Base_Node_Id <> Surface_Node_Id
        Select w.BASE_NODE_ID, wnv.Node_Obs_No,Node_Position, wnv.Geog_Coord_System_id, wnv.Location_Qualifier 
          From ipl_wells_stg_vw w,
               ipl_well_node_stg_vw wnv
         WHere w.uwi = wnv.uwi
           and base_node_id <> surface_node_id 
        );
  
   -- Statuses
   CURSOR Status_Cur is
       Select wv.WELL_NUM, ws.status_id 
    From well_version wv,
         well_status ws
    WHere wv.uwi = ws.uwi
      and wv.source = '300IPL'
      and ws.source = '300IPL'
      and ws.Active_ind = 'Y'      
    MINUS
    Select w.BASE_NODE_ID, ws.status_id 
      From ipl_well_status_stg_vw ws, 
           ipl_wells_stg_vw w
     where ws.uwi = w.uwi;
   
    
    --License
    cursor license_cur
    is
        select v.ipl_uwi_local, l.license_id
        from ppdm.well_license l
        join ppdm.well_version v on v.uwi = l.uwi and v.source = l.source and v.active_ind = l.active_ind
        where l.source = '300IPL'
            and l.active_ind = 'Y'
        minus
        select uwi, wl_license_id as license_id
        from wim_loader.ipl_wells_stg_vw
    ;
    
  v_ipl_uwi_local        WELL_VERSION.WELL_NUM%TYPE;     
  v_uwi                  WELL_VERSION.UWI%TYPE;  
  V_WIM_STG_ID           NUMBER;
  v_Well_Num             WELL_VERSION.WELL_NUM%TYPE;
  v_Node_Obs_No          WELL_NODE_VERSION.NODE_OBS_NO%TYPE;
  v_Node_Position        WELL_NODE_VERSION.NODE_POSITION%TYPE;
  v_Geog_Coord_System_Id WELL_NODE_VERSION.Geog_Coord_System_ID%TYPE;
  v_Location_Qualifier   WELL_NODE_VERSION.Location_Qualifier%TYPE;
  v_node_id              WELL_NODE_VERSION.NODE_ID%TYPE;  
  v_Total                NUMBER;
  v_COMMIT               NUMBER;
  v_status_id            WELL_STATUS.STATUS_ID%TYPE; 
  v_status               WELL_STATUS.STATUS%TYPE;
  v_status_date          WELL_STATUS.STATUS_DATE%TYPE;
  v_status_type          WELL_STATUS.STATUS_TYPE%TYPE;
  v_license_id           WELL_LICENSE.LICENSE_ID%TYPE; 
  v_license_num          WELL_LICENSE.LICENSE_NUM%TYPE;
  
BEGIN
    
    v_Total  := 0;
    
     --Get commit value
    V_COMMIT := Commit_Value('WIM_LOADER_IHS_CDN');
 
   
    tlm_process_logger.info ('WIM_LOADER_IHS_CDN' || ' INACTIVATING - WELLS' );
  
    -- Inactivating Well_Version 
    --Populate wim_stg_well_version with 'I' action code    
    -- Wim_Gateway Inactivates well_Version and its nodes, statuses, licenses
   
    OPEN well_cur;         
        loop
            FETCH well_cur into v_well_num;
            exit when well_cur%NotFound;
            BEGIN
            --Get UWI from well_version using well_num             
             SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '300IPL'             
                AND well_num = v_well_num
                AND active_ind = 'Y';
                
             
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_IHS_CDN', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
            
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID,'I','Y',v_uwi, '300IPL', SYSDATE, 'WIM_LOADER_IHS_CDN');
          
         
            v_total := v_total+1;
                 
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;     
            
        commit;
               
         Exception when NO_DATA_FOUND then
                -- tlm_process_logger.warning('WIM_LOADER_IHS_CDN - duplicate rows for Base_Node_ID: ' || V_REC.BASE_NODE_ID);
               NULL;
          END;
    end loop;
    
    --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
    WellAction ('R', 'WIM_LOADER_IHS_CDN', 'INACTIVATION');
        
  tlm_process_logger.info ('WIM_LOADER_IHS_CDN' || ' INACTIVATING - NODES' );
   
 -- Inactivating Well_Nodes only. 
    --Populate wim_stg_well_node_version with 'I' action code
    --and populate wim_stg_Well_Version with 'X' action code so it wont be updated.
    -- Wim_Gateway Inactivates well_Node_Version only.
   
  v_total := 0;
  Open Nodes_Cur;
    Loop
        FETCH Nodes_Cur into  v_well_num, v_Node_Obs_No, v_Node_Position, v_Geog_coord_System_Id, v_Location_Qualifier;
            exit when Nodes_Cur%NotFound;
       
           BEGIN
            --Get Uwi from well_Version table using v_ipl_uwi_local
             SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '300IPL'
                AND well_num = v_well_num;
                 
            --Get Node_Id from well_Node_Version table using uwi, geog_coord_system, location_qualifier            
                SELECT node_id into v_node_id
                  FROM well_node_version 
                 WHERE source = '300IPL'
                   AND ipl_uwi = v_uwi
                   AND node_obs_no = v_node_obs_no
                   AND location_qualifier = v_location_qualifier
                   AND geog_coord_system_id = v_geog_coord_system_id
                   AND Node_Position = v_Node_Position;               
            
            tlm_process_logger.info ('WIM_LOADER_IHS_CDN' || ' INACTIVATING - NODES - uwi:' || v_uwi || ' - ');       
         
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_IHS_CDN', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
        
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, WELL_NUM, SOURCE )
            VALUES(V_WIM_STG_ID,'X','Y',v_uwi, v_well_num, '300IPL');
          
            INSERT INTO wim.wim_stg_well_node_version (WIM_STG_ID, WIM_SEQ,WIM_ACTION_CD, ACTIVE_IND, IPL_UWI, GEOG_COORD_SYSTEM_ID, 
                                                       LOCATION_QUALIFIER, NODE_OBS_NO, NODE_ID,NODE_POSITION,  SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID, 1, 'I','Y',v_uwi, v_geog_coord_system_id, v_location_qualifier, v_node_obs_no, v_node_id, v_node_Position, '300IPL', sysdate, 'WIM_LOADER_IHS_CDN');
         
            v_total := v_total+1;
            --v_commit := v_commit+1;
                 
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;     
        
        commit;
        
         Exception when TOO_MANY_ROWS then
                tlm_process_logger.warning('WIM_LOADER_IHS_CDN - INACTIVATING NODES: duplicate rows for well: ' || v_uwi || ', node position: ' || v_node_position);
               NULL;
         END;
        
    End Loop;
    
    --call WIM_GATEWAY.WELL_ACTION to Apply updates to WELL_* tables.
    WellAction ('R', 'WIM_LOADER_IHS_CDN', 'INACTIVATION');
    
  
    --Inactivate Statuses
    tlm_process_logger.info ('WIM_LOADER_IHS_CDN' || ' INACTIVATING - STATUSES' );
 
 -- Inactivating Well_Status only. 
    --Populate wim_stg_well_Status with 'I' action code
    --and populate wim_stg_Well_Version with 'X' action code so it wont be updated.
    -- Wim_Gateway Inactivates well_Status only.
   
  v_total := 0;
  Open Status_Cur;
    Loop
        FETCH Status_Cur into  v_well_num, v_status_id; --, v_status, v_status_date, v_status_type ;
            exit when Status_Cur%NotFound;
           
        begin
            --Get Uwi from well_Version table using v_ipl_uwi_local
             SELECT uwi into v_uwi
               FROM well_version 
              WHERE source = '300IPL'
                AND well_num = v_well_num;
                  
            INSERT INTO wim.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ('R', 'WIM_LOADER_IHS_CDN', SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;

            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, WELL_NUM, SOURCE )
            VALUES(V_WIM_STG_ID,'X','Y',v_uwi, v_well_num, '300IPL');
          
            INSERT INTO wim.wim_stg_well_status (WIM_STG_ID, WIM_SEQ, WIM_ACTION_CD, ACTIVE_IND, UWI, STATUS_ID, STATUS, STATUS_DATE, 
                                                  SOURCE, ROW_CHANGED_DATE, ROW_CHANGED_BY )
            VALUES(V_WIM_STG_ID, 1, 'I','Y',v_uwi, v_status_id, v_status, v_status_date,'300IPL', SYSDATE, 'WIM_LOADER_IHS_CDN');
          
            v_total := v_total+1;
                 
            if v_total = v_commit then
               COMMIT;
               v_total := 0;
            END IF;     
            commit;
        Exception 
         when TOO_MANY_ROWS then
              tlm_process_logger.warning('WIM_LOADER_IHS_CDN - INACTIVATING STATUSES: duplicate rows for WELL_NUM: ' || v_well_num);
               NULL;
               when NO_DATA_FOUND then
                     NULL;
        end;
    End Loop;
    close status_cur;
    --call WIM_GATEWAY.WELL_ACTION to apply updates to WELL_* tables
    WellAction ('R', 'WIM_LOADER_IHS_CDN', 'INACTIVATION');
--  
    tlm_process_logger.info ('WIM_LOADER_IHS_CDN' || ' INACTIVATING - LICENSES' );
 
    v_total := 0;   
    open license_cur;         
    loop
        fetch license_cur into v_ipl_uwi_local, v_license_id;
        exit when license_cur%notfound;            
        
        --Get Uwi from well_Version table using v_ipl_uwi_local
        SELECT uwi into v_uwi
        FROM ppdm.well_version 
        WHERE source = '300IPL'
            AND ipl_uwi_local = v_ipl_uwi_local
        ;
        
        insert into wim.wim_stg_request(status_cd, row_created_by, row_created_date)
        values ('R', 'WIM_LOADER_IHS_CDN', sysdate)
        returning wim_stg_id into v_wim_stg_id;
    
        insert into wim.wim_stg_well_version(wim_stg_id, wim_action_cd, active_ind, uwi, source, row_changed_date, row_changed_by)
        values(v_wim_stg_id, 'X', 'Y', v_uwi, '300IPL', sysdate, 'WIM_LOADER_IHS_CDN');
        
        insert into wim.wim_stg_well_license(wim_stg_id, wim_action_cd, active_ind, uwi, license_id, source, row_changed_date, row_changed_by)
        values(v_wim_stg_id, 'I', 'Y', v_uwi, v_license_id, '300IPL', sysdate, 'WIM_LOADER_IHS_CDN');
    
        v_total := v_total + 1;
         
        if v_total = v_commit then
            commit;
            v_commit := 0;
        end if;
        commit;
    end loop;
    close license_cur;
    
    -- call WIM_GATEWAY.WELL_ACTION
    wellaction('R', 'WIM_LOADER_IHS_CDN', 'INACTIVATION');
END INACTIVATE_300_SOURCE;


/*----------------------------------------------------------------------------------------------------------
Function:  GetWellStatus
Detail:    This Procedure gets status from r_well_status.
           This is called from POPULATE_WELL_STATUS_STG.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
FUNCTION GetWellStatus (
    P_WELL_ID   VARCHAR2, 
    P_STATUS    VARCHAR2
   ) 
    RETURN VARCHAR2
IS

v_num NUMBER;
v_status VARCHAR2(20);
BEGIN
        v_status := NULL;
        
      --get status Code    
        select count(*) into v_num
          from r_well_status 
          where ACTIVE_IND = 'Y'
          AND ( STATUS LIKE P_STATUS);
                      
        if v_num > 0 then        
           select DISTINCT Status into v_STATUS                  
             from r_well_status 
            where ACTIVE_IND = 'Y'
              AND ( STATUS LIKE P_STATUS) and rownum =1;                                      
        end if;
    
        RETURN v_STATUS;
END; 

/*----------------------------------------------------------------------------------------------------------
Function:  CheckWellLicense
Detail:    This Procedure checks if License record needs to be updated or Added.      

          This is called from POPULATE_WELL_LICENSE_STG.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
FUNCTION CheckwellLicense(
    P_UWI           VARCHAR2, 
    P_LICENSE_ID    VARCHAR2, 
    P_SOURCE        VARCHAR2
  ) 
    RETURN VARCHAR2
IS
v_num NUMBER;

BEGIN
     SELECT count(*) into v_num
      FROM well_license
     WHERE uwi = P_UWI
       and LICENSE_ID = P_LICENSE_ID
       and source = P_SOURCE;
      
    if v_num > 0 then
     RETURN 'U';
    else
     RETURN 'A';
    end if;

END;

/*----------------------------------------------------------------------------------------------------------
Function:  PrefixZeros
Detail:    This function adds zeros infron of Status_is, if no there 
            450 source- dont have zeros infront.
            
          This is called from CheckWellStatus.

Created On: Jan. 2013
History of Change:
------------------------------------------------------------------------------------------------------------*/

FUNCTION PrefixZeros(p_value well_status.status_id%TYPE)
RETURN VARCHAR2
is
v_result well_status.status_id%TYPE;

begin

     If length(p_value) = 1 THEN
         v_result := '00' ||p_value;
     ElSIF length(p_value) = 2 THEN
        v_result := '0' ||p_value;
     ELSE
        -- no need to do anything   
        v_result := p_value;
     END IF;
    
    RETURN v_result;
    
END;
/*----------------------------------------------------------------------------------------------------------
Function:  CheckWellStatus
Detail:    This Procedure checks if Status needs to be updated or Added. If need to be added, it also return
           next Status_ID to be used.     

          This is called from POPULATE_WELL_STATUS_STG.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
FUNCTION CheckWellStatus (
    P_WELL_ID           WELL_VERSION.UWI%TYPE, 
    P_SOURCE            WELL_VERSION.SOURCE%TYPE, 
    P_STATUS_CD         WELL_STATUS.STATUS%TYPE, 
    P_STATUS_ID IN OUT  WELL_STATUS.STATUS_ID%TYPE
   )
     RETURN VARCHAR2
IS
    v_num       NUMBER;
    v_status    NUMBER;
    v_count     NUMBER;    
    v_status_id WELL_STATUS.Status_ID%TYPE;
    
    BEGIN           
                
     --Need to prefix 00 before checking, becasue 450 source dont have 00 infront

     SELECT count(*) into v_num
       FROM WELL_STATUS
      WHERE UWI = p_WELL_ID
        AND SOURCE = P_SOURCE
        AND (( P_SOURCE ='100TLM' AND STATUS = P_STATUS_CD) -- for 100 source
        OR ( status_id = P_STATUS_ID) );
      
       
      IF v_num > 0 
      THEN  -- Status already exists
      
       --Get the max   
       SELECT MAX(STATUS_ID) into V_STATUS_ID        
          FROM WELL_STATUS
         WHERE UWI = p_WELL_ID
           AND SOURCE = P_SOURCE          
           AND (( P_SOURCE ='100TLM' AND STATUS = P_STATUS_CD) -- for 100 source
            OR ( status_id = P_STATUS_ID) );

        
        
        --for 300 , 450 , 500 source, use the same ID as IHS source, for other like 100TLM
        --get the latest one, because there could be more than one status_Ids for the same status.
                                   
        IF P_SOURCE = '100TLM' THEN -- for 100 source we need to get max id 
            P_STATUS_ID := V_STATUS_ID;     
        END IF;
         
        RETURN 'U'; --exists   
 
      ELSE -- NEW status
             
         select count(*) into v_count
            from well_status
           where uwi = p_WELL_ID
             and source = P_SOURCE;
                 
         if v_count > 0 then
            --get the new status_id         
            select max(status_id)+1 into V_STATUS_ID
              from well_status
             where uwi = p_well_id
               and source = p_source;      
         else
             V_STATUS_ID := 1; -- This is the first one                          
         end if;
         
        -- for 300, 450 or 500 source use same as in source
        --for 100 source, there is always one status no id is given        
        IF P_SOURCE = '100TLM' then
           P_STATUS_ID := PrefixZeros(V_STATUS_ID);
        ELSE -- need to put 00 infront if not there already
           P_STATUS_ID := PrefixZeros(P_STATUS_ID);           
        END IF;
 
       RETURN 'A'; --new
      
      end if;
    

END;

/*----------------------------------------------------------------------------------------------------------
Function:  CheckWellNodeVersion
Detail:    This Procedure checks if Node needs to be updated or Added     

          This is called from POPULATE_WELL_NODES_STG.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
FUNCTION CheckWellNodeVersion (
    P_NODE_ID               WELL_NODE_VERSION.NODE_ID%TYPE,
    P_GEOG_COORD_SYSTEM_ID  WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE, 
    P_NODE_OBS_NO           WELL_NODE_VERSION.NODE_OBS_NO%TYPE ,
    P_SOURCE                WELL_VERSION.SOURCE%TYPE, 
    P_LOCATION_QUALIFIER    WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE
  )
    RETURN VARCHAR2
IS
    v_num NUMBER;
    BEGIN
    
    
    SELECT count(*) into v_num
      FROM well_node_version
     WHERE NODE_ID = P_NODE_ID
       and source = P_SOURCE
       and node_obs_no = P_NODE_OBS_NO
       AND geog_coord_system_id = P_GEOG_COORD_SYSTEM_ID
       AND location_qualifier = P_LOCATION_QUALiFIER; --'N/A';
       
    if v_num > 0 then
     RETURN 'U';
    else
     RETURN 'A';
    end if;

END;

/*----------------------------------------------------------------------------------------------------------
PROCEDURE: POPULATE_WELL_VERSION_STG
Detail:    This procedure POPULATES WIM_STG_WELL_VERSION TABLE
            
           This is called from POPULATE_STG_TABLES PROCEDURE
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/

PROCEDURE Populate_well_Version_Stg ( 
    P_WIM_STG_ID    WIM.WIM_STG_REQUEST.WIM_STG_ID%TYPE, 
    P_TLM_ID        WELL_VERSION.UWI%TYPE, 
    P_ACTION_CD     WIM.WIM_STG_WELL_VERSION.WIM_ACTION_CD%TYPE, 
    P_LOADER        VARCHAR2, 
    P_SOURCE        WELL_VERSION.SOURCE%TYPE, 
    P_WELL          CWS_WELLS_STG_VW%ROWTYPE,  
    P_Error IN OUT  VARCHAR2 
    )                              
                                
IS

BEGIN
      
          INSERT INTO WIM.WIM_STG_WELL_VERSION (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND,UWI, SOURCE,
                 ABANDONMENT_DATE, ASSIGNED_FIELD, BASE_NODE_ID, BOTTOM_HOLE_LATITUDE, BOTTOM_HOLE_LONGITUDE,
                 CASING_FLANGE_ELEV, WIM_CASING_FLANGE_ELEV_CUOM,CASING_FLANGE_ELEV_OUOM, Completion_Date, CONFIDENTIAL_DATE, 
                 CONFIDENTIAL_DEPTH, WIM_CONFIDENTIAL_DEPTH_CUOM, CONFIDENTIAL_DEPTH_OUOM, CONFIDENTIAL_TYPE, CONFID_STRAT_NAME_SET_ID,
                 CONFID_STRAT_UNIT_ID, COUNTRY, COUNTY, CURRENT_CLASS, CURRENT_STATUS, CURRENT_STATUS_DATE,
                 DEEPEST_DEPTH, WIM_DEEPEST_DEPTH_CUOM, DEEPEST_DEPTH_OUOM, Depth_Datum, Depth_Datum_Elev, WIM_Depth_Datum_Elev_CUOM,Depth_Datum_Elev_OUOM, 
                 DERRICK_FLOOR_ELEV, WIM_DERRICK_FLOOR_ELEV_CUOM, DERRICK_FLOOR_ELEV_OUOM, DIFFERENCE_LAT_MSL, DISCOVERY_IND, DISTRICT,                
                 DRILL_TD, WIM_Drill_TD_CUOM,Drill_TD_OUOM, EFFECTIVE_DATE, ELEV_REF_DATUM, EXPIRY_DATE, FAULTED_IND,
                 FINAL_DRILL_DATE, FINAL_TD, WIM_FINAL_TD_CUOM,FINAL_TD_OUOM, GEOGRAPHIC_REGION, GEOLOGIC_PROVINCE, 
                 Ground_Elev, WIM_Ground_Elev_CUOM, Ground_Elev_OUOM, GROUND_ELEV_TYPE, INITIAL_CLASS, KB_ELEV, WIM_KB_ELEV_CUOM,
                 KB_ELEV_OUOM, LEASE_NAME, LEASE_NUM,LEGAL_SURVEY_TYPE, LOCATION_TYPE, LOG_TD, WIM_LOG_TD_CUOM, LOG_TD_OUOM, MAX_TVD, 
                 WIM_MAX_TVD_CUOM,MAX_TVD_OUOM, NET_PAY, WIM_NET_PAY_CUOM,NET_PAY_OUOM, Oldest_Strat_Age, OLDEST_STRAT_NAME_SET_AGE, 
                 OLDEST_STRAT_NAME_SET_ID, Oldest_Strat_Unit_Id, Operator, PARENT_RELATIONSHIP_TYPE,
                 Parent_UWI, PLATFORM_ID, PLATFORM_SF_TYPE,  Plot_Name, Plot_Symbol, PLUGBACK_DEPTH, WIM_PLUGBACK_DEPTH_CUOM, PLUGBACK_DEPTH_OUOM,
                 PPDM_GUID, PROFILE_TYPE,PROVINCE_STATE, REGULATORY_AGENCY, REMARK, RIG_ON_SITE_DATE, RIG_RELEASE_DATE, 
                 ROTARY_TABLE_ELEV, SOURCE_DOCUMENT, Spud_Date, STATUS_TYPE, SUBSEA_ELEV_REF_TYPE,  SURFACE_LATITUDE, 
                 SURFACE_LONGITUDE, SURFACE_NODE_ID, TAX_CREDIT_CODE, TD_STRAT_AGE, TD_STRAT_NAME_SET_AGE, TD_STRAT_NAME_SET_ID,TD_STRAT_UNIT_ID, 
                 WATER_ACOUSTIC_VEL, WATER_ACOUSTIC_VEL_OUOM, Water_Depth, WATER_DEPTH_DATUM, WIM_WATER_DEPTH_CUOM, WATER_DEPTH_OUOM, 
                 WELL_EVENT_NUM, WELL_GOVERNMENT_ID, WELL_INTERSECT_MD, WELL_NAME, WELL_NUM, WELL_NUMERIC_ID, WHIPSTOCK_DEPTH, 
                 WIM_WHIPSTOCK_DEPTH_CUOM,WHIPSTOCK_DEPTH_OUOM, IPL_Licensee, IPL_OFFSHORE_IND, IPL_PIDStatus, IPL_PRSTATUS, IPL_ORSTATUS, IPL_ONPROD_DATE, 
                 IPL_ONINJECT_DATE, IPL_CONFIDENTIAL_STRAT_AGE, IPL_POOL, IPL_LAST_UPDATE, IPL_UWI_Sort, IPL_UWI_DISPLAY, IPL_TD_TVD, 
                 IPL_PLUGBACK_TVD,IPL_WHIPSTOCK_TVD, IPL_WATER_TVD,IPL_ALT_Source, IPL_xAction_Code,ROW_CHANGED_BY, 
                 ROW_CHANGED_DATE , ROW_CREATED_BY , ROW_CREATED_DATE,IPL_BASIN, IPL_BLOCK, IPL_AREA, IPL_TWP, IPL_TRACT, IPL_LOT, IPL_CONC, 
                 IPL_UWI_LOCAL, ROW_QUALITY)                                               
         VALUES (P_WIM_STG_ID, P_ACTION_CD , P_WELL.ACTIVE_IND, P_TLM_ID, P_SOURCE, 
                P_WELL.ABANDONMENT_DATE, P_WELL.ASSIGNED_FIELD, P_WELL.BASE_NODE_ID,P_WELL.BOTTOM_HOLE_LATITUDE, P_WELL.BOTTOM_HOLE_LONGITUDE,
                P_WELL.CASING_FLANGE_ELEV, P_WELL.CASING_FLANGE_ELEV_CUOM, P_WELL.CASING_FLANGE_ELEV_OUOM, P_WELL.Completion_Date, 
                P_WELL.CONFIDENTIAL_DATE, P_WELL.CONFIDENTIAL_DEPTH, P_WELL.CONFIDENTIAL_DEPTH_CUOM,P_WELL.CONFIDENTIAL_DEPTH_OUOM, P_WELL.CONFIDENTIAL_TYPE, 
                P_WELL.CONFID_STRAT_NAME_SET_ID,P_WELL.CONFID_STRAT_UNIT_ID, P_WELL.COUNTRY, P_WELL.COUNTY, P_WELL.CURRENT_CLASS, P_WELL.CURRENT_STATUS, 
                P_WELL.CURRENT_STATUS_DATE, P_WELL.DEEPEST_DEPTH, P_WELL.DEEPEST_DEPTH_CUOM, P_WELL.DEEPEST_DEPTH_OUOM, P_WELL.Depth_Datum, P_WELL.Depth_Datum_Elev, 
                P_WELL.Depth_Datum_Elev_CUOM, P_WELL.Depth_Datum_Elev_OUOM,P_WELL.DERRICK_FLOOR_ELEV,P_WELL.DERRICK_FLOOR_ELEV_CUOM,P_WELL.DERRICK_FLOOR_ELEV_OUOM, 
                P_WELL.DIFFERENCE_LAT_MSL,P_WELL.DISCOVERY_IND, P_WELL.DISTRICT,P_WELL.DRILL_TD, P_WELL.Drill_TD_CUOM,P_WELL.Drill_TD_OUOM,  P_WELL.EFFECTIVE_DATE, 
                P_WELL.ELEV_REF_DATUM,P_WELL.EXPIRY_DATE,P_WELL.FAULTED_IND, P_WELL.FINAL_DRILL_DATE, P_WELL.FINAL_TD, P_WELL.FINAL_TD_CUOM, P_WELL.FINAL_TD_OUOM,
                P_WELL.GEOGRAPHIC_REGION, P_WELL.GEOLOGIC_PROVINCE, P_WELL.Ground_Elev,P_WELL.Ground_Elev_CUOM, P_WELL.Ground_Elev_OUOM, P_WELL.GROUND_ELEV_TYPE, 
                P_WELL.INITIAL_CLASS, P_WELL.KB_ELEV,P_WELL.KB_ELEV_CUOM, P_WELL.KB_ELEV_OUOM,P_WELL.LEASE_NAME, P_WELL.LEASE_NUM,P_WELL.LEGAL_SURVEY_TYPE, 
                P_WELL.LOCATION_TYPE,P_WELL.LOG_TD, P_WELL.LOG_TD_CUOM, P_WELL.LOG_TD_OUOM, P_WELL.MAX_TVD, P_WELL.MAX_TVD_CUOM, P_WELL.MAX_TVD_OUOM,P_WELL.NET_PAY, 
                P_WELL.NET_PAY_CUOM, P_WELL.NET_PAY_OUOM,P_WELL.Oldest_Strat_Age,P_WELL.OLDEST_STRAT_NAME_SET_AGE,P_WELL.OLDEST_STRAT_NAME_SET_ID, 
                P_WELL.Oldest_Strat_Unit_Id, P_WELL.Operator,P_WELL.PARENT_RELATIONSHIP_TYPE,P_WELL.Parent_UWI, P_WELL.PLATFORM_ID,P_WELL.PLATFORM_SF_TYPE,  
                P_WELL.Plot_Name, P_WELL.Plot_Symbol, P_WELL.PLUGBACK_DEPTH,  P_WELL.PLUGBACK_DEPTH_CUOM, P_WELL.PLUGBACK_DEPTH_OUOM, P_WELL.PPDM_GUID,
                P_WELL.PROFILE_TYPE,P_WELL.PROVINCE_STATE, P_WELL.REGULATORY_AGENCY, P_WELL.REMARK, P_WELL.RIG_ON_SITE_DATE, P_WELL.RIG_RELEASE_DATE, 
                P_WELL.ROTARY_TABLE_ELEV, P_WELL.SOURCE_DOCUMENT, P_WELL.Spud_Date, P_WELL.STATUS_TYPE, P_WELL.SUBSEA_ELEV_REF_TYPE,  P_WELL.SURFACE_LATITUDE, 
                P_WELL.SURFACE_LONGITUDE, P_WELL.SURFACE_NODE_ID, P_WELL.TAX_CREDIT_CODE, P_WELL.TD_STRAT_AGE,P_WELL.TD_STRAT_NAME_SET_AGE, 
                P_WELL.TD_STRAT_NAME_SET_ID,P_WELL.TD_STRAT_UNIT_ID, P_WELL.WATER_ACOUSTIC_VEL,P_WELL.WATER_ACOUSTIC_VEL_OUOM, P_WELL.Water_Depth, 
                P_WELL.WATER_DEPTH_DATUM, P_WELL.WATER_DEPTH_CUOM, P_WELL.WATER_DEPTH_OUOM,P_WELL.WELL_EVENT_NUM, P_WELL.WELL_GOVERNMENT_ID, 
                P_WELL.WELL_INTERSECT_MD, P_WELL.WELL_NAME,P_WELL.WELL_NUM, P_WELL.WELL_NUMERIC_ID, 
                P_WELL.WHIPSTOCK_DEPTH, P_WELL.WHIPSTOCK_DEPTH_CUOM,P_WELL.WHIPSTOCK_DEPTH_OUOM, P_WELL.IPL_Licensee, P_WELL.IPL_OFFSHORE_IND,
                P_WELL.IPL_PIDStatus,P_WELL.IPL_PRSTATUS, P_WELL.IPL_ORSTATUS, P_WELL.IPL_ONPROD_DATE, P_WELL.IPL_ONINJECT_DATE, 
                P_WELL.IPL_CONFIDENTIAL_STRAT_AGE, P_WELL.IPL_POOL,P_WELL.IPL_LAST_UPDATE, P_WELL.IPL_UWI_Sort, P_WELL.IPL_UWI_DISPLAY, 
                P_WELL.IPL_TD_TVD, P_WELL.IPL_PLUGBACK_TVD, P_WELL.IPL_WHIPSTOCK_TVD,P_WELL.IPL_WATER_TVD,P_WELL.IPL_ALT_Source, P_WELL.IPL_xAction_Code,
                P_WELL.ROW_CHANGED_BY, P_WELL.ROW_CHANGED_DATE , P_WELL.ROW_CREATED_BY,P_WELL.ROW_CREATED_DATE, P_WELL.IPL_BASIN, P_WELL.IPL_BLOCK, 
                P_WELL.IPL_AREA, P_WELL.IPL_TWP, P_WELL.IPL_TRACT, P_WELL.IPL_LOT, P_WELL.IPL_CONC, 
                P_WELL.IPL_UWI_LOCAL, P_WELL.ROW_QUALITY);
                
      EXCEPTION
    WHEN OTHERS
      THEN
        P_Error := SUBSTR(SQLERRM,1,1000);
        tlm_process_logger.error ( P_LOADER || ' FAILED in POPULATE_WELL_VERSION_STG: Oracle Error - ' || SQLERRM);                                                        
      ROLLBACK;
      
END Populate_well_Version_Stg;


/*----------------------------------------------------------------------------------------------------------
PROCEDURE: POPULATE_WELL_NODES_STG
Detail:    This procedure POPULATES WIM_STG_WELL_NODE_VERSION TABLE
            
           This is called from POPULATE_STG_TABLES PROCEDURE
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/

PROCEDURE POPULATE_WELL_NODES_STG ( 
    P_WIM_STG_ID        WIM.WIM_STG_REQUEST.WIM_STG_ID%TYPE, 
    P_TLM_ID            WELL_VERSION.UWI%TYPE, 
    P_NODE_POSITION     WELL_NODE_VERSION.NODE_POSITION%TYPE,
    P_ACTION_CD         WIM.WIM_STG_WELL_VERSION.WIM_ACTION_CD%TYPE, 
    P_LOADER            VARCHAR2, 
    P_SOURCE            WELL_VERSION.SOURCE%TYPE,  
    P_WELL              PID_WELL_NODE_STG_VW%ROWTYPE,  
    P_Error IN OUT      VARCHAR2 
   )                              
                                
IS

 v_Action_Cd VARCHAR2(1);
 v_Seq       NUMBER;
 v_NodeID    WELL_NODE_VERSION.NODE_ID%TYPE;
 
 
BEGIN
        
    v_seq := 0;
 
       Select count(1) into v_Seq
        from wim.wim_stg_Well_node_version
        where wim_stg_id = p_wim_stg_id;   
          
           IF P_NODE_POSITION = 'S' AND P_WELL.NODE_ID IS NOT NULL AND P_TLM_ID is not null THEN            
            -- check if adding a new node version or updating           
              v_NodeID := P_TLM_ID ||'1'; 
              
           ELSIF P_NODE_POSITION = 'B' AND P_WELL.NODE_ID IS NOT NULL AND P_TLM_ID is not null THEN  
              v_NodeID := P_TLM_ID ||'0';              
           END IF;
           
           IF P_TLM_ID is null THEN  --If P_TLM_ID is null ( means new well) not need to check, simple 'A'
              v_Action_Cd := 'A';                
           ELSE
             v_Action_Cd := CheckWellNodeVersion ( v_NodeID, P_WELL.GEOG_COORD_SYSTEM_ID, P_WELL.NODE_OBS_NO, P_SOURCE, P_WELL.LOCATION_QUALIFIER); 
           END IF;
           
          -- DBMS_OUTPUT.PUT_LINE('v_NodeID' || '**' || v_NodeID);
             v_seq := v_seq+1;              
             
             INSERT INTO WIM.WIM_STG_WELL_NODE_VERSION ( WIM_STG_ID, WIM_SEQ, WIM_ACTION_CD, Node_Id, SOURCE, NODE_OBS_NO,ACQUISITION_ID, ACTIVE_IND,
                           COUNTRY, COUNTY, EASTING, WIM_EASTING_CUOM, EASTING_OUOM, EFFECTIVE_DATE, ELEV, WIM_ELEV_CUOM, ELEV_OUOM, EW_DIRECTION,
                           EXPIRY_DATE, GEOG_COORD_SYSTEM_ID,Latitude, Legal_Survey_type, LOCATION_QUALIFIER, 
                           LOCATION_QUALITY, Longitude,MAP_COORD_SYSTEM_ID,MD, WIM_MD_CUOM, MD_OUOM, MONUMENT_ID, MONUMENT_SF_TYPE, 
                           NODE_POSITION, NORTHING, WIM_NORTHING_CUOM, NORTHING_OUOM, NORTH_TYPE, NS_DIRECTION,POLAR_AZIMUTH, POLAR_OFFSET, 
                           WIM_POLAR_OFFSET_CUOM, POLAR_OFFSET_OUOM,
                           PPDM_GUID, PREFERRED_IND, PROVINCE_STATE,  Remark,REPORTED_TVD, WIM_REPORTED_TVD_CUOM, REPORTED_TVD_OUOM, VERSION_TYPE, 
                           X_OFFSET,  WIM_X_OFFSET_CUOM, X_OFFSET_OUOM, Y_OFFSET, WIM_Y_OFFSET_CUOM, Y_OFFSET_OUOM, IPL_XACTION_CODE, ROW_CHANGED_BY, ROW_CHANGED_DATE, ROW_CREATEd_BY, 
                           ROW_CREATED_DATE, IPL_UWI, ROW_QUALITY)       
             VALUES (P_WIM_STG_ID, v_seq, v_Action_Cd, v_NodeID, P_source, P_WELL.NODE_OBS_NO,
                    P_WELL.ACQUISITION_ID, P_WELL.ACTIVE_IND, P_WELL.COUNTRY, P_WELL.COUNTY, P_WELL.EASTING, 
                    P_WELL.EASTING_CUOM, P_WELL.EASTING_OUOM, P_WELL.EFFECTIVE_DATE, P_WELL.ELEV, P_WELL.ELEV_CUOM, P_WELL.ELEV_OUOM,
                    P_WELL.EW_DIRECTION,
                    P_WELL.EXPIRY_DATE, P_WELL.GEOG_COORD_SYSTEM_ID, P_WELL.Latitude, P_WELL.Legal_Survey_type, P_WELL.LOCATION_QUALIFIER, 
                    P_WELL.LOCATION_QUALITY, P_WELL.Longitude, P_WELL.MAP_COORD_SYSTEM_ID, P_WELL.MD, P_WELL.MD_CUOM, P_WELL.MD_OUOM, 
                    P_WELL.MONUMENT_ID, P_WELL.MONUMENT_SF_TYPE, P_NODE_POSITION, P_WELL.NORTHING, P_WELL.NORTHING_CUOM,
                    P_WELL.NORTHING_OUOM, 
                    P_WELL.NORTH_TYPE, P_WELL.NS_DIRECTION,P_WELL.POLAR_AZIMUTH, P_WELL.POLAR_OFFSET, P_WELL.POLAR_OFFSET_CUOM, 
                    P_WELL.POLAR_OFFSET_OUOM,
                    P_WELL.PPDM_GUID, P_WELL.PREFERRED_IND, P_WELL.PROVINCE_STATE,  P_WELL.Remark, P_WELL.REPORTED_TVD, 
                    P_WELL.REPORTED_TVD_CUOM, P_WELL.REPORTED_TVD_OUOM, P_WELL.VERSION_TYPE, P_WELL.X_OFFSET, 
                    P_WELL.X_OFFSET_CUOM, P_WELL.X_OFFSET_OUOM, P_WELL.Y_OFFSET, 
                    P_WELL.Y_OFFSET_CUOM, P_WELL.Y_OFFSET_OUOM, P_WELL.IPL_XACTION_CODE, P_WELL.ROW_CHANGED_BY, P_WELL.ROW_CHANGED_DATE,
                    P_WELL.ROW_CREATEd_BY, P_WELL.ROW_CREATED_DATE,P_TLM_ID, P_WELL.ROW_QUALITY);
                     
                        
    EXCEPTION
    WHEN OTHERS
      THEN
        P_Error :=  SUBSTR(SQLERRM,1,1000);
        tlm_process_logger.error ( P_LOADER || ' FAILED in POPULATE_WELL_NODES_STG: Oracle Error - ' || SQLERRM);                                                        
      ROLLBACK;
           
END POPULATE_WELL_NODES_STG;  
/*----------------------------------------------------------------------------------------------------------
PROCEDURE: POPULATE_WELL_STATUS_STG
Detail:    This procedure POPULATES WIM_STG_STATUS TABLE
            
           This is called from POPULATE_STG_TABLES PROCEDURE
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
PROCEDURE POPULATE_WELL_STATUS_STG ( 
    P_WIM_STG_ID    NUMBER, 
    P_TLM_ID        VARCHAR2, 
    P_ACTION_CD     VARCHAR2, 
    P_LOADER        VARCHAR2, 
    P_SOURCE        VARCHAR2, 
    P_WELL          PID_WELL_STATUS_STG_VW%ROWTYPE,  
    P_Error IN OUT  VARCHAR2 
   )                              
                                
IS

 v_statusID VARCHAR2(10);
 v_WELL_STATUS_CD VARCHAR2(10); 
 v_statusNUM NUMBER;
 v_Status VARCHAR2(20);
 v_num NUMBER; 
 v_Action_Cd VARCHAR2(1);
 v_seq NUMBER;
 
BEGIN
        
       v_seq := 0;
       v_StatusID := NULL;
       
       --Seq for WIM_STG_WELL_STATUS table.
       Select count(1) into v_Seq
        from wim.wim_stg_Well_status
        where wim_stg_id = p_wim_stg_id;
        
        
         IF P_WELL.STATUS IS NOT NULL then           
         
           --v_WELL_STATUS_CD := P_WELL.WS_STATUS;
           v_WELL_STATUS_CD := getWellStatus(P_TLM_ID, P_WELL.STATUS);
           
            -- Use the same status_id as in 300 source. 
            -- For 100TLM there is no statusId and always one status in source.
            IF P_Source != '100TLM' THEN 
                v_StatusID := PrefixZeros(P_WELL.STATUS_ID);             
            END IF;
          
              
            --This will return Status_ID and ActionCd
            v_Action_Cd := CheckWellStatus (P_TLM_ID, P_SOURCE,v_WELL_STATUS_CD, v_StatusID);
           
                 
            if v_WELL_STATUS_CD is null then 
               v_WELL_STATUS_CD := P_WELL.STATUS;
            end if;
        
          INSERT INTO WIM.WIM_STG_WELL_STATUS(WIM_STG_ID, WIM_SEQ, WIM_ACTION_CD, UWI, SOURCE, ACTIVE_IND, status_id, EFFECTIVE_DATE,    
                                            EXPIRY_DATE, PPDM_GUID, REMARK,  STATUS,STATUS_DATE, STATUS_DEPTH, WIM_STATUS_DEPTH_CUOM, 
                                            STATUS_DEPTH_OUOM,IPL_XACTION_CODE,STATUS_TYPE, ROW_CHANGED_BY, ROW_CHANGED_DATE,
                                            ROW_CREATED_BY,ROW_CREATED_DATE, ROW_QUALITY)
            VALUES(P_WIM_STG_ID, v_Seq+1, v_Action_Cd, P_TLM_ID, P_SOURCE, P_WELL.ACTIVE_IND,  v_StatusID, P_WELL.EFFECTIVE_DATE,    
                    P_WELL.EXPIRY_DATE, P_WELL.PPDM_GUID, P_WELL.REMARK,  v_WELL_STATUS_CD,
                    P_WELL.STATUS_DATE, P_WELL.STATUS_DEPTH, P_WELL.STATUS_DEPTH_CUOM,P_WELL.STATUS_DEPTH_OUOM, 
                    P_WELL.IPL_XACTION_CODE,P_WELL.STATUS_TYPE, P_WELL.ROW_CHANGED_BY, P_WELL.ROW_CHANGED_DATE,
                    P_WELL.ROW_CREATED_BY,P_WELL.ROW_CREATED_DATE, P_WELL.ROW_QUALITY);
          end if;
         
      
   EXCEPTION
    WHEN OTHERS
      THEN
        P_Error :=  SUBSTR(SQLERRM,1,1000);
        tlm_process_logger.error ( P_LOADER || ' FAILED in POPULATE_WELL_STATUS_STG: Oracle Error - ' || SQLERRM);                                                        
      ROLLBACK;      
   
END POPULATE_WELL_STATUS_STG;

/*----------------------------------------------------------------------------------------------------------
PROCEDURE: POPULATE_WELL_LICENSE_STG
Detail:    This procedure POPULATES WIM_STG_LICENSE TABLE
            
           This is called from POPULATE_STG_TABLES PROCEDURE
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
PROCEDURE POPULATE_WELL_LICENSE_STG ( 
    P_WIM_STG_ID    NUMBER, 
    P_TLM_ID        VARCHAR2, 
    P_ACTION_CD     VARCHAR2, 
    P_LOADER        VARCHAR2, 
    P_SOURCE        VARCHAR2, 
    P_WELL          PID_WELLS_STG_VW%ROWTYPE,  
    P_Error IN OUT  VARCHAR2 
    )                              
IS

 v_Action_Cd VARCHAR2(1);
BEGIN
        
         IF P_WELL.WL_LICENSE_ID IS NOT NULL   THEN  
          --TLM_ID should go to Licesne_Id         
           v_Action_Cd := CheckwellLicense(P_TLM_ID, P_WELL.WL_LICENSE_ID, P_SOURCE );
             INSERT INTO WIM.WIM_STG_WELL_LICENSE( WIM_STG_ID, WIM_ACTION_CD,UWI, LICENSE_ID, ACTIVE_IND, AGENT, APPLICATION_ID, 
                    AUTHORIZED_STRAT_UNIT_ID, BIDDING_ROUND_NUM, CONTRACTOR, DIRECTION_TO_LOC, WIM_DIRECTION_TO_LOC_CUOM,DIRECTION_TO_LOC_OUOM, 
                    DISTANCE_REF_POINT, DISTANCE_TO_LOC, WIM_DISTANCE_TO_LOC_CUOM,DISTANCE_TO_LOC_OUOM, DRILL_RIG_NUM,
                    DRILL_SLOT_NO, DRILL_TOOL, EFFECTIVE_DATE, EXCEPTION_GRANTED, EXCEPTION_REQUESTED,                     
                    EXPIRED_IND, EXPIRY_DATE, FEES_PAID_IND, LICENSEE, LICENSEE_CONTACT_ID,                     
                    LICENSE_DATE, LICENSE_NUM, NO_OF_WELLS, OFFSHORE_COMPLETION_TYPE, 
                    PERMIT_REFERENCE_NUM, PERMIT_REISSUE_DATE, PERMIT_TYPE, PLATFORM_NAME, PPDM_GUID,
                    PROJECTED_DEPTH, WIM_PROJECTED_DEPTH_CUOM, PROJECTED_DEPTH_OUOM, PROJECTED_STRAT_UNIT_ID, PROJECTED_TVD,
                    WIM_PROJECTED_TVD_CUOM,PROJECTED_TVD_OUOM, PROPOSED_SPUD_DATE, PURPOSE, RATE_SCHEDULE_ID, REGULATION,                   
                    REGULATORY_AGENCY, REGULATORY_CONTACT_ID, REMARK, RIG_CODE, RIG_SUBSTR_HEIGHT, 
                    WIM_RIG_SUBSTR_HEIGHT_CUOM,RIG_SUBSTR_HEIGHT_OUOM, RIG_TYPE, SECTION_OF_REGULATION, STRAT_NAME_SET_ID,                     
                    SURVEYOR, TARGET_OBJECTIVE_FLUID, IPL_PROJECTED_STRAT_AGE, IPL_ALT_SOURCE, 
                    IPL_XACTION_CODE, ROW_CHANGED_BY,ROW_CHANGED_DATE, ROW_CREATED_BY, 
                    ROW_CREATED_DATE, IPL_WELL_OBJECTIVE, ROW_QUALITY)
            VALUES (P_WIM_STG_ID,V_ACTION_CD, P_TLM_ID, P_WELL.WL_LICENSE_ID, P_WELL.WL_ACTIVE_IND, P_WELL.WL_AGENT, P_WELL.WL_APPLICATION_ID, 
                    P_WELL.WL_AUTHORIZED_STRAT_UNIT_ID, P_WELL.WL_BIDDING_ROUND_NUM, P_WELL.WL_CONTRACTOR, P_WELL.WL_DIRECTION_TO_LOC, P_WELL.WL_DIRECTION_TO_LOC_CUOM, 
                    P_WELL.WL_DIRECTION_TO_LOC_OUOM,P_WELL.WL_DISTANCE_REF_POINT, P_WELL.WL_DISTANCE_TO_LOC, P_WELL.WL_DISTANCE_TO_LOC_CUOM,
                    P_WELL.WL_DISTANCE_TO_LOC_OUOM, P_WELL.WL_DRILL_RIG_NUM, 
                    P_WELL.WL_DRILL_SLOT_NO, P_WELL.WL_DRILL_TOOL,P_WELL.WL_EFFECTIVE_DATE, P_WELL.WL_EXCEPTION_GRANTED, P_WELL.WL_EXCEPTION_REQUESTED,                    
                    P_WELL.WL_EXPIRED_IND, P_WELL.WL_EXPIRY_DATE, P_WELL.WL_FEES_PAID_IND,P_WELL.WL_LICENSEE, P_WELL.WL_LICENSEE_CONTACT_ID,                     
                    P_WELL.WL_LICENSE_DATE, P_WELL.WL_LICENSE_NUM, P_WELL.WL_NO_OF_WELLS, P_WELL.WL_OFFSHORE_COMPLETION_TYPE, 
                    P_WELL.WL_PERMIT_REFERENCE_NUM, P_WELL.WL_PERMIT_REISSUE_DATE, P_WELL.WL_PERMIT_TYPE,P_WELL.WL_PLATFORM_NAME, P_WELL.WL_PPDM_GUID,                     
                    P_WELL.WL_PROJECTED_DEPTH,P_WELL.WL_PROJECTED_DEPTH_CUOM, P_WELL.WL_PROJECTED_DEPTH_OUOM, P_WELL.WL_PROJECTED_STRAT_UNIT_ID, P_WELL.WL_PROJECTED_TVD,
                    P_WELL.WL_PROJECTED_TVD_CUOM,P_WELL.WL_PROJECTED_TVD_OUOM, P_WELL.WL_PROPOSED_SPUD_DATE, P_WELL.WL_PURPOSE,P_WELL.WL_RATE_SCHEDULE_ID,
                    P_WELL.WL_REGULATION,                     
                    P_WELL.WL_REGULATORY_AGENCY, P_WELL.WL_REGULATORY_CONTACT_ID, P_WELL.WL_REMARK, P_WELL.WL_RIG_CODE, P_WELL.WL_RIG_SUBSTR_HEIGHT, 
                    P_WELL.WL_RIG_SUBSTR_HEIGHT_CUOM,P_WELL.WL_RIG_SUBSTR_HEIGHT_OUOM, P_WELL.WL_RIG_TYPE, P_WELL.WL_SECTION_OF_REGULATION, 
                    P_WELL.WL_STRAT_NAME_SET_ID,                     
                    P_WELL.WL_SURVEYOR, P_WELL.WL_TARGET_OBJECTIVE_FLUID, P_WELL.WL_IPL_PROJECTED_STRAT_AGE, P_WELL.WL_IPL_ALT_SOURCE, 
                    P_WELL.WL_IPL_XACTION_CODE, P_WELL.WL_ROW_CHANGED_BY,P_WELL.WL_ROW_CHANGED_DATE, P_WELL.WL_ROW_CREATED_BY, 
                    P_WELL.WL_ROW_CREATED_DATE, P_WELL.WL_IPL_WELL_OBJECTIVE, P_WELL.WL_ROW_QUALITY);
         END IF; 

   EXCEPTION
    WHEN OTHERS
      THEN
        P_Error :=  SUBSTR(SQLERRM,1,1000);
        tlm_process_logger.error ( P_LOADER || ' FAILED in POPULATE_WELL_LICENSE_STG: Oracle Error - ' || SQLERRM);                                                        
      ROLLBACK;
     
END POPULATE_WELL_LICENSE_STG;

/*----------------------------------------------------------------------------------------------------------
FUNCTION: LOADER_NAME
Detail:    This function return the name of the loader for a given source
            
           This is called from following procedures: 
            POPULATE_STG_TABLES
            REACTIVATE
            INACTIVATE
            
Created On: August. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/

FUNCTION LOADER_NAME(P_SOURCE VARCHAR2)
RETURN VARCHAR2

IS
   
BEGIN
        IF P_SOURCE = '100TLM' THEN
           RETURN 'WIM_LOADER_CWS';
        ELSIF P_SOURCE = '300IPL' THEN
           RETURN 'WIM_LOADER_IHS_CDN';
        ELSIF P_SOURCE = '500PRB' THEN
           RETURN 'WIM_LOADER_IHS_INT';
        ELSIF P_SOURCE = '450PID' THEN
           RETURN'WIM_LOADER_IHS_US';
        END IF; 
END;

/*----------------------------------------------------------------------------------------------------------
Procedure: POPULATE_STG_TABLES
Detail:    This procedure populates Staging tables ( WIM_STG_REQUEST, WIM_STG_WELL_VERSION, WIM_STG_WELL_M_B, WIM_STG_STATUS,
           WIM_STG_LICENSE )
           This is called from Load_Cws_WElls, Load_Pid_Wells, Load_Probe_WElls, Load_IPL_Wells and Reactivate procedure.
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
PROCEDURE POPULATE_STG_TABLES(
    P_TLM_ID        WELL_VERSION.UWI%TYPE, 
    P_UWI           WELL_VERSION.IPL_UWI_LOCAL%TYPE, 
    P_SOURCE        WELL_VERSION.SOURCE%TYPE,
    P_ACTION_CD     VARCHAR2, 
    P_REC           PID_WELLS_STG_VW%ROWTYPE, 
    P_NODE_TABLE    VARCHAR2, 
    P_STATUS_TABLE  VARCHAR2,
    P_ERRORMSG      OUT VARCHAR2
)
IS
    V_WIM_STG_ID    WIM.WIM_STG_REQUEST.WIM_STG_ID%TYPE;
    NODE_REC        PID_WELL_NODE_STG_VW%ROWTYPE;
    STATUS_REC      PID_WELL_STATUS_STG_VW%ROWTYPE;    
    V_QUERY_STR     VARCHAR2(2000);
    TYPE CUR_TYP    IS REF CURSOR;
    NODE_CUR        CUR_TYP;
    STATUS_CUR      CUR_TYP;
    V_LOADER        VARCHAR2(20);
BEGIN
    V_LOADER := LOADER_NAME(P_SOURCE);
    
    INSERT INTO WIM.wim_stg_request (STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
    VALUES ('R', V_LOADER, SYSDATE)
    RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
    
    Populate_Well_Version_Stg(V_WIM_STG_ID, P_TLM_ID, P_ACTION_CD, V_LOADER, P_SOURCE, P_REC, p_ErrorMsg);
    POPULATE_WELL_LICENSE_STG(V_WIM_STG_ID, P_TLM_ID, P_ACTION_CD, V_LOADER, P_SOURCE, P_REC, p_ErrorMsg);
    COMMIT;
       
    --for multiple nodes
    v_query_str := 'Select * from ' || P_NODE_TABLE || ' where uwi = :1' ;
    OPEN node_cur FOR v_query_str using P_UWI;
    LOOP
        FETCH node_cur into node_rec;
        exit when node_cur%NOTFOUND; 
        
        --P_REC.base_node_id and P_rec.Surface_Node_Id 
        If node_rec.node_position = 'B' then
            POPULATE_WELL_NODES_STG(V_WIM_STG_ID, P_TLM_ID,'B', P_ACTION_CD, V_LOADER, P_SOURCE,node_rec,p_ErrorMsg);
        end if;
        
        if p_rec.base_node_id = p_rec.surface_node_id then
            --If pointing to the same node, create surface node, same as base node, if it is already there then update
            POPULATE_WELL_NODES_STG(V_WIM_STG_ID, P_TLM_ID, 'S', P_ACTION_CD, V_LOADER, P_SOURCE,node_rec,p_ErrorMsg);               
        elsIf node_rec.node_position = 'S' then
            POPULATE_WELL_NODES_STG(V_WIM_STG_ID, P_TLM_ID, 'S', P_ACTION_CD, V_LOADER, P_SOURCE,node_rec,p_ErrorMsg);               
        end if;
    end loop;
    close node_cur;

    v_query_str := 'Select * from ' || P_STATUS_TABLE || ' where uwi = :1' ;
       
    -- for multiple statuses
    OPEN status_cur FOR v_query_str using P_UWI;
    LOOP
        FETCH status_cur into status_rec;
        exit when status_cur%NOTFOUND;                         
            POPULATE_WELL_STATUS_STG(V_WIM_STG_ID, P_TLM_ID, P_ACTION_CD, V_LOADER, P_SOURCE, status_rec,p_ErrorMsg);
    end loop;          
    close status_cur;
exception 
    when others then
        tlm_process_logger.error(V_LOADER || ' - FAILED, ptlm_id: ' || P_TLM_ID || ' log: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm);
END POPULATE_STG_TABLES;

/*----------------------------------------------------------------------------------------------------------
Procedure: CREATE_WARNIGNS
Detail:    Procedure creates following warnings:    
            1- When 100 source well matched with other wells from different sources, create a warning in WIM_AUDIT_LOG table.
            2- When there are multiple matches
            3- when there is no match
            and one Information message to show how the well is matched.

           This is called from FINDWELL.
           
Created On: July. 2012
History of Change:
------------------------------------------------------------------------------------------------------------*/

PROCEDURE CREATE_WARNINGS(
    P_SOURCE                WELL_VERSION.SOURCE%TYPE, 
    PTLM_ID                 WELL_VERSION.UWI%TYPE,
    V_ACTION_CD             WIM.WIM_STG_WELL_VERSION.WIM_ACTION_CD%TYPE,
    PMATCHEDBY              VARCHAR2,
    pcountry                WELL_VERSION.COUNTRY%TYPE,
    pwell_num               WELL_VERSION.WELL_NUM%TYPE,
    puwi                    WELL_VERSION.IPL_UWI_LOCAL%TYPE,
    pwell_name              WELL_VERSION.WELL_NAME%type,
    pspud_date              DATE,
    prig_release_date       DATE,
    pkb_elev                well_version.kb_elev%TYPE DEFAULT NULL,
    pdrill_td               well_version.drill_td%TYPE DEFAULT NULL,
    pbottom_hole_latitude   well_version.bottom_hole_latitude%TYPE,            
    pbottom_hole_longitude  well_version.bottom_hole_longitude%TYPE,        
    psurface_latitude       well_version.surface_latitude%TYPE,            
    psurface_longitude      well_version.surface_longitude%TYPE,            
    pplot_name              WELL_VERSION.PLOT_NAME%TYPE DEFAULT NULL,
    plicense_num            well_license.license_num%TYPE DEFAULT NULL
)
IS
    v_count         NUMBER;
    v_matched_wells VARCHAR2(200);
    v_audit_id      NUMBER;
    v_audit_type    VARCHAR2(10);
    v_message       wim_audit_log.text%TYPE;
    v_warning       wim_audit_log.text%TYPE;
BEGIN
    v_message := '
        find_wells (
            ptlm_id=>'
            || ptlm_id
            || '
            ,pcountry=> '''
            || NVL (pcountry, 'NULL')
            || '''
            ,pwell_num=> '''
            || NVL (pwell_num, 'NULL')
            || '''
            ,puwi=> '''
            || NVL (puwi, 'NULL')
            || '''
            ,pwell_name=> '''
            || NVL (pwell_name, 'NULL')
            || '''
            ,pspud_date=>'''
            || pspud_date
            || '''
            ,prig_release_date=> '''
            || prig_release_date
            || '''
            ,pkb_elev=>'
            || pkb_elev
            || '
            ,pdrill_td=>'
            || pdrill_td
            || '
            ,pbottom_hole_latitude=> '
            || pbottom_hole_latitude
            || '
            ,pbottom_hole_longitude=> '
            || pbottom_hole_longitude
            || '
            ,psurface_latitude=> '
            || psurface_latitude
            || '
            ,psurface_longitude=> '
            || psurface_longitude
            || '
            ,pplot_name=> '''
            || NVL (pplot_name, 'NULL')
            || '''
            ,plicense_num=> '''
            || NVL (plicense_num, 'NULL')
            || '''
            ,psource=> '''
            || NVL (p_source, 'NULL')
            || '''
        ) ';
        
        SELECT COUNT (DISTINCT tlm_id) into v_count           
        FROM wim.wim_find_well;

        IF v_count > 1 THEN 
            v_warning := v_message || ' - No unique match found. Possible multiple matches.';
            v_audit_type := 'W';
        ELSIF pmatchedby IS NOT NULL and p_source != '100TLM' THEN
            v_warning := 'TLM_ID:' || ptlm_id || ' found by ' || pmatchedby;
            v_audit_type := 'I';
        END IF;
            
        if length(v_warning) > 0 then
            wim.wim_audit.audit_event (
                paudit_id   => v_audit_id,
                paction     => 'S',
                paudit_type => v_audit_type,
                ptlm_id     => PTLM_ID,
                psource     => p_source,
                ptext       => v_warning,
                puser       => USER
            );
        end if;
eND;


/*----------------------------------------------------------------------------------------------------------
Function:   FINDWELL
Detail:    This Function call WIM_SEARCH's Find_WElls function to find a well. I           
           First it finds the well by Well_Num, If found then Action_Cd = 'U'
           
           If not match, if continues to find by ipl_uwi_local ( in other sources), If found in other source and it is a single match, then
           Action_Cd ='A'
           
           If still no match, then it tries to find with rest of parameters ( in other sources), IF found and it is a single match, then
           Action_Cd = 'A' Otherwise Action_Cd = 'C' (New)
          
           If source is 100TLM and action_Cd is 'C', no need to create a new TLM_ID, using the same ID as CorpWell.
           
           Called from Load_CWS_WElls, Load_PID_WELLS, LOAD_IPL_WELLS, LOAD_PROBE_WELLS procedures
           
Created On: Sept. 2011
History:  
        vRajpoot    July 2012       Modified to use new WIM_SEARCH.FIND_WELLS function.
------------------------------------------------------------------------------------------------------------*/

FUNCTION FINDWELL( 
    P_TLM_ID  IN OUT       well_version.uwi%type,  
    PSOURCE                well_Version.source%type, 
    PCOUNTRY               well_Version.country%type               DEFAULT NULL,
    PUWI                   well_Version.ipl_uwi_local%type         DEFAULT NULL, 
    PWELL_NAME             well_version.well_name%type             DEFAULT NULL, 
    PSPUD_DATE             well_version.spud_date%type             DEFAULT NULL,
    PRIG_RELEASe_DATE      well_version.rig_release_date%type      DEFAULT NULL, 
    PKB_ELEV               well_version.kb_elev%type               DEFAULT NULL, 
    PDRILL_TD              well_Version.drill_td%type              DEFAULT NULL, 
    PBOTTOM_HOLE_LATITUDE  well_Version.bottom_hole_latitude%type  DEFAULT NULL, 
    PBOTTOM_HOLE_LONGITUDE well_Version.bottom_hole_longitude%type DEFAULT NULL,
    PSURFACE_LATITUDE      well_Version.surface_latitude%type      DEFAULT NULL,  
    PSURFACE_LONGITUDE     well_Version.surface_longitude%type     DEFAULT NULL, 
    PWELL_NUM              well_version.well_num%type              DEFAULT NULL, 
    PPLOT_NAME             well_Version.plot_name%type             DEFAULT NULL, 
    PLICENSE_NUM           well_license.license_num%TYPE           DEFAULT NULL 
) RETURN VARCHAR2
IS
    V_ACTION_CD     VARCHAR2(1);
    V_TLM_ID        WELL_VERSION.UWI%TYPE := NULL;
    v_count         NUMBER;
    V_MATCHED_BY    VARCHAR2(20);
    v_matches       NUMBER;
BEGIN
    V_TLM_ID := P_TLM_ID; --save the original id (for CWS)
    P_TLM_ID := NULL;
    V_ACTION_CD := NULL;
  
    --First call- to search by unique id, WELL_NUM               
    IF PWELL_NUM IS NOT NULL THEN
        v_matches := WIM.WIM_SEARCH.FIND_WELLS ( 
            PTLM_ID         =>  P_TLM_ID,
            PWELL_NUM       =>  PWELL_NUM, 
            PSOURCE         =>  PSOURCE,
            PFINDBYALIAS_FG =>  'V'  -- Means use Well_Version table and no aLias search                                          
        );
        
        If v_matches = 1 THEN --means there is a match    
            V_ACTION_CD := 'U';
            P_TLM_ID := P_TLM_ID;
            V_MATCHED_BY := 'WELL_NUM';
            
            RETURN V_ACTION_CD;                    
        end if;
    END IF;       
             
    --search by unique id, UWI_LOCAL
    IF PUWI IS NOT NULL THEN                
        v_matches := WIM.WIM_SEARCH.FIND_WELLS ( 
            PTLM_ID        =>  P_TLM_ID,
            PCOUNTRY       =>  PCOUNTRY, 
            PUWI           =>  PUWI,
            PFINDBYALIAS_FG =>  'V'   -- Means use Well_Version table and no aLias search                                       
        );
    END IF;    
         
    If v_matches > 0 then
        -- Only get the matches that are in other sources and do not already exist in well_version with the same source.
        
        select count(distinct tlm_id) into v_count
        from wim.wim_find_well w
        where source != psource
            and tlm_id not in (select uwi from well_Version where source = psource and uwi = w.tlm_id AND active_ind = 'Y')
        ;
        
        -- IF there is a match then we Add a well
        -- If source is from CWS we need to create the well to preserve the Talisman ID
        -- then move the other sources to this well.
        IF v_count = 1 THEN  
            V_MATCHED_BY := 'UWI'; 
            V_ACTION_CD := 'A';
            
            SELECT DISTINCT TLM_ID into P_TLM_ID 
            FROM wim.wim_find_well w
            where source != psource
                and tlm_id not in (Select uwi from well_Version where source = psource and uwi = w.tlm_id AND active_ind = 'Y')
            ;
            
            RETURN V_ACTION_CD;
        end if;
    END IF;            
         
         
    P_TLM_ID := NULL;    
        
    v_matches := WIM.WIM_SEARCH.FIND_WELLS ( 
        PTLM_ID                 => P_TLM_ID,
        PCOUNTRY                => PCOUNTRY, 
        --PUWI                    => PUWI,
        PWELL_NAME              => PWELL_NAME,
        PSPUD_DATE              => PSPUD_DATE,
        PRIG_RELEASE_DATE       => PRIG_RELEASE_DATE,
        PKB_ELEV                => PKB_ELEV,
        PDRILL_TD               => PDRILL_TD,
        PBOTTOM_HOLE_LATITUDE   => PBOTTOM_HOLE_LATITUDE,
        PBOTTOM_HOLE_LONGITUDE  => PBOTTOM_HOLE_LONGITUDE,
        PSURFACE_LATITUDE       => PSURFACE_LATITUDE,
        PSURFACE_LONGITUDE      => PSURFACE_LONGITUDE,
        PPLOT_NAME              => PPLOT_NAME,
        PLICENSE_NUM            => PLICENSE_NUM,
        PFINDBYALIAS_FG         =>  'V', -- Means use Well_Version table and no aLias search
        PTOLERANCE              => 5,
        PELEVTOLERANCE          => 0       --default is 1                                        
    );                     
        
        -- Only get the matches that are in other sources and do not already exist in well_version with the same source.
        select count(distinct tlm_id) into v_count
        from wim.wim_find_well w
        where source != psource
            and tlm_id not in (Select uwi from well_Version where source = psource and uwi = w.tlm_id AND active_ind = 'Y')
        ;
        
        If v_count = 1 THEN 
            select distinct tlm_id  into p_tlm_id
            from wim.wim_find_well w
            where source != psource                     
                and tlm_id not in (Select uwi from well_Version where source = psource and uwi = w.tlm_id AND active_ind = 'Y')
            ;
            
            V_ACTION_CD := 'A';
            V_MATCHED_BY := 'ALL PARAMETERS';
        else
            V_ACTION_CD := 'C';
            P_TLM_ID := NULL;
        end if;

    --Create warnings in wim_audit_log table     
    CREATE_WARNINGS(
        PSOURCE, V_TLM_ID, V_ACTION_CD, V_MATCHED_BY, pcountry, pwell_num,
        puwi,pwell_name, pspud_date, prig_release_date, pkb_elev,
        pdrill_td, pbottom_hole_latitude, pbottom_hole_longitude,        
        psurface_latitude, psurface_longitude, pplot_name, plicense_num
    );
    RETURN V_ACTION_CD;
END;

/*----------------------------------------------------------------------------------------------------------
FUNCTION: STOPPROCESS
Detail:    This FUNCTION checks if loader should run or not.
            
           This is called from LOAD_CWS_WELLS, LOAD_PID_WELLS, LOAD_PROBE_WELLS, LOAD_IPL_WELLS AND WELLACTION
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
FUNCTION StopProcess(
     P_LOADER VARCHAR2
 ) 
    RETURN VARCHAR2
IS

v_keyvalue varchar2(1);
v_num NUMBER;
BEGIN

v_keyvalue := 'N';

    Select count(*) into v_num
      FROM config_settings
     WHERE process = P_LOADER
      and key_name = 'SHUT DOWN';
      
    IF v_num != 0 then
    SELECT key_value into v_keyvalue
      FROM config_settings
     WHERE process = P_LOADER
      and key_name = 'SHUT DOWN';
    end if;
    
    return v_keyvalue;

END;      

/*----------------------------------------------------------------------------------------------------------
FUNCTION: SOURCE_COUNT_ERROR
Detail:   This FUNCTION checks the loaders stage tables for a % drop in well count
          If the drop is greater than 5% the loader will terminate.
            
          This is called from LOAD_CWS_WELLS, LOAD_PID_WELLS, LOAD_PROBE_WELLS, LOAD_IPL_WELLS AND WELLACTION
            
Created On: Apr. 2015
History of Change:
------------------------------------------------------------------------------------------------------------*/
function source_count_error(p_loader varchar2) 
    return boolean
is
    v_keyvalue    varchar2(1);
    v_table       varchar2(50);
    v_source      ppdm.well_version.source%type;
    v_sql         varchar2(2000);
    v_filter      varchar2(2000) := null;
    v_stg_cnt     number;
    v_num         number;
    v_return      boolean;
    
    type v_loader_data is varray(2) of integer;
begin
    case p_loader
        when 'WIM_LOADER_CWS' then
            v_table := 'CWS_WELLS_STG_VW';
            v_source := '100TLM';
        when 'WIM_LOADER_IHS_CDN' then
            v_table := 'WELL_IPLSTG_MV';
            v_source := '300IPL';
        when 'WIM_LOADER_IHS_US' then
            v_table := 'WELL_PIDSTG_MV';
            v_source := '450PID';
        when 'WIM_LOADER_IHS_INT' then
            v_table := 'WELL_VERSIONPRBSTG_MV';
            v_source := '500PRB';
            v_filter := ' country not in (select country from ppdm_admin.r_country_ap)';
    end case;
    
    select key_value into v_stg_cnt
    from config_settings
    where process = p_loader
        and key_name = 'STG COUNT';
    
    if v_stg_cnt = 0 then
        v_return := false;
    else
        v_sql := '
            select count(*)
            from ' || v_table
        ;
        
        if v_filter is not null then
            v_sql := v_sql || ' where ' || v_filter;
        end if;
        
        execute immediate v_sql into v_num;
        
        v_sql := '
            select trunc(' || v_num || '/ count(*) * 100)
            from ppdm.well_version
            where source = :v_source
        ';
        
        if v_filter is not null then
            v_sql := v_sql || ' and ' || v_filter;
        end if;
         
        execute immediate v_sql into v_num using v_source;
        
        if v_num < v_stg_cnt then
            v_return := true;
        else
            v_return := false;
        end if;
    end if;
    
    return v_return;    
end;

function can_move_well(p_tlm_id varchar2) return boolean
is
begin
    return true;
end;

/*----------------------------------------------------------------------------------------------------------
procedure:     load_cws_wells
detail:        loads 100TLM source. calls findwells function to get the action_cd, populate stagings tables,
            calls wim_gateway.well_action to update ppdm well tables.
created on: nov. 2011
history of change:
    Updated Jan 22, 2015 - updated to load only '7CN' and '7US' from CWS
------------------------------------------------------------------------------------------------------------*/
procedure load_cws_wells
is
    cursor wells_2_merge(puwi varchar2)
    is
        select uwi as tlm_id, source
        from ppdm.well_version
        where ipl_uwi_local = puwi
    ;
    
    type merge_query_t is table of varchar2(4000) index by binary_integer;
    type return_t is table of varchar2(100) index by binary_integer;
    v_merge_query   merge_query_t;
    v_return        return_t;
    
    p_tlm_id        well_version.uwi%type;
    v_action_cd     varchar2(1);
    v_errormsg      varchar2(1000);
    v_rec           pid_wells_stg_vw%rowtype;
    v_tlm_id        well_version.uwi%type;
    v_str           varchar2(2000);
    v_cnt           number;
    v_matched_wells varchar2(2000);
    v_query_cnt     number := 0;
    v_status        number := null;
begin
    tlm_process_logger.info ('WIM_LOADER_CWS - STARTED');
    
    -- check if it is ok to start the loader
    if start_loader('WIM_LOADER_CWS') = 'N' then
        ppdm_admin.tlm_process_logger.warning('WIM_LOADER_CWS - ENDING. ALREADY RUNNING');
        return;
    end if;    
    
    if source_count_error('WIM_LOADER_CWS') then
        tlm_process_logger.error('WIM_LOADER_CWS TERMINATED - Error in source data, well counts below accepted range.');
        return;
    end if;
    
    if stopprocess('WIM_LOADER_CWS') = 'N' then  
        reactivate('100TLM');
    end if;
    
    -- the view returns wells with changes that are not in WIM 
    for rec in (select * from wim_loader.cws_wells_changes_vw)
    loop
        if stopprocess('WIM_LOADER_CWS') = 'Y' then
            commit;
            tlm_process_logger.warning('WIM_LOADER_CWS TERMINATED');
            return;
        end if;
        
        begin
            -- get well data (cws_wells_stg view contains well_version, node_mode_m_b, license data)
            select * into v_rec from cws_wells_stg_vw where uwi = rec.uwi;
            -- find well and get the action code
            -- for 100TLM source, it action code is 'c' or 'u', so no need to pass all the other attribute
            -- we pass the other attributes to find out if it matching with  other  source wells. if it does wim_search will
            -- create warning message in wim_audit_log table.
            p_tlm_id := v_rec.uwi;    
            v_action_cd := findwell(
                p_tlm_id               => p_tlm_id,
                psource                => '100TLM',
                pcountry               => v_rec.country,
                puwi                   => v_rec.ipl_uwi_local,
                pwell_name             => v_rec.well_name,
                pbottom_hole_latitude  => v_rec.bottom_hole_latitude,
                pbottom_hole_longitude => v_rec.bottom_hole_longitude,
                psurface_latitude      => v_rec.surface_latitude,
                psurface_longitude     => v_rec.surface_longitude,
                pwell_num              => v_rec.well_num
            );
            
            -- if adding to a well
            -- save matched wells for moving back to CWS WELL
            if v_action_cd = 'A' then
                -- change action to create so we preserve CWS Repsol ID
                v_action_cd := 'C';
                
                -- check for multiple tlm_ids;
                select count(distinct tlm_id) into v_cnt
                from wim.wim_find_well
                ;
                
                if v_cnt > 1 then 
                    -- warn multiple repsol wells identified for uwi
                    ppdm_admin.tlm_process_logger.warning('WIM_LOADER_CWS - AUTOMERGE - MULTIPLE TLM_ID''s FOUND FOR UWI ' || v_rec.ipl_uwi_local);
                else 
                    -- check for tlm_id allready having active 100TLM attached
                    select distinct(tlm_id) into v_tlm_id
                    from wim.wim_find_well
                    ;
                    
                    select count(1) into v_cnt
                    from ppdm.well_version
                    where uwi = v_tlm_id
                        and source = '100TLM'
                        and active_ind = 'Y'
                    ;
                    
                    if v_cnt = 1 then
                        -- warn wells to move have a 100TLM
                        ppdm_admin.tlm_process_logger.warning('WIM_LOADER_CWS - AUTOMERGE - WELLS TO MOVE ALREADY HAVE A 100TLM SOURCE FOR ' || v_rec.ipl_uwi_local);
                    else
                        for rec in wells_2_merge(v_rec.ipl_uwi_local)
                        loop
                            v_query_cnt := v_query_cnt + 1;
                            v_return(v_query_cnt) := v_rec.uwi;
                            v_merge_query(v_query_cnt) := 'begin wim.wim_well_action.well_move(''' || rec.tlm_id || ''', ''' || rec.source || ''', :1, ''' || user || ''', :2); end;';
                        end loop;
                    end if;
                end if;
            end if;
            
            populate_stg_tables(v_rec.uwi, v_rec.uwi, '100TLM', v_action_cd, v_rec, 'CWS_WELL_NODE_STG_VW', 'CWS_WELL_STATUS_STG_VW', v_errormsg);
            
            if v_errormsg is not null then
                tlm_process_logger.error('WIM_LOADER_CWS - FAILED. ' || v_errormsg); 
                return;
            end if;
        exception 
            when no_data_found then
                null;
        end;
    end loop;
    commit;                                 
    
    -- call wim_gateway.well_action to apply updates to well_* tables
    wellaction('R', 'WIM_LOADER_CWS', 'LOAD WELLS');
    tlm_process_logger.info('WIM_LOADER_CWS - WELL_ACTION_COMPLETED');
    
    if v_query_cnt > 0 then
        for i in 1 .. v_query_cnt
        loop
            execute immediate v_merge_query(i) using in out v_return(i), in out v_status;
            if v_status <> 0 then
                tlm_process_logger.info('WIM_LOADER_CWS AUTOMERGE - ' || regexp_replace(v_merge_query(i), q'[^.+?'([0-9]*)'.+?'(.{6})'.*]', 'Merged \1(\2) to TLM_ID ' || v_return(i)));
            else
                tlm_process_logger.info('WIM_LOADER_CWS AUTOMERGE - ' || regexp_replace(v_merge_query(i), q'[^.+?'([0-9]*)'.+?'(.{6})'.*]', 'Merged \1(\2) to TLM_ID ' || v_return(i)));
            end if;
        end loop;
    end if;
    
    -- Inactivation
    if stopprocess('WIM_LOADER_CWS') = 'N' then
        inactivate('100TLM');
    end if;
    
    -- Inactivate the wells that are in black list.
    blacklist_wells('100TLM');
        
    tlm_process_logger.info('WIM_LOADER_CWS - COMPLETED');
exception 
    when others then
        tlm_process_logger.error('WIM_LOADER_CWS - FAILED ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || sqlerrm);
end load_cws_wells;

/*----------------------------------------------------------------------------------------------------------
PROCEDURE: LOAD_PID_WELLS
Detail:    LOADS 450PID SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, populate stagings tables,
           Calls WIM_GATEWAY.well_action to update ppdm well tables.
           
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/        
PROCEDURE LOAD_PID_WELLS 
IS
  
  
 P_TLM_ID                       WELL_VERSION.UWI%TYPE;
 v_ACTION_CD                    VARCHAR2(1); 
 v_REC                          PID_WELLS_STG_VW%ROWTYPE;
 v_ErrorMsg                     VARCHAR2(1000);
 v_max_well_version_date        WELL_VERSION.ROW_CHANGED_DATE%TYPE;
 v_max_well_node_version_date   WELL_NODE_VERSION.ROW_CHANGED_DATE%TYPE;
 v_mviews_refreshed             Number;
 
 BEGIN

   tlm_process_logger.info ('WIM_LOADER_IHS_US - STARTED');
   
       --Check if it is ok to start the loader
    IF Start_Loader( 'WIM_LOADER_IHS_US') = 'N' THEN
        
        --Add message to tlm_process log
        tlm_process_logger.info ('WIM_LOADER_IHS_US - Ending. Already Running');
        RETURN;            
    
    END IF;   
    
    -- VR Commented out for testing only
    --Refresh MView first
    --****************
    Refresh_PID_MViews(v_mviews_refreshed);
    
    if v_mviews_refreshed = 0 then --means mViews didnt get refreshed, no need to continue
       tlm_process_logger.info ( 'WIM_LOADER_IHS_US Terminated: MViews Refresh Failed');
        RETURN;
   end if;
   
    if source_count_error('WIM_LOADER_IHS_US') then
        tlm_process_logger.info('WIM_LOADER_IHS_US TERMINATED - Error in source data, well counts below accepted range.');
        return;
    end if;
    
   --REactivation     
       IF StopProcess('WIM_LOADER_IHS_US') = 'N' then  
         REACTIVATE('450PID');
       end if;
      
     FOR PID_SOURCE in (select well_num from pid_wells_changes_vw)
    --FOR PID_SOURCE in ( select UWI AS WELL_NUM from well_pidstg_mv where active_ind = 'Y' and province_state = 'AZ') 
             
-- PID_WELLS_CHANGES_VW view checks if there are any ihs wells ' changed/created date is > wells in ppdm database
--And any wells where attributes dont match by comparing all of the attributes 
    --  FOR PID_SOURCE in ( select well_num from PID_WELLS_CHANGES_VW)     
         loop
           P_TLM_ID := NULL;
            if StopProcess('WIM_LOADER_IHS_US') = 'Y' then
                  COMMIT;
                  tlm_process_logger.info ( 'WIM_LOADER_IHS_US Terminated');
                 RETURN;
            end if;
       Begin     
         -- PID_WELL_STG view has well_Version, nodE_m_b and license information. Should only be one row .   
          
          SELECT * INTO V_REC
          FROM PID_WELLS_STG_VW WHERE WELL_NUM = PID_SOURCE.WELL_NUM;        
           
               
          V_ACTION_CD := FINDWELL (P_TLM_ID                => P_TLM_ID,
                                     PSOURCE                => '450PID',
                                     PCOUNTRY               => V_REC.COUNTRY,
                                     PUWI                   => V_REC.IPL_UWI_LOCAL,
                                     PWELL_NAME             => V_REC.WELL_NAME,
                                     PSPUD_DATE             => V_REC.SPUD_DATE,
                                     PKB_ELEV               => V_REC.KB_ELEV,
                                     PDRILL_TD              => V_REC.DRILL_TD,
                                     PBOTTOM_HOLE_LATITUDE  => V_REC.BOTTOM_HOLE_LATITUDE,
                                     PBOTTOM_HOLE_LONGITUDE => V_REC.BOTTOM_HOLE_LONGITUDE,
                                     PSURFACE_LATITUDE      => V_REC.SURFACE_LATITUDE,
                                     PSURFACE_LONGITUDE     => V_REC.SURFACE_LONGITUDE,
                                     PWELL_NUM              => V_REC.WELL_NUM,
                                     PPLOT_NAME             => V_REC.PLOT_NAME
                                    );
        
       
             POPULATE_STG_TABLES(P_TLM_ID, V_REC.uwi, '450PID',  V_ACTION_CD, V_REC, 'PID_WELL_NODE_STG_VW', 'PID_WELL_STATUS_STG_VW', V_ERRORMSG);
        
       
          if v_ErrorMsg is not null then
                tlm_process_logger.error ('WIM_LOADER_IHS_US - FAILED. ' || v_ErrorMsg); 
                RETURN;
          end if;
       Exception 
         when TOO_MANY_ROWS then
               tlm_process_logger.warning('WIM_LOADER_IHS_US - duplicate rows for Base_Node_ID: ' || V_REC.BASE_NODE_ID);
               --insert into VRAJPOOT.temp values (v_Rec.Base_node_id, sysdate);
               NULL;
         when NO_DATA_FOUND then
               NULL;
      end;
 
             
     END LOOP;
      
        COMMIT;
       
       --call WIM_GATEWAY.WELL_ACTION to apply updates to Well_* table 
       WellAction('R', 'WIM_LOADER_IHS_US', 'LOAD WELLS');
       
       
       IF StopProcess('WIM_LOADER_IHS_US') = 'N' then
         INACTIVATE('450PID');
       END IF; 
        
        
       --run to CHECK if there are any data differences between PPDM and IHS
       --PID_PPDM_COMPARE_REPORT;
        
        --Inactivate the wells that are in black list.
        BlackList_Wells('450PID');
        
        tlm_process_logger.info ('WIM_LOADER_IHS_US - COMPLETED');
 
       
    
         
    EXCEPTION 
          WHEN OTHERS THEN
           tlm_process_logger.error ('WIM_LOADER_IHS_US - FAILED '|| sqlerrm);
          
    END LOAD_PID_WELLS; 

/*----------------------------------------------------------------------------------------------------------
PROCEDURE: LOAD_PROBE_WELLS
Detail:    LOADS 500PRB SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, populate stagings tables,
           Calls WIM_GATEWAY.well_action to update ppdm well tables.
           
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/        
PROCEDURE LOAD_PROBE_WELLS
IS
  
 P_TLM_ID                       WELL_VERSION.UWI%TYPE; 
 v_ACTION_CD                    VARCHAR2(1); 
 v_REC                          PID_WELLS_STG_VW%ROWTYPE;
 v_ErrorMsg                     VARCHAR2(1000);  
 v_max_well_version_date        WELL_VERSION.ROW_CHANGED_DATE%TYPE;
 v_max_well_node_version_date   WELL_NODE_VERSION.ROW_CHANGED_DATE%TYPE;
 v_mviews_refreshed             NUMBER;
 
 BEGIN

   tlm_process_logger.info ('WIM_LOADER_IHS_INT - STARTED');
   
  IF Start_Loader( 'WIM_LOADER_IHS_INT') = 'N' THEN
        
        --Add message to tlm_process log
        tlm_process_logger.info ('WIM_LOADER_IHS_INT - Ending. Already Running');
        RETURN;            
    
    END IF;  
   
    --Refresh MView first
    Refresh_PROBE_MViews(v_mviews_refreshed);
    if v_mviews_refreshed = 0 then --means mViews didnt get refreshed, no need to continue
        tlm_process_logger.info ( 'WIM_LOADER_IHS_INT Terminated: MViews Refresh Failed');
        RETURN;
    end if;
    
    if source_count_error('WIM_LOADER_IHS_INT') then
        tlm_process_logger.info('WIM_LOADER_IHS_INT TERMINATED - Error in source data, well counts below accepted range.');
        return;
    end if;
                  
       if StopProcess('WIM_LOADER_IHS_INT') = 'N' then  
          REACTIVATE('500PRB');
        end if;
                      
   FOR PROBE_SOURCE in (SELECT * from PROBE_WELLS_CHANGES_VW) 
   --FOR PROBE_SOURCE in (select * from PROBE_WELLS_STG_VW where uwi  in ('1000347064','1000347211')) 
   loop          
          P_TLM_ID := NULL;
          IF STOPPROCESS('WIM_LOADER_IHS_INT') = 'Y' THEN
             COMMIT;
             TLM_PROCESS_LOGGER.INFO ( 'WIM_LOADER_IHS_INT Terminated');
             RETURN;
          END IF;
            
          -- PROBE_WELLS_STG view has well_Version, nodE_m_b and license information. Should only be one row .
          SELECT * INTO V_REC
          FROM PROBE_WELLS_STG_VW WHERE WELL_Num = PROBE_SOURCE.WELL_NUM;
        
          V_ACTION_CD := FINDWELL (  P_TLM_ID                => P_TLM_ID,
                                     PSOURCE                => '500PRB',
                                     PCOUNTRY               => V_REC.COUNTRY,
                                     PUWI                   => V_REC.IPL_UWI_LOCAL,
                                     PWELL_NAME             => V_REC.WELL_NAME,
                                     PSPUD_DATE             => V_REC.SPUD_DATE,                                     
                                     PDRILL_TD              => V_REC.DRILL_TD,
                                     PBOTTOM_HOLE_LATITUDE  => V_REC.BOTTOM_HOLE_LATITUDE,
                                     PBOTTOM_HOLE_LONGITUDE => V_REC.BOTTOM_HOLE_LONGITUDE,
                                     PSURFACE_LATITUDE      => V_REC.SURFACE_LATITUDE,
                                     PSURFACE_LONGITUDE     => V_REC.SURFACE_LONGITUDE,
                                     PWELL_NUM              => V_REC.WELL_NUM,
                                     PPLOT_NAME             => V_REC.PLOT_NAME
                                    );
          POPULATE_STG_TABLES(P_TLM_ID, V_REC.uwi,'500PRB', V_ACTION_CD, V_REC, 'PROBE_WELL_NODE_STG_VW', 'PROBE_WELL_STATUS_STG_VW', V_ERRORMSG);
     
          
          IF V_ERRORMSG IS NOT NULL THEN
             TLM_PROCESS_LOGGER.ERROR ('WIM_LOADER_IHS_INT - FAILED. ' || V_ERRORMSG); 
             RETURN;
          END IF;
             
       END LOOP;
    
        COMMIT;
       --call WIM_GATEWAY.WELL_ACTION to apply updates to well_* tables
        WellAction('R', 'WIM_LOADER_IHS_INT','LOAD WELLS');
        
  
         if StopProcess('WIM_LOADER_IHS_INT') = 'N' then
          INACTIVATE('500PRB');
        end if;
    
       --run to CHECK if there are any data differences between PPDM and IHS
--       PROBE_PPDM_COMPARE_REPORT;
       
       --Inactivate the wells that are in black list.
        BlackList_Wells('500PRB');
            
        tlm_process_logger.info ('WIM_LOADER_IHS_INT - COMPLETED');
    
   
         
    EXCEPTION 
          WHEN OTHERS THEN
           tlm_process_logger.error ('WIM_LOADER_IHS_INT - FAILED '|| sqlerrm);
          
    END LOAD_PROBE_WELLS; 
    
/*----------------------------------------------------------------------------------------------------------
PROCEDURE: LOAD_IPL_WELLS
Detail:    LOADS 300IPL SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, populate stagings tables,
           Calls WIM_GATEWAY.well_action to update ppdm well tables.
           
            
Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/        
PROCEDURE LOAD_IPL_WELLS
IS
   
 P_TLM_ID        WELL_VERSION.UWI%TYPE;
 v_ACTION_CD     VARCHAR2(1);
 v_REC           PID_WELLS_STG_VW%ROWTYPE;
 v_ErrorMsg      VARCHAR2(1000);
 v_mviews_refreshed number;
  
 BEGIN
    v_mviews_refreshed:=0;
    
    tlm_process_logger.info ('WIM_LOADER_IHS_CDN - STARTED');
    
      IF Start_Loader( 'WIM_LOADER_IHS_CDN') = 'N' THEN
        
        --Add message to tlm_process log
        tlm_process_logger.info ('WIM_LOADER_IHS_CDN - Ending. Already Running');
        RETURN;
    END IF;
    
      --Refresh MView first
    --****************
    Refresh_IPL_MViews(v_mviews_refreshed);
    

    if v_mviews_refreshed = 0 then --means mViews didnt get refreshed, no need to continue
     tlm_process_logger.info ( 'WIM_LOADER_IHS_CDN Terminated: MViews Refresh Failed');
      RETURN;
    end if;
    
    if source_count_error('WIM_LOADER_IHS_CDN') then
        tlm_process_logger.info('WIM_LOADER_IHS_CDN TERMINATED - Error in source data, well counts below accepted range.');
        return;
    end if;
    
    IF StopProcess('WIM_LOADER_IHS_CDN') = 'N' then           
       REACTIVATE('300IPL');
    END IF;
           
     FOR IPL_SOURCE in (SELECT * FROM IPL_WELLS_CHANGES_VW)
     LOOP
       
           IF STOPPROCESS('WIM_LOADER_IHS_CDN') = 'Y' THEN
              TLM_PROCESS_LOGGER.INFO ( 'WIM_LOADER_IHS_CDN Terminated');
              RETURN;
            END IF;  
            
          --IPL_WELLS_STG view has well_Version, nodE_m_b and license information. Should only be one row .
          BEGIN       
          SELECT * INTO V_REC
          FROM IPL_WELLS_STG_VW WHERE BASE_NODE_ID = IPL_SOURCE.BASE_NODE_ID;
        
            P_TLM_ID := NULL;
            --Base_Node_Id is the ihs unique id for Canadian Wells.
            --and Base_Node_Id will be used to populate well_num attribute.
            --will search by Well_Num first
             
               V_ACTION_CD := FINDWELL ( P_TLM_ID                => P_TLM_ID,
                                         PSOURCE                => '300IPL',
                                         PCOUNTRY               => V_REC.COUNTRY,
                                         PUWI                   => V_REC.IPL_UWI_LOCAL,
                                         PWELL_NAME             => V_REC.WELL_NAME,
                                         PRIG_RELEASE_DATE      => V_REC.RIG_RELEASE_DATE,
                                         PBOTTOM_HOLE_LATITUDE  => V_REC.BOTTOM_HOLE_LATITUDE,
                                         PBOTTOM_HOLE_LONGITUDE => V_REC.BOTTOM_HOLE_LONGITUDE,
                                         PSURFACE_LATITUDE      => V_REC.SURFACE_LATITUDE,
                                         PSURFACE_LONGITUDE     => V_REC.SURFACE_LONGITUDE,
                                         PWELL_NUM              => V_REC.WELL_NUM                                     
                                    );
              --ppdm_admin.tlm_process_logger.info('IHSCAN - ' || V_REC.UWI || '--' || V_ACTION_CD || '--' || P_TLM_ID || '--' || IPL_SOURCE.BASE_NODE_ID);
              
              POPULATE_STG_TABLES(P_TLM_ID, V_REC.UWI, '300IPL', V_ACTION_CD, V_REC, 'IPL_WELL_NODE_STG_VW', 'IPL_WELL_STATUS_STG_VW', V_ERRORMSG);
              
             if v_ErrorMsg is not null then
                tlm_process_logger.error ('WIM_LOADER_IHS_CDN - FAILED. ' || v_ErrorMsg); 
                RETURN;
            end if;
            
            --If there are duplicates in source (C_TALISMAN_IHSDATA), add a warning and continue. 
               Exception 
                    when TOO_MANY_ROWS then
                        tlm_process_logger.warning('WIM_LOADER_IHS_CDN - duplicate rows for Base_Node_ID: ' || V_REC.BASE_NODE_ID);
                        NULL;
                    when NO_DATA_FOUND then
                        NULL;
         end;
       END LOOP;
    
       COMMIT;
        
        --call WIM_GATEWAY.WELL_ACTION to apply updates to well_* tables
        WellAction('R', 'WIM_LOADER_IHS_CDN','LOAD WELLS');
      
  
        IF StopProcess('WIM_LOADER_IHS_CDN') = 'N' then          
          INACTIVATE('300IPL');
          null;
        END IF;  
        
        --Inactivate the wells that are in black list.
        BlackList_Wells('300IPL');
        
        tlm_process_logger.info ('WIM_LOADER_IHS_CDN - COMPLETED');
        
 
         
    EXCEPTION 
          WHEN OTHERS THEN
           tlm_process_logger.error ('WIM_LOADER_IHS_CDN - FAILED '|| sqlerrm);
          
END LOAD_IPL_WELLS;            


    
/*----------------------------------------------------------------------------------------------------------
PROCEDURE:  WellAction
Detail:    This procedure reads WIM_STG_REQUEST rows with status = 'R'and calls WIM_GATEWAY.WELL_ACTION
            to process. 
            This is called from LOAD_CWS_WELLS, LOAD_PID_WELLS, LOAD_PROBE_WELLS, LOAD_IPL_WELLS, INACTIVATE
            REACTIVATE, INACTIVATE_100_SOURCE, INACTIVATE_450_SOURCE, INACTIVATE_500_SOURCE AND
            INACTIVATE_300_SOURCE PROCEDURES.
Created On: Nov. 2011
History of Change:
 Aud 15, 2013     V.Rajpoot   Added new parameter P_MANUAL_RUN to control the logging.
------------------------------------------------------------------------------------------------------------*/
 PROCEDURE WellAction (
    P_STATUS_CD     VARCHAR2, 
    P_LOADER        VARCHAR2, 
    P_ACTION        VARCHAR2 DEFAULT NULL,
    P_MANUAL_RUN    VARCHAR2 DEFAULT 'N'
    )
 IS
    pwim_stg_id NUMBER(14);
        ptlm_id VARCHAR2(20);
         Status VARCHAR2(200);
       Audit_No NUMBER;
      req_count NUMBER := 1;
        v_total NUMBER;    
       
    BEGIN

       IF P_MANUAL_RUN ='Y' THEN
        tlm_process_logger.info ( P_LOADER || ' RE-STARTED'); 
       END IF;
       
        v_Total := 0;
--        SELECT COUNT(wim_stg_id) INTO req_count 
--          FROM wim.wim_stg_request 
--         WHERE STATUS_CD = P_STATUS_CD          
--           AND ROW_CREATED_BY = P_LOADER;
          
        
   --      For i IN 1..req_count LOOP
         For rec in ( Select wim_Stg_id from wim.wim_stg_Request where STATUS_CD = P_STATUS_CD AND ROW_CREATED_BY = P_LOADER) 
         LOOP
   
         If StopProcess(P_LOADER) = 'N' then
         
          --  Select Wim_Stg_id into pwim_stg_id 
            --  from wim.wim_stg_Request
           --  where STATUS_CD = P_STATUS_CD          
           --    AND ROW_CREATED_BY = P_LOADER 
            --   and rownum = 1;

              WIM.wim_gateway.well_action(rec.wim_stg_id, ptlm_id, Status, Audit_No);     
              v_total := v_total + 1;
          else
            tlm_process_logger.info ( P_LOADER || ' Terminated');  
            tlm_process_logger.info ( P_LOADER ||' ' || P_ACTION || ' - Total wells processed: ' || v_total);
          
            RETURN;
          end if;
             
         END LOOP; 
         
         if P_ACTION ='RE-ACTIVATE' then
            v_total := v_total/2; --1/2 the actual count, because there are 2 entries in staging, for reactivation and update
         end if;
         tlm_process_logger.info (P_LOADER || ' ' || P_ACTION || ' - Total wells processed: ' || v_total);
            
        IF P_MANUAL_RUN ='Y' THEN
            tlm_process_logger.info ( P_LOADER || ' COMPLETED'); 
        END IF;
END WellAction;   

   
   
/*--   --NOT USED right now
--   FUNCTION GET_COUNTRY_CODE(p_Country IN VARCHAR2) 
--   RETURN VARCHAR2
--     
--   IS
--    V_COUNTRY VARCHAR2(30);
--    BEGIN       
--       CASE P_COUNTRY            
--            WHEN 'CA' THEN V_COUNTRY  := '7CN';
--            WHEN 'CO' THEN V_COUNTRY  := '2CO';
--            WHEN 'CU' THEN V_COUNTRY  := '2CU';
--            WHEN 'DZ' THEN V_COUNTRY  := '1AL';
--            WHEN 'GA' THEN V_COUNTRY  := '1GA';
--            WHEN 'GB' THEN V_COUNTRY  := '5UK';
--            WHEN 'ID' THEN V_COUNTRY  := '3ID';
--            WHEN 'MY' THEN V_COUNTRY  := '3MA';
--            WHEN 'NA' THEN V_COUNTRY  := '1NA';
--            WHEN 'NL'  THEN V_COUNTRY  := '5NT';
--            WHEN 'PER' THEN V_COUNTRY := '2PE';
--            WHEN 'QA'  THEN V_COUNTRY  := '6QA';
--            WHEN 'SDN' THEN V_COUNTRY := '1SU';
--            WHEN 'TT' THEN V_COUNTRY  := '2TT';
--            WHEN 'TU' THEN V_COUNTRY  := '1TU';
--            WHEN 'US' THEN V_COUNTRY  := '7US';
--            WHEN 'VN' THEN V_COUNTRY  := '3VI';
--            WHEN 'AU' THEN V_COUNTRY  := '4AU';
--            WHEN 'KU' THEN V_COUNTRY  := '6IA';
--            WHEN 'IQ' THEN V_COUNTRY  := '6IA';
--          ELSE  RETURN NULL;
--           END CASE;
--   RETURN V_COUNTRY;
--   END;
*/   

/*----------------------------------------------------------------------------------------------------------
Function:   WellExists
Detail:    This function checks if given uwi, well_num or ipl_uwi_local exist in Source database.
           This is called from Reactivate procedure.
Created On: Sept. 2011
History:
------------------------------------------------------------------------------------------------------------*/

Function WellExists (
    P_SOURCE    well_version.source%type, 
    P_UWI       well_version.uwi%type, 
    P_WELL_NUM  well_version.well_num%TYPE, 
    P_UWI_LOCAL well_version.ipl_uwi_local%TYPE
   ) 
   RETURN NUMBER
IS

v_num NUMBER;
BEGIN

   IF P_SOURCE = '100TLM' THEN       
      SELECT COUNT(WELL_ID) INTO V_NUM
        FROM WELL_CURRENT_DATA@CWS.WORLD
       WHERE WELL_ID = P_UWI
          AND country_cd in ('US', 'CA')
          AND upper(well_status_cd) <> 'CANCEL';   
    END IF;
      
   IF P_SOURCE = '450PID' THEN      
      SELECT COUNT(UWI) INTO V_NUM
        FROM PID_WELLS_STG_VW
       WHERE WELL_NUM = P_WELL_NUM
         AND NVL(ACTIVE_IND,'z') != 'N';
   END IF;   
   
   IF P_SOURCE = '500PRB' THEN
      SELECT COUNT(UWI) INTO V_NUM
        FROM PROBE_WELLS_STG_VW
       WHERE WELL_NUM = P_WELL_NUM
         AND NVL(ACTIVE_IND,'z') != 'N'
         AND country not in (select country from ppdm_admin.r_country_ap);
   END IF;
   
   IF P_SOURCE = '300IPL' THEN
      SELECT COUNT(UWI) INTO V_NUM
        FROM IPL_WELLS_STG_VW
       WHERE WELL_NUM = P_WELL_NUM
         AND NVL(ACTIVE_IND,'z') != 'N';
   END IF;
    
   RETURN V_NUM;
    
END;

/*----------------------------------------------------------------------------------------------------------
Procedure: Reactivate
Detail:    This function checks if there any wells needs to be reactivated. If there are, then it reactivates the well
           first and then reloads it to bring any other changes.     

          This is called from Load_CWS_WEllS, Load_PID_Wells, Load_Probe_WEllS, Load_IPL_Wells.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
procedure Reactivate ( 
    P_SOURCE    VARCHAR2
   )
IS

    V_UWI           WELL_VERSION.UWI%TYPE;
    V_WELL_NUM      WELL_VERSION.WELL_NUM%TYPE;
    V_UWI_LOCAL     WELL_VERSION.IPL_UWI_LOCAL%TYPE;
    V_NUM           NUMBER;
    V_WIM_STG_ID    WIM.WIM_STG_REQUEST.WIM_STG_ID%TYPE;    
    V_REC           PID_WELLS_STG_VW%ROWTYPE;
    V_NODE_TABLE    VARCHAR2(30);  
    V_STATUS_TABLE  VARCHAR2(30);
    V_LOADER        VARCHAR2(20);
    V_ERRORMSG      VARCHAR2(1000); 
    
    
    CURSOR well_cur IS
     SELECT uwi, well_num, ipl_uwi_local from well_version 
     where source = P_SOURCE and ACTIVE_IND = 'N'
      and well_num not in ( select well_num from well_Version where source = P_SOURCE and ACTIVE_IND = 'Y');-- this is a check to ignore, If there is, dont need to reactivate it
                                                                                                         -- if there is another well with same well_num in same source.
    
 BEGIN

  
    V_LOADER := LOADER_NAME(P_SOURCE);
  --  tlm_process_logger.info (V_LOADER || ' RE-ACTIVATE WELL STARTED');
    
    Open Well_Cur;
    Loop 
        FETCH well_cur into v_uwi, v_well_num, v_uwi_local;
        
         Exit When well_cur%Notfound;
          
         --call a function to check if well exists in source database         
         v_num := wellExists(P_SOURCE, V_UWI, V_WELL_NUM, V_UWI_LOCAL);
         
         IF V_NUM > 0 then -- well is active in source but inactive in ppdm
                
            --Populate WIM_STG_Request and WIM_STG_WELL_VERSION tables to simply Reactivate the well. 
            --SELECT wim.WIM_STG_ID_SEQ.nextval INTO V_WIM_STG_ID   FROM DUAL;
                
            INSERT INTO wim.wim_stg_request ( STATUS_CD, ROW_CREATED_BY, ROW_CREATED_DATE)
            VALUES ( 'R', V_LOADER, SYSDATE)
            RETURNING WIM_STG_ID INTO V_WIM_STG_ID;
                
            INSERT INTO wim.wim_stg_well_version (WIM_STG_ID, WIM_ACTION_CD, ACTIVE_IND, UWI, SOURCE )
            VALUES(V_WIM_STG_ID,'R','Y',V_UWI, P_SOURCE);
     
            -- After Reactivation, Now re load that well, to get any changes could have been made.
            If P_SOURCE = '450PID' then              
               SELECT * INTO V_REC FROM PID_WELLS_STG_VW WHERE well_num = V_WELL_NUM;        
               V_NODE_TABLE := 'PID_WELL_NODE_STG_VW';
               V_STATUS_TABLE := 'PID_WELL_STATUS_STG_VW';
               POPULATE_STG_TABLES(V_UWI, V_REC.UWI, P_SOURCE,'U',V_REC,V_NODE_TABLE, V_STATUS_TABLE, V_ERRORMSG);
            end if;
            
            if P_SOURCE = '100TLM' then             
               SELECT * INTO V_REC FROM CWS_WELLS_STG_VW WHERE uwi = V_UWI;
               V_NODE_TABLE := 'CWS_WELL_NODE_STG_VW';
               V_STATUS_TABLE := 'CWS_WELL_STATUS_STG_VW'; 
               POPULATE_STG_TABLES(V_UWI, V_REC.UWI, P_SOURCE, 'U',V_REC,V_NODE_TABLE, V_STATUS_TABLE, V_ERRORMSG);              
            end if;
            
            if P_SOURCE = '300IPL' then               
               SELECT * INTO V_REC FROM IPL_WELLS_STG_VW WHERE WELL_NUM =  V_WELL_NUM;
               V_NODE_TABLE := 'IPL_WELL_NODE_STG_VW';
               V_STATUS_TABLE := 'IPL_WELL_STATUS_STG_VW';
               POPULATE_STG_TABLES(V_UWI, V_REC.UWI, P_SOURCE, 'U',V_REC,V_NODE_TABLE, V_STATUS_TABLE, V_ERRORMSG);
            end if;
            
            if P_SOURCE = '500PRB' then          
               SELECT * INTO V_REC FROM PROBE_WELLS_STG_VW WHERE well_num = V_WELL_NUM; 
               V_NODE_TABLE := 'PROBE_WELL_NODE_STG_VW';
               V_STATUS_TABLE := 'PROBE_WELL_STATUS_STG_VW';
               POPULATE_STG_TABLES(V_UWI, V_REC.UWI, P_SOURCE, 'U',V_REC,V_NODE_TABLE, V_STATUS_TABLE, V_ERRORMSG);
            end if;
       
         END IF;   
         IF v_ErrorMsg is not null then
           tlm_process_logger.error (V_LOADER || 'RE-ACTIVATE WELL - FAILED. ' || v_ErrorMsg); 
            RETURN;
         END if;
         
        END LOOP;
      COMMIT;
      
      --Wim Wim_Gateway to process the wells from Staging tables.
      WellAction ('R', V_LOADER,'RE-ACTIVATE');
               
    EXCEPTION
    WHEN OTHERS THEN
        tlm_process_logger.error (V_LOADER ||' RE-ACTIVATE WELL - FAILED ' || sqlerrm);


END Reactivate;


/*----------------------------------------------------------------------------------------------------------
Procedure: InActivate
Detail:   This procedure Inactivates wells in PPDM database.
          This is called from Load_CWS_WEllS, Load_PID_Wells, Load_Probe_Wells, Load_IPL_Wells.

Created On: Nov. 2011
History of Change:
------------------------------------------------------------------------------------------------------------*/
procedure Inactivate ( 
    P_SOURCE    VARCHAR2
   )
IS

 V_LOADER VARCHAR2(20);
 
-- This procedure checks if well from well_Version table exist in Source ( CWS, @IHS) table, if it doesnt,
-- InActivate it in PET* database ( by calling wim gateway)

    BEGIN
      
         V_LOADER := LOADER_NAME(P_SOURCE);
        -- tlm_process_logger.info (V_LOADER || ' INACTIVATION STARTED');  
                     
        if P_SOURCE = '100TLM' then         
          INACTIVATE_100_SOURCE;        
        elsif P_SOURCE = '450PID' then          
          INACTIVATE_450_SOURCE;
        elsif P_SOURCE = '500PRB' then          
          INACTIVATE_500_SOURCE;        
        elsif P_SOURCE = '300IPL' then          
          INACTIVATE_300_SOURCE;        
        end if;
         
    EXCEPTION
    WHEN OTHERS THEN
        tlm_process_logger.error (V_LOADER || ' INACTIVATION - FAILED ' || sqlerrm);
    
END;
END WIM_LOADER;