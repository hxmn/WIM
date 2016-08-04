--------------------------------------------------------
--  DDL for Package WIM_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "WIM"."WIM_SEARCH" 
IS
/*****************************************************************************
SCRIPT: WIM.WIM_Search.pks

 PURPOSE:
   Package specification for the WIM Search functionality

 DEPENDENCIES
   See Package Specification

 EXECUTION:
   See Package Specification

   Syntax:
    N/A
 HISTORY:
    See Package body.
*****************************************************************************/

/****************************************************************************
FIND_WELL Function
*****************************************************************************
   This function returns the TLM_ID of a well based on the provided parameters
  (WELL_NUM, TLM_ID, IPL_UWI_LOCAL, WELL_NAME,PLOT_NAME)

Parameter notes:
      palias                  Find a well(s) based on alias. It could be Well_Name, TLM_ID, PLOT_NAME, IPL_UWI_LOCAL or COUNTRY 
      pfind_type              Find_Type to determine what attribute to be used for search. e.g TLM_ID, IPL_UWI_LOCAL, WELL_NUM, WELL_NAME,PLOT_NAME
      psource                 Find a well based on source, default value is Null.
      pfindbyalias_fg         Flag to decide if we need to search by alias or not. Default value is 'Y'
-----------------------------------------------------------------------------------------*/
 FUNCTION find_well (
   palias            well_alias.well_alias%TYPE,
      pfind_type        WELL_ALIAS.ALIAS_TYPE%TYPE DEFAULT 'TLM_ID',
      psource           well_version.SOURCE%TYPE DEFAULT NULL,
      pfindbyalias_fg   VARCHAR2 DEFAULT 'A' --'Y'      
   )
      RETURN VARCHAR2;
  
/*****************************************************************************
  FIND_WELLS function
 *****************************************************************************
    This function returns the  number of matches and TLM_ID (as an out parameter, only if there is a single match)
      If pfindbyalias_fg flag is 'W' and Source is NULL, then it reads from WELL table and no alias search.
      If pfindbyalias_fg flag is 'A' and SOURCE is NULL, then it reads from WELL_VERSION table and does alias search.      
      If pfindbyalias_fg flag is 'V' and SOURCE is given then if reads from WELL_VERSION table and No alias search
      If pfindbyalias_fg flag is 'A' and Source is given,then it reads from WELL_VERSION and Well_ALias for a given source.
      If pfindbyalias_fg flag is 'V' and Source is NULL,then it reads from WELL_VERSION in all sources and No Alias search
      If pfindbyalias_fg flag is 'W' and Source is given,then it reads from WELL for given source and No Alias Search
         
    Parameter notes:
      ptlm_id                  UWI ( out parameter, only if it is a single match)
      pcountry                 search will be done based on given country or all. Default value is null.
      pwell_num                search will be done based on given well_num or all. Default value is null.
      puwi                     search will be done based on given ipl_uwi_local or all. Default value is null.
      pwell_name               search will be done based on given well_name or all. Default value is null.
      pspud_date               search will be done based on given spud_date or all. Default value is null.
      prig_release_date        search will be done based on given rig_release_date or all. Default value is null.
      pkb_elev                 search will be done based on given kb_elev or all. Default value is null.
      pdrill_td                search will be done based on given drill_Td or all. Default value is null. 
      pbottom_hole_latitude    search will be done based on given bottom_hole_latitude or all. Default value is null.  
      pbottom_hole_longitude   search will be done based on given bottom_hole_longitude or all. Default value is null.  
      psurface_latitude        search will be done based on given surface_latitude or all.Default value is null.   
      psurface_longitude       search will be done based on given surface_longitude or all .Default value is null.  
      pplot_name               search will be done based on given plot_name or all.Default value is null.  
      plicense_num             search will be done based on given license_num ( using well_license table), 
                                if no licencse provided then it doesnt search in well_license table. Default value is null.  
      psource                  search will be done based  on given source or all. Default value is null.     
      pwide_search_fg           Flag to decide if we need to do wide search (e.g. Use 'OR' )
      pfindbyalias_fg           Flag to decide if we need to search by alias or not, search using WEll table or Well_Version ADD_WELL
                                
                                Source    AliasFg     Action
                                Null         W       Search only wells for any source
                                Null         A       Search versions and aliases for all sources
                                Specified    V       Search only versions for this source
                                Specified    A       Search versions and aliases but only for this source
                                Null         V       Search only versions for any source
                                Specified    W       Search only wells for this source

                                Default value is 'A'
                                
      ptolerance               tolerance level used for Latitudes and Longitudes
      pelevtolerance           tolerance level to be used to Drill_Td and KB_Elev, Default value is 1.
--------------------------------------------------------------------------------------------------------*/
 FUNCTION find_wells (
      ptlm_id         IN OUT   WELL_VERSION.UWI%TYPE,
      pcountry                 WELL_VERSION.COUNTRY%TYPE                    DEFAULT NULL,
      pwell_num                WELL_VERSION.WELL_NUM%TYPE                   DEFAULT NULL,
      puwi                     WELL_VERSION.IPL_UWI_LOCAL%TYPE              DEFAULT NULL,
      pwell_name               WELL_VERSION.WELL_NAME%TYPE                  DEFAULT NULL,
      pspud_date               WELL_VERSION.SPUD_DATE%TYPE                  DEFAULT NULL,
      prig_release_date        WELL_VERSION.RIG_RELEASE_DATE%TYPE           DEFAULT NULL,
      pkb_elev                 WELL_VERSION.KB_ELEV%TYPE                    DEFAULT NULL,
      pdrill_td                WELL_VERSION.DRILL_TD%TYPE                   DEFAULT NULL,
      pbottom_hole_latitude    WELL_VERSION.BOTTOM_HOLE_LATITUDE%TYPE       DEFAULT NULL,
      pbottom_hole_longitude   WELL_VERSION.BOTTOM_HOLE_LONGITUDE%TYPE      DEFAULT NULL,
      psurface_latitude        WELL_VERSION.SURFACE_LATITUDE%TYPE           DEFAULT NULL,
      psurface_longitude       WELL_VERSION.SURFACE_LONGITUDE%TYPE          DEFAULT NULL,
      pgeog_coord_system_id    WELL_NODE_VERSION.GEOG_COORD_SYSTEM_ID%TYPE  DEFAULT NULL,
      pplot_name               WELL_VERSION.PLOT_NAME%TYPE                  DEFAULT NULL,
      plicense_num             WELL_LICENSE.LICENSE_NUM%TYPE                DEFAULT NULL,
      psource                  WELL_VERSION.SOURCE%TYPE                     DEFAULT NULL,
      pwide_search_fg          VARCHAR2                                     DEFAULT 'N',
      pfindbyalias_fg          VARCHAR2                                     DEFAULT 'A', 
      ptolerance               NUMBER                                       DEFAULT 5,
      pelevtolerance           NUMBER                                       DEFAULT 1
   ) RETURN NUMBER;
         

END wim_search;

/
