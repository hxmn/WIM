/***************************************************************************************************
 ihs_well_completion  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_completion;

create or replace force view ppdm.ihs_well_completion
(
  uwi,
  source,
  completion_obs_no,
  active_ind,
  base_depth,
  base_depth_ouom,
  base_strat_unit_id,
  completion_date,
  completion_method,
  completion_strat_unit_id,
  completion_type,
  effective_date,
  expiry_date,
  ppdm_guid,
  remark,
  strat_name_set_id,
  top_depth,
  top_depth_ouom,
  top_strat_unit_id,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  x_perf_status,
  x_perf_shots,
  province_state,
  top_strat_age,
  base_strat_age
)
as
  select /*+ use_nl(wc wv) */
         wv."UWI",
         wc."SOURCE",
         wc."COMPLETION_OBS_NO",
         wc."ACTIVE_IND",
         wc."BASE_DEPTH",
         wc."BASE_DEPTH_OUOM",
         wc."BASE_STRAT_UNIT_ID",
         wc."COMPLETION_DATE",
         wc."COMPLETION_METHOD",
         wc."COMPLETION_STRAT_UNIT_ID",
         wc."COMPLETION_TYPE",
         wc."EFFECTIVE_DATE",
         wc."EXPIRY_DATE",
         wc."PPDM_GUID",
         wc."REMARK",
         wc."STRAT_NAME_SET_ID",
         wc."TOP_DEPTH",
         wc."TOP_DEPTH_OUOM",
         wc."TOP_STRAT_UNIT_ID",
         wc."ROW_CHANGED_BY",
         wc."ROW_CHANGED_DATE",
         wc."ROW_CREATED_BY",
         wc."ROW_CREATED_DATE",
         wc."ROW_QUALITY",
         wc."X_PERF_STATUS",
         wc."X_PERF_SHOTS",
         wc."PROVINCE_STATE",
         wc."TOP_STRAT_AGE",
         wc."BASE_STRAT_AGE"
    from well_completion@c_talisman_ihsdata wc, well_version wv
   where     wv.ipl_uwi_local = wc.uwi
         and wv.SOURCE = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_completion to ppdm_ro;
