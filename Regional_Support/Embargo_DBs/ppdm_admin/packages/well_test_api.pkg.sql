create or replace PACKAGE      WELL_TEST_API
IS
-- SCRIPT: PPDM.WELL_TEST_API.pks
--
-- PURPOSE:
--   Package specification for the  PPDM.WELL_TEST_API functionality
--   
--
--   Procedure/Function Summary
--      tlm_id_change      Move data in Well test system
--      tlm_id_can_change  Check if moving data in Well Test system might cause any constraint violation
   
-- DEPENDENCIES
--  tables:
----tlm_well_test
----tlm_well_test_analysis
----tlm_well_test_blow_desc
----tlm_well_test_contaminant
----tlm_well_test_cushion
----tlm_well_test_equipment
----tlm_well_test_flow
----tlm_well_test_flow_meas
----tlm_well_test_mud
----tlm_well_test_period
----tlm_well_test_press_meas
----tlm_well_test_pressure
----tlm_well_test_quality
----tlm_well_test_recorder
----tlm_well_test_recovery
----tlm_well_test_remark
----tlm_well_test_slope

--
-- EXECUTION:
--   Used by  WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE  procedure
--
--   Syntax:
--    
--
-- HISTORY:
--   0.1    15-Jan-11  S. Makarov    Initial version



    -- WELL_TEST_API to enable changes to be made to the WELL_TEST data
    -- other than through the GUI

  
    --  Reassign items in the WELL_TEST  tables to a new TLM Well ID.
    --  Used when wells are merged or split to ensure WELL_TEST data is linked
    --  to the correct TLM IDs.
    --
    --  Procedure does not COMMIT the change to allow caller to apply
    --  as part of wider transaction.
    --
    PROCEDURE TLM_ID_CHANGE (
        pOld_TLM_ID  IN   VARCHAR2,
        pNew_TLM_ID  IN   VARCHAR2
    );
   FUNCTION tlm_id_can_change (
      pold_tlm_id   IN   VARCHAR2,
      pnew_tlm_id   IN   VARCHAR2
   )
      RETURN NUMBER;
END;
/

create or replace PACKAGE BODY            well_test_api
IS
-- SCRIPT: well_test_api.pkb
--
-- PURPOSE:
--   Package body for the well_test_api functionality
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
-- 0.1 15-Jan-11  S. Makarov    Initial version
-- 0.2 16-Jan-12 V. Rajpoot Added Detail logs (counts) to the TLM_Process_Log

   PROCEDURE tlm_id_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
   IS
   --v_count NUMBER;
   v_detail CLOB;
   
   BEGIN
   --Get the counts
   
       
    -- Insert a new row to these 2 parent tables first, so the child tables records
    -- can be updated.
    INSERT INTO tlm_well_test_period
        (select pnew_tlm_id, Source,Test_Type, Run_Num,Test_Num, Period_Type,Period_Obs_No,
                Active_IND, Casing_Pressure, Casing_Pressure_OUOM, Effective_Date, Expiry_Date,
                Period_Duration, Period_Duration_OUOM, PPDM_GUID, Remark, Tubing_Pressure, 
                Tubing_Pressure_OUOM, Row_Changed_By, Row_Changed_Date, Row_Created_By, 
                Row_Created_Date, Row_Quality from tlm_well_test_period where uwi = pold_tlm_id );
  v_detail := chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_PERIOD records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
  
 
     INSERT INTO tlm_well_test_Recorder
        (select pnew_tlm_id,Source, Test_Type, Run_Num, Test_Num, Recorder_Id, Active_IND,
                Effective_Date, Expiry_Date, Max_Capacity_Pressure, Max_Capacity_Pressure_OUOM,
                Max_Capacity_Temp, Max_Capacity_Temp_OUOM,Performance_Quality, PPDM_GUID,
                Recorder_Depth, Recorder_Depth_OUOM, Recorder_Inside_IND, Recorder_Max_Temp,
                Recorder_Max_Temp_OUOM, Recorder_Min_Temp, Recorder_Min_Temp_OUOM,
                Recorder_Position, Recorder_Resolution, Recorder_Resolution_OUOM, RECORDER_TYPE,
                Recorder_Used_IND, Remark, Row_Changed_By, Row_Changed_Date, Row_Created_By,
                Row_Created_Date, Row_Quality from tlm_well_test_recorder where uwi = pold_tlm_id);
      v_detail := v_detail || chr(10) || SQL%ROWCOUNT ||  ' TLM_WELL_TEST_RECORDER records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
             
                
      --  Reassign any Information Items to the new TLM ID
      UPDATE tlm_well_test
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
     v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
 
