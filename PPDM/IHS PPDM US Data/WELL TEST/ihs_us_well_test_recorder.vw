DROP VIEW PPDM.IHS_US_WELL_TEST_RECORDER;

/* Formatted on 4/2/2013 11:40:33 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_TEST_RECORDER
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   RECORDER_ID,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   MAX_CAPACITY_PRESSURE,
   MAX_CAPACITY_PRESSURE_OUOM,
   MAX_CAPACITY_TEMP,
   MAX_CAPACITY_TEMP_OUOM,
   PERFORMANCE_QUALITY,
   PPDM_GUID,
   RECORDER_DEPTH,
   RECORDER_DEPTH_OUOM,
   RECORDER_INSIDE_IND,
   RECORDER_MAX_TEMP,
   RECORDER_MAX_TEMP_OUOM,
   RECORDER_MIN_TEMP,
   RECORDER_MIN_TEMP_OUOM,
   RECORDER_POSITION,
   RECORDER_RESOLUTION,
   RECORDER_RESOLUTION_OUOM,
   RECORDER_TYPE,
   RECORDER_USED_IND,
   REMARK,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT WV.UWI,
          wv.SOURCE,
          wtrec.test_type,
          wtrec.run_num,
          wtrec.test_num,
          wtrec.recorder_id,
          wtrec.active_ind,
          wtrec.effective_date,
          wtrec.expiry_date,
          wtrec.max_capacity_pressure,
          wtrec.max_capacity_pressure_ouom,
          wtrec.max_capacity_temp,
          wtrec.max_capacity_temp_ouom,
          wtrec.performance_quality,
          wtrec.ppdm_guid,
          wtrec.recorder_depth*.3048,
          'FT' AS "recorder_depth_ouom",
          wtrec.recorder_inside_ind,
          wtrec.recorder_max_temp,
          wtrec.recorder_max_temp_ouom,
          wtrec.recorder_min_temp,
          wtrec.recorder_min_temp_ouom,
          wtrec.recorder_position,
          wtrec.recorder_resolution,
          wtrec.recorder_resolution_ouom,
          wtrec.recorder_type,
          wtrec.recorder_used_ind,
          wtrec.remark,
          wtrec.row_changed_by,
          wtrec.row_changed_date,
          wtrec.row_created_by,
          wtrec.row_created_date,
          wtrec.row_quality,
          wtrec.province_state
     FROM well_test_recorder@C_TALISMAN_US_IHSDATAQ wtrec, well_version wv
    WHERE     wv.well_num = wtrec.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_TEST_RECORDER TO PPDM_RO;