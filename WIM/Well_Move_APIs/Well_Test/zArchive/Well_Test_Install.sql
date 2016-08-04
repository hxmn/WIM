{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fmodern Courier;}{\f1\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red255\green255\blue255;\red0\green0\blue0;\red128\green128\blue0;\red0\green128\blue0;\red255\green0\blue0;\red128\green0\blue0;}
{\*\generator Msftedit 5.41.21.2509;}\viewkind4\uc1\pard\cf1\highlight2\f0\fs20 CREATE\cf3  \cf1 OR\cf3  \cf1 REPLACE\cf3  \cf1 PACKAGE\cf3  PPDM_ADMIN\cf1 .\cf4 WELL_TEST_API\cf3\par
\cf1 IS\cf3\par
\cf5\i -- SCRIPT: PPDM.WELL_TEST_API.pks\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- PURPOSE:\cf3\i0\par
\cf5\i --   Package specification for the  PPDM.WELL_TEST_API functionality\cf3\i0\par
\cf5\i --   \cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i --   Procedure/Function Summary\cf3\i0\par
\cf5\i --      tlm_id_change      Move data in Well test system\cf3\i0\par
\cf5\i --      tlm_id_can_change  Check if moving data in Well Test system might cause any constraint violation\cf3\i0\par
   \par
\cf5\i -- DEPENDENCIES\cf3\i0\par
\cf5\i --  tables:\cf3\i0\par
\cf5\i ----tlm_well_test\cf3\i0\par
\cf5\i ----tlm_well_test_analysis\cf3\i0\par
\cf5\i ----tlm_well_test_blow_desc\cf3\i0\par
\cf5\i ----tlm_well_test_contaminant\cf3\i0\par
\cf5\i ----tlm_well_test_cushion\cf3\i0\par
\cf5\i ----tlm_well_test_equipment\cf3\i0\par
\cf5\i ----tlm_well_test_flow\cf3\i0\par
\cf5\i ----tlm_well_test_flow_meas\cf3\i0\par
\cf5\i ----tlm_well_test_mud\cf3\i0\par
\cf5\i ----tlm_well_test_period\cf3\i0\par
\cf5\i ----tlm_well_test_press_meas\cf3\i0\par
\cf5\i ----tlm_well_test_pressure\cf3\i0\par
\cf5\i ----tlm_well_test_quality\cf3\i0\par
\cf5\i ----tlm_well_test_recorder\cf3\i0\par
\cf5\i ----tlm_well_test_recovery\cf3\i0\par
\cf5\i ----tlm_well_test_remark\cf3\i0\par
\cf5\i ----tlm_well_test_slope\cf3\i0\par
\par
\cf5\i --\cf3\i0\par
\cf5\i -- EXECUTION:\cf3\i0\par
\cf5\i --   Used by  WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE  procedure\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i --   Syntax:\cf3\i0\par
\cf5\i --    \cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- HISTORY:\cf3\i0\par
\cf5\i --   0.1    15-Jan-11  S. Makarov    Initial version\cf3\i0\par
\par
\par
\par
    \cf5\i -- WELL_TEST_API to enable changes to be made to the WELL_TEST data\cf3\i0\par
    \cf5\i -- other than through the GUI\cf3\i0\par
\par
  \par
    \cf5\i --  Reassign items in the WELL_TEST  tables to a new TLM Well ID.\cf3\i0\par
    \cf5\i --  Used when wells are merged or split to ensure WELL_TEST data is linked\cf3\i0\par
    \cf5\i --  to the correct TLM IDs.\cf3\i0\par
    \cf5\i --\cf3\i0\par
    \cf5\i --  Procedure does not COMMIT the change to allow caller to apply\cf3\i0\par
    \cf5\i --  as part of wider transaction.\cf3\i0\par
    \cf5\i --\cf3\i0\par
    \cf1 PROCEDURE\cf3  TLM_ID_CHANGE \cf1 (\cf3\par
        pOld_TLM_ID  \cf1 IN\cf3    \cf6 VARCHAR2\cf1 ,\cf3\par
        pNew_TLM_ID  \cf1 IN\cf3    \cf6 VARCHAR2\cf3\par
    \cf1 );\cf3\par
   \cf1 FUNCTION\cf3  tlm_id_can_change \cf1 (\cf3\par
      pold_tlm_id   \cf1 IN\cf3    \cf6 VARCHAR2\cf1 ,\cf3\par
      pnew_tlm_id   \cf1 IN\cf3    \cf6 VARCHAR2\cf3\par
   \cf1 )\cf3\par
      \cf1 RETURN\cf3  \cf6 NUMBER\cf1 ;\cf3\par
