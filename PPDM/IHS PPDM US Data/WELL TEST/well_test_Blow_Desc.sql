DROP VIEW WELL_TEST_BLOW_DESC;

/* Formatted on 11/06/2013 8:32:12 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW WELL_TEST_BLOW_DESC
(
   UWI,
   SOURCE,
   TEST_TYPE,
   TEST_NUM,
   BLOW_OBS_NUM,
   BLOW_DESCRIPTION,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE,
   RUN_NUM,
   ACTIVE_IND
)
AS


   SELECT /*+ RULE */
          uwi,
          wtbd.SOURCE,
          wtbd.test_type,
          wtbd.test_num,
          wtbd.blow_obs_num,
          wtbd.blow_description,
          wtbd.row_changed_by,
          wtbd.row_changed_date,
          wtbd.row_created_by,
          wtbd.row_created_date,
          wtbd.row_quality,
          wtbd.province_state,
          wtbd.run_num,
          wtbd.active_ind
     FROM TLM_well_test_blow_desc wtbd
    WHERE  active_ind = 'Y'
UNION ALL
   SELECT /*+ RULE */
         uwi,
          wtbd.SOURCE,
          wtbd.test_type,
          wtbd.test_num,
          wtbd.blow_obs_num,
          wtbd.blow_description,
          wtbd.row_changed_by,
          wtbd.row_changed_date,
          wtbd.row_created_by,
          wtbd.row_created_date,
          wtbd.row_quality,
          wtbd.province_state,
          wtbd.run_num,
          wtbd.active_ind
     FROM ihs_cdn_well_test_blow_desc wtbd;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_BLOW_DESC FOR WELL_TEST_BLOW_DESC;


CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_BLOW_DESC FOR WELL_TEST_BLOW_DESC;


CREATE OR REPLACE SYNONYM WTBD FOR WELL_TEST_BLOW_DESC;

GRANT SELECT ON WELL_TEST_BLOW_DESC TO PPDM_RO;
