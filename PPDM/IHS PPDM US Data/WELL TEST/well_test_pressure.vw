DROP VIEW PPDM.WELL_TEST_PRESSURE;

/* Formatted on 4/2/2013 11:41:05 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_TEST_PRESSURE
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   PERIOD_TYPE,
   PERIOD_OBS_NO,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   END_PRESSURE,
   END_PRESSURE_OUOM,
   EXPIRY_DATE,
   PPDM_GUID,
   QUALITY_CODE,
   RECORDER_ID,
   REMARK,
   START_PRESSURE,
   START_PRESSURE_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT "UWI",
          "SOURCE",
          "TEST_TYPE",
          "RUN_NUM",
          "TEST_NUM",
          "PERIOD_TYPE",
          "PERIOD_OBS_NO",
          "ACTIVE_IND",
          "EFFECTIVE_DATE",
          "END_PRESSURE",
          "END_PRESSURE_OUOM",
          "EXPIRY_DATE",
          "PPDM_GUID",
          "QUALITY_CODE",
          "RECORDER_ID",
          "REMARK",
          "START_PRESSURE",
          "START_PRESSURE_OUOM",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY",
          -- IHS EXTENSIONS
          NULL AS "PROVINCE_STATE"
     FROM tlm_well_test_pressure
   UNION ALL
   SELECT wtpr.uwi,
          wtpr.SOURCE,
          wtpr.test_type,
          wtpr.run_num,
          wtpr.test_num,
          wtpr.period_type,
          wtpr.period_obs_no,
          wtpr.active_ind,
          wtpr.effective_date,
          wtpr.end_pressure,
          wtpr.end_pressure_ouom,
          wtpr.expiry_date,
          wtpr.ppdm_guid,
          wtpr.quality_code,
          wtpr.recorder_id,
          wtpr.remark,
          wtpr.start_pressure,
          wtpr.start_pressure_ouom,
          wtpr.row_changed_by,
          wtpr.row_changed_date,
          wtpr.row_created_by,
          wtpr.row_created_date,
          wtpr.row_quality,
          -- IHS EXTENSIONS
          wtpr.province_state
     FROM IHS_CDN_WELL_TEST_PRESSURE wtpr
   UNION ALL
   SELECT iuwtp.uwi,
          iuwtp.SOURCE,
          iuwtp.test_type,
          iuwtp.run_num,
          iuwtp.test_num,
          iuwtp.period_type,
          iuwtp.period_obs_no,
          iuwtp.active_ind,
          iuwtp.effective_date,
          iuwtp.end_pressure,
          iuwtp.end_pressure_ouom,
          iuwtp.expiry_date,
          iuwtp.ppdm_guid,
          iuwtp.quality_code,
          iuwtp.recorder_id,
          iuwtp.remark,
          iuwtp.start_pressure,
          iuwtp.start_pressure_ouom,
          iuwtp.row_changed_by,
          iuwtp.row_changed_date,
          iuwtp.row_created_by,
          iuwtp.row_created_date,
          iuwtp.row_quality,
          -- IHS EXTENSIONS
          iuwtp.province_state
     FROM IHS_US_WELL_TEST_PRESSURE iuwtp;


DROP SYNONYM DATA_FINDER.WELL_TEST_PRESSURE;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_PRESSURE FOR PPDM.WELL_TEST_PRESSURE;


DROP SYNONYM EDIOS_ADMIN.WELL_TEST_PRESSURE;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_PRESSURE FOR PPDM.WELL_TEST_PRESSURE;


DROP SYNONYM PPDM.WTPSR;
CREATE OR REPLACE SYNONYM PPDM.WTPSR FOR PPDM.WELL_TEST_PRESSURE;


GRANT SELECT ON PPDM.WELL_TEST_PRESSURE TO PPDM_RO;