\cf1 END;\cf3\par
\cf1 /\par
\par
CREATE\cf3  \cf1 OR\cf3  \cf1 REPLACE\cf3  \cf1 PACKAGE\cf3  \cf1 BODY\cf3  PPDM_ADMIN\cf1 .\cf4 well_test_api\cf3\par
\cf1 IS\cf3\par
\cf5\i -- SCRIPT: well_test_api.pkb\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- PURPOSE:\cf3\i0\par
\cf5\i --   Package body for the well_test_api functionality\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- DEPENDENCIES\cf3\i0\par
\cf5\i --   See Package Specification\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- EXECUTION:\cf3\i0\par
\cf5\i --   See Package Specification\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i --   Syntax:\cf3\i0\par
\cf5\i --    N/A\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- HISTORY:\cf3\i0\par
\cf5\i -- 0.1 15-Jan-11  S. Makarov    Initial version\cf3\i0\par
\cf5\i -- 0.2 16-Jan-12 V. Rajpoot Added Detail logs (counts) to the TLM_Process_Log\cf3\i0\par
\par
   \cf1 PROCEDURE\cf3  tlm_id_change \cf1 (\cf3 pold_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 ,\cf3  pnew_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 )\cf3\par
   \cf1 IS\cf3\par
   \cf5\i --v_count NUMBER;\cf3\i0\par
   v_detail \cf6 CLOB\cf1 ;\cf3\par
   \par
   \cf1 BEGIN\cf3\par
   \cf5\i --Get the counts\cf3\i0\par
   \par
       \par
    \cf5\i -- Insert a new row to these 2 parent tables first, so the child tables records\cf3\i0\par
    \cf5\i -- can be updated.\cf3\i0\par
    \cf1 INSERT\cf3  \cf1 INTO\cf3  tlm_well_test_period\par
        \cf1 (select\cf3  pnew_tlm_id\cf1 ,\cf3  \cf1 Source,\cf3 Test_Type\cf1 ,\cf3  Run_Num\cf1 ,\cf3 Test_Num\cf1 ,\cf3  Period_Type\cf1 ,\cf3 Period_Obs_No\cf1 ,\cf3\par
                Active_IND\cf1 ,\cf3  Casing_Pressure\cf1 ,\cf3  Casing_Pressure_OUOM\cf1 ,\cf3  Effective_Date\cf1 ,\cf3  Expiry_Date\cf1 ,\cf3\par
                Period_Duration\cf1 ,\cf3  Period_Duration_OUOM\cf1 ,\cf3  PPDM_GUID\cf1 ,\cf3  \cf1 Remark,\cf3  Tubing_Pressure\cf1 ,\cf3  \par
                Tubing_Pressure_OUOM\cf1 ,\cf3  Row_Changed_By\cf1 ,\cf3  Row_Changed_Date\cf1 ,\cf3  Row_Created_By\cf1 ,\cf3  \par
                Row_Created_Date\cf1 ,\cf3  Row_Quality \cf1 from\cf3  tlm_well_test_period \cf1 where\cf3  uwi \cf1 =\cf3  pold_tlm_id \cf1 );\cf3\par
  v_detail \cf1 :=\cf3  \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_PERIOD records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
  \par
 \par
     \cf1 INSERT\cf3  \cf1 INTO\cf3  tlm_well_test_Recorder\par
        \cf1 (select\cf3  pnew_tlm_id\cf1 ,Source,\cf3  Test_Type\cf1 ,\cf3  Run_Num\cf1 ,\cf3  Test_Num\cf1 ,\cf3  Recorder_Id\cf1 ,\cf3  Active_IND\cf1 ,\cf3\par
                Effective_Date\cf1 ,\cf3  Expiry_Date\cf1 ,\cf3  Max_Capacity_Pressure\cf1 ,\cf3  Max_Capacity_Pressure_OUOM\cf1 ,\cf3\par
                Max_Capacity_Temp\cf1 ,\cf3  Max_Capacity_Temp_OUOM\cf1 ,\cf3 Performance_Quality\cf1 ,\cf3  PPDM_GUID\cf1 ,\cf3\par
                Recorder_Depth\cf1 ,\cf3  Recorder_Depth_OUOM\cf1 ,\cf3  Recorder_Inside_IND\cf1 ,\cf3  Recorder_Max_Temp\cf1 ,\cf3\par
                Recorder_Max_Temp_OUOM\cf1 ,\cf3  Recorder_Min_Temp\cf1 ,\cf3  Recorder_Min_Temp_OUOM\cf1 ,\cf3\par
                Recorder_Position\cf1 ,\cf3  Recorder_Resolution\cf1 ,\cf3  Recorder_Resolution_OUOM\cf1 ,\cf3  RECORDER_TYPE\cf1 ,\cf3\par
                Recorder_Used_IND\cf1 ,\cf3  \cf1 Remark,\cf3  Row_Changed_By\cf1 ,\cf3  Row_Changed_Date\cf1 ,\cf3  Row_Created_By\cf1 ,\cf3\par
                Row_Created_Date\cf1 ,\cf3  Row_Quality \cf1 from\cf3  tlm_well_test_recorder \cf1 where\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 );\cf3\par
      v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  ||  \cf6 ' TLM_WELL_TEST_RECORDER records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
             \par
                \par
      \cf5\i --  Reassign any Information Items to the new TLM ID\cf3\i0\par
      \cf1 UPDATE\cf3  tlm_well_test\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
     v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
 \par
