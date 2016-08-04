create or replace PACKAGE            well_area_api
IS
-- SCRIPT: PPDM.geochem_api pks
--
-- PURPOSE:
--   Package specification for the  PPDM.well_area_api functionality
--   
--
--   Procedure/Function Summary
--      tlm_id_change      Move data in WELL_AREA system
--      tlm_id_can_change  Check if moving data in WELL_AREA system might cause any constraint violation
   
-- DEPENDENCIES

--
-- EXECUTION:
--   Used by  WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE  procedure
--
--   Syntax:
--    
--
-- HISTORY:
--   0.1    09-June-11  V.Rajpoot    Initial version
   --  Reassign items in the WELL_AREA  table to a new TLM Well ID.
   --  Used when wells are merged or split to ensure WELL_AREA data is linked
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

create or replace PACKAGE BODY            well_area_api
IS
-- SCRIPT: PPDM.well_area_api.pkb
--
-- PURPOSE:
--   Package body for the PPDM.well_area_api functionality
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
--   0.1   9-June-11  V. Rajpoot    Initial version
--   0.2  16-Jan-12   V. Rajpoot    Added Detail logs (counts) to the TLM_Process_Log

   PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
   IS
 
   v_detail VARCHAR2(2000);
   
   BEGIN
   
  
      --  Reassign any Information Items to the new TLM ID
      UPDATE WELL_AREA
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;

      v_detail := chr(10) || SQL%ROWCOUNT || ' WELL_AREA records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
     
      -- Log the changes
      tlm_process_logger.info
         (   'PPDM_ADMIN.WELL_AREA_API.TLM_ID_CHANGE: Well records moved from TLM ID: '
          || pold_tlm_id
          || ' TO TLM ID: '
          || pnew_tlm_id || v_detail
         );
         
      -- Log the Details
     -- tlm_process_logger.info ( v_Msg);
         
       
   END tlm_id_change;

   FUNCTION tlm_id_can_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
      RETURN NUMBER
   IS
      vcount   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vcount
        FROM well_area a INNER JOIN well_area b
             ON a.area_type = b.area_type
           AND a.area_id = b.area_id
           AND a.source = b.source
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;


      RETURN 1;                                -- can move data, no vialations
   END;
END well_area_api;
--  Give permission to the WIM Gateway