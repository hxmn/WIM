DROP VIEW WELL_TEST_QUALITY;

/* Formatted on 11/06/2013 8:28:20 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW WELL_TEST_QUALITY
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   QUALITY_OBS_NO,
   TEST_RESULT_CODE,
   QUALITY_MISRUN_CODE,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   PROVINCE_STATE,
   ACTIVE_IND
)
AS
 SELECT /*+ RULE */
         uwi,
          wtq.SOURCE,
          wtq.test_type,
          wtq.run_num,
          wtq.test_num,
          wtq.quality_obs_no,
          wtq.test_result_code,
          wtq.quality_misrun_code,
          wtq.row_changed_by,
          wtq.row_changed_date,
          wtq.row_created_by,
          wtq.row_created_date,
          wtq.province_state,
          wtq.active_ind
     FROM tlm_well_test_quality wtq
     where active_ind ='Y'
     union all
   SELECT /*+ RULE */
         wtq.uwi,
          wtq.SOURCE,
          wtq.test_type,
          wtq.run_num,
          wtq.test_num,
          wtq.quality_obs_no,
          wtq.test_result_code,
          wtq.quality_misrun_code,
          wtq.row_changed_by,
          wtq.row_changed_date,
          wtq.row_created_by,
          wtq.row_created_date,
          wtq.province_state,
          wtq.active_ind
     FROM ihs_cdn_well_test_quality wtq;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_QUALITY FOR WELL_TEST_QUALITY;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_QUALITY FOR WELL_TEST_QUALITY;

CREATE OR REPLACE SYNONYM WTQ FOR WELL_TEST_QUALITY;

GRANT SELECT ON WELL_TEST_QUALITY TO PPDM_RO;
