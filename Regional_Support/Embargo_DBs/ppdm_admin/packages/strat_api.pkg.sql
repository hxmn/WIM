create or replace PACKAGE strat_api
IS
-- SCRIPT: PPDM_ADMIN.strat_api pks
--
-- PURPOSE:
-- Package specification for the PPDM_ADMIN.strat_api functionality
-- 
--
-- Procedure/Function Summary
-- tlm_id_change Move data in TLM_STRAT* tables
-- tlm_id_can_change Check if moving data in TLM_STRAT tables might cause any constraint violation
 
-- DEPENDENCIES
-- TLM_STRAT_UNIT
-- TLM_STRAT_NAME_SET
-- TLM_STRAT_WELL_SECTION

--
-- EXECUTION:
-- Used by WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE procedure
--
-- Syntax:
-- 
--
-- HISTORY:
-- 0.1 17-Jan-12 V.Rajpoot Initial version


 -- PPDM_ADMIN.STRAT_API to enable changes to be made to the TLM_STRAT data
   -- other than through the GUI

   --  Reassign items in the TLM_STRAT  tables to a new TLM Well ID.
   --  Used when wells are merged or split to ensure well core data is linked
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

create or replace PACKAGE BODY            STRAT_API
IS
-- SCRIPT: PPDM_ADMIN.STRAT_api.pkb
--
-- PURPOSE:
--   Package body for the PPDM_ADMIN.strat_api functionality
--
-- DEPENDENCIES
--   See Package Specification
--
-- EXECUTION:
--   See Package Specification
--
--   Syntax:
--    N/A
--
-- HISTORY:
--   0.1    17-Jan-12  V.Rajpoot    Initial version

   PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
   IS
   
   v_detail varchar2(2000);
   
   
   BEGIN
      --  Reassign any Information Items to the new TLM ID

       UPDATE TLM_STRAT_WELL_SECTION
         SET UWI = PNEW_TLM_ID
       WHERE UWI = POLD_TLM_ID;
       
       v_detail := chr(10) || SQL%ROWCOUNT || ' TLM_STRAT_WELL_SECTION records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
   
       
      -- Log the changes
      tlm_process_logger.info
         (   'PPDM_ADMIN.STRAT_API.TLM_ID_CHANGE: Well records moved from TLM ID: '
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
        FROM TLM_STRAT_WELL_SECTION A INNER JOIN TLM_STRAT_WELL_SECTION B
             ON A.UWI = POLD_TLM_ID
            AND B.UWI = PNEW_TLM_ID
            AND A.STRAT_NAME_SET_ID = B.STRAT_NAME_SET_ID
            AND A.STRAT_UNIT_ID = B.STRAT_UNIT_ID
            AND A.INTERP_ID = B.INTERP_ID;           
            
      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key violation
      END IF;

        
      RETURN 1;                  -- can move data, no violations
      
   END;
   
END STRAT_API;
--  Give permission to the WIM Gateway