create or replace PACKAGE     wim_validate
IS
/*-----------------------------------------------------------------------------------------------------------------------------------
 SCRIPT: WIM.WIM_VALIDATE.pks

 PURPOSE:
      This package contains functions and procedures to validate well information before inserting/updating/Inactivating/Reactivating.
      It is called from WIM_WELL_ACTION package.
      
      It is part of WIM_GATEWAY.
      
      Procedure/Function Details
            validate_tlm_id            Function      Checks if TLM_ID is provided (when Inserting a new Well)
                                                    Checks to make sure if exists in well_Version table ( when Updating, Adding,
                                                        Inactivating or Reactivating)
                                                    Returns 0 if success, or 1 if the value is not found.
            if_then_check              Function     Checks data depending on IF Conditions set up in Validate_Rule tables   
            condition_check            Function     Checks data depending on Conditions set up in Validate_Rule tables
            mandatory_field            Function     Checks data depending on REQ_FIELD_NAME setup in Validate_Rule, * tables
            ref_check                  Function     Checks data depending on REQ_FIELD_NAME/REF_TABLE_NAME set up in Validate_Rule, * tables    
            tlm_id_check               Function     Checks if TLM_ID is provided (when Inserting a new Well)
                                                    Checks to make sure if exists in well_Version table ( when Updating, Adding, 
                                                        Inactivating or Reactivating)
                                                     Returns 0 if success, or 1 if the value is not found.
            country_consistency_check  Function     Checks wells with country Australia, if it is consistent with others versions of 
                                                    the same well.
            country_latlong_check                   Validate_Country_LatLong table is used to perform this check
                                                    This function checks if well's lat/longs are between lat/longs and in country
                                                    as specificed in Validate_Country_LatLong table. 
            lat_long_prec_check        Function     Checks if lat/longs precision is same as it is specified in Validate_Rule tables. 
                                                    This applies when Creating, Adding or Updating wells.
            validate_uom               Function     Checks if UOM value is missing, 
                                                    (e.g if distance_to_loc value is provided but wim_distance_to_loc_uom is not ) 
                                                    If it is, adds an Error message to wim_audit_log table.
                                                    This applies when Creating, Adding or Updating wells.
            validate_well             Function      From wim_stg_well_version ( before processing), it does the following validations:
                                                    OUM convertion                                                
                                                    Generate Missing Data
                                                    All Custom and No Table specific validations
                                                    Validates: Well_Version, Well_License, Well_Node_Version and well_Node_m_b specific data.
            ipl_offshore_ind_trnsf					Transforms the IPL_OFFSHORE_IND attribuye from Y/N to 'OFFSHORE/ONSHORE'
			ipl_sort_display_trnsf					Transforms ipl_uwi_sort-display into a standard set for all Canadian wells 
													with a VALID ipl_uwi_local
             
 DEPENDENCIES
   WIM_WELL_ACTION
   WIM_GATEWAY
   VALIDATE_* tables
   WIM_STG_* tables

 EXECUTION:
   See Package Specification

   Syntax:
    N/A

 HISTORY:
         See package body for change log
-----------------------------------------------------------------------------------------------------------------------------------*/
/******************************************************************************************************
  VALIDATE_TLM_ID Function
 *******************************************************************************************************
   This function Checks if TLM_ID is provided (when Inserting a new Well)
   Checks to make sure if exists in well_Version table (Updating, Adding, INactivating or Reactivating)
    Returns 0 if success, or 1 if the value is not found.
   
    Parameter notes:      
      paudit_id     audit id for this operation(e.g Create, Add, Update, or Move)
      paction       Action is 'M' for Moving
      ptlm_Id       tlm_id being validated
      psource       source of the tlm_id that being validated
      puser         user that requested this.
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION validate_tlm_id (
      paudit_id   wim_audit_log.audit_id%TYPE,
      paction     wim_audit_log.action%TYPE,
      ptlm_id     wim_audit_log.tlm_id%TYPE,
      psource     wim_audit_log.SOURCE%TYPE,
      puser IN    wim_audit_log.row_created_by%TYPE      
   )
      RETURN NUMBER;

/******************************************************************************************************
  IF_THEN_CHECK Function
 *******************************************************************************************************
  Checks data depending on IF Conditions set up in Validate_Rule tables  
   Returns 0 if success, or 1 if the value is not found.
   
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION if_then_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  CONDITION_CHECK Function
 *******************************************************************************************************
  Checks data depending on Conditions set up in Validate_Rule tables
  Returns 0 if success, or 1 if the value is not found.
           
   
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION condition_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  MANDATORY_FIELD Function
 *******************************************************************************************************
  Checks data depending on REQ_FIELD_NAME setup in Validate_Rule, * tables
  Returns number of errors; 0 means success          
   
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION mandatory_field (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  REF_CHECK Function
 *******************************************************************************************************
  This function checks data depending on REQ_FIELD_NAME/REF_TABLE_NAME set up in Validate_Rule, * tables
  Returns 0 if success, or 1 if the value is not found.   
  
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION ref_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  TLMD_ID_CHECK Function
 *******************************************************************************************************
  This function 
           Checks if TLM_ID is provided (when Inserting a new Well)
           Checks to make sure if exists in well_Version table ( when Updating, Adding, Inactivating or Reactivating)
           Returns 0 if success, or 1 if the value is not found.  
  
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION tlm_id_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  COUNTRY_CONSISTENCY_CHECK Function
 *******************************************************************************************************
  This function checks Checks wells with country Australia, if it is consistent with others versions of 
   the same well.  
   
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION country_consistency_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;
      
/******************************************************************************************************
  COUNTRY_LATLONG_CHECK Function
 *******************************************************************************************************
  This function checks if well's lat/longs are between lat/longs and in country
    as specificed in Validate_Country_LatLong table.
    Validate_Country_LatLong table is used to perform this check. 
    RETURNS number of errors, 0 means no errors. 
   
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION country_latlong_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  LAT_LONG_PREC_CHECK Function
 *******************************************************************************************************
  This function Checks if lat/longs precision is same as it is specified in Validate_Rule tables. 
  This applies when Creating, Adding or Updating wells.
     
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION lat_long_prec_check (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  IPL_SORT_DISPLAY_TRNSF Function
 *******************************************************************************************************
  This function Checks if ipl_uwi_local (government id) is not null, and populates
  the ipl_uwi_sort and ipl_uwi_display attributes.
     
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   function ipl_sort_display_trnsf (
      pstg_id     wim_stg_request.wim_stg_id%type,
      pseq        number,
      prule_id    number,
      paudit_id   number
   ) return number;

/******************************************************************************************************
  IPL_OFFSHORE_IND_TRNSF Function
 *******************************************************************************************************
  This function Checks if ipl_offshore_ind is one of 'Y' and 'N', and populates the 
  ipl_offshore_ind in the stage table with 'OFFSHORE' or 'ONSHORE'.
     
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   function ipl_offshore_ind_trnsf (
      pstg_id     wim_stg_request.wim_stg_id%type,
      pseq        number,
      prule_id    number,
      paudit_id   number
   ) return number;
   
/******************************************************************************************************
  VALIDATION_UOM Function
 *******************************************************************************************************
  This function Checks if UOM value is missing, 
  (e.g if distance_to_loc value is provided but wim_distance_to_loc_uom is not ) 
  If it is, adds an Error message to wim_audit_log table.
  This applies when Creating, Adding or Updating wells.  
     
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION validate_uom (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      paudit_id   NUMBER
   )
      RETURN NUMBER;

/******************************************************************************************************
  VALIDATE_WELL Function
 *******************************************************************************************************
  This function does the following validations:
    OUM convertion                                                
    Generate Missing Data
    All Custom and No Table specific validations
    Validates: Well_Version, Well_License, Well_Node_Version and well_Node_m_b specific data.
             
   
    Parameter notes:  
    pstg_id                 Staging id of the well record being checked.
    ppriority_level_cd      priority of the validation rule 
-------------------------------------------------------------------------------------------------------*/ 
   FUNCTION validate_well (
      pstg_id              wim_stg_request.wim_stg_id%TYPE,
      ppriority_level_cd   validate_rule.priority_level_cd%TYPE DEFAULT 10
   )
      RETURN NUMBER;
END wim_validate;