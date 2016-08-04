DROP VIEW IHS_CDN_WELL_TEST_QUALITY;

/* Formatted on 11/06/2013 8:28:20 AM (QP5 v5.227.12220.39754) */
CREATE OR REPLACE FORCE VIEW IHS_CDN_WELL_TEST_QUALITY
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
         wv.uwi,
          wv.source,
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
     FROM well_test_quality@c_talisman_ihsdata wtq, well_version wv
    WHERE     wv.ipl_uwi_local = wtq.uwi
          AND wv.SOURCE = '300IPL'
          AND wv.active_ind = 'Y';


GRANT SELECT ON IHS_CDN_WELL_TEST_QUALITY TO PPDM_RO;

select * from IHS_CDN_WELL_TEST_QUALITY;
select * from well_test_quality;