/*******************************************************************************************
   IHS_US_WELL_DIR_SRVY  (View)

 History
 20160614 cdong     QC1838
                    Change conversion to use hard-coded value of 0.3048 (ft to m), which is faster
                      than using the wim.wim_util.uom_conversion function.
                    Use lpad to set survey_id to three characters, instead of ppdm_admin.tlm_util.prefix_zeros.
                      This would then make the survey_id consistent with code for the DF US dir srvy mv.
                      Data at IHS is '1', '2', '3', '4', '5', '101'.
                    Use case-stmt to resolve EPSG code for geog_coord_system_id, instead of utility
                      function ppdm_admin.tlm_util.prefix_zeros.
                      Data at IHS is 'NAD27' or 'NAD83'.

 *******************************************************************************************/

--drop view PPDM.IHS_US_WELL_DIR_SRVY;


create or replace force view PPDM.IHS_US_WELL_DIR_SRVY
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
as
  select wv.uwi,
         lpad(wds.survey_id, 3, '0')     as survey_id,
         wv.SOURCE,
         wds.active_ind,
         wds.azimuth_north_type,
         wds.base_depth,
         wds.base_depth_ouom,
         wds.compute_method,
         case upper(nvl(wds.coord_system_id, 'foo'))
             when 'NAD83' then '4269'
             when 'NAD27' then '4267'
             when 'FOO'   then NULL
             else '9999'
           end                            as coord_system_id,
         wds.dir_survey_class,
         wds.effective_date,
         wds.ew_direction,
         wds.expiry_date,
         wds.magnetic_declination,
         wds.offset_north_type,
         wds.plane_of_proposal,
         wds.ppdm_guid,
         wds.record_mode,
         wds.remark,
         wds.report_apd,
         wds.report_log_datum,
         wds.report_log_datum_elev,
         wds.report_log_datum_elev_ouom,
         wds.report_perm_datum,
         wds.report_perm_datum_elev,
         wds.report_perm_datum_elev_ouom,
         wds.source_document,
         wds.survey_company,
         wds.survey_date,
         wds.survey_numeric_id,
         wds.survey_quality,
         wds.survey_type,
         wds.top_depth,
         wds.top_depth_ouom,
         wds.row_changed_by,
         wds.row_changed_date,
         wds.row_created_by,
         wds.row_created_date,
         wds.row_quality,
         wds.province_state
    from well_dir_srvy@c_talisman_us_ihsdataq wds, well_version wv
   where     wv.well_num = wds.uwi
         and wv.SOURCE = '450PID'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_us_well_dir_srvy to data_finder;
grant select on ppdm.ihs_us_well_dir_srvy to dir_srvy_ro;
grant select on ppdm.ihs_us_well_dir_srvy to ppdm_ro;
grant select on ppdm.ihs_us_well_dir_srvy to spatial;


--CREATE OR REPLACE SYNONYM SPATIAL.IHS_US_WELL_DIR_SRVY FOR PPDM.IHS_US_WELL_DIR_SRVY;
