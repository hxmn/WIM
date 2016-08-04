DROP PACKAGE WIM_LOADER;

CREATE OR REPLACE PACKAGE            WIM_LOADER
AS 

/*----------------------------------------------------------------------------------------------------------
 SCRIPT: WIM_LOADER.wim_loader.pks

 PURPOSE:
   Package body for the WIM WIM_LOADER functionality, to load CWS(100TLM), 300IPL, 500PRB, 450PID source wells to PPDM
   using WIM GATEWAY

    Procedure/Function Details:
    LOAD_PID_WELLS          This procedure Loads 450PID SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, 
                            populate stagings tables, Calls WIM_GATEWAY.well_action to update ppdm well tables.
    
    LOAD_PROBE_WELLS        This procedure Loads 500PRB SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, 
                            populate stagings tables, Calls WIM_GATEWAY.well_action to update ppdm well tables.
    
    
    WELL_ACTION             This procedure reads WIM_STG_REQUEST rows with status = 'R'and calls WIM_GATEWAY.WELL_ACTION
                            to process.  This is called from LOAD_CWS_WELLS, LOAD_PID_WELLS, LOAD_PROBE_WELLS, LOAD_IPL_WELLS, INACTIVATE
                            REACTIVATE, INACTIVATE_100_SOURCE, INACTIVATE_450_SOURCE, INACTIVATE_500_SOURCE AND
                            INACTIVATE_300_SOURCE PROCEDURES
                            
    REACTIVATE              This function checks if there any wells needs to be reactivated. If there are, then it reactivates the well
                            first and then reloads it to bring any other changes.                          
                            
    INACTIVATE              This procedure Inactivates wells in PPDM database.
                            This is called from Load_CWS_WEllS, Load_PID_Wells, Load_Probe_Wells, Load_IPL_Wells.                 
                            
 DEPENDENCIES   
   WIM_SEARCH
   WIM_GATEWAY

   Syntax:
    N/A

 HISTORY:
   for change log, see Package Body
----------------------------------------------------------------------------------------------------------------------*/

   
/*****************************************************************************
  LOAD_PID_WELLS Procedure
 *****************************************************************************
    This procedure Loads 450PID SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, 
    populate stagings tables,
    Calls WIM_GATEWAY.well_action to update ppdm well tables.
    

    Parameter notes:
      NONE
*/    
   PROCEDURE LOAD_PID_WELLS;

/*****************************************************************************
  LOAD_PROBE_WELLS Procedure
 *****************************************************************************
    This procedure Loads 500PRB SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, 
    populate stagings tables,
    Calls WIM_GATEWAY.well_action to update ppdm well tables.
    
    Parameter notes:
      NONE
*/
   PROCEDURE LOAD_PROBE_WELLS;

/*****************************************************************************
  LOAD_CWS_WELLS Procedure
 *****************************************************************************
    This procedure Loads 100TLM SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, 
    populate stagings tables,
    Calls WIM_GATEWAY.well_action to update ppdm well tables.
    

    Parameter notes:
      NONE
*/
   PROCEDURE LOAD_CWS_WELLS;

/*****************************************************************************
  LOAD_IPL_WELLS Procedure
 *****************************************************************************
    This procedure Loads 300IPL SOURCE. CALLS FINDWELLS FUNCTION TO get the action_cd, 
    populate stagings tables,
    Calls WIM_GATEWAY.well_action to update ppdm well tables.
    

    Parameter notes:
      NONE
*/
   PROCEDURE LOAD_IPL_WELLS;    

/*****************************************************************************
  WELL_ACTION Procedure
 *****************************************************************************
    This procedure reads WIM_STG_REQUEST rows with status = 'R'and calls WIM_GATEWAY.WELL_ACTION
    to process. 
    This is called from LOAD_CWS_WELLS, LOAD_PID_WELLS, LOAD_PROBE_WELLS, LOAD_IPL_WELLS, INACTIVATE
    REACTIVATE, INACTIVATE_100_SOURCE, INACTIVATE_450_SOURCE, INACTIVATE_500_SOURCE AND
    INACTIVATE_300_SOURCE PROCEDURES

    Parameter notes:
      P_STATUS_CD       Status_Cd, it is 'R' for Ready
      P_LOADER          name of the loader ( e.g. CWSLOADER, PIDLOADER)
      P_ACTION           Default is Null, if calling from Inactivation, then it is INACTIVATION. It is used for creating a message in 
                        tlm_process_log table.     
*/
   PROCEDURE WELLACTION ( P_STATUS_CD VARCHAR2, P_LOADER VARCHAR2, P_ACTION VARCHAR2 DEFAULT NULL, P_MANUAL_RUN    VARCHAR2 DEFAULT 'N');

