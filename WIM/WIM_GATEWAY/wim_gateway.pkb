create or replace PACKAGE BODY       "WIM_GATEWAY" 
IS
   /*-----------------------------------------------------------------------------------------------------------------------------------
    SCRIPT: WIM.wim_gateway.pkb

    PURPOSE:
      Package body for the WIM  GATEWAY functionality
      All the packages in WIM will be part of WIM_GATEWAY, except WIM_SEARCH.


    DEPENDENCIES
      WIM_WELL_ACTION

    EXECUTION:
      See Package Specification

      Syntax:
       N/A

    HISTORY:
      VER:
      1.0.0    08-Apr-10     R. Masterman   Initial version
      1.0.1    21-June-12    V. Rajpoot     Modified find_well_ext and Find_well_Extended and Find_Well. Passed new parameter "pfindbyalias_fg"
      1.0.2    27-Aug-2012  V.Rajpoot       Modified WIM_WELL_ACTION package body.
                                            Added a check before Reactivation. Check if active well is already there with the same well_num/source.
                                            If there is, then do not reactivate.
      1.0.3  14-Sept-2012   V.Rajpoot   Changed WIM_WELL_ACTION.WELL_ACTION_UPDATE procedure ( Changed the logic where it decides to add an alias.)
                                        (If Alias(e.g Well_Name) is Null before, then no alias will added because well_alias can not be Null.
                                        If well_name is not null and changed to some other value, alias will be added
                                        If well_name is not null and changed to null then alias will be added.)

      1.1.0    13-Aug-12     V. Rajpoot     Added Function Version
                                            Removed calls  to WIM_SEARCH.FIND_WELL_EXTENDED, WIM_SEARCH.FIND_WELL_EXT

      1.2.0    07-Dec-12     V.Rajpoot    Modified WIM_WELL_ACTION.Well_Move procedure
                                          When transferring an alias, sometimes it will create a constraint error, because of duplications.
                                          Changed it: When transferring , it will now increment Well_Alias_Id

                                          changed precedence order for Node Rollup. Moved 100TLM after 500PRB. Task #1173
                                          Modifed Update_WV_Location procedure to filter out nodes with Null Lat/Longs

       1.3.0   18-Jan-13      V.Rajpoot    Added to call UPDATE_WIM.CREATE_WELL function to create or add a well.
                                           This is a simple interface to take care of populating staging table and updating wim.

       1.4.0   21-Mar-13     V.Rajpoot    Modified UPDATE_WIM.Create_WELl and Update_WEll. Added 3 new parameters
                                          KB_ELEV_OUOM, GROUND_ELEV, GROUND_ELEV_OUOM

       1.4.1   5-June-13    V.Rajpoot    Removed a call to Well_Action_Override procedure. This procedure created
                                        override version if there are any specials chars in a well_name

       1.4.2   29-July-13   V.Rajpoot    Added new attribute Location_Accuracy adn Rig_Name, updated wim_well_action and wim_rollup packages
       1.4.3   21.Feb-13    K.Edwards   Added attributea OPERATOR and IPL_LICENSEE TO CREATE_WELL and UPDATE_WELL FUNCTIONS
       1.4.4   13-Mar-14    K.EDWARDS   Added basic logging to tlm_process_log
       1.4.5   17-Mar-14    K.EDWARDS   Added atributes P_WV_REGULATORY_AGENCY, P_WL_AGENT, P_WL_LICENSEE_CONTACT_ID, P_WL_REGULATORY_AGENCY, P_WL_REGULATORY_CONTACT_ID, P_WL_SURVEYOR
       1.4.6   09-Aug-14    K.Edwards   Added pragma autonomous_transaction; to Create and Update well functions for use with applications
                                        that call the functions (AP PDMS GEOWIZ)
       1.4.7   27-Apr-15    K.Edwards   Added DRILL_TD, and DTILL_TD_OUOM attributes (GEOWIZ)
   ----------------------------------------------------------------------------------------------------------------------------------- */

   /*----------------------------------------------------------------------------------------------------------
   Function:  VERSION
   Detail:    This function returns version # of the pcakage.

   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION Version
      RETURN VARCHAR2
   IS
   -- Return package version number
   -- Format: nn.mm.ll (kk)
   -- nn - Major version (Numeric)
   -- mm - Functional change (Numeric)
   -- ll - Bug fix revision (Numeric)
   -- k - Optional - Test version (letters)

   BEGIN
      RETURN '1.4.7';
   END Version;

   /*----------------------------------------------------------------------------------------------------------
  Function:  FIND_WELL
  Detail:    This Function is a simple find well, finds well by tlm_Id or well_num or well_name or plor_name or ipl_uwi.
              Returns TLM_ID if match found.

              Left it in WIM_GATEWAY for now, because it is used by iWim ( thru WIM_GATEWAY)

  History of Change:
  ------------------------------------------------------------------------------------------------------------*/
   FUNCTION find_well (
      palias             PPDM.WELL_ALIAS.WELL_ALIAS%TYPE,
      pfind_type         VARCHAR2 DEFAULT 'TLM_ID',
      psource            PPDM.WELL_VERSION.SOURCE%TYPE DEFAULT NULL,
      pfindbyalias_fg    VARCHAR2 DEFAULT 'Y')
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN wim_search.find_well (palias,
                                   pfind_type,
                                   psource,
                                   pfindbyalias_fg);
   END;


   /*----------------------------------------------------------------------------------------------------------
   Function:  NEXT_WIM_STG_ID
   Detail:    This Function gets nextval for wim_stg_id_seq to be used as next wim_stg_id for wim_stg_* tables.

   History of Change:
   ------------------------------------------------------------------------------------------------------------*/
   FUNCTION next_wim_stg_id
      RETURN NUMBER
   IS
      v_id   NUMBER;
   BEGIN
      SELECT wim_stg_id_seq.NEXTVAL INTO v_id FROM DUAL;

      RETURN v_id;
   END;


   /*----------------------------------------------------------------------------------------------------------
 Function:  WELL_ACTION
 Detail:    This Procedure makes call to WIM_WELL_ACTION.WELL_ACTION to
             Update, Create, Inactivate, Reactivate, Delete well

 History of Change:
 ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE well_action (
      pwim_stg_id                 NUMBER,
      ptlm_id              IN OUT VARCHAR2,
      pstatus_cd              OUT VARCHAR2,
      paudit_no               OUT NUMBER,
      ppriority_level_cd          validate_rule.priority_level_cd%TYPE DEFAULT 10)
   IS
   BEGIN
      wim_well_action.well_action (pwim_stg_id,
                                   ptlm_id,
                                   pstatus_cd,
                                   paudit_no,
                                   ppriority_level_cd);
   END;


   /*----------------------------------------------------------------------------------------------------------
 Function:  WELL_MOVE
 Detail:    This Procedure makes call to WIM_WELL_ACTION.WELL_MOVE to
             Move/Merge well

 History of Change:
 ------------------------------------------------------------------------------------------------------------*/
   PROCEDURE well_move (
      pfrom_tlm_id   IN     ppdm.well_version.uwi%TYPE,
      pfrom_source   IN     ppdm.well_version.SOURCE%TYPE,
      pto_tlm_id     IN OUT ppdm.well_version.uwi%TYPE,
      puser          IN     ppdm.well_version.row_created_by%TYPE DEFAULT USER,
      pstatus           OUT NUMBER)
   IS
      caction   CONSTANT VARCHAR2 (1) := 'M';
      verrors            NUMBER (14) := 0;
      vcount             NUMBER (14) := 0;
   BEGIN
      wim_well_action.well_move (pfrom_tlm_id,
                                 pfrom_source,
                                 pto_tlm_id,
                                 puser,
                                 pstatus);
   END;


   /*----------------------------------------------------------------------------------------------------------
   FUNCTION:    CREATE_WELL

   DETAIL:        THIS FUNCTION MAKES CALL TO UPDATE_WIM.CREATE_WELL TO
               CREATE OR ADD A WELL.
               THIS IS A SIMPLE INTERFACE TO TAKE CARE OF POPULATING STAGING TABLE AND UPDATING WIM.
               IT RETURN A NUMBER 0 = FAILED, 1 = COMPLETED

   HISTORY:    1.4.3   K.EDWARDS   Added P_OPERATOR, P_IPL_LICENSEE, P_CONTRACTOR, and P_WL_LICENSEE attributes
               1.4.4   K.EDWARDS   Added basic logging to tlm_process_log
   ------------------------------------------------------------------------------------------------------------*/
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
      RETURN NUMBER
   IS
      pragma autonomous_transaction;
      V_STATUS   NUMBER;
   BEGIN
      V_STATUS :=
         UPDATE_WIM.CREATE_WELL (
            P_TLM_ID                     => P_TLM_ID,
            P_SOURCE                     => P_SOURCE,
            P_COUNTRY                    => P_COUNTRY,
            P_PROVINCE_STATE             => P_PROVINCE_STATE,
            P_WELL_NAME                  => P_WELL_NAME,
            P_PLOT_NAME                  => P_PLOT_NAME,
            P_KB_ELEV                    => P_KB_ELEV,
            P_KB_ELEV_OUOM               => P_KB_ELEV_OUOM,
            P_GROUND_ELEV                => P_GROUND_ELEV,
            P_GROUND_ELEV_OUOM           => P_GROUND_ELEV_OUOM,
            P_REMARK                     => P_REMARK,
            P_WELL_NUM                   => P_WELL_NUM,
            P_UWI                        => P_UWI,
            P_BOTTOM_HOLE_LATITUDE       => P_BOTTOM_HOLE_LATITUDE,
            P_BOTTOM_HOLE_LONGITUDE      => P_BOTTOM_HOLE_LONGITUDE,
            P_SURFACE_LATITUDE           => P_SURFACE_LATITUDE,
            P_SURFACE_LONGITUDE          => P_SURFACE_LONGITUDE,
            P_STATUS                     => P_STATUS,
            P_DRILL_TD                   => P_DRILL_TD,
            P_DRILL_TD_OUOM              => P_DRILL_TD_OUOM,
            P_OPERATOR                   => P_OPERATOR,
            P_IPL_LICENSEE               => P_IPL_LICENSEE,
            P_REGULATORY_AGENCY          => P_REGULATORY_AGENCY,
            P_BH_LOCATION_QUALIFIER      => P_BH_LOCATION_QUALIFIER,
            P_BH_GEOG_COORD_SYSTEM_ID    => P_BH_GEOG_COORD_SYSTEM_ID,
            P_SUR_LOCATION_QUALIFIER     => P_SUR_LOCATION_QUALIFIER,
            P_SUR_GEOG_COORD_SYSTEM_ID   => P_SUR_GEOG_COORD_SYSTEM_ID,
            P_WL_AGENT                   => P_WL_AGENT,
            P_WL_LICENSE_NUM             => P_WL_LICENSE_NUM,
            P_WL_CONTRACTOR              => P_WL_CONTRACTOR,
            P_WL_LICENSEE                => P_WL_LICENSEE,
            P_WL_LICENSEE_CONTACT_ID     => P_WL_LICENSEE_CONTACT_ID,
            P_WL_REGULATORY_AGENCY       => P_WL_REGULATORY_AGENCY,
            P_WL_REGULATORY_CONTACT_ID   => P_WL_REGULATORY_CONTACT_ID,
            P_WL_SURVEYOR                => P_WL_SURVEYOR
        );
    
      commit;
      
      IF V_STATUS = 1
      THEN
        PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO('WIM.WIM_GATEWAY.CREATE_WELL - WELL ID ' || P_TLM_ID || ' CREATED');
      ELSE
        PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO('WIM.WIM_GATEWAY.CREATE_WELL - WELL CREATION FAILED');
      END IF;
        
      RETURN V_STATUS;
   END;

   /*----------------------------------------------------------------------------------------------------------
   FUNCTION:    UPDATE_WELL

   DETAIL:        THIS FUNCTION MAKES CALL TO UPDATE_WIM.UPDATE_WELL TO
               CREATE OR ADD A WELL.
               THIS IS A SIMPLE INTERFACE TO TAKE CARE OF POPULATING STAGING TABLE AND UPDATING WIM.
               IT RETURN A NUMBER 0 = FAILED, 1 = COMPLETED

    HISTORY:    1.4.3   K.EDWARDS   Added P_OPERATOR, P_IPL_LICENSEE, P_CONTRACTOR, and P_WL_LICENSEE attributes
                1.4.4   K.EDWARDS   Added basic logging to tlm_process_log
   ------------------------------------------------------------------------------------------------------------*/
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
      RETURN NUMBER
   IS
      pragma autonomous_transaction;
      V_STATUS   NUMBER;
   BEGIN
      V_STATUS :=
         UPDATE_WIM.UPDATE_WELL (
            P_TLM_ID                     => P_TLM_ID,
            P_SOURCE                     => P_SOURCE,
            P_COUNTRY                    => P_COUNTRY,
            P_PROVINCE_STATE             => P_PROVINCE_STATE,
            P_WELL_NAME                  => P_WELL_NAME,
            P_PLOT_NAME                  => P_PLOT_NAME,
            P_KB_ELEV                    => P_KB_ELEV,
            P_KB_ELEV_OUOM               => P_KB_ELEV_OUOM,
            P_GROUND_ELEV                => P_GROUND_ELEV,
            P_GROUND_ELEV_OUOM           => P_GROUND_ELEV_OUOM,
            P_REMARK                     => P_REMARK,
            P_WELL_NUM                   => P_WELL_NUM,
            P_UWI                        => P_UWI,
            P_BOTTOM_HOLE_LATITUDE       => P_BOTTOM_HOLE_LATITUDE,
            P_BOTTOM_HOLE_LONGITUDE      => P_BOTTOM_HOLE_LONGITUDE,
            P_SURFACE_LATITUDE           => P_SURFACE_LATITUDE,
            P_SURFACE_LONGITUDE          => P_SURFACE_LONGITUDE,
            P_STATUS                     => P_STATUS,
            P_DRILL_TD                   => P_DRILL_TD,
            P_DRILL_TD_OUOM              => P_DRILL_TD_OUOM,
            P_OPERATOR                   => P_OPERATOR,
            P_IPL_LICENSEE               => P_IPL_LICENSEE,
            P_REGULATORY_AGENCY          => P_REGULATORY_AGENCY,
            P_BH_GEOG_COORD_SYSTEM_ID    => P_BH_GEOG_COORD_SYSTEM_ID,
            P_BH_LOCATION_QUALIFIER      => P_BH_LOCATION_QUALIFIER,
            P_BH_NODE_OBS_NO             => P_BH_NODE_OBS_NO,
            P_SUR_GEOG_COORD_SYSTEM_ID   => P_SUR_GEOG_COORD_SYSTEM_ID,
            P_SUR_LOCATION_QUALIFIER     => P_SUR_LOCATION_QUALIFIER,
            P_SUR_NODE_OBS_NO            => P_SUR_NODE_OBS_NO,
            P_WL_AGENT                   => P_WL_AGENT,
            P_WL_LICENSE_NUM             => P_WL_LICENSE_NUM,
            P_WL_CONTRACTOR              => P_WL_CONTRACTOR,
            P_WL_LICENSEE                => P_WL_LICENSEE,
            P_WL_LICENSEE_CONTACT_ID     => P_WL_LICENSEE_CONTACT_ID,
            P_WL_REGULATORY_AGENCY       => P_WL_REGULATORY_AGENCY,
            P_WL_REGULATORY_CONTACT_ID   => P_WL_REGULATORY_CONTACT_ID,
            P_WL_SURVEYOR                => P_WL_SURVEYOR   
        );
      
      commit;
      
      IF V_STATUS = 1
      THEN
        PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO('WIM.WIM_GATEWAY.UPDATE_WELL - WELL UPDATED SUCCESFULLY');
      ELSE
        PPDM_ADMIN.TLM_PROCESS_LOGGER.INFO('WIM.WIM_GATEWAY.UPDATE_WELL - WELL UPDATED FAILED');
      END IF;  
      RETURN V_STATUS;
   END;
END WIM_GATEWAY;