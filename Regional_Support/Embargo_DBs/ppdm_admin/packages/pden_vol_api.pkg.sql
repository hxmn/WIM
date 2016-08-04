create or replace PACKAGE pden_vol_api
IS
-- SCRIPT: PPDM_ADMIN.pden_vol_api pks
--
-- PURPOSE:
-- Package specification for the PPDM_ADMIN.pden_vol_api functionality
-- 
--
-- Procedure/Function Summary
-- tlm_id_change Move data in TLM_PDEN_VOL_BY_MONTH table
-- tlm_id_can_change Check if moving data in TLM_PDEN_VOL_BY_MONTH might cause any constraint violation
 
-- DEPENDENCIES
-- TLM_PDEN_VOL_BY_MONTH

--
-- EXECUTION:
-- Used by WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE procedure
--
-- Syntax:
-- 
--
-- HISTORY:
-- 0.1 10-Jan-12 V.Rajpoot Initial version





 -- PPDM_ADMIN.PDEN_VOL_API to enable changes to be made to the TLM_PDEN_VOL_BY_MONTH data
   -- other than through the GUI

   --  Reassign items in the TLM_PDEN_VOL_BY_MONTH  tables to a new TLM Well ID.
   --  Used when wells are merged or split to ensure PDEV VOL data is linked
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

create or replace PACKAGE BODY            pden_vol_api
IS
-- SCRIPT: PPDM.dir_srvy_api.pkb
--
-- PURPOSE:
--   Package body for the PPDM_ADMIN.pden_vol_api functionality
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

   PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
   IS
   
   v_detail VARCHAR2(2000);
   
   BEGIN
             
    --  Reassign any Information Items to the new TLM ID    
    -- Insert a new row to this parent table first, so the child tables records
    -- can be updated.
    INSERT INTO PDEN
        (select pnew_tlm_id, pden_type, Source, Active_IND, Country, current_operator, current_prod_str_name, current_status_date,
                current_well_str_number, district, effective_date, enhanced_recovery_type, expiry_date, field_id, geographic_region,
                geologic_province, last_injection_date, last_production_date, last_reported_date, location_desc, location_desc_type,
                on_injection_date, on_production_date, pden_name, pden_short_name, pden_status, plot_name, plot_symbol, pool_id, ppdm_guid,
                primary_product,production_method, proprietary_ind, province_state, remark, state_or_federal_waters, strat_name_set_id, strat_unit_id,
                string_serial_number, row_changed_by,row_changed_date, row_Created_by, row_created_date, row_quality
                from PDEN where pden_id = pold_tlm_id );

     v_detail :=  CHR(10) || SQL%ROWCOUNT || ' PDEN records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
   
   
     UPDATE tlm_pden_vol_by_month
         SET pden_id = pnew_tlm_id
       WHERE pden_id = pold_tlm_id;
  
      v_detail := v_detail || CHR(10) || SQL%ROWCOUNT || ' TLM_PDEN_VOL_BY_MONTH records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
    
       DELETE from PDEN
        WHERE PDEN_ID = pold_tlm_id;
        
    
        -- Log the changes
      tlm_process_logger.info
         (   'PPDM_ADMIN.PDEN_VOL_API.TLM_ID_CHANGE: Well records moved from TLM ID: '
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
      
      
      SELECT COUNT(*) INTO VCOUNT
        FROM PDEN A INNER JOIN PDEN B
          ON A.SOURCE = B.SOURCE
          AND A.PDEN_TYPE = 'WELL'
          AND B.PDEN_TYPE = 'WELL'
          AND A.PDEN_ID = POLD_TLM_ID
          AND B.PDEN_ID = PNEW_TLM_ID;
          
      IF vcount > 0
      THEN
         RETURN 0;               -- can not move data, primary key vialotion
      END IF;
      

      SELECT COUNT (*)
        INTO vcount
        FROM TLM_PDEN_VOL_BY_MONTH A INNER JOIN TLM_PDEN_VOL_BY_MONTH B
             ON A.PDEN_SOURCE = B.PDEN_SOURCE
            AND A.PDEN_ID = POLD_TLM_ID
            AND B.PDEN_ID = PNEW_TLM_ID
            AND A.VOLUME_METHOD = B.VOLUME_METHOD
            AND A.ACTIVITY_TYPE = B.ACTIVITY_TYPE
            AND A.PRODUCT_TYPE = B.PRODUCT_TYPE
            AND A.YEAR = B.YEAR
            AND A.AMENDMENT_SEQ_NO = B.AMENDMENT_SEQ_NO
            AND A.PDEN_TYPE = 'WELL'
            AND B.PDEN_TYPE = 'WELL';

      IF vcount > 0
      THEN
         RETURN 0;               -- can not move data, primary key vialotion
      END IF;


      RETURN 1;                  -- can move data, no violations
   END;
   
END PDEN_VOL_API;
--  Give permission to the WIM Gateway