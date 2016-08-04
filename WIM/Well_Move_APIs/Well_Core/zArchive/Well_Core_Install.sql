{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fmodern Courier;}{\f1\fswiss\fcharset0 Arial;}}
{\colortbl ;\red0\green0\blue255;\red255\green255\blue255;\red0\green0\blue0;\red128\green128\blue0;\red0\green128\blue0;\red255\green0\blue0;\red128\green0\blue0;}
{\*\generator Msftedit 5.41.21.2509;}\viewkind4\uc1\pard\cf1\highlight2\f0\fs20 CREATE\cf3  \cf1 OR\cf3  \cf1 REPLACE\cf3  \cf1 PACKAGE\cf3  PPDM_ADMIN\cf1 .\cf4 well_core_api\cf3\par
\cf1 IS\cf3\par
\cf5\i -- SCRIPT: PPDM_ADMIN.well_core_api pks\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- PURPOSE:\cf3\i0\par
\cf5\i -- Package specification for the PPDM_ADMIN.well_core_api functionality\cf3\i0\par
\cf5\i -- \cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- Procedure/Function Summary\cf3\i0\par
\cf5\i -- tlm_id_change Move data in TLM_WELL_CORE table\cf3\i0\par
\cf5\i -- tlm_id_can_change Check if moving data in TLM_WELL_CORE might cause any constraint violation\cf3\i0\par
 \par
\cf5\i -- DEPENDENCIES\cf3\i0\par
\cf5\i -- TLM_WELL_CORE\cf3\i0\par
\par
\cf5\i --\cf3\i0\par
\cf5\i -- EXECUTION:\cf3\i0\par
\cf5\i -- Used by WIM.EXTERNAL_DEPENDENCIES.WELL_MOVE procedure\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- Syntax:\cf3\i0\par
\cf5\i -- \cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- HISTORY:\cf3\i0\par
\cf5\i -- 0.1 10-Jan-12 V.Rajpoot Initial version\cf3\i0\par
\par
\par
 \cf5\i -- PPDM_ADMIN.PDEN_VOL_API to enable changes to be made to the TLM_well_core data\cf3\i0\par
   \cf5\i -- other than through the GUI\cf3\i0\par
\par
   \cf5\i --  Reassign items in the TLM_WELL_CORE  tables to a new TLM Well ID.\cf3\i0\par
   \cf5\i --  Used when wells are merged or split to ensure well core data is linked\cf3\i0\par
   \cf5\i --  to the correct TLM IDs.\cf3\i0\par
   \cf5\i --\cf3\i0\par
   \cf5\i --  Procedure does not COMMIT the change to allow caller to apply\cf3\i0\par
   \cf5\i --  as part of wider transaction.\cf3\i0\par
   \cf5\i --\cf3\i0\par
   \cf1 PROCEDURE\cf3  tlm_id_change \cf1 (\cf3 pold_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 ,\cf3  pnew_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 );\cf3\par
\par
   \cf1 FUNCTION\cf3  tlm_id_can_change \cf1 (\cf3\par
      pold_tlm_id   \cf1 IN\cf3    \cf6 VARCHAR2\cf1 ,\cf3\par
      pnew_tlm_id   \cf1 IN\cf3    \cf6 VARCHAR2\cf3\par
   \cf1 )\cf3\par
      \cf1 RETURN\cf3  \cf6 NUMBER\cf1 ;\cf3\par
