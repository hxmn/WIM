CREATE OR REPLACE PACKAGE PPDM_ADMIN.well_completions_api
IS
-- SCRIPT: PPDM_ADMIN.well_completions_api pks
--
-- PURPOSE:
-- Package specification for the PPDM_ADMIN.well_completions_api functionality
-- 
--
-- Procedure/Function Summary
-- tlm_id_change Move data in TLM_WELL_COMPLETIONS table
-- tlm_id_can_change Check if moving data in TLM_WELL_COMPLETIONS might cause any constraint violation
 
-- DEPENDENCIES
-- TLM_WELL_CORE

--
-- EXECUTION:
-- Used by WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE procedure
--
-- Syntax:
-- 
--
-- HISTORY:
-- 0.1 10-Jan-12 V.Rajpoot Initial version


 -- PPDM_ADMIN.PDEN_VOL_API to enable changes to be made to the TLM_well_Completions data
   -- other than through the GUI

   --  Reassign items in the TLM_WELL_COMPLETIONS  tables to a new TLM Well ID.
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
--package body

CREATE OR REPLACE PACKAGE BODY PPDM_ADMIN.WELL_COMPLETIONS_API
IS
-- SCRIPT: PPDM_ADMIN.WELL_CORE_api.pkb
--
-- PURPOSE:
--   Package body for the PPDM_AMDIN.pden_vol_api functionality
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
--   0.1    10-Jan-12  V.Rajpoot    Initial version
--   0.2    16-Jan-12 V. Rajpoot Added Detail logs (counts) to the TLM_Process_Log

   PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
   IS

   v_detail VARCHAR2(2000);
   
   BEGIN

   
      --  Reassign any Information Items to the new TLM ID
      UPDATE TLM_WELL_COMPLETION
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;

        v_detail := CHR(10) || SQL%ROWCOUNT || ' TLM_WELL_COMPLETION records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;     
      
        -- Log the changes
      tlm_process_logger.info
         (   'PPDM_ADMIN.WELL_COMPLETIONS_API.TLM_ID_CHANGE: Well records moved from TLM ID: '
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
        FROM TLM_WELL_COMPLETION A INNER JOIN TLM_WELL_COMPLETION B
             ON A.SOURCE = B.SOURCE
            AND A.UWI = POLD_TLM_ID
            AND B.UWI = PNEW_TLM_ID
            AND A.COMPLETION_OBS_NO = B.COMPLETION_OBS_NO;
            
      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

     
      
      
      RETURN 1;                                -- can move data, no violations
      
   END;
   
END WELL_COMPLETIONS_API;
--  Give permission to the WIM Gateway
/



