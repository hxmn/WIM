CREATE OR REPLACE PACKAGE WIM.wim_validate_cust
IS

/*-----------------------------------------------------------------------------------------------------------------------------------
 SCRIPT: WIM.WIM_VALIDATE_CUST.pks

 PURPOSE:
      This package contains a function to validate Nodes:
      It is part of WIM_GATEWAY.
      
      
      PROCEDIRE/FUNCTON DETAILS
      
      VALIDATE_NODES        Function        This Function Checks for missing nodes
                                            checks the node id follow the numbering convention ( .e.g Surface Node should be TLM_ID || '1' )
      
      
DEPENDENCIES   
   WIM_STG_* tables
   VALIDATE_* tables

 EXECUTION:
   See Package Specification

   Syntax:
    N/A

 HISTORY:
         See package body for change log    
      
------------------------------------------------------------------------------------------------------------------------------------*/

/******************************************************************************************************
  VALIDATE_NODES Function
 *******************************************************************************************************
  This Function Checks for missing nodes
  checks the node id follow the numbering convention ( .e.g Surface Node should be TLM_ID || '1' )
 
    Parameter notes:  
    pstg_id         Staging id of the well record being checked.
    pseq            sequence  number
    prule_id        validation rule id
    paudit_id       Audit id to be used to record audit log in wim_audit_log
-------------------------------------------------------------------------------------------------------*/ 

   FUNCTION validate_nodes (
      pstg_id     wim_stg_request.wim_stg_id%TYPE,
      pseq        NUMBER,
      prule_id    NUMBER,
      paudit_id   NUMBER
   )
      RETURN NUMBER;
END wim_validate_cust; 
 
/