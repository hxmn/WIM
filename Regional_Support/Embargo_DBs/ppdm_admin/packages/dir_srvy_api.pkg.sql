create or replace PACKAGE      dir_srvy_api
IS
-- SCRIPT: PPDM.dir_srvy_api pks
--
-- PURPOSE:
--   Package specification for the  PPDM.dir_srvy_api functionality
--   
--
--   Procedure/Function Summary
--      tlm_id_change      Move data in DIR SRVY system
--      tlm_id_can_change  Check if moving data in DIR SRVY system might cause any constraint violation
   
-- DEPENDENCIES
--   tlm_well_dir_srvy  table
--    tlm_well_dir_srvy_station table

--
-- EXECUTION:
--   Used by  WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE  procedure
--
--   Syntax:
--    
--
-- HISTORY:
--   0.1    15-Jan-11  S. Makarov    Initial version





   -- DIR_SRVY_API to enable changes to be made to the DIR_SRVY data
   -- other than through the GUI

   --  Reassign items in the DIR_SRVY  tables to a new TLM Well ID.
   --  Used when wells are merged or split to ensure DIR_SRVY data is linked
   --  to the correct TLM IDs.
   --
   --  Procedure does not COMMIT the change to allow caller to apply
   --  as part of wider transaction.
   --
   PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2);

   FUNCTION tlm_id_can_change (
      pold_tlm_id   IN   VARCHAR2,
      pnew_tlm_id   IN   VARCHAR2
   )
      RETURN NUMBER;
END;
/

create or replace PACKAGE BODY dir_srvy_api
IS
-- SCRIPT: PPDM.dir_srvy_api.pkb
--
-- PURPOSE:
-- Package body for the PPDM.dir_srvy_api functionality
--
-- DEPENDENCIES
-- See Package Specification
--
-- EXECUTION:
-- See Package Specification
--
-- Syntax:
-- N/A
--
-- HISTORY:
-- 0.1 15-Jan-11 S. Makarov Initial version
-- 0.2 16-Jan-12 V. Rajpoot Added Detail logs (counts) to the TLM_Process_Log

 PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
 IS

 v_detail varchar2(2000);
 
 BEGIN
 
     -- Reassign any Information Items to the new TLM ID
     UPDATE tlm_well_dir_srvy_station
     SET uwi = pnew_tlm_id
     WHERE uwi = pold_tlm_id;

     v_detail :=  chr(10) ||  SQL%ROWCOUNT || ' TLM_WELL_DIR_SRVY_STATION records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
  
     UPDATE tlm_well_dir_srvy
     SET uwi = pnew_tlm_id
     WHERE uwi = pold_tlm_id;
    
     v_detail := v_detail || chr(10) ||  SQL%ROWCOUNT || ' TLM_WELL_DIR_SRVY records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
  
     -- Log the changes
     tlm_process_logger.info
     ( 'PPDM_ADMIN.DIR_SRVY_API.TLM_ID_CHANGE: Well records moved from TLM ID: '
     || pold_tlm_id
              || ' TO TLM ID: '
              || pnew_tlm_id || v_detail
             );
     
   END tlm_id_change;

   FUNCTION tlm_id_can_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
      RETURN NUMBER
   IS
      vcount   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_dir_srvy a INNER JOIN tlm_well_dir_srvy b
             ON a.survey_id = b.survey_id
           AND a.SOURCE = b.SOURCE
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

/* SMakarov
There is no point of checking tlm_well_dir_srvy_station table,
PK includes fields from PK in tlm_well_dir_srvy
*/
      RETURN 1;                                -- can move data, no vialations
   END;
END dir_srvy_api;
--  Give permission to the WIM Gateway