/*****************************************************************************
  REACTIVATE Procedure
 *****************************************************************************
   This function checks if there any wells needs to be reactivated. If there are, then it reactivates the well
   first and then reloads it to bring any other changes.     

   This is called from Load_CWS_WEllS, Load_PID_Wells, Load_Probe_WEllS, Load_IPL_Wells.

    Parameter notes:
      P_SOURCE          Name of the source, Re-activating wells for this passed source.
*/
   PROCEDURE REACTIVATE ( P_SOURCE VARCHAR2);           
    
/*****************************************************************************
  INACTIVATE Procedure
 *****************************************************************************
    This procedure Inactivates wells in PPDM database.
     This is called from Load_CWS_WEllS, Load_PID_Wells, Load_Probe_Wells, Load_IPL_Wells.

    Parameter notes:
      P_SOURCE          Name of the source, Inactivating wells for this passed source.
*/   
   PROCEDURE INACTIVATE ( P_SOURCE VARCHAR2);
    
  /*****************************************************************************
  FINDWELL Procedure
 *****************************************************************************
   This Function call WIM_SEARCH's Find_WElls function to find a well. I           
   First it finds the well by Well_Num, If found a match then Action_Cd = 'U'
   If no match found, if continues to find by ipl_uwi_local ( in other sources), If matched in other source and it is a single match, then
           Action_Cd ='A'
   If still no match, then it tries to find with rest of parameters ( in other sources), IF found and it is a single match, then
           Action_Cd = 'A' Otherwise Action_Cd = 'C' (New)
        
   If source is 100TLM and action_Cd is 'C', no need to create a new TLM_ID, using the same ID as CorpWell.
           
    This procedure never gets called on its own, Left it here testing/troubshooting purposes,
    
    Parameter notes:
    P_TLM_ID                UWI ( out parameter, only if there is a single match)
    PSOURCE                 search will be done based  on given source or all. Default value is null.       
    PCOUNTRY                search will be done based on given country or all. Default value is null.
    PUWI                    search will be done based on given ipl_uwi_local or all. Default value is null.
    PWELL_NAME              search will be done based on given well_name or all. Default value is null.
    PSPUD_DATE              search will be done based on given spud_date or all. Default value is null.
    PRIG_rELEASE_DATE       search will be done based on given rig_release_date or all. Default value is null.
    PKB_ELEV                search will be done based on given kb_elev or all. Default value is null.        
    PDRILL_TD               search will be done based on given drill_Td or all. Default value is null.
    PBOTTOM_HOLE_LATITUDE   search will be done based on given bottom_hole_latitude or all. Default value is null.
    PBOTTOM_HOLE_LONGITUDE  search will be done based on given bottom_hole_longitude or all. Default value is null.   
    PSURFACE_LATITUDE       search will be done based on given surface_latitude or all.Default value is null.  
    PSURFACE_LONGITUDE      search will be done based on given surface_longitude or all .Default value is null. 
    PWELL_NUM               search will be done based on given well_num or all. Default value is null.
    PPLOT_NAME              search will be done based on given plot_name or all.Default value is null. 
    PLICENSE_NUM            search will be done based on given license_num ( using well_license table), 
                            if no licencse_num is provided then it doesn't search in well_license table. Default value is null.  
*/   
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
    )
    RETURN VARCHAR2;
    
  /*****************************************************************************
  BlackList_Wells Procedure
 *****************************************************************************
   This Procedure inactivatse wells in Black_List_Wells table.
    
    Parameter notes:
     PSOURCE                 Inactivate the wells for passed source. Default value is null.     
                              
*/ 
    PROCEDURE BlackList_Wells (
        P_SOURCE            WELL_VERSION.SOURCE%TYPE DEFAULT NULL);
             
    END WIM_LOADER;

/

GRANT EXECUTE ON WIM_LOADER TO WIM;
