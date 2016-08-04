DROP VIEW PPDM.IHS_US_WELL_DIR_SRVY;

/* Formatted on 11/6/2012 1:22:49 PM (QP5 v5.185.11230.41888) */
CREATE OR REPLACE FORCE VIEW PPDM.IHS_US_WELL_DIR_SRVY
(
   UWI,
   SURVEY_ID,
   SOURCE,
   ACTIVE_IND,
   AZIMUTH_NORTH_TYPE,
   BASE_DEPTH,
   BASE_DEPTH_OUOM,
   COMPUTE_METHOD,
   COORD_SYSTEM_ID,
   DIR_SURVEY_CLASS,
   EFFECTIVE_DATE,
   EW_DIRECTION,
   EXPIRY_DATE,
   MAGNETIC_DECLINATION,
   OFFSET_NORTH_TYPE,
   PLANE_OF_PROPOSAL,
   PPDM_GUID,
   RECORD_MODE,
   REMARK,
   REPORT_APD,
   REPORT_LOG_DATUM,
   REPORT_LOG_DATUM_ELEV,
   REPORT_LOG_DATUM_ELEV_OUOM,
   REPORT_PERM_DATUM,
   REPORT_PERM_DATUM_ELEV,
   REPORT_PERM_DATUM_ELEV_OUOM,
   SOURCE_DOCUMENT,
   SURVEY_COMPANY,
   SURVEY_DATE,
   SURVEY_NUMERIC_ID,
   SURVEY_QUALITY,
   SURVEY_TYPE,
   TOP_DEPTH,
   TOP_DEPTH_OUOM,
   ROW_CHANGED_BY,
   ROW_CHANGED_DATE,
   ROW_CREATED_BY,
   ROW_CREATED_DATE,
   ROW_QUALITY,
   PROVINCE_STATE
)
AS
   SELECT wv.UWI,
          ppdm_admin.tlm_util.prefix_zeros(WDS.survey_id),
          wv.SOURCE,
          WDS.active_ind,
          WDS.azimuth_north_type,
          WDS.base_depth,
          WDS.base_depth_ouom,
          WDS.compute_method,
          ppdm_admin.tlm_util.Get_coord_System_ID(wds.coord_system_id),
          WDS.dir_survey_class,
          WDS.effective_date,
          WDS.ew_direction,
          WDS.expiry_date,
          WDS.magnetic_declination,
          WDS.offset_north_type,
          WDS.plane_of_proposal,
          WDS.ppdm_guid,
          WDS.record_mode,
          WDS.remark,
          WDS.report_apd,
          WDS.report_log_datum,
          WDS.report_log_datum_elev,
          WDS.report_log_datum_elev_ouom,
          WDS.report_perm_datum,
          WDS.report_perm_datum_elev,
          WDS.report_perm_datum_elev_ouom,
          WDS.source_document,
          WDS.survey_company,
          WDS.survey_date,
          WDS.survey_numeric_id,
          WDS.survey_quality,
          WDS.survey_type,
          WDS.top_depth,
          WDS.top_depth_ouom,
          WDS.row_changed_by,
          WDS.row_changed_date,
          WDS.row_created_by,
          WDS.row_created_date,
          WDS.row_quality,
          WDS.province_state
     FROM well_dir_srvy@C_TALISMAN_US_IHSDATAQ wds, well_version wv
    WHERE     wv.well_num = wds.uwi
          AND wv.SOURCE = '450PID'
          AND wv.active_ind = 'Y';

DROP SYNONYM SPATIAL.IHS_US_WELL_DIR_SRVY;

CREATE OR REPLACE SYNONYM SPATIAL.IHS_US_WELL_DIR_SRVY FOR PPDM.IHS_US_WELL_DIR_SRVY;

GRANT SELECT ON PPDM.IHS_US_WELL_DIR_SRVY TO PPDM_RO;

GRANT SELECT ON PPDM.IHS_US_WELL_DIR_SRVY TO SPATIAL;
