DROP VIEW PPDM.WELL_TEST_REMARK;

/* Formatted on 11/14/2012 8:07:01 AM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.WELL_TEST_REMARK
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
   SELECT "UWI",
          "SOURCE",
          "TEST_TYPE",
          "RUN_NUM",
          "TEST_NUM",
          "REMARK_OBS_NO",
          "ACTIVE_IND",
          "EFFECTIVE_DATE",
          "EXPIRY_DATE",
          "PPDM_GUID",
          "REMARK",
          "REMARK_TYPE",
          "ROW_CHANGED_BY",
          "ROW_CHANGED_DATE",
          "ROW_CREATED_BY",
          "ROW_CREATED_DATE",
          "ROW_QUALITY",
          NULL AS "PROVINCE_STATE"
     FROM tlm_well_test_remark
   UNION ALL
   SELECT wtrmk.uwi,
          wtrmk.SOURCE,
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
          -- IHS extensions
          wtrmk.province_state
     FROM IHS_CDN_WELL_TEST_remark wtrmk
   UNION ALL
   SELECT wtrmk.uwi,
          wtrmk.SOURCE,
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
          -- IHS extensions
          wtrmk.province_state
     FROM IHS_US_WELL_TEST_remark wtrmk;


DROP SYNONYM EDIOS_ADMIN.WELL_TEST_REMARK;

CREATE OR REPLACE SYNONYM EDIOS_ADMIN.WELL_TEST_REMARK FOR PPDM.WELL_TEST_REMARK;


DROP SYNONYM SDP_APPL.WELL_TEST_REMARK;

CREATE OR REPLACE SYNONYM SDP_APPL.WELL_TEST_REMARK FOR PPDM.WELL_TEST_REMARK;


DROP SYNONYM PPDM.WTRM;

CREATE OR REPLACE SYNONYM PPDM.WTRM FOR PPDM.WELL_TEST_REMARK;


DROP SYNONYM DATA_FINDER.WELL_TEST_REMARK;

CREATE OR REPLACE SYNONYM DATA_FINDER.WELL_TEST_REMARK FOR PPDM.WELL_TEST_REMARK;


GRANT SELECT ON PPDM.WELL_TEST_REMARK TO PPDM_RO;