\cf5\i --       UPDATE tlm_well_test_period\cf3\i0\par
\cf5\i --         SET uwi = pnew_tlm_id\cf3\i0\par
\cf5\i --       WHERE uwi = pold_tlm_id;\cf3\i0\par
       \par
\par
      \cf1 UPDATE\cf3  tlm_well_test_analysis\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
 v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_ANALYSIS records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
 \par
      \cf1 UPDATE\cf3  tlm_well_test_blow_desc\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
  v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_BLOW_DESC records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
 \par
      \cf1 UPDATE\cf3  tlm_well_test_contaminant\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
   v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_CONTAMINANT records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
 \par
      \cf1 UPDATE\cf3  tlm_well_test_cushion\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
 v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_CUSHION records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
 \par
      \cf1 UPDATE\cf3  tlm_well_test_equipment\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
  v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_EQUIPMENT records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
 \par
      \cf1 UPDATE\cf3  tlm_well_test_flow\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
  v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_FLOW records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
 \par
      \cf1 UPDATE\cf3  tlm_well_test_flow_meas\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
  v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_FLOW_MEAS records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
\par
      \cf1 UPDATE\cf3  TLM_WELL_TEST_MUD\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
  v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_MUD records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
\par
      \cf1 UPDATE\cf3  TLM_WELL_TEST_PRESS_MEAS\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_PRESS_MEAS records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
\par
\par
      \cf1 UPDATE\cf3  tlm_well_test_pressure\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
   v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_PRESSURE records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
\par
      \cf1 UPDATE\cf3  tlm_well_test_quality\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
  v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_QUALITY records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
\par
\cf5\i --      UPDATE tlm_well_test_recorder\cf3\i0\par
\cf5\i --         SET uwi = pnew_tlm_id\cf3\i0\par
\cf5\i --       WHERE uwi = pold_tlm_id;\cf3\i0\par
      \cf1 UPDATE\cf3  tlm_well_test_recovery\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
   v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_RECOVERY records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
  \par
      \cf1 UPDATE\cf3  tlm_well_test_remark\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
 v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_REMARK records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
\par
      \cf1 UPDATE\cf3  tlm_well_test_slope\par
         \cf1 SET\cf3  uwi \cf1 =\cf3  pnew_tlm_id\par
       \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
   v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_TEST_SLOPE records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
\par
       \cf1 DELETE\cf3  \cf1 from\cf3  tlm_well_test_period\par
        \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
        \par
       \cf1 DELETE\cf3  \cf1 from\cf3  tlm_well_test_recorder\par
        \cf1 WHERE\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 ;\cf3\par
