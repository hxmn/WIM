/***************************************************************************************************
 ihs_well_core_sample_desc  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_core_sample_desc;

create or replace force view ppdm.ihs_well_core_sample_desc
(
  uwi,
  source,
  core_id,
  analysis_obs_no,
  sample_num,
  sample_analysis_obs_no,
  sample_desc_obs_no,
  active_ind,
  base_depth,
  base_depth_ouom,
  description,
  dip_angle,
  effective_date,
  expiry_date,
  lithology_desc,
  porosity_length,
  porosity_length_ouom,
  porosity_quality,
  porosity_type,
  ppdm_guid,
  recovered_amount,
  recovered_amount_ouom,
  remark,
  sample_type,
  show_length,
  show_length_ouom,
  show_quality,
  show_type,
  strat_name_set_id,
  strat_unit_id,
  swc_recovery_type,
  top_depth,
  top_depth_ouom,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  province_state,
  strat_unit_age
)
as
  select /*+ use_nl(wcsd wv) */
         wv."UWI",
         wcsd."SOURCE",
         wcsd."CORE_ID",
         wcsd."ANALYSIS_OBS_NO",
         wcsd."SAMPLE_NUM",
         wcsd."SAMPLE_ANALYSIS_OBS_NO",
         wcsd."SAMPLE_DESC_OBS_NO",
         wcsd."ACTIVE_IND",
         wcsd."BASE_DEPTH",
         wcsd."BASE_DEPTH_OUOM",
         wcsd."DESCRIPTION",
         wcsd."DIP_ANGLE",
         wcsd."EFFECTIVE_DATE",
         wcsd."EXPIRY_DATE",
         wcsd."LITHOLOGY_DESC",
         wcsd."POROSITY_LENGTH",
         wcsd."POROSITY_LENGTH_OUOM",
         wcsd."POROSITY_QUALITY",
         wcsd."POROSITY_TYPE",
         wcsd."PPDM_GUID",
         wcsd."RECOVERED_AMOUNT",
         wcsd."RECOVERED_AMOUNT_OUOM",
         wcsd."REMARK",
         wcsd."SAMPLE_TYPE",
         wcsd."SHOW_LENGTH",
         wcsd."SHOW_LENGTH_OUOM",
         wcsd."SHOW_QUALITY",
         wcsd."SHOW_TYPE",
         wcsd."STRAT_NAME_SET_ID",
         wcsd."STRAT_UNIT_ID",
         wcsd."SWC_RECOVERY_TYPE",
         wcsd."TOP_DEPTH",
         wcsd."TOP_DEPTH_OUOM",
         wcsd."ROW_CHANGED_BY",
         wcsd."ROW_CHANGED_DATE",
         wcsd."ROW_CREATED_BY",
         wcsd."ROW_CREATED_DATE",
         wcsd."ROW_QUALITY",
         wcsd."PROVINCE_STATE",
         wcsd."STRAT_UNIT_AGE"
    from well_core_sample_desc@c_talisman_ihsdata wcsd, well_version wv
   where     wv.ipl_uwi_local = wcsd.uwi
         and wv.SOURCE = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_core_sample_desc to ppdm_ro;
