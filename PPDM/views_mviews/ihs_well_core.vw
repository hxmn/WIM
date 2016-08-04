/***************************************************************************************************
 ihs_well_core  (view)

 20140808 remove hint for rule-based optimization, as performance in 11.2.0.4 is very poor with the hint
 20140827 add hint for nested-loop joins

 **************************************************************************************************/

drop view ppdm.ihs_well_core;

create or replace force view ppdm.ihs_well_core
(
  uwi,
  source,
  core_id,
  active_ind,
  analysis_report,
  base_depth,
  base_depth_ouom,
  contractor,
  core_barrel_size,
  core_barrel_size_ouom,
  core_diameter,
  core_diameter_ouom,
  core_handling_type,
  core_oriented_ind,
  core_show_type,
  core_type,
  coring_fluid,
  digit_avail_ind,
  effective_date,
  expiry_date,
  gamma_correlation_ind,
  operation_seq_no,
  ppdm_guid,
  primary_core_strat_unit_id,
  recovered_amount,
  recovered_amount_ouom,
  recovered_amount_uom,
  recovery_date,
  remark,
  reported_core_num,
  run_num,
  shot_recovered_count,
  sidewall_ind,
  strat_name_set_id,
  top_depth,
  top_depth_ouom,
  total_shot_count,
  row_changed_by,
  row_changed_date,
  row_created_by,
  row_created_date,
  row_quality,
  x_top_strat_unit_id,
  x_base_strat_unit_id,
  province_state,
  top_strat_age,
  base_strat_age,
  primary_strat_age
)
as
  select /*+ use_nl(wc wv) */
         wv."UWI",
         wc."SOURCE",
         wc."CORE_ID",
         wc."ACTIVE_IND",
         wc."ANALYSIS_REPORT",
         wc."BASE_DEPTH",
         wc."BASE_DEPTH_OUOM",
         wc."CONTRACTOR",
         wc."CORE_BARREL_SIZE",
         wc."CORE_BARREL_SIZE_OUOM",
         wc."CORE_DIAMETER",
         wc."CORE_DIAMETER_OUOM",
         wc."CORE_HANDLING_TYPE",
         wc."CORE_ORIENTED_IND",
         wc."CORE_SHOW_TYPE",
         wc."CORE_TYPE",
         wc."CORING_FLUID",
         wc."DIGIT_AVAIL_IND",
         wc."EFFECTIVE_DATE",
         wc."EXPIRY_DATE",
         wc."GAMMA_CORRELATION_IND",
         wc."OPERATION_SEQ_NO",
         wc."PPDM_GUID",
         wc."PRIMARY_CORE_STRAT_UNIT_ID",
         wc."RECOVERED_AMOUNT",
         wc."RECOVERED_AMOUNT_OUOM",
         wc."RECOVERED_AMOUNT_UOM",
         wc."RECOVERY_DATE",
         wc."REMARK",
         wc."REPORTED_CORE_NUM",
         wc."RUN_NUM",
         wc."SHOT_RECOVERED_COUNT",
         wc."SIDEWALL_IND",
         wc."STRAT_NAME_SET_ID",
         wc."TOP_DEPTH",
         wc."TOP_DEPTH_OUOM",
         wc."TOTAL_SHOT_COUNT",
         wc."ROW_CHANGED_BY",
         wc."ROW_CHANGED_DATE",
         wc."ROW_CREATED_BY",
         wc."ROW_CREATED_DATE",
         wc."ROW_QUALITY",
         wc."X_TOP_STRAT_UNIT_ID",
         wc."X_BASE_STRAT_UNIT_ID",
         wc."PROVINCE_STATE",
         wc."TOP_STRAT_AGE",
         wc."BASE_STRAT_AGE",
         wc."PRIMARY_STRAT_AGE"
    from well_core@c_talisman_ihsdata wc, well_version wv
   where     wv.ipl_uwi_local = wc.uwi
         and wv.source = '300IPL'
         and wv.active_ind = 'Y'
;


grant select on ppdm.ihs_well_core to ppdm_ro;
