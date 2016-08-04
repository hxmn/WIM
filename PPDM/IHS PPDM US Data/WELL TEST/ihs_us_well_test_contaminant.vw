DROP VIEW PPDM.IHS_US_WELL_TEST_CONTAMINANT;

/* Formatted on 4/2/2013 11:40:27 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_TEST_CONTAMINANT
(
   UWI,
   SOURCE,
   TEST_TYPE,
   RUN_NUM,
   TEST_NUM,
   RECOVERY_OBS_NO,
   CONTAMINANT_SEQ_NO,
   ACTIVE_IND,
   CONTAMINANT_TYPE,
   EFFECTIVE_DATE,
   EXPIRY_DATE,
   PPDM_GUID,
   REMARK,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT wv.uwi,
          wV.SOURCE,
          wc.test_type,
          wc.run_num,
          wc.test_num,
          wc.recovery_obs_no,
          wc.contaminant_seq_no,
          wc.active_ind,
          wc.contaminant_type,
          wc.effective_date,
          wc.expiry_date,
          wc.ppdm_guid,
          wc.remark,
          wc.row_changed_by,
          wc.row_changed_date,
          wc.row_created_by,
          wc.row_created_date,
          wc.row_quality,
          wc.province_state
     FROM well_test_contaminant@C_TALISMAN_US_IHSDATAQ wc, well_version wv
    WHERE     wv.well_num = wc.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';


GRANT SELECT ON PPDM.IHS_US_WELL_TEST_CONTAMINANT TO PPDM_RO;
