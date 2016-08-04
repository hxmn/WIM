DROP VIEW PPDM.IHS_US_WELL_TEST_RECOVERY;

/* Formatted on 4/2/2013 11:40:34 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_TEST_RECOVERY
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   RECOVERY_OBS_NO,
   ACTIVE_IND,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   MULTIPLE_TEST_IND,
   PERIOD_OBS_NO,
   PERIOD_TYPE,
   PPDM_GUID,
   RECOVERY_AMOUNT,
   RECOVERY_AMOUNT_OUOM,
   RECOVERY_AMOUNT_PERCENT,
   RECOVERY_AMOUNT_UOM,
   RECOVERY_DESC,
   RECOVERY_METHOD,
   RECOVERY_SHOW_TYPE,
   RECOVERY_TYPE,
   REMARK,
   REVERSE_CIRCULATION_IND,
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
          wtrv.test_type,
          wtrv.run_num,
          wtrv.test_num,
          wtrv.recovery_obs_no,
          wtrv.active_ind,
          wtrv.effective_date,
          wtrv.expiry_date,
          wtrv.multiple_test_ind,
          wtrv.period_obs_no,
          wtrv.period_type,
          wtrv.ppdm_guid,
          wtrv.recovery_amount,
          wtrv.recovery_amount_ouom,
          wtrv.recovery_amount_percent,
          wtrv.recovery_amount_uom,
          wtrv.recovery_desc,
          wtrv.recovery_method,
          wtrv.recovery_show_type,
          wtrv.recovery_type,
          wtrv.remark,
          wtrv.reverse_circulation_ind,
          wtrv.row_changed_by,
          wtrv.row_changed_date,
          wtrv.row_created_by,
          wtrv.row_created_date,
          wtrv.row_quality,
          wtrv.province_state
     FROM well_test_recovery@C_TALISMAN_US_IHSDATAQ wtrv, well_version wv
    WHERE     wv.well_num = wtrv.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_TEST_RECOVERY TO PPDM_RO;