\cf1 END;\cf3\par
\cf1 /\par
\par
CREATE\cf3  \cf1 OR\cf3  \cf1 REPLACE\cf3  \cf1 PACKAGE\cf3  \cf1 BODY\cf3  PPDM_ADMIN\cf1 .\cf4 WELL_CORE_API\cf3\par
\cf1 IS\cf3\par
\cf5\i -- SCRIPT: PPDM_ADMIN.WELL_CORE_api.pkb\cf3\i0\par
\cf5\i --\cf3\i0\par
\cf5\i -- PURPOSE:\cf3\i0\par
\cf5\i --   Package body for the PPDM_AMDIN.pden_vol_api functionality\cf3\i0\par
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
\cf5\i --   0.1    10-Jan-12  V.Rajpoot    Initial version\cf3\i0\par
\par
   \cf1 PROCEDURE\cf3  tlm_id_change \cf1 (\cf3 pold_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 ,\cf3  pnew_tlm_id \cf1 IN\cf3  \cf6 VARCHAR2\cf1 )\cf3\par
   \cf1 IS\cf3\par
   \par
   v_detail \cf6 varchar2\cf1 (\cf7 2000\cf1 );\cf3\par
  \par
   \par
   \cf1 BEGIN\cf3\par
      \cf5\i --  Reassign any Information Items to the new TLM ID\cf3\i0\par
 \par
     \par
     \par
     \cf5\i --Add a new record to parent tables first, so child record can be modified     \cf3\i0\par
     \cf1 Insert\cf3  \cf1 into\cf3  TLM_WELL_CORE\par
      \cf1 (Select\cf3  pnew_tlm_id\cf1 ,\cf3  \cf1 source,\cf3  core_id\cf1 ,\cf3  active_ind\cf1 ,\cf3  analysis_report\cf1 ,\cf3  base_depth\cf1 ,\cf3  base_depth_ouom\cf1 ,\cf3  contractor\cf1 ,\cf3  core_barrel_size\cf1 ,\cf3  core_barrel_size_ouom\cf1 ,\cf3\par
              core_diameter\cf1 ,\cf3 core_diameter_ouom\cf1 ,\cf3  core_handling_type\cf1 ,\cf3  core_oriented_ind\cf1 ,\cf3  core_show_type\cf1 ,\cf3  core_type\cf1 ,\cf3  coring_fluid\cf1 ,\cf3  digit_avail_ind\cf1 ,\cf3               \par
              effectivE_date\cf1 ,\cf3  expiry_date\cf1 ,\cf3  gamma_correlation_ind\cf1 ,\cf3  operation_seq_no\cf1 ,\cf3  ppdm_guid\cf1 ,\cf3  primary_core_strat_unit_id\cf1 ,\cf3  \par
              recovered_amount\cf1 ,\cf3  recovered_amount_ouom\cf1 ,\cf3  recovered_amount_uom\cf1 ,\cf3  recovery_date\cf1 ,\cf3\par
              \cf1 remark,\cf3  reported_core_num\cf1 ,\cf3  run_num\cf1 ,\cf3  shot_recovered_count\cf1 ,\cf3  sidewall_ind\cf1 ,\cf3  strat_name_set_id\cf1 ,\cf3  top_depth\cf1 ,\cf3  top_depth_ouom\cf1 ,\cf3\par
              total_shot_count\cf1 ,\cf3    \par
              row_changed_by\cf1 ,\cf3  row_changed_date\cf1 ,\cf3  row_created_by\cf1 ,\cf3  row_created_date\cf1 ,\cf3\par
              row_quality  \cf1 from\cf3  TLM_WELL_CORE \cf1 Where\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 );\cf3\par
      \par
       v_detail \cf1 :=\cf3  \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_CORE records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
       \par
      \cf1 Insert\cf3  \cf1 into\cf3  WELL_CORE_ANALYSIS\par
      \cf1 (Select\cf3  pnew_tlm_id\cf1 ,\cf3  \cf1 source,\cf3  core_id\cf1 ,\cf3  analysis_obs_no\cf1 ,\cf3  active_ind\cf1 ,\cf3  analysis_date\cf1 ,\cf3  analyzing_company\cf1 ,\cf3  analyzing_company_loc\cf1 ,\cf3  analyzing_file_num\cf1 ,\cf3  \par
              core_analyst_name\cf1 ,\cf3\par
              effectivE_date\cf1 ,\cf3  expiry_date\cf1 ,\cf3  ppdm_guid\cf1 ,\cf3  primary_sample_type\cf1 ,\cf3  \cf1 remark,\cf3   sample_diameter\cf1 ,\cf3  sample_diameter_ouom\cf1 ,\cf3  sample_length\cf1 ,\cf3  sample_length_ouom\cf1 ,\cf3\par
              sample_shape\cf1 ,\cf3  second_sample_type\cf1 ,\cf3  row_changed_by\cf1 ,\cf3  row_changed_date\cf1 ,\cf3  row_created_by\cf1 ,\cf3  row_created_date\cf1 ,\cf3\par
              row_quality \cf1 from\cf3  WELL_CORE_ANALYSIS \cf1 Where\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 );\cf3\par
   \par
    v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' WELL_CORE_ANALYSIS records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
    \par
    \cf1 Insert\cf3  \cf1 into\cf3  TLM_WELL_CORE_SAMPLE_ANAL\par
      \cf1 (Select\cf3  pnew_tlm_id\cf1 ,\cf3  \cf1 source,\cf3  core_id\cf1 ,\cf3  analysis_obs_no\cf1 ,\cf3  sample_num\cf1 ,\cf3  sample_analysis_obs_no\cf1 ,\cf3  active_ind\cf1 ,\cf3  bulk_density\cf1 ,\cf3  bulk_density_ouom\cf1 ,\cf3\par
              bulk_mass_oil_sat\cf1 ,\cf3  bulk_mass_oil_sat_ouom\cf1 ,\cf3  bulk_mass_sand_sat\cf1 ,\cf3 bulk_mass_sand_sat_ouom\cf1 ,\cf3  bulk_mass_water_sat\cf1 ,\cf3  bulk_mass_water_sat_ouom\cf1 ,\cf3\par
              bulk_volume_oil_sat\cf1 ,\cf3  bulk_volume_water_sat\cf1 ,\cf3  confine_perm_pressure\cf1 ,\cf3  confine_perm_pressure_ouom\cf1 ,\cf3  confine_por_pressure\cf1 ,\cf3\par
              confine_por_pressure_ouom\cf1 ,\cf3  confine_sat_pressure\cf1 ,\cf3  confine_sat_pressure_ouom\cf1 ,\cf3  effective_date\cf1 ,\cf3  effective_porosity\cf1 ,\cf3  expiry_date\cf1 ,\cf3\par
              gas_sat_volume\cf1 ,\cf3  grain_density\cf1 ,\cf3  grain_density_ouom\cf1 ,\cf3  grain_mass_oil_sat\cf1 ,\cf3  grain_mass_oil_sat_ouom\cf1 ,\cf3  grain_mass_water_sat\cf1 ,\cf3\par
              grain_mass_water_sat_ouom\cf1 ,\cf3  interval_depth\cf1 ,\cf3  interval_depth_ouom\cf1 ,\cf3  interval_length\cf1 ,\cf3  interval_length_ouom\cf1 ,\cf3  k90\cf1 ,\cf3  k90_ouom\cf1 ,\cf3\par
              k90_qualifier\cf1 ,\cf3  kmax\cf1 ,\cf3  kmax_ouom\cf1 ,\cf3  kmax_qualifier\cf1 ,\cf3  kvert\cf1 ,\cf3  kvert_ouom\cf1 ,\cf3  kvert_qualifier\cf1 ,\cf3  oil_sat\cf1 ,\cf3  pore_volume_gas_sat\cf1 ,\cf3\par
              pore_volume_oil_sat\cf1 ,\cf3  pore_volume_water_sat\cf1 ,\cf3  porosity\cf1 ,\cf3  ppdm_guid\cf1 ,\cf3  \cf1 remark,\cf3   top_depth\cf1 ,\cf3  top_depth_ouom\cf1 ,\cf3\par
              water_sat\cf1 ,\cf3  row_changed_by\cf1 ,\cf3  row_changed_date\cf1 ,\cf3  row_created_by\cf1 ,\cf3  row_created_date\cf1 ,\cf3\par
              row_quality \cf1 from\cf3  TLM_WELL_CORE_SAMPLE_ANAL \cf1 Where\cf3  uwi \cf1 =\cf3  pold_tlm_id\cf1 );\cf3\par
      \par
      v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_CORE_SAMPLE_ANAL records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
      \par
