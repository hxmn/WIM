create or replace PACKAGE       "WIM_WELL_ACTION" 
IS
/******************************************************************************************************************************
 SCRIPT: WIM.WIM_Well_Action.pks

 PURPOSE:
   Package specification for the WIM Action ( Update, Create, Inactivate, Reactivate, Delete..) functionality
    
    
    
 DEPENDENCIES
   WIM_STG_* tables
   

 EXECUTION:
   See Package Specification

   Syntax:
    N/A

 HISTORY:
    See Package Body
---------------------------------------------------------------------------------------------------------------------------------------------*/


/*****************************************************************************
  ADD_ALIAS procedure
  *****************************************************************************
 This Procedure adds alias to WELL_ALIAS table everytime there is change in 
  (WELL_NAME, WELL_NUM, TLM_ID, PLOT_NAME, COUNTRY attributes) and on well move/merge


   Parameter notes:
    ptlm_id           TLM_ID
    psource           Source  of the TLM_ID   
    palias_type       type of alias (e.g. UWI or PLOT_NAME or WELL_NAME,..)   
    palias_value      Actual value of alias
    preason_type      reason for the change
    puser             user name    
------------------------------------------------------------------------------*/

   PROCEDURE add_alias (
      ptlm_id        well_alias.uwi%TYPE,
      psource        well_alias.SOURCE%TYPE,
      palias_type    well_alias.alias_type%TYPE,
      palias_value   well_alias.well_alias%TYPE,
      preason_type   well_alias.reason_type%TYPE DEFAULT 'Update',
      puser          well_alias.row_created_by%TYPE DEFAULT USER
   );

/****************************************************************************
  OUM_CONVERSION procedure
 *****************************************************************************
 
 This procedure does Unit conversions for well_version and child tables.
 Parameter notes:
  pwim_stg_id           wim_stg_id of a well record
------------------------------------------------------------------------------*/
   PROCEDURE oum_conversion (pwim_stg_id NUMBER);


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
      he action to be carried out is defined in WIM_STG_WELL_VERSION.WIM_ACTION_CD:
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
-----------------------------------------------------------------------------------*/

   PROCEDURE well_action (
      pwim_stg_id                   NUMBER,
      ptlm_id              IN OUT   VARCHAR2,
      pstatus_cd           OUT      VARCHAR2,
      paudit_id            OUT      NUMBER,
      ppriority_level_cd            validate_rule.priority_level_cd%TYPE
            DEFAULT 10
   );

/*****************************************************************************
  WELL_MOVE procedure
 *****************************************************************************
 This Procedure Moves or Merges a well.

   Parameter notes:
    pfrom_tlm_id      TLM_ID moving
    pfrom_source       Source of the TLM_ID moving    
    pto_tlm_id        TLM_ID moving To
    puser             user name    
    pstatus           It is the audit_id for the move. if is an out parameter, 
-----------------------------------------------------------------------------------*/
   PROCEDURE well_move (
      pfrom_tlm_id   IN       well_version.uwi%TYPE,
      pfrom_source   IN       well_version.SOURCE%TYPE,
      pto_tlm_id     IN OUT   well_version.uwi%TYPE,
      puser          IN       well_version.row_created_by%TYPE DEFAULT USER, 
      pstatus        OUT      NUMBER
   );

   
END wim_well_action;