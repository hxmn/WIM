create or replace PACKAGE     "UPDATE_WIM" 
AS
   /*----------------------------------------------------------------------------------------------------------
    SCRIPT: WIM.UPDATE_WIM.pks

    PURPOSE:
      Package Spec for WIM.UPDATE_WIM functionality, to create new wells in WIM Database using WIM GATEWAY.


       Procedure/Function Details:
       CREATE_WELL        This Function adds/creates a well in WIM database using parameters passed.
                           It returns status. 0 means failed, 1 means successful
                           Returns TLM_ID as an outparameter

       UPDATE_WELL        This Function updates well in WIM database using parameters passed.
                           It returns status. 0 means failed, 1 means successful

    DEPENDENCIES
      WIM_GATEWAY
      WIM_WELL_ACTION
      TLM_PROCESS_LOGGER
      WIM_AUDIT_EVENT

      Syntax:
       N/A

    HISTORY:
        1.0.3      21-Feb-2013      K.Edwards           Added OPERATOR, IPL_LICENSEE, CONTRACTOR and WL_LICENSEE attributes
        1.0.4      13-MarR-2014     k.edwards           Added basic (INFO) logging to tlm_process_l
        1.0.5      17-Mar-2014      k.edwards           Added atributes P_WV_REGULATORY_AGENCY, P_WL_AGENT, P_WL_LICENSEE_CONTACT_ID, P_WL_REGULATORY_AGENCY, P_WL_REGULATORY_CONTACT_ID, P_WL_SURVEYOR
        1.0.6	     02-Jul-2014	    k.edwards			      Changed CREATE_WELL and UPDATE_WELL to cascade country changes down to the node tables. 
        1.0.7      27-Apr-2015	    k.edwards			      Added DRILL_TD, and DRILL_TD_OUOM attributes to craete/update well (GEOWIZ)
   ----------------------------------------------------------------------------------------------------------------------*/

   /*****************************************************************************
     Version procedure
    *****************************************************************************
    This function returns version # of the pcakage

     Parameter Notes:
         None
   -----------------------------------------------------------------------------------------*/
   FUNCTION Version
      RETURN VARCHAR2;

   /*****************************************************************************
     CREATE_WELL Function
    *****************************************************************************
       This Function creates a new well in WIM Database.
       It populates stagings tables from parameters passed.
       Calls WIM_GATEWAY.well_action to update ppdm well tables.


       Parameter notes:
       P_TLM_ID                 TLM_ID to use to create or add a well. Default value is null.
       P_SOURCE                 Source of the TLM_ID being created/added
       P_COUNTRY                 Country for the well being created/added. It is a required parameter
       P_PROVINCE_STATE          province_state for the well being created/added. default value is null
       P_WELL_NAME              well_name for the well being created/added. default value is null, it is not required for TLM overide version.
       P_PLOT_NAME
       P_KB_ELEV                 kb_elev for the well being created/added. default value is null
       P_KB_ELEV_OUOM
       P_GROUND_ELEV             
       P_GROUND_ELEV_OUOM
       P_REMARK                  remark for the well being created/added. default value is null
       P_WELL_NUM
       P_UWI                     ipl_uwi_local for the well being created/added. default value is null
       P_BOTTOM_HOLE_LATITUDE    bottom_hole_latitude for the well being created/added. default value is null
       P_BOTTOM_HOLE_LONGITUDE   bottom_hole_longitude for the well being created/added. default value is null
       P_SURFACE_LATITUDE        surface_latitude for the well being created/added. default value is null
       P_SURFACE_LONGITUDE       surface_longitude for the well being created/added. default value is null
       P_STATUS                  current_status for the well being created/added. default value is null                  
       P_DRILL_TD                  DRILLERS TOTAL DEPTH: Total or maximum depth of the well as reported by the operator/ driller.    
       P_DRILL_TD_OUOM             DRILLERS TOTAL DEPTH OUOM: Driller total depth original unit of measure.    
       P_OPERATOR                
       P_IPL_LICENSEE            
       P_BH_LOCATION_QUALIFIER   bottom hole location_qualifier for the well being created/added. default value is null
       P_BH_GEOG_COORD_SYSTEM_ID Bottom hole geog_coord_system_id for the well being created/added. default value is null
       P_BH_NODE_OBS_NO          
       P_SUR_LOCATION_QUALIFIER    surface location_qualifier for the well being created/added. default value is null
       P_SUR_GEOG_COORD_SYSTEM_ID  surface geog_coord_system_id for the well being created/added. default value is null
       P_SUR_NODE_OBS_NO         
       P_WL_AGENT                  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_LICENSE_NUM            license_num for the well being created/added. default value is null
       P_WL_CONTRACTOR             BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium. 
       P_WL_LICENSEE               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WV_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_LICENSEE_CONTACT_ID    BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_CONTACT_ID  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_SURVEYOR               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.                
   */

   FUNCTION UPDATE_WELL (
      P_TLM_ID                      WELL_VERSION.UWI%TYPE,
      P_SOURCE                      WELL_VERSION.SOURCE%TYPE,
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

   
   /*****************************************************************************
     UPDATE_WELL Function
    *****************************************************************************
       This Function UPDATES a well in WIM Database.
       It populates stagings tables from parameters passed.
       Calls WIM_GATEWAY.well_action to update ppdm well tables.


       Parameter notes:
       P_TLM_ID                 TLM_ID to use to create or add a well. Default value is null.
       P_SOURCE                 Source of the TLM_ID being created/added
       P_COUNTRY                 Country for the well being created/added. It is a required parameter
       P_PROVINCE_STATE          province_state for the well being created/added. default value is null
       P_WELL_NAME              well_name for the well being created/added. default value is null, it is not required for TLM overide version.
       P_PLOT_NAME
       P_KB_ELEV                 kb_elev for the well being created/added. default value is null
       P_KB_ELEV_OUOM
       P_GROUND_ELEV             
       P_GROUND_ELEV_OUOM
       P_REMARK                  remark for the well being created/added. default value is null
       P_WELL_NUM
       P_UWI                     ipl_uwi_local for the well being created/added. default value is null
       P_BOTTOM_HOLE_LATITUDE    bottom_hole_latitude for the well being created/added. default value is null
       P_BOTTOM_HOLE_LONGITUDE   bottom_hole_longitude for the well being created/added. default value is null
       P_STATUS                  current_status for the well being created/added. default value is null                  
       P_DRILL_TD                  DRILLERS TOTAL DEPTH: Total or maximum depth of the well as reported by the operator/ driller.    
       P_DRILL_TD_OUOM             DRILLERS TOTAL DEPTH OUOM: Driller total depth original unit of measure.    
       P_OPERATOR                
       P_IPL_LICENSEE            
       P_REGULATORY_AGENCY
       P_BH_LOCATION_QUALIFIER   bottom hole location_qualifier for the well being created/added. default value is null
       P_BH_GEOG_COORD_SYSTEM_ID Bottom hole geog_coord_system_id for the well being created/added. default value is null
       P_BH_NODE_OBS_NO          
       P_SURFACE_LATITUDE        surface_latitude for the well being created/added. default value is null
       P_SURFACE_LONGITUDE       surface_longitude for the well being created/added. default value is null
       P_SUR_LOCATION_QUALIFIER  surface location_qualifier for the well being created/added. default value is null
       P_SUR_GEOG_COORD_SYSTEM_ID surface geog_coord_system_id for the well being created/added. default value is null
       P_SUR_NODE_OBS_NO         
       P_WL_AGENT                  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_LICENSE_NUM            license_num for the well being created/added. default value is null
       P_WL_CONTRACTOR             BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium. 
       P_WL_LICENSEE               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WV_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_LICENSEE_CONTACT_ID    BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_AGENCY      BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_REGULATORY_CONTACT_ID  BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.
       P_WL_SURVEYOR               BUSINESS ASSOCIATE:  Unique identifier for a business associate, such as a person, company, regulatory agency, government or consortium.                
   */
   FUNCTION CREATE_WELL (
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
END UPDATE_WIM;