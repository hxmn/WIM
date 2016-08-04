create or replace PACKAGE       "WIM_GATEWAY" 
IS
   /*-----------------------------------------------------------------------------------------------------------------------------------
    SCRIPT: WIM.wim_gateway.pks

    PURPOSE:
      Package spec for the WIM_GATEWAY functionality
      All the packages in WIM will be part of WIM_GATEWAY, except WIM_SEARCH.

    DEPENDENCIES
      WIM_WELL_ACTION

    EXECUTION:
      See Package Specification

      Syntax:
       N/A

    HISTORY:
      1.0.0    08-Apr-10    R. Masterman  Initial version
      1.0.1    21-June-12   V. Rajpoot    Modified find_well_ext and Find_well_Extended and FInd_Well. Passed new parameter "pfindbyalias_fg"
      1.0.2    27-Aug-2012  V.Rajpoot     Modified WIM_WELL_ACTION package body.
                                          Added a check before Reactivation. Check if active well is already there with the same well_num/source.
                                          If there is, then do not reactivate.
      1.1.0    13-Aug-12    V. Rajpoot    Added a new function Version
                                          Removed calls  to WIM_SEARCH.FIND_WELL_EXTENDED, WIM_SEARCH.FIND_WELL_EXT

      1.2.0    07-Dec-12   V.Rajpoot    Modified WIM_WELL_ACTION.Well_Move procedure
                                         When transferring an alias, sometimes it will create a constraint error, because of duplications.
                                         Changed it: When transferring , it will now increment Well_Alias_Id

                                         changed precedence order for Node Rollup. Moved 100TLM after 500PRB. Task #1173
                                         Modifed Update_WV_Location procedure to filter out nodes with Null Lat/Longs

      1.3.0   18-Jan-13    V.Rajpoot    Added to call UPDATE_WIM.CREATE_WELL function to create or add a well.
                                         This is a simple interface to take care of populating staging table and updating wim.
      1.4.0   21-Mar-13    V.Rajpoot    Modified UPDATE_WIM.Create_WELl and Update_WEll. Added 3 new parameters
                                        KB_ELEV_OUOM, GROUND_ELEV, GROUND_ELEV_OUOM

      1.4.1   5-June-13    V.Rajpoot    Removed a call to Well_Action_Override procedure. This procedure created
                                        override version if there are any specials chars in a well_name

     1.4.2   29-July-13   V.Rajpoot    Added new attribute Location_Accuracy adn Rig_Name, updated wim_well_action and wim_rollup packages
     1.4.3   21-Feb-13    K.Edwards    Added operator and ipl_licensee attributes to CREATE_WELL and UPDATE_WELL functions
     1.4.3   21-fEB-13    K.Edwards    Added P_OPERATOR, P_IPL_LICENSEE, P_CONTRACTOR, and P_WL_LICENSEE attributes
     1.4.4   13-Mar-14    K.EDWARDS    Added basic logging to tlm_process_log
     1.4.5   17-Mar-14    K.EDWARDS    Added atributes P_WV_REGULATORY_AGENCY, P_WL_AGENT, P_WL_LICENSEE_CONTACT_ID, P_WL_REGULATORY_AGENCY, P_WL_REGULATORY_CONTACT_ID, P_WL_SURVEYOR
     1.4.6   09-Aug-14    K.Edwards    Added pragma autonomous_transaction; to Create and Update well functions for use with applications
                                       that call the functions (AP PDMS GEOWIZ)
     1.4.7   27-Apr-15    K.Edwards    Added DRILL_TD, and DTILL_TD_OUOM attributes (GEOWIZ)
   -----------------------------------------------------------------------------------------------------------------------------------*/
   /*****************************************************************************
     Version procedure
    *****************************************************************************
    This function returns version # of the pcakage

     Parameter Notes:
         None
   -----------------------------------------------------------------------------------------*/
   FUNCTION Version
      RETURN VARCHAR2;

   /*******************************************************************************************
     FIND_WELL FUNCTION
    *******************************************************************************************
    This function calls wim_search.Find_Well. It returns the TLM_ID of a well based on the provided parameters
                                  (WELL_NUM, TLM_ID, IPL_UWI_LOCAL, WELL_NAME,PLOT_NAME)

       Parameter notes:
         palias                   Find a well(s) based on alias. It could be Well_Name, TLM_ID, PLOT_NAME, IPL_UWI_LOCAL or COUNTRY
         pfind_type               Find_Type to determine what attribute to be used for search. e.g TLM_ID, IPL_UWI_LOCAL, WELL_NUM, WELL_NAME,PLOT_NAME
         psource                 find a well based on source
         pfindbyalias_fg         Flag to decide if we need to search by alias or not. Default value is 'Y'
   -------------------------------------------------------------------------------------------*/
   FUNCTION find_well (
      palias             PPDM.WELL_ALIAS.WELL_ALIAS%TYPE,
      pfind_type         VARCHAR2 DEFAULT 'TLM_ID',
      psource            PPDM.WELL_VERSION.SOURCE%TYPE DEFAULT NULL,
      pfindbyalias_fg    VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2;

   /*********************************************************************************************
   --  NEXT_WIM_STG_ID function
   -- *******************************************************************************************
   -- This Function gets nextval for wim_stg_id_seq to be used as next wim_stg_id for wim_stg_* tables.
   -------------------------------------------------------------------------------------------*/
   FUNCTION Next_WIM_STG_ID
      RETURN NUMBER;

   /*****************************************************************************
     WELL_ACTION procedure
    *****************************************************************************
       This procedure provides the ability to Create a new well, add a new
       version to an existing well, update the attributes of an existing well,
       deactivate the well version or permenantly delete it.
       The pAction parameter controls which of these actions is performed.
       The pStatus parameter returns an ID to retrieve validation messages from
       the WIM_AUDIT_LOG table.

       Parameter notes:
         pwim_stg_id        id in WIM_STG_REQUEST table
         the action to be carried out is defined in WIM_STG_WELL_VERSION.WIM_ACTION_CD:
                          C to Create a new well
                          A to Add a new version to an existing well
                          U to Update the attributes of an existing well version
                          I to INACTIVATE or soft delete a well
                          D to physically remove or hard delete a well
         paudit_id      return  0 or Audit Id number if there
                        are errors or warnings. The Audit Id can be used to retrieve
                        the errors/warnings from the WIM_AUDIT_LOG table to show the
                        user.
         ppriority_level_cd  is the level of validation required to process this request,
                          1  - only mandatory checks
                          2  - mandatory and "nice to have" checks,
                          3  - all applicable checks
                         we will finilize it later
   -----------------------------------------------------------------------------------------------------*/
   PROCEDURE well_action (
      pwim_stg_id                 NUMBER,
      ptlm_id              IN OUT VARCHAR2,
      pstatus_cd              OUT VARCHAR2,
      paudit_no               OUT NUMBER,
      ppriority_level_cd          validate_rule.priority_level_cd%TYPE DEFAULT 10);



   /******************************************************************************************************
     WELL_MOVE procedure
    ******************************************************************************************************
    This Procedure makes call to WIM_WELL_ACTION.WELL_MOVE to
    Move/Merge well

      Parameter notes:
       pfrom_tlm_id      TLM_ID moving
       pfrom_source       Source of the TLM_ID moving
       pto_tlm_id        TLM_ID moving To
       puser             user name
       pstatus           It is the audit_id for the move. if is an out parameter,
   -----------------------------------------------------------------------------------------------------*/
   PROCEDURE well_move (
      pfrom_tlm_id   IN     ppdm.well_version.uwi%TYPE,
      pfrom_source   IN     ppdm.well_version.SOURCE%TYPE,
      pto_tlm_id     IN OUT ppdm.well_version.uwi%TYPE,
      puser          IN     ppdm.well_version.row_created_by%TYPE DEFAULT USER,
      pstatus           OUT NUMBER);

   /******************************************************************************************************
     CREATE_WELL Function
    ******************************************************************************************************
    This Function makes call to UPDATE_WIM.CREATE_WELL to
    Create or add a well.
    This is a simple interface to take care of populating staging table and updating wim.
    It returns a number 0 = failed, 1 = completed

      Parameter notes:
       P_TLM_ID                T   LM_ID to use to create or add a well. Default value is null.
       P_SOURCE                    Source of the TLM_ID being created/added
       P_COUNTRY                   Country for the well being created/added. It is a required parameter
       P_PROVINCE_STATE            province_state for the well being created/added. default value is null
       P_WELL_NAME                 well_name for the well being created/added. default value is null, it is not required for TLM overide version.
       P_PLOT_NAME
       P_KB_ELEV                   kb_elev for the well being created/added. default value is null
       P_KB_ELEV_OUOM              kb_elev_ouom for the well being created/added. default value is null
       P_GROUND_ELEV               ground_elev for the well being created/added. default value is null
       P_GROUND_ELEV_OUOM          ground_elev_ouom for the well being created/added. default value is null
       P_REMARK                    remark for the well being created/added. default value is null
       P_WELL_NUM
       P_UWI                       ipl_uwi_local for the well being created/added. default value is null
       P_BOTTOM_HOLE_LATITUDE      bottom_hole_latitude for the well being created/added. default value is null
       P_BOTTOM_HOLE_LONGITUDE     bottom_hole_longitude for the well being created/added. default value is null
       P_SURFACE_LATITUDE          surface_latitude for the well being created/added. default value is null
       P_SURFACE_LONGITUDE         surface_longitude for the well being Craeted/added. default value is null
       P_STATUS                    current_status for the well being created/added. default value is null
       P_DRILL_TD                  DRILLERS TOTAL DEPTH: Total or maximum depth of the well as reported by the operator/ driller.    
       P_DRILL_TD_OUOM             DRILLERS TOTAL DEPTH OUOM: Driller total depth original unit of measure.    
       P_OPERATOR                  OPERATOR: The Business Associate representing the owners of the well, responsible for the operations of drilling and producing the well and for reporting these activities to the partners and regulatory agencies.
       P_IPL_LICENSEE              business associate licensee for the well being created/added. default value is null
       P_REGULATORY_AGENCY
       P_BH_LOCATION_QUALIFIER     Location Qualifier for Base Node being added. default value is null
       P_BH_GEOG_COORD_SYSTEM_ID   Geog_Coord_System_Id for Base Node begin added. default value is null
       P_SUR_LOCATION_QUALIFIER    Location Qualifier for Surface Node being added. default value is null
       P_SUR_GEOG_COORD_SYSTEM_ID  Geog_Coord_System_Id for Surface Node being added. default value is null
       P_WL_AGENT                  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_LICENSE_NUM            license_num for the well being created/added. default value is null
       P_WL_CONTRACTOR             BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium. 
       P_WL_LICENSEE               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WV_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_LICENSEE_CONTACT_ID    BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_CONTACT_ID  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_SURVEYOR               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
   -----------------------------------------------------------------------------------------------------*/

   FUNCTION Create_Well (
      P_TLM_ID                     IN OUT WELL_VERSION.UWI%TYPE,
      P_SOURCE                            WELL_VERSION.SOURCE%TYPE DEFAULT NULL,
      P_COUNTRY                           WELL_VERSION.COUNTRY%TYPE,
      P_PROVINCE_STATE                    WELL_VERSION.PROVINCE_STATE%TYPE DEFAULT NULL,
      P_WELL_NAME                         WELL_VERSION.WELL_NAME%TYPE DEFAULT NULL, --could be null for override version
      P_PLOT_NAME                         WELL_VERSION.PLOT_NAME%TYPE DEFAULT NULL,
      P_KB_ELEV                           WELL_VERSION.KB_ELEV%TYPE DEFAULT NULL,
      P_KB_ELEV_OUOM                      WELL_VERSION.KB_ELEV_OUOM%TYPE DEFAULT NULL,
      P_GROUND_ELEV                       WELL_VERSION.GROUND_ELEV%TYPE DEFAULT NULL,
      P_GROUND_ELEV_OUOM                  WELL_VERSION.GROUND_ELEV_OUOM%TYPE DEFAULT NULL,
      P_REMARK                            WELL_VERSION.REMARK%TYPE DEFAULT NULL,
      P_WELL_NUM                          WELL_VERSION.WELL_NUM%TYPE DEFAULT NULL,
      P_UWI                               WELL_VERSION.IPL_UWI_LOCAL%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LATITUDE              WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LONGITUDE             WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LATITUDE                  WELL_VERSION.SURFACE_LATITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LONGITUDE                 WELL_VERSION.SURFACE_LONGITUDE%TYPE DEFAULT NULL,
      P_STATUS                            WELL_VERSION.CURRENT_STATUS%TYPE DEFAULT NULL,
      P_DRILL_TD                          WELL_VERSION.DRILL_TD%TYPE DEFAULT NULL,
      P_DRILL_TD_OUOM                     WELL_VERSION.DRILL_TD_OUOM%TYPE DEFAULT NULL,
      P_OPERATOR                          WELL_VERSION.OPERATOR%TYPE DEFAULT NULL,
      P_IPL_LICENSEE                      WELL_VERSION.IPL_LICENSEE%TYPE DEFAULT NULL,
      P_REGULATORY_AGENCY                 WELL_VERSION.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_BH_LOCATION_QUALIFIER             WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_BH_GEOG_COORD_SYSTEM_ID           WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_SUR_LOCATION_QUALIFIER            WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_SUR_GEOG_COORD_SYSTEM_ID          WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_WL_AGENT                          WELL_LICENSE.AGENT%TYPE DEFAULT NULL,
      P_WL_LICENSE_NUM                    WELL_LICENSE.LICENSE_NUM%TYPE DEFAULT NULL,
      P_WL_CONTRACTOR                     WELL_LICENSE.CONTRACTOR%TYPE DEFAULT NULL,
      P_WL_LICENSEE                       WELL_LICENSE.LICENSEE%TYPE DEFAULT NULL,
      P_WL_LICENSEE_CONTACT_ID            WELL_LICENSE.LICENSEE_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_REGULATORY_AGENCY              WELL_LICENSE.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_WL_REGULATORY_CONTACT_ID          WELL_LICENSE.REGULATORY_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_SURVEYOR                       WELL_LICENSE.SURVEYOR%TYPE DEFAULT NULL)          
      RETURN NUMBER;

   /******************************************************************************************************
     UPDATE_WELL Function
    ******************************************************************************************************
    This Function makes call to UPDATE_WIM.UPDATE_WELL to
    Update existing well.
    This is a simple interface to take care of populating staging table and updating wim.
    It returns a number 0 = failed, 1 = completed

      Parameter notes:
       P_TLM_ID                T   LM_ID to use to create or add a well. Default value is null.
       P_SOURCE                    Source of the TLM_ID being created/added
       P_COUNTRY                   Country for the well being created/added. It is a required parameter
       P_PROVINCE_STATE            province_state for the well being created/added. default value is null
       P_WELL_NAME                 well_name for the well being created/added. default value is null, it is not required for TLM overide version.
       P_PLOT_NAME
       P_KB_ELEV                   kb_elev for the well being created/added. default value is null
       P_KB_ELEV_OUOM              kb_elev_ouom for the well being created/added. default value is null
       P_GROUND_ELEV               ground_elev for the well being created/added. default value is null
       P_GROUND_ELEV_OUOM          ground_elev_ouom for the well being created/added. default value is null
       P_REMARK                    remark for the well being created/added. default value is null
       P_WELL_NUM
       P_UWI                       ipl_uwi_local for the well being created/added. default value is null
       P_BOTTOM_HOLE_LATITUDE      bottom_hole_latitude for the well being created/added. default value is null
       P_BOTTOM_HOLE_LONGITUDE     bottom_hole_longitude for the well being created/added. default value is null
       P_SURFACE_LONGITUDE         surface_longitude for the well being created/added. default value is null
       P_SUR_LOCATION_QUALIFIER    Location Qualifier for Surface Node for well being craeted/added. default value is null
       P_STATUS                    current_status for the well being created/added. default value is null
       P_DRILL_TD                  DRILLERS TOTAL DEPTH: Total or maximum depth of the well as reported by the operator/ driller.    
       P_DRILL_TD_OUOM             DRILLERS TOTAL DEPTH OUOM: Driller total depth original unit of measure.    
       P_OPERATOR                  OPERATOR: The Business Associate representing the owners of the well, responsible for the operations of drilling and producing the well and for reporting these activities to the partners and regulatory agencies.
       P_IPL_LICENSEE              business associate licensee for the well being created/added. default value is null
       P_REGULATORY_AGENCY
       P_BH_LOCATION_QUALIFIER     Location Qualifier for Base Node being updated/added. default value is null
       P_BH_GEOG_COORD_SYSTEM_ID   Geog_Coord_System_Id for Base Node being updated/added. default value is null
       P_BH_NODE_OBS_NO            Node_Obs_No for Base Node being updated/added. default value is null
       P_SURFACE_LATITUDE          surface_latitude for the well being created/added. default value is null
       P_SUR_GEOG_COORD_SYSTEM_ID  Geog_Coord_System_Id for Surface Node for well being craeted/added. default value is null
       P_SUR_NODE_OBS_NO           Node_Obs_No for Surface Node being updated/added. default value is null
       P_WL_LICENSE_NUM            license_num for the well being created/added. default value is null
       P_WL_LICENSEE               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_CONTRACTOR             BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium. 
       P_WL_LICENSEE               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WV_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_AGENT                  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_LICENSEE_CONTACT_ID    BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_CONTACT_ID  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_SURVEYOR               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium. 
   -----------------------------------------------------------------------------------------------------*/
   FUNCTION UPDATE_WELL (
      P_TLM_ID                      WELL_VERSION.UWI%TYPE,
      P_SOURCE                      WELL_VERSION.SOURCE%TYPE DEFAULT NULL,
      P_COUNTRY                     WELL_VERSION.COUNTRY%TYPE,
      P_PROVINCE_STATE              WELL_VERSION.PROVINCE_STATE%TYPE DEFAULT NULL,
      P_WELL_NAME                   WELL_VERSION.WELL_NAME%TYPE DEFAULT NULL, --could be null for override version
      P_PLOT_NAME                   WELL_VERSION.PLOT_NAME%TYPE DEFAULT NULL,
      P_KB_ELEV                     WELL_VERSION.KB_ELEV%TYPE DEFAULT NULL,
      P_KB_ELEV_OUOM                WELL_VERSION.KB_ELEV_OUOM%TYPE DEFAULT NULL,
      P_GROUND_ELEV                 WELL_VERSION.GROUND_ELEV%TYPE DEFAULT NULL,
      P_GROUND_ELEV_OUOM            WELL_VERSION.GROUND_ELEV_OUOM%TYPE DEFAULT NULL,
      P_REMARK                      WELL_VERSION.REMARK%TYPE DEFAULT NULL,
      P_WELL_NUM                    WELL_VERSION.WELL_NUM%TYPE DEFAULT NULL,
      P_UWI                         WELL_VERSION.IPL_UWI_LOCAL%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LATITUDE        WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE DEFAULT NULL,
      P_BOTTOM_HOLE_LONGITUDE       WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LATITUDE            WELL_VERSION.SURFACE_LATITUDE%TYPE DEFAULT NULL,
      P_SURFACE_LONGITUDE           WELL_VERSION.SURFACE_LONGITUDE%TYPE DEFAULT NULL,
      P_STATUS                      WELL_VERSION.CURRENT_STATUS%TYPE DEFAULT NULL,
      P_DRILL_TD                    WELL_VERSION.DRILL_TD%TYPE DEFAULT NULL,
      P_DRILL_TD_OUOM               WELL_VERSION.DRILL_TD_OUOM%TYPE DEFAULT NULL,
      P_OPERATOR                    WELL_VERSION.OPERATOR%TYPE DEFAULT NULL,
      P_IPL_LICENSEE                WELL_VERSION.IPL_LICENSEE%TYPE DEFAULT NULL,
      P_REGULATORY_AGENCY           WELL_VERSION.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_BH_LOCATION_QUALIFIER       WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_BH_GEOG_COORD_SYSTEM_ID     WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_BH_NODE_OBS_NO              WELL_NODE_VERSION.NODE_OBS_NO%TYPE DEFAULT NULL,
      P_SUR_LOCATION_QUALIFIER      WELL_NODE_VERSION.LOCATION_QUALIFIER%TYPE DEFAULT NULL,
      P_SUR_GEOG_COORD_SYSTEM_ID    WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE DEFAULT NULL,
      P_SUR_NODE_OBS_NO             WELL_NODE_VERSION.NODE_OBS_NO%TYPE DEFAULT NULL,
      P_WL_AGENT                    WELL_LICENSE.AGENT%TYPE DEFAULT NULL,
      P_WL_LICENSE_NUM              WELL_LICENSE.LICENSE_NUM%TYPE DEFAULT NULL,
      P_WL_CONTRACTOR               WELL_LICENSE.CONTRACTOR%TYPE DEFAULT NULL,
      P_WL_LICENSEE                 WELL_LICENSE.LICENSEE%TYPE DEFAULT NULL,
      P_WL_LICENSEE_CONTACT_ID      WELL_LICENSE.LICENSEE_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_REGULATORY_AGENCY        WELL_LICENSE.REGULATORY_AGENCY%TYPE DEFAULT NULL,
      P_WL_REGULATORY_CONTACT_ID    WELL_LICENSE.REGULATORY_CONTACT_ID%TYPE DEFAULT NULL,
      P_WL_SURVEYOR                 WELL_LICENSE.SURVEYOR%TYPE DEFAULT NULL)          
      RETURN NUMBER;
END wim_gateway;