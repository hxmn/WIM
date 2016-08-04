/***************************************************************************************************

  Combo view to return directional survey header information from Talisman and IHS (Canada and US)

  History
   20141002 cdong       Modify to return only active directional surveys  (TIS Task 1529)
                        This will line up this view with the other dir srvy objects (inventory count, spatial)

 ***************************************************************************************************/

drop view ppdm.well_dir_srvy;


create or replace force view ppdm.well_dir_srvy
(  uwi,
   survey_id,
   source,
   active_ind,
   azimuth_north_type,
   base_depth,
   base_depth_ouom,
   compute_method,
   coord_system_id,
   dir_survey_class,
   effective_date,
   ew_direction,
   expiry_date,
   magnetic_declination,
   offset_north_type,
   plane_of_proposal,
   ppdm_guid,
   record_mode,
   remark,
   report_apd,
   report_log_datum,
   report_log_datum_elev,
   report_log_datum_elev_ouom,
   report_perm_datum,
   report_perm_datum_elev,
   report_perm_datum_elev_ouom,
   source_document,
   survey_company,
   survey_date,
   survey_numeric_id,
   survey_quality,
   survey_type,
   top_depth,
   top_depth_ouom,
   row_changed_by,
   row_changed_date,
   row_created_by,
   row_created_date,
   row_quality,
   province_state,
   x_orig_document
)
as
   select UWI,
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
          PROVINCE_STATE,
          X_ORIG_DOCUMENT
     from tlm_well_dir_srvy tlm
    where tlm.active_ind = 'Y'

  union all
   select UWI,
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
          PROVINCE_STATE,
          X_ORIG_DOCUMENT
     from ihs_cdn_well_dir_srvy ihsc
    where ihsc.active_ind = 'Y'

  union all
   select UWI,
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
          PROVINCE_STATE,
          ' ' as X_ORIG_DOCUMENT
     from ihs_us_well_dir_srvy ihsu
    where ihsu.active_ind = 'Y'
;


------------------------------------------------
-- Grants

grant select on ppdm.well_dir_srvy to ppdm_ro;

grant select on ppdm.well_dir_srvy to dir_srvy_ro;

grant delete, insert, select, update on ppdm.well_dir_srvy to dir_srvy_rw;



------------------------------------------------
-- Synonyms: can be run via ppdm_admin schema

create or replace synonym ppdm.wds                          for ppdm.well_dir_srvy;
create or replace synonym geowiz.well_dir_srvy              for ppdm.well_dir_srvy;
create or replace synonym geowiz_survey.well_dir_srvy       for ppdm.well_dir_srvy;
create or replace synonym sdp.well_dir_srvy                 for ppdm.well_dir_srvy;
create or replace synonym sdp_appl.well_dir_srvy            for ppdm.well_dir_srvy;
create or replace synonym data_finder.well_dir_srvy         for ppdm.well_dir_srvy;
create or replace synonym geowiz_appl.well_dir_srvy         for ppdm.well_dir_srvy;
create or replace synonym geoframe_appl.well_dir_srvy       for ppdm.well_dir_srvy;
create or replace synonym geowiz_survey_appl.well_dir_srvy  for ppdm.well_dir_srvy;
create or replace synonym spatial_appl.well_dir_srvy        for ppdm.well_dir_srvy;

