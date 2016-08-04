create or replace PACKAGE well_core_api
IS
-- SCRIPT: PPDM_ADMIN.well_core_api pks
--
-- PURPOSE:
-- Package specification for the PPDM_ADMIN.well_core_api functionality
-- 
--
-- Procedure/Function Summary
-- tlm_id_change Move data in TLM_WELL_CORE table
-- tlm_id_can_change Check if moving data in TLM_WELL_CORE might cause any constraint violation
 
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


 -- PPDM_ADMIN.PDEN_VOL_API to enable changes to be made to the TLM_well_core data
   -- other than through the GUI

   --  Reassign items in the TLM_WELL_CORE  tables to a new TLM Well ID.
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

create or replace PACKAGE BODY            WELL_CORE_API
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

   PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
   IS
   
   v_detail varchar2(2000);
  
   
   BEGIN
      --  Reassign any Information Items to the new TLM ID
 
     
     
     --Add a new record to parent tables first, so child record can be modified     
     Insert into TLM_WELL_CORE
      (Select pnew_tlm_id, source, core_id, active_ind, analysis_report, base_depth, base_depth_ouom, contractor, core_barrel_size, core_barrel_size_ouom,
              core_diameter,core_diameter_ouom, core_handling_type, core_oriented_ind, core_show_type, core_type, coring_fluid, digit_avail_ind,              
              effectivE_date, expiry_date, gamma_correlation_ind, operation_seq_no, ppdm_guid, primary_core_strat_unit_id, 
              recovered_amount, recovered_amount_ouom, recovered_amount_uom, recovery_date,
              remark, reported_core_num, run_num, shot_recovered_count, sidewall_ind, strat_name_set_id, top_depth, top_depth_ouom,
              total_shot_count,   
              row_changed_by, row_changed_date, row_created_by, row_created_date,
              row_quality  from TLM_WELL_CORE Where uwi = pold_tlm_id);
      
       v_detail := chr(10) || SQL%ROWCOUNT || ' TLM_WELL_CORE records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
       
      Insert into WELL_CORE_ANALYSIS
      (Select pnew_tlm_id, source, core_id, analysis_obs_no, active_ind, analysis_date, analyzing_company, analyzing_company_loc, analyzing_file_num, 
              core_analyst_name,
              effectivE_date, expiry_date, ppdm_guid, primary_sample_type, remark,  sample_diameter, sample_diameter_ouom, sample_length, sample_length_ouom,
              sample_shape, second_sample_type, row_changed_by, row_changed_date, row_created_by, row_created_date,
              row_quality from WELL_CORE_ANALYSIS Where uwi = pold_tlm_id);
   
    v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' WELL_CORE_ANALYSIS records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
    
    Insert into TLM_WELL_CORE_SAMPLE_ANAL
      (Select pnew_tlm_id, source, core_id, analysis_obs_no, sample_num, sample_analysis_obs_no, active_ind, bulk_density, bulk_density_ouom,
              bulk_mass_oil_sat, bulk_mass_oil_sat_ouom, bulk_mass_sand_sat,bulk_mass_sand_sat_ouom, bulk_mass_water_sat, bulk_mass_water_sat_ouom,
              bulk_volume_oil_sat, bulk_volume_water_sat, confine_perm_pressure, confine_perm_pressure_ouom, confine_por_pressure,
              confine_por_pressure_ouom, confine_sat_pressure, confine_sat_pressure_ouom, effective_date, effective_porosity, expiry_date,
              gas_sat_volume, grain_density, grain_density_ouom, grain_mass_oil_sat, grain_mass_oil_sat_ouom, grain_mass_water_sat,
              grain_mass_water_sat_ouom, interval_depth, interval_depth_ouom, interval_length, interval_length_ouom, k90, k90_ouom,
              k90_qualifier, kmax, kmax_ouom, kmax_qualifier, kvert, kvert_ouom, kvert_qualifier, oil_sat, pore_volume_gas_sat,
              pore_volume_oil_sat, pore_volume_water_sat, porosity, ppdm_guid, remark,  top_depth, top_depth_ouom,
              water_sat, row_changed_by, row_changed_date, row_created_by, row_created_date,
              row_quality from TLM_WELL_CORE_SAMPLE_ANAL Where uwi = pold_tlm_id);
      
      v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_CORE_SAMPLE_ANAL records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
      

      UPDATE TLM_WELL_CORE_SAMPLE_DESC
         SET UWI = PNEW_TLM_ID
       WHERE UWI = POLD_TLM_ID;
           
      v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_CORE_SAMPLE_DESC records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
    
       DELETE FROM TLM_WELL_CORE_SAMPLE_ANAL
       WHERE UWI = POLD_TLM_ID;
     
      DELETE FROM WELL_CORE_ANALYSIS
       WHERE UWI = POLD_TLM_ID;
    
      DELETE FROM TLM_WELL_CORE
       WHERE UWI = POLD_TLM_ID;
          
     
          
        -- Log the changes
      tlm_process_logger.info
         (   'PPDM_ADMIN.WELL_CORE_API.TLM_ID_CHANGE: Well records moved from TLM ID: '
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
        FROM TLM_WELL_CORE A INNER JOIN TLM_WELL_CORE B
             ON A.SOURCE = B.SOURCE
            AND A.UWI = POLD_TLM_ID
            AND B.UWI = PNEW_TLM_ID
            AND A.CORE_ID = B.CORE_ID;
            
      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key violation
      END IF;

           SELECT COUNT (*)
        INTO vcount
        FROM WELL_CORE_ANALYSIS A INNER JOIN WELL_CORE_ANALYSIS B
             ON A.SOURCE = B.SOURCE
            AND A.UWI = POLD_TLM_ID
            AND B.UWI = PNEW_TLM_ID
            AND A.CORE_ID = B.CORE_ID
            AND A.ANALYSIS_OBS_NO = B.ANALYSIS_OBS_NO;
            
      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key violation
      END IF;
      SELECT COUNT(*)
        INTO VCOUNT
        FROM TLM_WELL_CORE_SAMPLE_ANAL A INNER JOIN TLM_WELL_CORE_SAMPLE_ANAL B
          ON A.SOURCE = B.SOURCE
         AND A.CORE_ID = B.CORE_ID
         AND A.ANALYSIS_OBS_NO = B.ANALYSIS_OBS_NO
         AND A.SAMPLE_NUM = B.SAMPLE_NUM
         AND A.SAMPLE_ANALYSIS_OBS_NO = B.SAMPLE_ANALYSIS_OBS_NO
         AND A.UWI = pold_tlm_id
         and B.UWI = pnew_tlm_id; 
      
      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key violation
      END IF;

      
     SELECT COUNT(*)
        INTO VCOUNT
        FROM TLM_WELL_CORE_SAMPLE_DESC A INNER JOIN TLM_WELL_CORE_SAMPLE_DESC B
          ON A.SOURCE = B.SOURCE
         AND A.CORE_ID = B.CORE_ID
         AND A.ANALYSIS_OBS_NO = B.ANALYSIS_OBS_NO
         AND A.SAMPLE_NUM = B.SAMPLE_NUM
         AND A.SAMPLE_ANALYSIS_OBS_NO = B.SAMPLE_ANALYSIS_OBS_NO
         AND A.SAMPLE_DESC_OBS_NO = B.SAMPLE_DESC_OBS_NO
         AND A.UWI = pold_tlm_id
         and B.UWI = pnew_tlm_id; 
      
      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key violation
      END IF;
      
      
      RETURN 1;                                -- can move data, no violations
      
   END;
   
END WELL_CORE_API;
--  Give permission to the WIM Gateway