\par
      \cf5\i -- Log the changes\cf3\i0\par
      \cf4 tlm_process_logger\cf1 .\cf3 info\par
         \cf1 (\cf3    \cf6 'PPDM_ADMIN.WELL_TEST_API.TLM_ID_CHANGE: Well records moved from TLM ID: '\cf3\par
          || pold_tlm_id\par
          || \cf6 ' TO TLM ID: '\cf3\par
          || pnew_tlm_id ||v_Detail\par
         \cf1 );\cf3\par
      \par
         \par
   \cf1 END\cf3  tlm_id_change\cf1 ;\cf3\par
\par
   \cf1 FUNCTION\cf3  tlm_id_can_change \cf1 (\cf3 pold_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 ,\cf3  pnew_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 )\cf3\par
      \cf1 RETURN\cf3  \cf6 NUMBER\cf3\par
   \cf1 IS\cf3\par
      vcount   \cf6 NUMBER\cf1 ;\cf3\par
   \cf1 BEGIN\cf3\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_analysis \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_analysis b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_type \cf1 =\cf3  b\cf1 .\cf3 period_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_obs_no \cf1 =\cf3  b\cf1 .\cf3 period_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 analysis_obs_no \cf1 =\cf3  b\cf1 .\cf3 analysis_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_contaminant \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_contaminant b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 recovery_obs_no \cf1 =\cf3  b\cf1 .\cf3 recovery_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_cushion \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_cushion b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 cushion_obs_no \cf1 =\cf3  b\cf1 .\cf3 cushion_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_equipment \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_equipment b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 equipment_type \cf1 =\cf3  b\cf1 .\cf3 equipment_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 equip_obs_no \cf1 =\cf3  b\cf1 .\cf3 equip_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_flow \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_flow b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_type \cf1 =\cf3  b\cf1 .\cf3 period_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_obs_no \cf1 =\cf3  b\cf1 .\cf3 period_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 fluid_type \cf1 =\cf3  b\cf1 .\cf3 fluid_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_flow_meas \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_flow_meas b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 measurement_obs_no \cf1 =\cf3  b\cf1 .\cf3 measurement_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_mud \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_mud b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 mud_type \cf1 =\cf3  b\cf1 .\cf3 mud_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_period \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_period b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_type \cf1 =\cf3  b\cf1 .\cf3 period_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_obs_no \cf1 =\cf3  b\cf1 .\cf3 period_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_press_meas \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_press_meas b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 measurement_obs_no \cf1 =\cf3  b\cf1 .\cf3 measurement_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_pressure \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_pressure b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_type \cf1 =\cf3  b\cf1 .\cf3 period_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 period_obs_no \cf1 =\cf3  b\cf1 .\cf3 period_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_recorder \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_recorder b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 recorder_id \cf1 =\cf3  b\cf1 .\cf3 recorder_id\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_recovery \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_recovery b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 recovery_obs_no \cf1 =\cf3  b\cf1 .\cf3 recovery_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  tlm_well_test_remark \cf1 a\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  tlm_well_test_remark b\par
             \cf1 ON\cf3  \cf1 a.SOURCE\cf3  \cf1 =\cf3  b\cf1 .SOURCE\cf3\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_type \cf1 =\cf3  b\cf1 .\cf3 test_type\par
           \cf1 AND\cf3  \cf1 a.\cf3 run_num \cf1 =\cf3  b\cf1 .\cf3 run_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 test_num \cf1 =\cf3  b\cf1 .\cf3 test_num\par
           \cf1 AND\cf3  \cf1 a.\cf3 remark_obs_no \cf1 =\cf3  b\cf1 .\cf3 remark_obs_no\par
           \cf1 AND\cf3  \cf1 a.\cf3 uwi \cf1 =\cf3  pold_tlm_id\par
           \cf1 AND\cf3  b\cf1 .\cf3 uwi \cf1 =\cf3  pnew_tlm_id\par
             \cf1 ;\cf3\par
\par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key vialotion\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \cf1 RETURN\cf3  \cf7 1\cf1 ;\cf3                                 \cf5\i -- can move data, no vialations\cf3\i0\par
   \cf1 END;\cf3\par
\cf1 END\cf3  \cf4 well_test_api\cf1 ;\cf3\par
\cf5\i --  Give permission to the WIM Gateway\cf3\i0\par
\cf1 /\cf0\highlight0\f1\par
}
 