\par
      \cf1 UPDATE\cf3  TLM_WELL_CORE_SAMPLE_DESC\par
         \cf1 SET\cf3  UWI \cf1 =\cf3  PNEW_TLM_ID\par
       \cf1 WHERE\cf3  UWI \cf1 =\cf3  POLD_TLM_ID\cf1 ;\cf3\par
           \par
      v_detail \cf1 :=\cf3  v_detail || \cf1 chr(\cf7 10\cf1 )\cf3  || \cf1 SQL\cf3 %\cf1 ROWCOUNT\cf3  || \cf6 ' TLM_WELL_CORE_SAMPLE_DESC records moved from TLM ID: '\cf3  || pold_tlm_id || \cf6 ' TO TLM ID: '\cf3 || pnew_tlm_id\cf1 ;\cf3\par
    \par
       \cf1 DELETE\cf3  \cf1 FROM\cf3  TLM_WELL_CORE_SAMPLE_ANAL\par
       \cf1 WHERE\cf3  UWI \cf1 =\cf3  POLD_TLM_ID\cf1 ;\cf3\par
     \par
      \cf1 DELETE\cf3  \cf1 FROM\cf3  WELL_CORE_ANALYSIS\par
       \cf1 WHERE\cf3  UWI \cf1 =\cf3  POLD_TLM_ID\cf1 ;\cf3\par
    \par
      \cf1 DELETE\cf3  \cf1 FROM\cf3  TLM_WELL_CORE\par
       \cf1 WHERE\cf3  UWI \cf1 =\cf3  POLD_TLM_ID\cf1 ;\cf3\par
          \par
     \par
          \par
        \cf5\i -- Log the changes\cf3\i0\par
      \cf4 tlm_process_logger\cf1 .\cf3 info\par
         \cf1 (\cf3    \cf6 'PPDM_ADMIN.WELL_CORE_API.TLM_ID_CHANGE: Well records moved from TLM ID: '\cf3\par
          || pold_tlm_id\par
          || \cf6 ' TO TLM ID: '\cf3\par
          || pnew_tlm_id || v_detail\par
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
   \par
\par
      \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  TLM_WELL_CORE \cf1 A\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  TLM_WELL_CORE B\par
             \cf1 ON\cf3  \cf1 A.SOURCE\cf3  \cf1 =\cf3  B\cf1 .SOURCE\cf3\par
            \cf1 AND\cf3  \cf1 A.\cf3 UWI \cf1 =\cf3  POLD_TLM_ID\par
            \cf1 AND\cf3  B\cf1 .\cf3 UWI \cf1 =\cf3  PNEW_TLM_ID\par
            \cf1 AND\cf3  \cf1 A.\cf3 CORE_ID \cf1 =\cf3  B\cf1 .\cf3 CORE_ID\cf1 ;\cf3\par
            \par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key violation\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
           \cf1 SELECT\cf3  \cf1 COUNT\cf3  \cf1 (\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  vcount\par
        \cf1 FROM\cf3  WELL_CORE_ANALYSIS \cf1 A\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  WELL_CORE_ANALYSIS B\par
             \cf1 ON\cf3  \cf1 A.SOURCE\cf3  \cf1 =\cf3  B\cf1 .SOURCE\cf3\par
            \cf1 AND\cf3  \cf1 A.\cf3 UWI \cf1 =\cf3  POLD_TLM_ID\par
            \cf1 AND\cf3  B\cf1 .\cf3 UWI \cf1 =\cf3  PNEW_TLM_ID\par
            \cf1 AND\cf3  \cf1 A.\cf3 CORE_ID \cf1 =\cf3  B\cf1 .\cf3 CORE_ID\par
            \cf1 AND\cf3  \cf1 A.\cf3 ANALYSIS_OBS_NO \cf1 =\cf3  B\cf1 .\cf3 ANALYSIS_OBS_NO\cf1 ;\cf3\par
            \par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key violation\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
      \cf1 SELECT\cf3  \cf1 COUNT(\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  VCOUNT\par
        \cf1 FROM\cf3  TLM_WELL_CORE_SAMPLE_ANAL \cf1 A\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  TLM_WELL_CORE_SAMPLE_ANAL B\par
          \cf1 ON\cf3  \cf1 A.SOURCE\cf3  \cf1 =\cf3  B\cf1 .SOURCE\cf3\par
         \cf1 AND\cf3  \cf1 A.\cf3 CORE_ID \cf1 =\cf3  B\cf1 .\cf3 CORE_ID\par
         \cf1 AND\cf3  \cf1 A.\cf3 ANALYSIS_OBS_NO \cf1 =\cf3  B\cf1 .\cf3 ANALYSIS_OBS_NO\par
         \cf1 AND\cf3  \cf1 A.\cf3 SAMPLE_NUM \cf1 =\cf3  B\cf1 .\cf3 SAMPLE_NUM\par
         \cf1 AND\cf3  \cf1 A.\cf3 SAMPLE_ANALYSIS_OBS_NO \cf1 =\cf3  B\cf1 .\cf3 SAMPLE_ANALYSIS_OBS_NO\par
         \cf1 AND\cf3  \cf1 A.\cf3 UWI \cf1 =\cf3  pold_tlm_id\par
         \cf1 and\cf3  B\cf1 .\cf3 UWI \cf1 =\cf3  pnew_tlm_id\cf1 ;\cf3  \par
      \par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key violation\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
\par
      \par
     \cf1 SELECT\cf3  \cf1 COUNT(\cf3 *\cf1 )\cf3\par
        \cf1 INTO\cf3  VCOUNT\par
        \cf1 FROM\cf3  TLM_WELL_CORE_SAMPLE_DESC \cf1 A\cf3  \cf1 INNER\cf3  \cf1 JOIN\cf3  TLM_WELL_CORE_SAMPLE_DESC B\par
          \cf1 ON\cf3  \cf1 A.SOURCE\cf3  \cf1 =\cf3  B\cf1 .SOURCE\cf3\par
         \cf1 AND\cf3  \cf1 A.\cf3 CORE_ID \cf1 =\cf3  B\cf1 .\cf3 CORE_ID\par
         \cf1 AND\cf3  \cf1 A.\cf3 ANALYSIS_OBS_NO \cf1 =\cf3  B\cf1 .\cf3 ANALYSIS_OBS_NO\par
         \cf1 AND\cf3  \cf1 A.\cf3 SAMPLE_NUM \cf1 =\cf3  B\cf1 .\cf3 SAMPLE_NUM\par
         \cf1 AND\cf3  \cf1 A.\cf3 SAMPLE_ANALYSIS_OBS_NO \cf1 =\cf3  B\cf1 .\cf3 SAMPLE_ANALYSIS_OBS_NO\par
         \cf1 AND\cf3  \cf1 A.\cf3 SAMPLE_DESC_OBS_NO \cf1 =\cf3  B\cf1 .\cf3 SAMPLE_DESC_OBS_NO\par
         \cf1 AND\cf3  \cf1 A.\cf3 UWI \cf1 =\cf3  pold_tlm_id\par
         \cf1 and\cf3  B\cf1 .\cf3 UWI \cf1 =\cf3  pnew_tlm_id\cf1 ;\cf3  \par
      \par
      \cf1 IF\cf3  vcount \cf1 >\cf3  \cf7 0\cf3\par
      \cf1 THEN\cf3\par
         \cf1 RETURN\cf3  \cf7 0\cf1 ;\cf3                 \cf5\i -- can not move data, primary key violation\cf3\i0\par
      \cf1 END\cf3  \cf1 IF;\cf3\par
      \par
      \par
      \cf1 RETURN\cf3  \cf7 1\cf1 ;\cf3                                 \cf5\i -- can move data, no violations\cf3\i0\par
      \par
   \cf1 END;\cf3\par
   \par
\cf1 END\cf3  \cf4 WELL_CORE_API\cf1 ;\cf3\par
\cf5\i --  Give permission to the WIM Gateway\cf3\i0\par
\cf1 /\cf0\highlight0\f1\par
}
 