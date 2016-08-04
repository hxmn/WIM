DROP VIEW PPDM.WELL_TEST_PERIOD;

/* Formatted on 4/2/2013 11:41:04 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_TEST_PERIOD
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   PERIOD_TYPE,
   PERIOD_OBS_NO,
   ACTIVE_IND,
   CASING_PRESSURE,
   CASING_PRESSURE_OUOM,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PERIOD_DURATION,
   PERIOD_DURATION_OUOM,
   PPDM_GUID,
   REMARK,
   TUBING_PRESSURE,
   TUBING_PRESSURE_OUOM,
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
          "CASING_PRESSURE",
          "CASING_PRESSURE_OUOM",
          "EFFECTIVE_DATE",
          "EXPIRY_DATE",
          "PERIOD_DURATION",
          "PERIOD_DURATION_OUOM",
          "PPDM_GUID",
          "REMARK",
          "TUBING_PRESSURE",
          "TUBING_PRESSURE_OUOM",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY",
          -- IHS EXTENSIONS
          NULL AS "PROVINCE_STATE"
     FROM tlm_well_test_period
   UNION ALL
   SELECT wtp.uwi,
          wtp.SOURCE,
          wtp.test_type,
          wtp.run_num,
          wtp.test_num,
          wtp.period_type,
          wtp.period_obs_no,
          wtp.active_ind,
          wtp.casing_pressure,
          wtp.casing_pressure_ouom,
          wtp.effective_date,
          wtp.expiry_date,
          wtp.period_duration,
          wtp.period_duration_ouom,
          wtp.ppdm_guid,
          wtp.remark,
          wtp.tubing_pressure,
          wtp.tubing_pressure_ouom,
          wtp.row_changed_by,
          wtp.row_changed_date,
          wtp.row_created_by,
          wtp.row_created_date,
          wtp.row_quality,
          wtp.province_state
     FROM IHS_CDN_WELL_TEST_period wtp
   UNION ALL
   SELECT iuwtp.uwi,
          iuwtp.SOURCE,
          iuwtp.test_type,
          iuwtp.run_num,
          iuwtp.test_num,
          iuwtp.period_type,
          iuwtp.period_obs_no,
          iuwtp.active_ind,
          iuwtp.casing_pressure,
          iuwtp.casing_pressure_ouom,
          iuwtp.effective_date,
          iuwtp.expiry_date,
          iuwtp.period_duration,
          iuwtp.period_duration_ouom,
          iuwtp.ppdm_guid,
          iuwtp.remark,
          iuwtp.tubing_pressure,
          iuwtp.tubing_pressure_ouom,
          iuwtp.row_changed_by,
          iuwtp.row_changed_date,
          iuwtp.row_created_by,
          iuwtp.row_created_date,
          iuwtp.row_quality,
          iuwtp.province_state
     FROM IHS_US_WELL_TEST_period iuwtp;


DROP SYNONYM DATA_FINDER.WELL_TEST_PERIOD;
CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_PERIOD FOR PPDM.WELL_TEST_PERIOD;


DROP SYNONYM EDIOS_ADMIN.WELL_TEST_PERIOD;
CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_PERIOD FOR PPDM.WELL_TEST_PERIOD;


DROP SYNONYM PPDM.WTP;
CREATE OR REPLACE SYNONYM PPDM.WTP FOR PPDM.WELL_TEST_PERIOD;



GRANT SELECT ON PPDM.WELL_TEST_PERIOD TO PPDM_RO;