--       UPDATE tlm_well_test_period
--         SET uwi = pnew_tlm_id
--       WHERE uwi = pold_tlm_id;
       

      UPDATE tlm_well_test_analysis
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
 v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_ANALYSIS records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
 
      UPDATE tlm_well_test_blow_desc
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
  v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_BLOW_DESC records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
 
      UPDATE tlm_well_test_contaminant
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
   v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_CONTAMINANT records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
 
      UPDATE tlm_well_test_cushion
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
 v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_CUSHION records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
 
      UPDATE tlm_well_test_equipment
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
  v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_EQUIPMENT records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
 
      UPDATE tlm_well_test_flow
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
  v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_FLOW records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
 
      UPDATE tlm_well_test_flow_meas
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
  v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_FLOW_MEAS records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;

      UPDATE TLM_WELL_TEST_MUD
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
  v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_MUD records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;

      UPDATE TLM_WELL_TEST_PRESS_MEAS
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_PRESS_MEAS records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;


      UPDATE tlm_well_test_pressure
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
   v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_PRESSURE records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;

      UPDATE tlm_well_test_quality
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
  v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_QUALITY records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;

--      UPDATE tlm_well_test_recorder
--         SET uwi = pnew_tlm_id
--       WHERE uwi = pold_tlm_id;
      UPDATE tlm_well_test_recovery
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
   v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_RECOVERY records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;
  
      UPDATE tlm_well_test_remark
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
 v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_REMARK records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;

      UPDATE tlm_well_test_slope
         SET uwi = pnew_tlm_id
       WHERE uwi = pold_tlm_id;
   v_detail := v_detail || chr(10) || SQL%ROWCOUNT || ' TLM_WELL_TEST_SLOPE records moved from TLM ID: ' || pold_tlm_id || ' TO TLM ID: '|| pnew_tlm_id;

       DELETE from tlm_well_test_period
        WHERE uwi = pold_tlm_id;
        
       DELETE from tlm_well_test_recorder
        WHERE uwi = pold_tlm_id;

      -- Log the changes
      tlm_process_logger.info
         (   'PPDM_ADMIN.WELL_TEST_API.TLM_ID_CHANGE: Well records moved from TLM ID: '
          || pold_tlm_id
          || ' TO TLM ID: '
          || pnew_tlm_id ||v_Detail
         );
      
         
   END tlm_id_change;

   FUNCTION tlm_id_can_change (pold_tlm_id IN VARCHAR2, pnew_tlm_id IN VARCHAR2)
      RETURN NUMBER
   IS
      vcount   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_analysis a INNER JOIN tlm_well_test_analysis b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.period_type = b.period_type
           AND a.period_obs_no = b.period_obs_no
           AND a.analysis_obs_no = b.analysis_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_contaminant a INNER JOIN tlm_well_test_contaminant b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.recovery_obs_no = b.recovery_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_cushion a INNER JOIN tlm_well_test_cushion b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.cushion_obs_no = b.cushion_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_equipment a INNER JOIN tlm_well_test_equipment b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.test_num = b.test_num
           AND a.equipment_type = b.equipment_type
           AND a.equip_obs_no = b.equip_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_flow a INNER JOIN tlm_well_test_flow b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.period_type = b.period_type
           AND a.period_obs_no = b.period_obs_no
           AND a.fluid_type = b.fluid_type
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_flow_meas a INNER JOIN tlm_well_test_flow_meas b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.measurement_obs_no = b.measurement_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_mud a INNER JOIN tlm_well_test_mud b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.mud_type = b.mud_type
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_period a INNER JOIN tlm_well_test_period b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.period_type = b.period_type
           AND a.period_obs_no = b.period_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_press_meas a INNER JOIN tlm_well_test_press_meas b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.measurement_obs_no = b.measurement_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_pressure a INNER JOIN tlm_well_test_pressure b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.period_type = b.period_type
           AND a.period_obs_no = b.period_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_recorder a INNER JOIN tlm_well_test_recorder b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.recorder_id = b.recorder_id
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_recovery a INNER JOIN tlm_well_test_recovery b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.recovery_obs_no = b.recovery_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      SELECT COUNT (*)
        INTO vcount
        FROM tlm_well_test_remark a INNER JOIN tlm_well_test_remark b
             ON a.SOURCE = b.SOURCE
           AND a.test_type = b.test_type
           AND a.run_num = b.run_num
           AND a.test_num = b.test_num
           AND a.remark_obs_no = b.remark_obs_no
           AND a.uwi = pold_tlm_id
           AND b.uwi = pnew_tlm_id
             ;

      IF vcount > 0
      THEN
         RETURN 0;                -- can not move data, primary key vialotion
      END IF;

      RETURN 1;                                -- can move data, no vialations
   END;
END well_test_api;
--  Give permission to the WIM Gateway