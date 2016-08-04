DROP VIEW PPDM.IHS_US_WELL_TEST_REMARK;

/* Formatted on 4/2/2013 11:40:35 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_TEST_REMARK
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   REMARK_OBS_NO,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   REMARK_TYPE,
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
          wtrmk.test_type,
          wtrmk.run_num,
          wtrmk.test_num,
          wtrmk.remark_obs_no,
          wtrmk.active_ind,
          wtrmk.effective_date,
          wtrmk.expiry_date,
          wtrmk.ppdm_guid,
          wtrmk.remark,
          wtrmk.remark_type,
          wtrmk.row_changed_by,
          wtrmk.row_changed_date,
          wtrmk.row_created_by,
          wtrmk.row_created_date,
          wtrmk.row_quality,
          wtrmk.province_state
     FROM well_test_remark@C_TALISMAN_US_IHSDATAQ wtrmk, well_version wv
    WHERE     wv.well_num = wtrmk.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_TEST_REMARK TO PPDM_RO;
