DROP VIEW IHS_CDN_WELL_TEST_BLOW_DESC;

/* Formatted on 11/06/2013 8:32:12 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW IHS_CDN_WELL_TEST_BLOW_DESC
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
         wv.uwi,
          wv.SOURCE,
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
     FROM well_test_blow_desc@c_talisman_ihsdata wtbd, well_version wv
    WHERE     wv.ipl_uwi_local = wtbd.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';


GRANT SELECT ON IHS_CDN_WELL_TEST_BLOW_DESC TO PPDM_RO;
